import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/path_segment.dart';

/// Downloads and caches Toronto PATH tunnel geometry from OpenStreetMap
class PathDataService extends ChangeNotifier {
  List<PathSegment> _segments = [];
  bool _isLoaded = false;
  bool _isLoading = false;
  String? _error;

  List<PathSegment> get segments => _segments;
  bool get isLoaded => _isLoaded;
  bool get isLoading => _isLoading;
  String? get error => _error;

  static const String _cacheKey = 'path_osm_data_v1';
  static const String _cacheTimeKey = 'path_osm_cache_time_v1';
  static const Duration _cacheExpiry = Duration(days: 7);
  static const String _overpassUrl = 'https://overpass-api.de/api/interpreter';

  // Overpass QL: fetch underground/tunnel ways in Toronto downtown core
  static const String _query = '''
[out:json][timeout:90];
(
  way["highway"]["tunnel"="yes"](43.637,-79.402,43.662,-79.368);
  way["highway"="corridor"](43.637,-79.402,43.662,-79.368);
  way["highway"]["indoor"="yes"](43.637,-79.402,43.662,-79.368);
  way["highway"]["layer"="-1"](43.637,-79.402,43.662,-79.368);
  way["highway"]["level"="-1"](43.637,-79.402,43.662,-79.368);
);
out body;
>;
out skel qt;
''';

  Future<void> loadData() async {
    if (_isLoaded || _isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_cacheKey);
      final cacheTimeMs = prefs.getInt(_cacheTimeKey) ?? 0;
      final cacheAge = DateTime.now().millisecondsSinceEpoch - cacheTimeMs;

      if (cachedJson != null && cacheAge < _cacheExpiry.inMilliseconds) {
        _parseOsmData(json.decode(cachedJson));
        debugPrint('PathDataService: loaded ${_segments.length} segments from cache');
      } else {
        await _fetchFromOverpass(prefs);
        debugPrint('PathDataService: loaded ${_segments.length} segments from Overpass');
      }
    } catch (e) {
      _error = 'Failed to load PATH data: $e';
      debugPrint('PathDataService error: $e');
    } finally {
      _isLoading = false;
      _isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> _fetchFromOverpass(SharedPreferences prefs) async {
    final response = await http.post(
      Uri.parse(_overpassUrl),
      body: {'data': _query},
      headers: {'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 90));

    if (response.statusCode == 200) {
      final body = response.body;
      prefs.setString(_cacheKey, body);
      prefs.setInt(_cacheTimeKey, DateTime.now().millisecondsSinceEpoch);
      _parseOsmData(json.decode(body));
    } else {
      throw Exception('Overpass API returned ${response.statusCode}');
    }
  }

  void _parseOsmData(Map<String, dynamic> data) {
    final elements = data['elements'] as List<dynamic>;

    // Build a node id → LatLng lookup
    final nodes = <int, LatLng>{};
    for (final el in elements) {
      if (el['type'] == 'node') {
        nodes[el['id'] as int] = LatLng(
          (el['lat'] as num).toDouble(),
          (el['lon'] as num).toDouble(),
        );
      }
    }

    // Build segments from ways
    final segments = <PathSegment>[];
    for (final el in elements) {
      if (el['type'] == 'way') {
        final nodeIds = el['nodes'] as List<dynamic>;
        final points = nodeIds
            .map((id) => nodes[id as int])
            .whereType<LatLng>()
            .toList();

        if (points.length >= 2) {
          segments.add(PathSegment(
            id: (el['id'] as int).toString(),
            points: points,
            name: (el['tags'] as Map<String, dynamic>?)?['name'] as String?,
          ));
        }
      }
    }
    _segments = segments;
  }

  /// Force refresh from network (ignores cache)
  Future<void> refresh() async {
    _isLoaded = false;
    _isLoading = false;
    _segments = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    await prefs.remove(_cacheTimeKey);
    await loadData();
  }
}
