import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:vector_math/vector_math.dart' as vmath;
import '../models/position.dart';

/// Service to handle accelerometer-based dead reckoning for underground navigation
class AccelerometerService extends ChangeNotifier {
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  
  bool _isTracking = false;
  vmath.Vector3 _velocity = vmath.Vector3.zero();
  vmath.Vector3 _displacement = vmath.Vector3.zero();
  vmath.Vector3 _previousAcceleration = vmath.Vector3.zero();
  DateTime? _lastUpdateTime;
  
  Position? _basePosition;
  Position? _estimatedPosition;
  double _heading = 0.0; // Direction in degrees
  
  // Calibration values
  final double _gravityThreshold = 0.5; // m/s² - threshold to filter out noise
  final double _driftCompensation = 0.98; // Reduce drift over time
  
  bool get isTracking => _isTracking;
  Position? get estimatedPosition => _estimatedPosition;
  double get heading => _heading;
  vmath.Vector3 get displacement => _displacement;

  /// Start accelerometer tracking with a base GPS position
  void startTracking(Position basePosition) {
    if (_isTracking) return;
    
    _basePosition = basePosition;
    _estimatedPosition = basePosition;
    _isTracking = true;
    _lastUpdateTime = DateTime.now();
    
    // Reset movement data
    _velocity = vmath.Vector3.zero();
    _displacement = vmath.Vector3.zero();
    _previousAcceleration = vmath.Vector3.zero();
    
    // Listen to accelerometer
    try {
      _accelerometerSubscription = accelerometerEventStream().listen(
        _handleAccelerometerEvent,
        onError: (error) {
          debugPrint('Accelerometer error: $error');
        },
      );
    } catch (e) {
      debugPrint('Accelerometer not available: $e');
    }

    // Listen to gyroscope for heading (optional — not all devices have one)
    try {
      _gyroscopeSubscription = gyroscopeEventStream().listen(
        _handleGyroscopeEvent,
        onError: (error) {
          debugPrint('Gyroscope error: $error');
        },
      );
    } catch (e) {
      debugPrint('Gyroscope not available: $e');
    }
    
    notifyListeners();
  }

  /// Stop accelerometer tracking
  void stopTracking() {
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    _isTracking = false;
    notifyListeners();
  }

  /// Handle accelerometer data for dead reckoning
  void _handleAccelerometerEvent(AccelerometerEvent event) {
    if (!_isTracking || _lastUpdateTime == null || _basePosition == null) return;
    
    final now = DateTime.now();
    final dt = now.difference(_lastUpdateTime!).inMilliseconds / 1000.0;
    
    if (dt <= 0 || dt > 1.0) {
      _lastUpdateTime = now;
      return; // Skip invalid time deltas
    }
    
    // Create acceleration vector (remove gravity component)
    vmath.Vector3 acceleration = vmath.Vector3(
      event.x,
      event.y,
      event.z - 9.81, // Remove gravity from z-axis
    );
    
    // Apply noise filtering - only track significant movements
    if (acceleration.length < _gravityThreshold) {
      acceleration = vmath.Vector3.zero();
    }
    
    // Calculate velocity using trapezoidal integration
    final avgAcceleration = (acceleration + _previousAcceleration) * 0.5;
    _velocity += avgAcceleration * dt;
    
    // Apply drift compensation
    _velocity *= _driftCompensation;
    
    // Calculate displacement
    final displacement = _velocity * dt;
    _displacement += displacement;
    
    // Update estimated position
    _updateEstimatedPosition(displacement, dt);
    
    // Store for next iteration
    _previousAcceleration = acceleration;
    _lastUpdateTime = now;
    
    notifyListeners();
  }

  /// Handle gyroscope data for heading estimation
  void _handleGyroscopeEvent(GyroscopeEvent event) {
    if (!_isTracking || _lastUpdateTime == null) return;
    
    final now = DateTime.now();
    final dt = now.difference(_lastUpdateTime!).inMilliseconds / 1000.0;
    
    if (dt <= 0 || dt > 1.0) return;
    
    // Update heading based on z-axis rotation (yaw)
    _heading += event.z * dt * (180 / pi); // Convert to degrees
    _heading = _heading % 360; // Keep in 0-360 range
    
    if (_heading < 0) _heading += 360;
  }

  /// Update estimated position based on displacement
  void _updateEstimatedPosition(vmath.Vector3 displacement, double dt) {
    if (_basePosition == null) return;
    
    // Convert displacement to lat/lng
    // Approximate: 1 degree latitude ≈ 111,000 meters
    // 1 degree longitude ≈ 111,000 * cos(latitude) meters
    
    final latChange = displacement.y / 111000.0;
    final lngChange = displacement.x / (111000.0 * cos(_basePosition!.latitude * pi / 180));
    
    _estimatedPosition = Position(
      latitude: _basePosition!.latitude + latChange,
      longitude: _basePosition!.longitude + lngChange,
      altitude: _basePosition!.altitude + displacement.z,
      timestamp: DateTime.now(),
      source: PositionSource.accelerometer,
    );
  }

  /// Reset tracking with new base position (e.g., when GPS becomes available)
  void resetWithNewBase(Position newBasePosition) {
    _basePosition = newBasePosition;
    _estimatedPosition = newBasePosition;
    _displacement = vmath.Vector3.zero();
    _velocity = vmath.Vector3.zero();
    _lastUpdateTime = DateTime.now();
    notifyListeners();
  }

  /// Get total distance traveled
  double getTotalDistance() {
    return _displacement.length;
  }

  /// Calibrate sensors (reset accumulated errors)
  void calibrate() {
    _velocity = vmath.Vector3.zero();
    _displacement = vmath.Vector3.zero();
    _previousAcceleration = vmath.Vector3.zero();
    notifyListeners();
  }

  @override
  void dispose() {
    stopTracking();
    super.dispose();
  }
}
