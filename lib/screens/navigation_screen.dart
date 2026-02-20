import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../services/location_service.dart';
import '../services/accelerometer_service.dart';
import '../services/underground_detector.dart';
import '../models/position.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  final MapController _mapController = MapController();
  bool _isInitialized = false;
  final List<Marker> _markers = [];
  final List<Polyline> _pathLines = [];
  final List<LatLng> _pathHistory = [];

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    final locationService = context.read<LocationService>();
    final accelerometerService = context.read<AccelerometerService>();
    final undergroundDetector = context.read<UndergroundDetector>();

    // Start GPS tracking
    await locationService.startTracking();

    // Listen to location changes
    locationService.addListener(() {
      final position = locationService.currentPosition;
      if (position != null) {
        _updateMap(position);
        undergroundDetector.updateGpsData(position, locationService.accuracy);

        // If underground, start accelerometer tracking
        if (undergroundDetector.isUnderground && !accelerometerService.isTracking) {
          accelerometerService.startTracking(position);
        }
        // If not underground and accelerometer is tracking, reset it
        else if (!undergroundDetector.isUnderground && accelerometerService.isTracking) {
          accelerometerService.resetWithNewBase(position);
        }
      }
    });

    // Listen to accelerometer estimates when underground
    accelerometerService.addListener(() {
      final detector = context.read<UndergroundDetector>();
      if (detector.isUnderground) {
        final estimatedPos = accelerometerService.estimatedPosition;
        if (estimatedPos != null) {
          _updateMap(estimatedPos);
        }
      }
    });

    setState(() {
      _isInitialized = true;
    });
  }

  void _updateMap(Position position) {
    setState(() {
      final latLng = LatLng(position.latitude, position.longitude);
      _pathHistory.add(latLng);

      // Update path line
      _pathLines.clear();
      if (_pathHistory.length > 1) {
        _pathLines.add(
          Polyline(
            points: List.from(_pathHistory),
            color: position.source == PositionSource.gps
                ? Colors.blue
                : Colors.orange,
            strokeWidth: 5,
          ),
        );
      }

      // Update marker
      _markers.clear();
      _markers.add(
        Marker(
          point: latLng,
          width: 40,
          height: 40,
          child: Icon(
            Icons.location_pin,
            color: position.source == PositionSource.gps
                ? Colors.blue
                : Colors.orange,
            size: 40,
          ),
        ),
      );
    });

    // Move camera to new position
    _mapController.move(
      LatLng(position.latitude, position.longitude),
      18.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Underground Toronto Navigator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetTracking,
            tooltip: 'Reset Tracking',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map
          _buildMap(),

          // Status overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildStatusBar(),
          ),

          // Info panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildInfoPanel(),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingButtons(),
    );
  }

  Widget _buildMap() {
    final locationService = context.watch<LocationService>();
    final initialPosition = locationService.currentPosition;

    if (initialPosition == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: LatLng(initialPosition.latitude, initialPosition.longitude),
        initialZoom: 18.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.underground.toronto',
        ),
        PolylineLayer(polylines: _pathLines),
        MarkerLayer(markers: _markers),
      ],
    );
  }

  Widget _buildStatusBar() {
    return Consumer<UndergroundDetector>(
      builder: (context, detector, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: detector.isUnderground
                ? Colors.orange.withOpacity(0.9)
                : Colors.green.withOpacity(0.9),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                detector.isUnderground ? Icons.location_off : Icons.location_on,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  detector.isUnderground
                      ? 'UNDERGROUND MODE - Using Accelerometer'
                      : 'GPS ACTIVE',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoPanel() {
    return Consumer3<LocationService, AccelerometerService, UndergroundDetector>(
      builder: (context, locationService, accelService, detector, child) {
        final position = detector.isUnderground
            ? accelService.estimatedPosition
            : locationService.currentPosition;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(
                'Position Source',
                position?.source.name.toUpperCase() ?? 'Unknown',
                position?.source == PositionSource.gps ? Colors.green : Colors.orange,
              ),
              const Divider(),
              _buildInfoRow(
                'Latitude',
                position?.latitude.toStringAsFixed(6) ?? 'N/A',
                Colors.blue,
              ),
              _buildInfoRow(
                'Longitude',
                position?.longitude.toStringAsFixed(6) ?? 'N/A',
                Colors.blue,
              ),
              _buildInfoRow(
                'Altitude',
                position != null ? '${position.altitude.toStringAsFixed(1)} m' : 'N/A',
                Colors.blue,
              ),
              const Divider(),
              _buildInfoRow(
                'GPS Accuracy',
                '${locationService.accuracy.toStringAsFixed(1)} m',
                locationService.accuracy < 20 ? Colors.green : Colors.red,
              ),
              if (detector.isUnderground) ...[
                _buildInfoRow(
                  'Distance Traveled',
                  '${accelService.getTotalDistance().toStringAsFixed(2)} m',
                  Colors.orange,
                ),
                _buildInfoRow(
                  'Heading',
                  '${accelService.heading.toStringAsFixed(1)}°',
                  Colors.orange,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
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

  void _centerOnCurrentLocation() {
    final locationService = context.read<LocationService>();
    final accelService = context.read<AccelerometerService>();
    final detector = context.read<UndergroundDetector>();

    final position = detector.isUnderground
        ? accelService.estimatedPosition
        : locationService.currentPosition;

    if (position != null) {
      _mapController.move(
        LatLng(position.latitude, position.longitude),
        18.0,
      );
    }
  }

  void _calibrateAccelerometer() {
    final accelService = context.read<AccelerometerService>();
    accelService.calibrate();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sensors calibrated'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _resetTracking() {
    setState(() {
      _pathHistory.clear();
      _pathLines.clear();
      _markers.clear();
    });

    final locationService = context.read<LocationService>();
    final accelService = context.read<AccelerometerService>();
    final detector = context.read<UndergroundDetector>();

    detector.reset();
    if (accelService.isTracking) {
      accelService.stopTracking();
    }
    if (locationService.isTracking) {
      locationService.stopTracking();
      locationService.startTracking();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tracking reset'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
