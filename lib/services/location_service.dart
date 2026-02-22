import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:permission_handler/permission_handler.dart';
import '../models/position.dart';

/// Service to handle GPS location tracking
class LocationService extends ChangeNotifier {
  Position? _currentPosition;
  bool _isTracking = false;
  StreamSubscription<geo.Position>? _positionSubscription;
  String? _errorMessage;
  double _accuracy = 0.0;
  double _heading = 0.0;

  Position? get currentPosition => _currentPosition;
  bool get isTracking => _isTracking;
  String? get errorMessage => _errorMessage;
  double get accuracy => _accuracy;
  /// GPS course in degrees (0 = north, 90 = east). Only valid while moving.
  double get heading => _heading;

  /// Initialize and request location permissions
  Future<bool> requestPermissions() async {
    try {
      final status = await Permission.location.request();
      if (status.isGranted) {
        return true;
      } else if (status.isDenied) {
        _errorMessage = 'Location permission denied';
        notifyListeners();
        return false;
      } else if (status.isPermanentlyDenied) {
        _errorMessage = 'Location permission permanently denied. Please enable in settings.';
        notifyListeners();
        await openAppSettings();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error requesting permissions: $e';
      notifyListeners();
    }
    return false;
  }

  /// Check if location services are enabled
  Future<bool> checkLocationServices() async {
    bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _errorMessage = 'Location services are disabled. Please enable them.';
      notifyListeners();
      return false;
    }
    return true;
  }

  /// Start tracking location
  Future<void> startTracking() async {
    if (_isTracking) return;

    final hasPermission = await requestPermissions();
    if (!hasPermission) return;

    final serviceEnabled = await checkLocationServices();
    if (!serviceEnabled) return;

    try {
      _isTracking = true;
      _errorMessage = null;
      notifyListeners();

      // Get initial position
      final initialPosition = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
      );
      _updatePosition(initialPosition);

      // Start listening to position updates
      const locationSettings = geo.LocationSettings(
        accuracy: geo.LocationAccuracy.high,
        distanceFilter: 1, // Update every 1 meter
      );

      _positionSubscription = geo.Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        _updatePosition,
        onError: (error) {
          _errorMessage = 'Location error: $error';
          notifyListeners();
        },
      );
    } catch (e) {
      _errorMessage = 'Error starting location tracking: $e';
      _isTracking = false;
      notifyListeners();
    }
  }

  /// Stop tracking location
  void stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _isTracking = false;
    notifyListeners();
  }

  /// Update current position from GPS data
  void _updatePosition(geo.Position geoPosition) {
    _currentPosition = Position(
      latitude: geoPosition.latitude,
      longitude: geoPosition.longitude,
      altitude: geoPosition.altitude,
      timestamp: DateTime.now(),
      source: PositionSource.gps,
    );
    _accuracy = geoPosition.accuracy;
    // heading is only meaningful when speed > ~0.5 m/s; keep last value otherwise
    if (geoPosition.speed > 0.5) {
      _heading = geoPosition.heading;
    }
    _errorMessage = null;
    notifyListeners();
  }

  /// Get last known position
  Future<Position?> getLastKnownPosition() async {
    try {
      final lastPosition = await geo.Geolocator.getLastKnownPosition();
      if (lastPosition != null) {
        return Position(
          latitude: lastPosition.latitude,
          longitude: lastPosition.longitude,
          altitude: lastPosition.altitude,
          timestamp: DateTime.now(),
          source: PositionSource.gps,
        );
      }
    } catch (e) {
      debugPrint('Error getting last known position: $e');
    }
    return null;
  }

  /// Calculate distance between two positions in meters
  static double calculateDistance(Position pos1, Position pos2) {
    return geo.Geolocator.distanceBetween(
      pos1.latitude,
      pos1.longitude,
      pos2.latitude,
      pos2.longitude,
    );
  }

  @override
  void dispose() {
    stopTracking();
    super.dispose();
  }
}
