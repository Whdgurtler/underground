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
  static const int _minCommonBssids = 2;
  static const double _maxUncertaintyMetres = 25.0;

  final List<FingerprintRecord> _db = [];
  bool _isAvailable = false;
  bool _isInitialized = false;

  int get fingerprintCount => _db.length;
  bool get isAvailable => _isAvailable;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    await _loadDb();

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

  Future<bool> recordFingerprint(Position knownPosition) async {
    if (!_isAvailable) return false;

    try {
      final canStart = await WiFiScan.instance.canStartScan(
        askPermissions: true,
      );
      if (canStart == CanStartScan.yes) {
        await WiFiScan.instance.startScan();
        await Future.delayed(const Duration(milliseconds: 500));
      }

      final results = await WiFiScan.instance.getScannedResults();
      if (results.isEmpty) return false;

      final readings = <String, int>{
        for (final ap in results)
          if (ap.bssid.isNotEmpty) ap.bssid: ap.level,
      };

      _db.add(FingerprintRecord(
        latitude: knownPosition.latitude,
        longitude: knownPosition.longitude,
        altitude: knownPosition.altitude,
        timestamp: DateTime.now(),
        readings: readings,
      ));

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

  Position? _knnEstimate(Map<String, int> currentScan) {
    final scored = <_ScoredRecord>[];

    for (final record in _db) {
      final common = record.readings.keys
          .where((bssid) => currentScan.containsKey(bssid))
          .toList();

      if (common.length < _minCommonBssids) continue;

      double sumSq = 0;
      for (final bssid in common) {
        final diff = (currentScan[bssid]! - record.readings[bssid]!).toDouble();
        sumSq += diff * diff;
      }
      scored.add(_ScoredRecord(record: record, distance: sqrt(sumSq / common.length)));
    }

    if (scored.isEmpty) return null;

    scored.sort((a, b) => a.distance.compareTo(b.distance));
    final neighbours = scored.take(_kNeighbours).toList();

    double totalWeight = 0, lat = 0, lng = 0, alt = 0;
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

    double maxSpread = 0;
    for (final n in neighbours) {
      final dLat = (n.record.latitude - lat) * 111000;
      final dLng = (n.record.longitude - lng) * 111000;
      final spread = sqrt(dLat * dLat + dLng * dLng);
      if (spread > maxSpread) maxSpread = spread;
    }

    if (maxSpread > _maxUncertaintyMetres) return null;

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
    await prefs.setString(_dbKey, json.encode(_db.map((r) => r.toJson()).toList()));
  }

  Future<void> _loadDb() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_dbKey);
    if (raw == null) return;
    try {
      final list = json.decode(raw) as List<dynamic>;
      _db.clear();
      _db.addAll(list.map((j) => FingerprintRecord.fromJson(j as Map<String, dynamic>)));
      debugPrint('WifiFingerprintService: loaded ${_db.length} fingerprints');
    } catch (e) {
      debugPrint('WifiFingerprintService: failed to load db – $e');
    }
  }

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
