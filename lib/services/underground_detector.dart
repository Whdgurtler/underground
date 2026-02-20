import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/position.dart';

/// Service to detect when the user has gone underground
class UndergroundDetector extends ChangeNotifier {
  bool _isUnderground = false;
  Position? _lastGpsPosition;
  DateTime? _lastGpsTime;
  Timer? _checkTimer;

  // Detection parameters
  static const Duration _gpsLossTimeout = Duration(seconds: 30);
  static const double _lowAccuracyThreshold = 50.0; // meters
  static const int _consecutiveLowAccuracyCount = 3;
  
  int _lowAccuracyCounter = 0;
  List<double> _recentAccuracies = [];

  bool get isUnderground => _isUnderground;
  Position? get lastGpsPosition => _lastGpsPosition;

  UndergroundDetector() {
    _startPeriodicCheck();
  }

  /// Start periodic checking for underground status
  void _startPeriodicCheck() {
    _checkTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkUndergroundStatus();
    });
  }

  /// Update with new GPS data
  void updateGpsData(Position? position, double accuracy) {
    if (position != null && position.source == PositionSource.gps) {
      _lastGpsPosition = position;
      _lastGpsTime = DateTime.now();
      
      // Track accuracy
      _recentAccuracies.add(accuracy);
      if (_recentAccuracies.length > 10) {
        _recentAccuracies.removeAt(0);
      }
      
      // Check if accuracy is poor
      if (accuracy > _lowAccuracyThreshold) {
        _lowAccuracyCounter++;
      } else {
        _lowAccuracyCounter = 0;
      }
      
      _checkUndergroundStatus();
    }
  }

  /// Check if user is underground based on GPS availability and accuracy
  void _checkUndergroundStatus() {
    bool wasUnderground = _isUnderground;
    
    if (_lastGpsTime == null) {
      _isUnderground = false;
      return;
    }
    
    final timeSinceLastGps = DateTime.now().difference(_lastGpsTime!);
    
    // Method 1: GPS signal lost for extended period
    final gpsLost = timeSinceLastGps > _gpsLossTimeout;
    
    // Method 2: Consecutive low accuracy readings
    final poorAccuracy = _lowAccuracyCounter >= _consecutiveLowAccuracyCount;
    
    // Method 3: Average accuracy degradation
    final avgAccuracy = _recentAccuracies.isEmpty 
        ? 0.0 
        : _recentAccuracies.reduce((a, b) => a + b) / _recentAccuracies.length;
    final significantDegradation = avgAccuracy > _lowAccuracyThreshold * 1.5;
    
    // Determine underground status
    _isUnderground = gpsLost || (poorAccuracy && significantDegradation);
    
    // Notify listeners only if status changed
    if (wasUnderground != _isUnderground) {
      debugPrint('Underground status changed: $_isUnderground');
      notifyListeners();
    }
  }

  /// Manually set underground status (for testing or known locations)
  void setUndergroundStatus(bool isUnderground) {
    if (_isUnderground != isUnderground) {
      _isUnderground = isUnderground;
      notifyListeners();
    }
  }

  /// Reset detector
  void reset() {
    _isUnderground = false;
    _lastGpsPosition = null;
    _lastGpsTime = null;
    _lowAccuracyCounter = 0;
    _recentAccuracies.clear();
    notifyListeners();
  }

  /// Get time since last GPS fix
  Duration? getTimeSinceLastGps() {
    if (_lastGpsTime == null) return null;
    return DateTime.now().difference(_lastGpsTime!);
  }

  /// Get average accuracy over recent readings
  double getAverageAccuracy() {
    if (_recentAccuracies.isEmpty) return 0.0;
    return _recentAccuracies.reduce((a, b) => a + b) / _recentAccuracies.length;
  }

  /// Check if user is likely in Toronto's PATH system
  bool isProbablyInPATH(Position? position) {
    if (position == null) return false;
    
    // Toronto downtown core coordinates where PATH exists
    // Rough boundaries: 43.645 to 43.655 latitude, -79.395 to -79.375 longitude
    final isInDowntown = position.latitude >= 43.640 &&
                        position.latitude <= 43.660 &&
                        position.longitude >= -79.400 &&
                        position.longitude <= -79.370;
    
    return isInDowntown && _isUnderground;
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    super.dispose();
  }
}
