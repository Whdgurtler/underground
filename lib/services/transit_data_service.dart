import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/subway_station.dart';
import '../models/path_segment.dart';

/// Downloads and caches TTC subway line geometry and station locations
/// from OpenStreetMap via the Overpass API.
///
/// Data is cached for 7 days in SharedPreferences.
class TransitDataService extends ChangeNotifier {
  List<SubwayStation> _stations = [];
  List<PathSegment> _subwaySegments = [];
  bool _isLoading = false;
  bool _isLoaded = false;
  String? _error;

  List<SubwayStation> get stations => _stations;
  List<PathSegment> get subwaySegments => _subwaySegments;
  bool get isLoading => _isLoading;
  bool get isLoaded => _isLoaded;
  String? get error => _error;

  static const String _cacheKey = 'transit_osm_data_v1';
  static const String _cacheTimeKey = 'transit_osm_cache_time_v1';
  static const Duration _cacheExpiry = Duration(days: 7);
  static const String _overpassUrl = 'https://overpass-api.de/api/interpreter';

  // Bounding box covering the full TTC subway network
  // south, west, north, east
  static const String _bbox = '43.581,-79.640,43.855,-79.116';

  static const String _query = '''
[out:json][timeout:30];
(
  way["railway"="subway"]($_bbox);
  node["railway"="station"]["station"="subway"]($_bbox);
  node["railway"="station"]["network"~"TTC",i]($_bbox);
);
out body;
>;
out skel qt;
''';

  Future<void> loadData() async {
    if (_isLoading || _isLoaded) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheTimeMs = prefs.getInt(_cacheTimeKey) ?? 0;
      final cacheAge = DateTime.now().millisecondsSinceEpoch - cacheTimeMs;
      final cachedJson = prefs.getString(_cacheKey);

      if (cachedJson != null && cacheAge < _cacheExpiry.inMilliseconds) {
        _parseData(json.decode(cachedJson));
        debugPrint(
            'TransitDataService: loaded from cache — '
            '${_stations.length} stations, ${_subwaySegments.length} segments');
      } else {
        final response = await http.post(
          Uri.parse(_overpassUrl),
          body: {'data': _query},
          headers: {'Accept': 'application/json'},
        ).timeout(const Duration(seconds: 35));

        if (response.statusCode == 200) {
          await prefs.setString(_cacheKey, response.body);
          await prefs.setInt(
              _cacheTimeKey, DateTime.now().millisecondsSinceEpoch);
          _parseData(json.decode(response.body));
          debugPrint(
              'TransitDataService: fetched from Overpass — '
              '${_stations.length} stations, ${_subwaySegments.length} segments');
        } else {
          throw Exception('Overpass returned ${response.statusCode}');
        }
      }
    } catch (e) {
      _error = 'Failed to load transit data: $e';
      debugPrint('TransitDataService error: $e');
    } finally {
      _isLoading = false;
      _isLoaded = true;
      notifyListeners();
    }
  }

  void _parseData(Map<String, dynamic> data) {
    final elements = data['elements'] as List<dynamic>;

    // Build node id → LatLng lookup
    final nodeCoords = <int, LatLng>{};
    for (final el in elements) {
      if (el['type'] == 'node' && el.containsKey('lat')) {
        nodeCoords[el['id'] as int] = LatLng(
          (el['lat'] as num).toDouble(),
          (el['lon'] as num).toDouble(),
        );
      }
    }

    // Parse stations
    _stations = [];
    for (final el in elements) {
      if (el['type'] == 'node') {
        final tags = (el['tags'] as Map<String, dynamic>?) ?? {};
        final railway = tags['railway'] as String?;
        if (railway == 'station') {
          final lat = (el['lat'] as num?)?.toDouble();
          final lng = (el['lon'] as num?)?.toDouble();
          if (lat != null && lng != null) {
            _stations.add(SubwayStation(
              id: el['id'].toString(),
              name: tags['name'] as String? ?? 'Unknown Station',
              location: LatLng(lat, lng),
              line: tags['line'] as String?,
            ));
          }
        }
      }
    }

    // Parse subway line ways
    _subwaySegments = [];
    for (final el in elements) {
      if (el['type'] == 'way') {
        final tags = (el['tags'] as Map<String, dynamic>?) ?? {};
        if (tags['railway'] == 'subway') {
          final nodeIds = (el['nodes'] as List<dynamic>).cast<int>();
          final points = nodeIds
              .map((id) => nodeCoords[id])
              .whereType<LatLng>()
              .toList();
          if (points.length >= 2) {
            _subwaySegments.add(PathSegment(
              id: (el['id'] as int).toString(),
              points: points,
              name: tags['name'] as String?,
            ));
          }
        }
      }
    }
  }

  /// Returns the nearest station within [radiusMetres] of [lat]/[lng],
  /// or null if none is close enough.
  SubwayStation? nearestStation(double lat, double lng,
      {double radiusMetres = 500}) {
    if (_stations.isEmpty) return null;

    SubwayStation? best;
    double bestDist = double.infinity;

    for (final s in _stations) {
      final d = _haversine(lat, lng, s.location.latitude, s.location.longitude);
      if (d < bestDist) {
        bestDist = d;
        best = s;
      }
    }
    return (best != null && bestDist <= radiusMetres) ? best : null;
  }

  double _haversine(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371000.0;
    final dLat = (lat2 - lat1) * pi / 180;
    final dLng = (lng2 - lng1) * pi / 180;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLng / 2) *
            sin(dLng / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }
}
