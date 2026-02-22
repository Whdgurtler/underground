import 'package:vector_math/vector_math.dart';

/// Represents a position in 3D space
class Position {
  final double latitude;
  final double longitude;
  final double altitude;
  final DateTime timestamp;
  final PositionSource source;

  Position({
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.timestamp,
    required this.source,
  });

  Position copyWith({
    double? latitude,
    double? longitude,
    double? altitude,
    DateTime? timestamp,
    PositionSource? source,
  }) {
    return Position(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      timestamp: timestamp ?? this.timestamp,
      source: source ?? this.source,
    );
  }

  @override
  String toString() {
    return 'Position(lat: $latitude, lng: $longitude, alt: $altitude, source: $source)';
  }
}

enum PositionSource {
  gps,
  accelerometer,
  estimated,
  mapMatched,
  wifi,
}

/// Represents movement data from accelerometer
class MovementData {
  final Vector3 acceleration;
  final Vector3 velocity;
  final Vector3 displacement;
  final DateTime timestamp;

  MovementData({
    required this.acceleration,
    required this.velocity,
    required this.displacement,
    required this.timestamp,
  });

  MovementData copyWith({
    Vector3? acceleration,
    Vector3? velocity,
    Vector3? displacement,
    DateTime? timestamp,
  }) {
    return MovementData(
      acceleration: acceleration ?? this.acceleration,
      velocity: velocity ?? this.velocity,
      displacement: displacement ?? this.displacement,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

/// Navigation state
class NavigationState {
  final Position currentPosition;
  final bool isUnderground;
  final double accuracy;
  final String? currentLocation;

  NavigationState({
    required this.currentPosition,
    required this.isUnderground,
    required this.accuracy,
    this.currentLocation,
  });
}
