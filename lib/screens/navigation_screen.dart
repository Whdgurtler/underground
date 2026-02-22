import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../services/location_service.dart';
import '../services/accelerometer_service.dart';
import '../services/underground_detector.dart';
import '../services/path_data_service.dart';
import '../services/map_matching_service.dart';
import '../services/wifi_fingerprint_service.dart';
import '../services/transit_data_service.dart';
import '../services/motion_detector.dart';
import '../models/position.dart';
import '../models/motion_mode.dart';
import '../models/subway_station.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  final MapController _mapController = MapController();

  final List<Marker> _markers = [];
  final List<Polyline> _pathHistory = [];
  final List<LatLng> _historyPoints = [];

  Position? _displayPosition;
  SubwayStation? _nearestStation;
  bool _surveyMode = false;
  bool _isSurveying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeServices().catchError((e) {
          debugPrint('NavigationScreen init error: $e');
        });
      }
    });
  }

  Future<void> _initializeServices() async {
    final locationService = context.read<LocationService>();
    final accelerometerService = context.read<AccelerometerService>();
    final undergroundDetector = context.read<UndergroundDetector>();
    final pathDataService = context.read<PathDataService>();
    final wifiService = context.read<WifiFingerprintService>();
    final transitService = context.read<TransitDataService>();
    final motionDetector = context.read<MotionDetector>();

    // Kick off data loads and motion detection in parallel
    pathDataService.loadData();
    transitService.loadData();
    wifiService.initialize();
    motionDetector.start();

    await locationService.startTracking();

    locationService.addListener(() {
      final position = locationService.currentPosition;
      if (position != null) {
        undergroundDetector.updateGpsData(position, locationService.accuracy);

        final isOnTrain = motionDetector.mode == MotionMode.onTrain;

        if (undergroundDetector.isUnderground) {
          if (!accelerometerService.isTracking && !isOnTrain) {
            // Just went underground while walking — start PDR
            accelerometerService.startTracking(
              position,
              initialHeadingDeg: locationService.heading,
            );
          } else if (accelerometerService.isTracking && isOnTrain) {
            // Boarded a train — stop PDR (vibrations cause false steps)
            accelerometerService.stopTracking();
          }
        } else {
          // GPS fix back — re-anchor PDR heading if still walking
          if (accelerometerService.isTracking) {
            accelerometerService.resetWithNewBase(
              position,
              headingDeg: locationService.heading,
            );
          }
        }

        _updateDisplay(position).catchError((e) {
          debugPrint('_updateDisplay error: $e');
        });
      }
    });

    // React immediately when motion mode changes (train/walk transition)
    motionDetector.addListener(() {
      if (!mounted) return;
      final isOnTrain = motionDetector.mode == MotionMode.onTrain;
      if (isOnTrain && accelerometerService.isTracking) {
        accelerometerService.stopTracking();
      } else if (!isOnTrain &&
          !accelerometerService.isTracking &&
          undergroundDetector.isUnderground) {
        final pos = locationService.currentPosition ?? _displayPosition;
        if (pos != null) {
          accelerometerService.startTracking(
            pos,
            initialHeadingDeg: locationService.heading,
          );
        }
      }
      if (mounted) setState(() {});
    });

    accelerometerService.addListener(() {
      if (!mounted) return;
      if (undergroundDetector.isUnderground) {
        final est = accelerometerService.estimatedPosition;
        if (est != null) {
          _updateDisplay(est).catchError((e) {
            debugPrint('_updateDisplay accel error: $e');
          });
        }
      }
    });
  }

  /// Position fusion pipeline:
  ///   raw (GPS / dead-reckoning)
  ///     → WiFi correction (walking, if available)
  ///     → map matching: PATH corridor (walking) or subway line (on-train)
  ///     → display
  Future<void> _updateDisplay(Position raw) async {
    if (!mounted) return;
    final mapMatcher = context.read<MapMatchingService>();
    final wifiService = context.read<WifiFingerprintService>();
    final detector = context.read<UndergroundDetector>();
    final motionDetector = context.read<MotionDetector>();

    Position best = raw;
    SubwayStation? station;

    if (detector.isUnderground) {
      if (motionDetector.mode == MotionMode.onTrain) {
        // On train: snap to nearest subway line geometry
        final snapped = mapMatcher.snapToNearestSubwayLine(best);
        if (snapped != null) best = snapped;
        // Find nearest station for display
        station = mapMatcher.nearestStation(best);
      } else {
        // Walking: WiFi correction then PATH corridor snap
        final wifiPos = await wifiService.estimatePosition();
        if (!mounted) return;
        if (wifiPos != null) best = wifiPos;

        final snapped = mapMatcher.snapToNearestCorridor(best);
        if (snapped != null) best = snapped;
      }
    }

    final latLng = LatLng(best.latitude, best.longitude);
    _historyPoints.add(latLng);

    if (!mounted) return;
    setState(() {
      _displayPosition = best;
      _nearestStation = station;

      _pathHistory.clear();
      if (_historyPoints.length > 1) {
        _pathHistory.add(Polyline(
          points: List.from(_historyPoints),
          color: _sourceColor(best.source),
          strokeWidth: 5,
        ));
      }

      _markers.clear();
      _markers.add(Marker(
        point: latLng,
        width: 40,
        height: 40,
        child: Icon(
          Icons.location_pin,
          color: _sourceColor(best.source),
          size: 40,
        ),
      ));
    });

    try {
      _mapController.move(latLng, 18.0);
    } catch (_) {}
  }

  Color _sourceColor(PositionSource source) {
    switch (source) {
      case PositionSource.gps:
        return Colors.blue;
      case PositionSource.wifi:
        return Colors.purple;
      case PositionSource.mapMatched:
        return Colors.green;
      case PositionSource.transit:
        return Colors.deepPurple;
      case PositionSource.accelerometer:
      case PositionSource.estimated:
        return Colors.orange;
    }
  }

  String _sourceLabel(PositionSource source) {
    switch (source) {
      case PositionSource.gps:
        return 'GPS';
      case PositionSource.wifi:
        return 'WiFi';
      case PositionSource.mapMatched:
        return 'Map Matched';
      case PositionSource.transit:
        return 'Subway Line';
      case PositionSource.accelerometer:
        return 'Dead Reckoning';
      case PositionSource.estimated:
        return 'Estimated';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Underground Toronto Navigator'),
        actions: [
          Consumer<UndergroundDetector>(
            builder: (context, detector, _) {
              if (!detector.isUnderground) return const SizedBox.shrink();
              return IconButton(
                icon: Icon(
                  _surveyMode ? Icons.wifi_tethering : Icons.wifi_tethering_off,
                  color: _surveyMode ? Colors.purple : null,
                ),
                tooltip: _surveyMode ? 'Exit Survey Mode' : 'Enter Survey Mode',
                onPressed: () => setState(() => _surveyMode = !_surveyMode),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetTracking,
            tooltip: 'Reset Tracking',
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildMap(),
          Positioned(top: 0, left: 0, right: 0, child: _buildStatusBar()),
          if (_surveyMode)
            Positioned(
              bottom: 16,
              right: 16,
              child: _buildSurveyButton(),
            ),
        ],
      ),
      // Info panel lives here so FABs automatically float above it
      bottomNavigationBar: _buildInfoPanel(),
      floatingActionButton: _buildFloatingButtons(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildMap() {
    final locationService = context.watch<LocationService>();
    final pathDataService = context.watch<PathDataService>();
    final transitService = context.watch<TransitDataService>();
    final initial = locationService.currentPosition;

    if (initial == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final corridorPolylines = pathDataService.segments
        .map((seg) => Polyline(
              points: seg.points,
              color: Colors.blue.withOpacity(0.35),
              strokeWidth: 3,
            ))
        .toList();

    // Subway lines in deep purple
    final subwayPolylines = transitService.subwaySegments
        .map((seg) => Polyline(
              points: seg.points,
              color: Colors.deepPurple.withOpacity(0.5),
              strokeWidth: 4,
            ))
        .toList();

    // Station dots
    final stationMarkers = transitService.stations
        .map((s) => Marker(
              point: s.location,
              width: 10,
              height: 10,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.deepPurple,
                  shape: BoxShape.circle,
                ),
              ),
            ))
        .toList();

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: LatLng(initial.latitude, initial.longitude),
        initialZoom: 18.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.underground.toronto',
        ),
        PolylineLayer(polylines: corridorPolylines),
        PolylineLayer(polylines: subwayPolylines),
        MarkerLayer(markers: stationMarkers),
        PolylineLayer(polylines: _pathHistory),
        MarkerLayer(markers: _markers),
      ],
    );
  }

  Widget _buildStatusBar() {
    return Consumer3<UndergroundDetector, PathDataService, MotionDetector>(
      builder: (context, detector, pathData, motionDetector, _) {
        final String statusText;
        final Color statusColor;
        final IconData statusIcon;

        if (motionDetector.mode == MotionMode.onTrain) {
          final stationName = _nearestStation?.name;
          statusText = stationName != null
              ? 'ON TRAIN — near $stationName'
              : 'ON TRAIN — TTC Subway';
          statusColor = Colors.deepPurple;
          statusIcon = Icons.train;
        } else if (detector.isUnderground) {
          statusText = 'UNDERGROUND — '
              '${_displayPosition != null ? _sourceLabel(_displayPosition!.source) : "Locating..."}';
          statusColor = Colors.orange;
          statusIcon = Icons.location_off;
        } else {
          statusText = 'GPS ACTIVE';
          statusColor = Colors.green;
          statusIcon = Icons.location_on;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.92),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.2), blurRadius: 8)
            ],
          ),
          child: Row(
            children: [
              Icon(statusIcon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  statusText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              if (pathData.isLoading)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              else if (pathData.isLoaded && pathData.segments.isNotEmpty)
                Tooltip(
                  message: '${pathData.segments.length} PATH corridors loaded',
                  child: const Icon(Icons.map, color: Colors.white, size: 16),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoPanel() {
    return Consumer3<LocationService, AccelerometerService, UndergroundDetector>(
      builder: (context, locationService, accelService, detector, _) {
        final pos = _displayPosition;

        return Consumer2<WifiFingerprintService, MotionDetector>(
          builder: (context, wifiService, motionDetector, _) {
            final isOnTrain = motionDetector.mode == MotionMode.onTrain;

            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.2), blurRadius: 8)
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow(
                    'Mode',
                    _modeLabel(motionDetector.mode),
                    _modeColor(motionDetector.mode),
                  ),
                  _infoRow(
                    'Position Source',
                    pos != null ? _sourceLabel(pos.source) : 'Unknown',
                    pos != null ? _sourceColor(pos.source) : Colors.grey,
                  ),
                  const Divider(height: 12),
                  _infoRow('Latitude',
                      pos?.latitude.toStringAsFixed(6) ?? 'N/A', Colors.blue),
                  _infoRow('Longitude',
                      pos?.longitude.toStringAsFixed(6) ?? 'N/A', Colors.blue),
                  _infoRow(
                    'Altitude',
                    pos != null
                        ? '${pos.altitude.toStringAsFixed(1)} m'
                        : 'N/A',
                    Colors.blue,
                  ),
                  const Divider(height: 12),
                  _infoRow(
                    'GPS Accuracy',
                    '${locationService.accuracy.toStringAsFixed(1)} m',
                    locationService.accuracy < 20 ? Colors.green : Colors.red,
                  ),
                  if (isOnTrain) ...[
                    if (_nearestStation != null)
                      _infoRow(
                        'Nearest Station',
                        _nearestStation!.name,
                        Colors.deepPurple,
                      ),
                  ] else if (detector.isUnderground) ...[
                    _infoRow(
                      'Steps',
                      '${accelService.stepCount}  '
                          '(${accelService.getTotalDistance().toStringAsFixed(0)} m)',
                      Colors.orange,
                    ),
                    _infoRow(
                      'Heading',
                      '${accelService.heading.toStringAsFixed(0)}°',
                      Colors.orange,
                    ),
                    _infoRow(
                      'WiFi Fingerprints',
                      '${wifiService.fingerprintCount} recorded',
                      wifiService.fingerprintCount > 10
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _modeLabel(MotionMode mode) {
    switch (mode) {
      case MotionMode.unknown:
        return 'Unknown';
      case MotionMode.stationary:
        return 'Stationary';
      case MotionMode.walking:
        return 'Walking';
      case MotionMode.onTrain:
        return 'On Train';
    }
  }

  Color _modeColor(MotionMode mode) {
    switch (mode) {
      case MotionMode.unknown:
        return Colors.grey;
      case MotionMode.stationary:
        return Colors.blue;
      case MotionMode.walking:
        return Colors.green;
      case MotionMode.onTrain:
        return Colors.deepPurple;
    }
  }

  Widget _infoRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w500, fontSize: 13)),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildSurveyButton() {
    return FloatingActionButton.extended(
      heroTag: 'survey',
      backgroundColor: _isSurveying ? Colors.grey : Colors.purple,
      onPressed: _isSurveying ? null : _recordFingerprint,
      icon: _isSurveying
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
            )
          : const Icon(Icons.wifi_find),
      label: Text(_isSurveying ? 'Recording...' : 'Record WiFi Here'),
    );
  }

  Widget _buildFloatingButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: 'center',
          onPressed: _centerOnCurrentLocation,
          tooltip: 'Center on Location',
          child: const Icon(Icons.my_location),
        ),
        const SizedBox(height: 12),
        FloatingActionButton(
          heroTag: 'calibrate',
          onPressed: _calibrateAccelerometer,
          tooltip: 'Calibrate Sensors',
          child: const Icon(Icons.center_focus_strong),
        ),
      ],
    );
  }

  Future<void> _recordFingerprint() async {
    final pos = _displayPosition;
    if (pos == null) {
      _showSnack('No position available to record fingerprint');
      return;
    }

    setState(() => _isSurveying = true);

    final wifiService = context.read<WifiFingerprintService>();
    final success = await wifiService.recordFingerprint(pos);

    setState(() => _isSurveying = false);

    _showSnack(success
        ? 'Fingerprint recorded (${wifiService.fingerprintCount} total) — '
            'using ${_sourceLabel(pos.source)} position'
        : 'WiFi scan failed — try again');
  }

  void _centerOnCurrentLocation() {
    final pos = _displayPosition;
    if (pos != null) {
      try {
        _mapController.move(LatLng(pos.latitude, pos.longitude), 18.0);
      } catch (_) {}
    }
  }

  void _calibrateAccelerometer() {
    context.read<AccelerometerService>().calibrate();
    _showSnack('Sensors calibrated');
  }

  void _resetTracking() {
    setState(() {
      _historyPoints.clear();
      _pathHistory.clear();
      _markers.clear();
      _displayPosition = null;
      _nearestStation = null;
    });

    final locationService = context.read<LocationService>();
    final accelService = context.read<AccelerometerService>();
    final detector = context.read<UndergroundDetector>();

    detector.reset();
    if (accelService.isTracking) accelService.stopTracking();
    if (locationService.isTracking) {
      locationService.stopTracking();
      locationService.startTracking();
    }

    _showSnack('Tracking reset');
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
