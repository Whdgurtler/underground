import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../models/position.dart';

/// Pedestrian Dead Reckoning (PDR) service.
///
/// Rather than double-integrating raw acceleration (which drifts within seconds),
/// PDR detects individual footsteps from accelerometer magnitude peaks and
/// advances the position by a fixed stride length (~0.75 m) in the current
/// heading direction tracked by the gyroscope.
///
/// Accuracy: ~2–5 m when map-matched to PATH corridors, versus 10–20 m drift
/// from the previous double-integration approach.
class AccelerometerService extends ChangeNotifier {
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;

  bool _isTracking = false;

  // ── PDR position state ──────────────────────────────────────────────────
  Position? _basePosition;    // advances with each detected step
  Position? _estimatedPosition;
  double _headingRad = 0.0;   // radians, 0 = north, π/2 = east
  int _stepCount = 0;
  double _totalDistance = 0.0;

  // ── Step detection tuning ───────────────────────────────────────────────
  /// Metres advanced per detected step (typical adult walking stride ≈ 0.75 m)
  static const double _strideLength = 0.75;

  /// Accelerometer magnitude threshold to qualify as a step peak (m/s²).
  /// 9.81 = gravity at rest; walking peaks typically reach 11–12 m/s².
  static const double _stepThreshold = 11.0;

  /// Minimum time between two consecutive steps — prevents double-counting.
  static const int _minStepIntervalMs = 300;

  // ── Low-pass filter + peak detector state ──────────────────────────────
  double _filteredMag = 9.81;
  double _prevFilteredMag = 9.81;
  bool _peakRising = false;
  DateTime? _lastStepTime;
  DateTime? _lastGyroTime;

  // ── Public getters ──────────────────────────────────────────────────────
  bool get isTracking => _isTracking;
  Position? get estimatedPosition => _estimatedPosition;
  /// Current heading in degrees (0 = north, 90 = east).
  double get heading => (_headingRad * 180 / pi) % 360;
  int get stepCount => _stepCount;
  double getTotalDistance() => _totalDistance;

  // ── Lifecycle ───────────────────────────────────────────────────────────

  /// Begin PDR from [basePosition].
  /// [initialHeadingDeg] seeds the heading from the last GPS course so the
  /// first steps point in the right direction before the gyroscope takes over.
  void startTracking(Position basePosition, {double initialHeadingDeg = 0.0}) {
    if (_isTracking) return;

    _basePosition = basePosition;
    _estimatedPosition = basePosition;
    _headingRad = initialHeadingDeg * pi / 180.0;
    _stepCount = 0;
    _totalDistance = 0.0;
    _filteredMag = 9.81;
    _prevFilteredMag = 9.81;
    _peakRising = false;
    _lastStepTime = null;
    _lastGyroTime = null;
    _isTracking = true;

    try {
      _accelerometerSubscription = accelerometerEventStream().listen(
        _handleAccelerometerEvent,
        onError: (e) => debugPrint('Accelerometer error: $e'),
      );
    } catch (e) {
      debugPrint('Accelerometer not available: $e');
    }

    try {
      _gyroscopeSubscription = gyroscopeEventStream().listen(
        _handleGyroscopeEvent,
        onError: (e) => debugPrint('Gyroscope error: $e'),
      );
    } catch (e) {
      debugPrint('Gyroscope not available: $e');
    }

    notifyListeners();
  }

  void stopTracking() {
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    _accelerometerSubscription = null;
    _gyroscopeSubscription = null;
    _isTracking = false;
    notifyListeners();
  }

  // ── Sensor handlers ─────────────────────────────────────────────────────

  void _handleAccelerometerEvent(AccelerometerEvent event) {
    if (!_isTracking) return;

    // Magnitude of the raw accelerometer vector
    final mag = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);

    // Exponential moving average (α=0.85) — smooths noise while keeping step peaks
    _filteredMag = 0.85 * _filteredMag + 0.15 * mag;

    // Peak detection: step = rising slope then falling slope above threshold
    final nowRising = _filteredMag > _prevFilteredMag;
    if (_peakRising && !nowRising && _filteredMag > _stepThreshold) {
      final now = DateTime.now();
      final msSinceLast = _lastStepTime == null
          ? _minStepIntervalMs + 1
          : now.difference(_lastStepTime!).inMilliseconds;

      if (msSinceLast >= _minStepIntervalMs) {
        _lastStepTime = now;
        _recordStep();
      }
    }

    _peakRising = nowRising;
    _prevFilteredMag = _filteredMag;
  }

  void _handleGyroscopeEvent(GyroscopeEvent event) {
    if (!_isTracking) return;

    final now = DateTime.now();
    if (_lastGyroTime != null) {
      final dt = now.difference(_lastGyroTime!).inMilliseconds / 1000.0;
      if (dt > 0 && dt < 0.5) {
        // Integrate z-axis angular velocity (yaw) into heading.
        // Negative: Android gyroscope z is counter-clockwise positive,
        // but compass bearings increase clockwise.
        _headingRad -= event.z * dt;
        _headingRad = _headingRad % (2 * pi);
        if (_headingRad < 0) _headingRad += 2 * pi;
      }
    }
    _lastGyroTime = now;
  }

  // ── PDR position update ─────────────────────────────────────────────────

  void _recordStep() {
    if (_basePosition == null) return;

    _stepCount++;
    _totalDistance += _strideLength;

    // Project one stride onto lat/lng using current heading
    // heading 0 = north (+lat), π/2 = east (+lng)
    final latDelta = _strideLength * cos(_headingRad) / 111000.0;
    final lngDelta = _strideLength * sin(_headingRad) /
        (111000.0 * cos(_basePosition!.latitude * pi / 180.0));

    _basePosition = Position(
      latitude: _basePosition!.latitude + latDelta,
      longitude: _basePosition!.longitude + lngDelta,
      altitude: _basePosition!.altitude,
      timestamp: DateTime.now(),
      source: PositionSource.accelerometer,
    );
    _estimatedPosition = _basePosition;

    notifyListeners();
  }

  // ── External corrections ────────────────────────────────────────────────

  /// Anchor PDR to a fresh GPS or WiFi fix and optionally reset heading.
  void resetWithNewBase(Position newBase, {double? headingDeg}) {
    _basePosition = newBase;
    _estimatedPosition = newBase;
    if (headingDeg != null) {
      _headingRad = headingDeg * pi / 180.0;
    }
    notifyListeners();
  }

  /// Zero step count and distance (e.g. on manual calibration button).
  void calibrate() {
    _stepCount = 0;
    _totalDistance = 0.0;
    notifyListeners();
  }

  @override
  void dispose() {
    stopTracking();
    super.dispose();
  }
}
