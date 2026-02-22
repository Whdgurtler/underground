import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import '../models/position.dart';
import '../models/subway_station.dart';
import 'path_data_service.dart';
import 'transit_data_service.dart';

/// Snaps dead-reckoning positions to the nearest corridor or subway line.
/// Eliminates lateral drift by keeping the user on valid tunnel geometry.
class MapMatchingService extends ChangeNotifier {
  final PathDataService _pathDataService;
  final TransitDataService _transitDataService;

  /// Max distance in metres before refusing to snap to a PATH corridor.
  static const double _maxPathSnapDistance = 30.0;

  /// Max distance in metres before refusing to snap to a subway line.
  static const double _maxSubwaySnapDistance = 200.0;

  MapMatchingService(this._pathDataService, this._transitDataService);

  /// Snap [position] to the nearest PATH corridor segment.
  /// Returns a [PositionSource.mapMatched] position if close enough, else null.
  Position? snapToNearestCorridor(Position position) {
    if (!_pathDataService.isLoaded || _pathDataService.segments.isEmpty) {
      return null;
    }

    double minDistance = double.infinity;
    LatLng? nearest;

    final point = LatLng(position.latitude, position.longitude);

    for (final segment in _pathDataService.segments) {
      for (int i = 0; i < segment.points.length - 1; i++) {
        final candidate = _nearestPointOnSegment(
          point,
          segment.points[i],
          segment.points[i + 1],
        );
        final dist = _haversineMetres(point, candidate);
        if (dist < minDistance) {
          minDistance = dist;
          nearest = candidate;
        }
      }
    }

    if (nearest == null || minDistance > _maxPathSnapDistance) return null;

    return Position(
      latitude: nearest.latitude,
      longitude: nearest.longitude,
      altitude: position.altitude,
      timestamp: position.timestamp,
      source: PositionSource.mapMatched,
    );
  }

  /// Snap [position] to the nearest TTC subway line segment.
  /// Returns a [PositionSource.transit] position if close enough, else null.
  Position? snapToNearestSubwayLine(Position position) {
    if (!_transitDataService.isLoaded ||
        _transitDataService.subwaySegments.isEmpty) {
      return null;
    }

    double minDistance = double.infinity;
    LatLng? nearest;

    final point = LatLng(position.latitude, position.longitude);

    for (final segment in _transitDataService.subwaySegments) {
      for (int i = 0; i < segment.points.length - 1; i++) {
        final candidate = _nearestPointOnSegment(
          point,
          segment.points[i],
          segment.points[i + 1],
        );
        final dist = _haversineMetres(point, candidate);
        if (dist < minDistance) {
          minDistance = dist;
          nearest = candidate;
        }
      }
    }

    if (nearest == null || minDistance > _maxSubwaySnapDistance) return null;

    return Position(
      latitude: nearest.latitude,
      longitude: nearest.longitude,
      altitude: position.altitude,
      timestamp: position.timestamp,
      source: PositionSource.transit,
    );
  }

  /// Nearest station within 500 m of [position], or null.
  SubwayStation? nearestStation(Position position) {
    return _transitDataService.nearestStation(
      position.latitude,
      position.longitude,
    );
  }

  /// Nearest point on line segment [a]→[b] to [p], clamped to the segment.
  LatLng _nearestPointOnSegment(LatLng p, LatLng a, LatLng b) {
    final dx = b.longitude - a.longitude;
    final dy = b.latitude - a.latitude;
    final lenSq = dx * dx + dy * dy;
    if (lenSq == 0) return a;

    final t = (((p.longitude - a.longitude) * dx) +
            ((p.latitude - a.latitude) * dy)) /
        lenSq;
    final tc = t.clamp(0.0, 1.0);

    return LatLng(a.latitude + tc * dy, a.longitude + tc * dx);
  }

  /// Haversine distance between two points in metres.
  double _haversineMetres(LatLng a, LatLng b) {
    const r = 6371000.0;
    final lat1 = a.latitude * pi / 180;
    final lat2 = b.latitude * pi / 180;
    final dLat = (b.latitude - a.latitude) * pi / 180;
    final dLon = (b.longitude - a.longitude) * pi / 180;
    final sinLat = sin(dLat / 2);
    final sinLon = sin(dLon / 2);
    final x = sinLat * sinLat + cos(lat1) * cos(lat2) * sinLon * sinLon;
    return r * 2 * atan2(sqrt(x), sqrt(1 - x));
  }
}
