import 'package:latlong2/latlong.dart';

class SubwayStation {
  final String id;
  final String name;
  final LatLng location;
  final String? line;

  const SubwayStation({
    required this.id,
    required this.name,
    required this.location,
    this.line,
  });
}
