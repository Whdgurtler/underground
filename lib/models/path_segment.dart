import 'package:latlong2/latlong.dart';

/// A single corridor segment in the Toronto PATH network
class PathSegment {
  final String id;
  final List<LatLng> points;
  final String? name;

  PathSegment({
    required this.id,
    required this.points,
    this.name,
  });
}
