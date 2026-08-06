import 'package:flutter/material.dart';
import '../utils/logger.dart';

class GlobalErrorBoundary extends StatefulWidget {
  final Widget child;

  const GlobalErrorBoundary({super.key, required this.child});

  @override
  State<GlobalErrorBoundary> createState() => _GlobalErrorBoundaryState();
}

class _GlobalErrorBoundaryState extends State<GlobalErrorBoundary> {
  Object? _error;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Text('Critical Error: $_error'),
        ),
      );
    }
    return widget.child;
  }
}

/// A simpler version using Flutter's ErrorWidget.builder
class AppErrorDisplay extends StatelessWidget {
  final Widget child;

  const AppErrorDisplay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails details) {
      Log.e('UI Error Caught', error: details.exception, stackTrace: details.stack, name: 'UI');
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off_rounded, color: Colors.blueGrey, size: 80),
                const SizedBox(height: 24),
                const Text(
                  'Connection or Rendering Issue',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                const SizedBox(height: 12),
                const Text(
                  'We encountered a problem while communicating with the server or rendering this screen.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 32),
                Text(
                  'Details: ${details.exception.toString().split('\n').first}',
                  style: const TextStyle(fontSize: 12, color: Colors.redAccent, fontFamily: 'monospace'),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    };
    return child;
  }
}
