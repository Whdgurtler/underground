import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/navigation_screen.dart';
import 'services/location_service.dart';
import 'services/accelerometer_service.dart';
import 'services/underground_detector.dart';
import 'services/path_data_service.dart';
import 'services/map_matching_service.dart';
import 'services/wifi_fingerprint_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const UndergroundTorontoApp());
}

class UndergroundTorontoApp extends StatelessWidget {
  const UndergroundTorontoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationService()),
        ChangeNotifierProvider(create: (_) => AccelerometerService()),
        ChangeNotifierProvider(create: (_) => UndergroundDetector()),
        ChangeNotifierProvider(create: (_) => PathDataService()),
        ChangeNotifierProvider(
          create: (ctx) => MapMatchingService(ctx.read<PathDataService>()),
        ),
        ChangeNotifierProvider(create: (_) => WifiFingerprintService()),
      ],
      child: MaterialApp(
        title: 'Underground Toronto Navigator',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
        ),
        home: const NavigationScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
