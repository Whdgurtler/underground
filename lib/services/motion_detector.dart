import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../models/motion_mode.dart';
import 'accelerometer_service.dart';

/// Classifies the user's motion state (stationary / walking / on-train)
/// by combining:
///   - Accelerometer magnitude variance (train vibrations are ~0.5–2 m²/s⁴)
///   - Step rate derived from [AccelerometerService] step counts
///
/// Classification runs every 2 seconds on a ~5-second rolling window.
class MotionDetector extends ChangeNotifier {
  final AccelerometerService _accelService;

  MotionMode _mode = MotionMode.unknown;
  MotionMode get mode => _mode;

  // ── Accelerometer variance window (~5 s at ~20 Hz → 100 samples) ────────
  final List<double> _magWindow = [];
  static const int _windowSize = 100;

  // ── Step-rate tracking (rolling 5-second window) ─────────────────────────
  int _lastKnownStepCount = 0;
  int _recentSteps = 0;
  DateTime? _stepWindowStart;
  static const Duration _stepWindowDuration = Duration(seconds: 5);

  // ── Classification thresholds ────────────────────────────────────────────
  /// Variance above this → train vibration (when no steps detected)
  static const double _trainVarianceMin = 0.5;

  /// Variance below this → essentially at rest
  static const double _stationaryVarianceMax = 0.08;

  /// Step rate above this (steps/sec) → definitely walking
  static const double _walkingStepRateMin = 0.4;

  /// High variance must be sustained for this long before switching to onTrain.
  /// Prevents a phone shake (< 1 s) from triggering train mode.
  static const Duration _trainDebounce = Duration(seconds: 3);

  /// Tracks when variance first exceeded [_trainVarianceMin] with no steps.
  /// Cleared whenever variance drops or steps are detected.
  DateTime? _highVarianceSince;

  StreamSubscription<AccelerometerEvent>? _accelSub;
  Timer? _classifyTimer;

  MotionDetector(this._accelService) {
    _lastKnownStepCount = _accelService.stepCount;
  }

  /// Start listening to sensors and classifying every 2 seconds.
  void start() {
    try {
      _accelSub = accelerometerEventStream().listen(
        _onAccel,
        onError: (e) => debugPrint('MotionDetector accel error: $e'),
      );
    } catch (e) {
      debugPrint('MotionDetector: accelerometer unavailable: $e');
    }
    _classifyTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _classify(),
    );
  }

  void _onAccel(AccelerometerEvent event) {
    final mag = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
    _magWindow.add(mag);
    if (_magWindow.length > _windowSize) _magWindow.removeAt(0);
  }

  void _classify() {
    if (_magWindow.length < 20) return;

    // Accumulate steps since last classify tick
    final currentSteps = _accelService.stepCount;
    final newSteps = currentSteps - _lastKnownStepCount;
    _lastKnownStepCount = currentSteps;

    if (newSteps > 0) {
      _recentSteps += newSteps;
      _stepWindowStart ??= DateTime.now();
    }

    // Expire step window older than 5 seconds
    if (_stepWindowStart != null &&
        DateTime.now().difference(_stepWindowStart!) > _stepWindowDuration) {
      _recentSteps = 0;
      _stepWindowStart = null;
    }

    final variance = _variance();
    final stepRate = _stepRate();

    // Track how long high variance has been sustained (debounce train detection)
    final trainCandidate = variance >= _trainVarianceMin && stepRate < 0.2;
    if (trainCandidate) {
      _highVarianceSince ??= DateTime.now();
    } else {
      _highVarianceSince = null; // reset if variance dropped or steps detected
    }
    final sustainedLongEnough = _highVarianceSince != null &&
        DateTime.now().difference(_highVarianceSince!) >= _trainDebounce;

    MotionMode newMode;
    if (stepRate >= _walkingStepRateMin) {
      newMode = MotionMode.walking;
    } else if (trainCandidate && sustainedLongEnough) {
      // Only call it a train if vibration has been continuous for 3+ seconds
      newMode = MotionMode.onTrain;
    } else if (variance <= _stationaryVarianceMax) {
      newMode = MotionMode.stationary;
    } else {
      newMode = MotionMode.unknown;
    }

    if (newMode != _mode) {
      _mode = newMode;
      notifyListeners();
    }
  }

  double _variance() {
    if (_magWindow.isEmpty) return 0;
    final mean = _magWindow.reduce((a, b) => a + b) / _magWindow.length;
    return _magWindow.fold(0.0, (s, v) => s + (v - mean) * (v - mean)) /
        _magWindow.length;
  }

  double _stepRate() {
    if (_stepWindowStart == null || _recentSteps == 0) return 0;
    final elapsedSec =
        DateTime.now().difference(_stepWindowStart!).inMilliseconds / 1000.0;
    return elapsedSec < 1 ? 0 : _recentSteps / elapsedSec;
  }

  @override
  void dispose() {
    _accelSub?.cancel();
    _classifyTimer?.cancel();
    super.dispose();
  }
}
