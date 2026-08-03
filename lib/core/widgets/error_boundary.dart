import 'package:flutter/material.dart';
import '../design_system/theme/app_theme.dart';
import 'custom_button.dart';

class GlobalErrorBoundary extends StatefulWidget {
  final Widget child;

  const GlobalErrorBoundary({super.key, required this.child});

  @override
  State<GlobalErrorBoundary> createState() => _GlobalErrorBoundaryState();

  // Static hook for the Logger to report errors
  static void Function(Object, StackTrace)? reportError;
}

class _GlobalErrorBoundaryState extends State<GlobalErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  void initState() {
    super.initState();
    // Register this boundary as the global error reporter
    GlobalErrorBoundary.reportError = _handleError;
  }

  @override
  void dispose() {
    GlobalErrorBoundary.reportError = null;
    super.dispose();
  }

  void _handleError(Object error, StackTrace stackTrace) {
    if (!mounted) return;
    setState(() {
      _error = error;
      _stackTrace = stackTrace;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: Scaffold(
          body: Container(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline_rounded,
                        color: Theme.of(context).colorScheme.error,
                        size: 64,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Something went wrong',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'The application encountered an unexpected error. Our team has been notified.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    CustomButton(
                      text: 'Restart Application',
                      fullWidth: true,
                      onPressed: () {
                        setState(() {
                          _error = null;
                          _stackTrace = null;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Error Details'),
                            content: SingleChildScrollView(
                              child: Text(
                                '$_error\n\n$_stackTrace',
                                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                              ),
                            ),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
                            ],
                          ),
                        );
                      },
                      child: const Text('Show Details'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return widget.child;
  }
}
