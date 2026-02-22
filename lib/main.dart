import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/navigation_screen.dart';
import 'services/location_service.dart';
import 'services/accelerometer_service.dart';
import 'services/underground_detector.dart';
import 'services/path_data_service.dart';
import 'services/map_matching_service.dart';
import 'services/wifi_fingerprint_service.dart';
import 'services/transit_data_service.dart';
import 'services/motion_detector.dart';

// ValueNotifier so any widget can react when an error is captured
final _errorNotifier = ValueNotifier<String?>(null);

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Catch Flutter framework errors (e.g. widget build exceptions)
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    _errorNotifier.value = '${details.exceptionAsString()}\n\n${details.stack}';
  };

  // Catch all other unhandled async / platform-channel errors
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint('UNCAUGHT: $error\n$stack');
    _errorNotifier.value = '$error\n\n$stack';
    return true; // Tell Flutter we handled it (prevents redundant reporting)
  };

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
        ChangeNotifierProvider(create: (_) => TransitDataService()),
        ChangeNotifierProvider(
          create: (ctx) => MapMatchingService(
            ctx.read<PathDataService>(),
            ctx.read<TransitDataService>(),
          ),
        ),
        ChangeNotifierProvider(create: (_) => WifiFingerprintService()),
        ChangeNotifierProvider(
          create: (ctx) => MotionDetector(ctx.read<AccelerometerService>()),
        ),
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
        home: const _AppRoot(),
        debugShowCheckedModeBanner: false,
        // Catch widget-tree build exceptions
        builder: (context, child) {
          ErrorWidget.builder = (FlutterErrorDetails details) {
            _errorNotifier.value =
                '${details.exceptionAsString()}\n\n${details.stack}';
            return _ErrorScreen(
              title: 'Widget Error',
              message: _errorNotifier.value!,
            );
          };
          return child ?? const SizedBox();
        },
      ),
    );
  }
}

/// Root widget — listens to _errorNotifier and swaps to the error screen
/// as soon as any uncaught exception is reported.
class _AppRoot extends StatelessWidget {
  const _AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: _errorNotifier,
      builder: (context, error, _) {
        if (error != null) {
          return _ErrorScreen(title: 'App Error — screenshot this', message: error);
        }
        return const NavigationScreen();
      },
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  final String title;
  final String message;
  const _ErrorScreen({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[900],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              SelectableText(
                message,
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
