import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi_scan/wifi_scan.dart';
import '../models/position.dart';

/// A single recorded WiFi fingerprint at a known location.
class FingerprintRecord {
  final double latitude;
  final double longitude;
  final double altitude;
  final DateTime timestamp;

  /// BSSID → RSSI (dBm)
  final Map<String, int> readings;

  FingerprintRecord({
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.timestamp,
    required this.readings,
  });

  Map<String, dynamic> toJson() => {
        'lat': latitude,
        'lng': longitude,
        'alt': altitude,
        'ts': timestamp.toIso8601String(),
        'readings': readings,
      };

  factory FingerprintRecord.fromJson(Map<String, dynamic> j) =>
      FingerprintRecord(
        latitude: (j['lat'] as num).toDouble(),
        longitude: (j['lng'] as num).toDouble(),
        altitude: (j['alt'] as num).toDouble(),
        timestamp: DateTime.parse(j['ts'] as String),
        readings: Map<String, int>.from(j['readings'] as Map),
      );
}

/// WiFi fingerprinting service.
///
/// Survey mode  – tap "Record" while standing at a known spot.
///               Uses whatever best position the app currently has
///               (GPS aboveground, map-matched/dead-reckoning underground).
///
/// Estimate mode – scans visible APs and runs K-nearest-neighbour
///                against the fingerprint database to return a Position.
class WifiFingerprintService extends ChangeNotifier {
  static const String _dbKey = 'wifi_fingerprint_db_v1';
  static const int _kNeighbours = 3;

  /// Minimum number of common BSSIDs needed to consider a fingerprint match.
  static const int _minCommonBssids = 2;

  /// Confidence threshold: if estimated position uncertainty exceeds this (m),
  /// we do not emit a WiFi-based position.
  static const double _maxUncertaintyMetres = 25.0;

  final List<FingerprintRecord> _db = [];
  bool _isAvailable = false;
  bool _isInitialized = false;

  int get fingerprintCount => _db.length;
  bool get isAvailable => _isAvailable;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Load persisted database
    await _loadDb();

    // Check if WiFi scanning is supported on this device
    try {
      final canScan = await WiFiScan.instance.canGetScannedResults(
        askPermissions: true,
      );
      _isAvailable = canScan == CanGetScannedResults.yes;
    } catch (e) {
      _isAvailable = false;
      debugPrint('WifiFingerprintService: WiFi scan not available – $e');
    }

    _isInitialized = true;
    notifyListeners();
  }

  // ──────────────────────────────────────────────────────────────
  // Survey mode
  // ──────────────────────────────────────────────────────────────

  /// Record the current WiFi environment at [knownPosition].
  ///
  /// Pass the best available position (GPS, map-matched, dead-reckoning —
  /// whatever the app currently has). The more fingerprints you record as
  /// you walk the PATH, the more accurate future estimates become.
  Future<bool> recordFingerprint(Position knownPosition) async {
    if (!_isAvailable) return false;

    try {
      // Trigger a fresh scan
      final canStart = await WiFiScan.instance.canStartScan(
        askPermissions: true,
      );
      if (canStart == CanStartScan.yes) {
        await WiFiScan.instance.startScan();
        // Brief wait for scan to complete
        await Future.delayed(const Duration(milliseconds: 500));
      }

      final results = await WiFiScan.instance.getScannedResults();
      if (results.isEmpty) return false;

      final readings = <String, int>{
        for (final ap in results)
          if (ap.bssid.isNotEmpty) ap.bssid: ap.level,
      };

      final record = FingerprintRecord(
        latitude: knownPosition.latitude,
        longitude: knownPosition.longitude,
        altitude: knownPosition.altitude,
        timestamp: DateTime.now(),
        readings: readings,
      );

      _db.add(record);
      await _saveDb();
      debugPrint(
          'WifiFingerprintService: recorded fingerprint at '
          '(${knownPosition.latitude.toStringAsFixed(5)}, '
          '${knownPosition.longitude.toStringAsFixed(5)}) '
          'with ${readings.length} APs');
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('WifiFingerprintService recordFingerprint error: $e');
      return false;
    }
  }

  // ──────────────────────────────────────────────────────────────
  // Estimate mode
  // ──────────────────────────────────────────────────────────────

  /// Scan current WiFi environment and return a position estimate.
  /// Returns null if the database is too small or confidence is too low.
  Future<Position?> estimatePosition() async {
    if (!_isAvailable || _db.isEmpty) return null;

    try {
      final results = await WiFiScan.instance.getScannedResults();
      if (results.isEmpty) return null;

      final currentScan = <String, int>{
        for (final ap in results)
          if (ap.bssid.isNotEmpty) ap.bssid: ap.level,
      };

      return _knnEstimate(currentScan);
    } catch (e) {
      debugPrint('WifiFingerprintService estimatePosition error: $e');
      return null;
    }
  }

  /// K-nearest-neighbour position estimation.
  /// Uses Euclidean distance in RSSI space over common BSSIDs.
  Position? _knnEstimate(Map<String, int> currentScan) {
    final scored = <_ScoredRecord>[];

    for (final record in _db) {
      final common = record.readings.keys
          .where((bssid) => currentScan.containsKey(bssid))
          .toList();

      if (common.length < _minCommonBssids) continue;

      // Euclidean RSSI distance over common BSSIDs
      double sumSq = 0;
      for (final bssid in common) {
        final diff = (currentScan[bssid]! - record.readings[bssid]!).toDouble();
        sumSq += diff * diff;
      }
      final dist = sqrt(sumSq / common.length);
      scored.add(_ScoredRecord(record: record, distance: dist));
    }

    if (scored.isEmpty) return null;

    // Take k nearest neighbours
    scored.sort((a, b) => a.distance.compareTo(b.distance));
    final neighbours = scored.take(_kNeighbours).toList();

    // Weighted average (weight = 1 / distance, guard against zero distance)
    double totalWeight = 0;
    double lat = 0;
    double lng = 0;
    double alt = 0;

    for (final n in neighbours) {
      final w = 1.0 / (n.distance + 0.001);
      totalWeight += w;
      lat += n.record.latitude * w;
      lng += n.record.longitude * w;
      alt += n.record.altitude * w;
    }

    lat /= totalWeight;
    lng /= totalWeight;
    alt /= totalWeight;

    // Rough uncertainty: spread of the k neighbours
    double maxSpread = 0;
    for (final n in neighbours) {
      final dLat = (n.record.latitude - lat) * 111000;
      final dLng = (n.record.longitude - lng) * 111000;
      final spread = sqrt(dLat * dLat + dLng * dLng);
      if (spread > maxSpread) maxSpread = spread;
    }

    if (maxSpread > _maxUncertaintyMetres) {
      debugPrint(
          'WifiFingerprintService: estimate uncertainty ${maxSpread.toStringAsFixed(1)} m too high');
      return null;
    }

    debugPrint(
        'WifiFingerprintService: estimated position with '
        '${neighbours.length} neighbours, '
        'uncertainty ${maxSpread.toStringAsFixed(1)} m');

    return Position(
      latitude: lat,
      longitude: lng,
      altitude: alt,
      timestamp: DateTime.now(),
      source: PositionSource.wifi,
    );
  }

  // ──────────────────────────────────────────────────────────────
  // Persistence
  // ──────────────────────────────────────────────────────────────

  Future<void> _saveDb() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(_db.map((r) => r.toJson()).toList());
    await prefs.setString(_dbKey, encoded);
  }

  Future<void> _loadDb() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_dbKey);
    if (raw == null) return;

    try {
      final list = json.decode(raw) as List<dynamic>;
      _db.clear();
      _db.addAll(list.map(
        (j) => FingerprintRecord.fromJson(j as Map<String, dynamic>),
      ));
      debugPrint('WifiFingerprintService: loaded ${_db.length} fingerprints');
    } catch (e) {
      debugPrint('WifiFingerprintService: failed to load db – $e');
    }
  }

  /// Clear all recorded fingerprints.
  Future<void> clearDatabase() async {
    _db.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_dbKey);
    notifyListeners();
  }
}

class _ScoredRecord {
  final FingerprintRecord record;
  final double distance;
  _ScoredRecord({required this.record, required this.distance});
}
