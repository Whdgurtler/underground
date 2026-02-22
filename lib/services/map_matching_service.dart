import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import '../models/position.dart';
import 'path_data_service.dart';

/// Snaps dead-reckoning positions to the nearest PATH corridor segment.
/// Eliminates lateral drift by keeping the user on valid tunnel geometry.
class MapMatchingService extends ChangeNotifier {
  final PathDataService _pathDataService;

  /// Max distance in metres before we refuse to snap (user is aboveground or off-network)
  static const double _maxSnapDistance = 30.0;

  MapMatchingService(this._pathDataService);

  /// Try to snap [position] to the nearest PATH corridor.
  /// Returns a [PositionSource.mapMatched] position if close enough,
  /// or null if the user is too far from any corridor.
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

    if (nearest == null || minDistance > _maxSnapDistance) return null;

    return Position(
      latitude: nearest.latitude,
      longitude: nearest.longitude,
      altitude: position.altitude,
      timestamp: position.timestamp,
      source: PositionSource.mapMatched,
    );
  }

  /// Nearest point on line segment [a]→[b] to [p], clamped to segment.
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
