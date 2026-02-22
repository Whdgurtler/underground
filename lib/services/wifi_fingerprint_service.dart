import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
/// NOTE: wifi_scan plugin removed for stability. This service stores and
/// estimates positions from pre-recorded fingerprints only.
/// Active scanning requires re-adding wifi_scan once the app is stable.
class WifiFingerprintService extends ChangeNotifier {
  static const String _dbKey = 'wifi_fingerprint_db_v1';
  static const int _kNeighbours = 3;
  static const int _minCommonBssids = 2;
  static const double _maxUncertaintyMetres = 25.0;

  final List<FingerprintRecord> _db = [];
  bool _isInitialized = false;

  int get fingerprintCount => _db.length;

  /// WiFi scanning disabled — always false until wifi_scan is re-added.
  bool get isAvailable => false;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;
    await _loadDb();
    _isInitialized = true;
    notifyListeners();
  }

  // ──────────────────────────────────────────────────────────────
  // Survey mode (disabled — returns false without scanning)
  // ──────────────────────────────────────────────────────────────

  Future<bool> recordFingerprint(Position knownPosition) async {
    debugPrint('WifiFingerprintService: active scanning disabled');
    return false;
  }

  // ──────────────────────────────────────────────────────────────
  // Estimate mode
  // ──────────────────────────────────────────────────────────────

  Future<Position?> estimatePosition() async {
    // No live scan available; return null
    return null;
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

  Future<void> clearDatabase() async {
    _db.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_dbKey);
    notifyListeners();
  }

  // ──────────────────────────────────────────────────────────────
  // KNN helper (kept for future use when scanning is re-enabled)
  // ──────────────────────────────────────────────────────────────

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
      final dist = sqrt(sumSq / common.length);
      scored.add(_ScoredRecord(record: record, distance: dist));
    }

    if (scored.isEmpty) return null;

    scored.sort((a, b) => a.distance.compareTo(b.distance));
    final neighbours = scored.take(_kNeighbours).toList();

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
}

class _ScoredRecord {
  final FingerprintRecord record;
  final double distance;
  _ScoredRecord({required this.record, required this.distance});
}
