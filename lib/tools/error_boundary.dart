import 'package:flutter/material.dart';

class ErrorBoundary extends StatefulWidget {
  final Widget child;

  const ErrorBoundary({Key? key, required this.child}) : super(key: key);

  @override
  _ErrorBoundaryState createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary>
    with TickerProviderStateMixin {
  bool hasError = false;
  FlutterErrorDetails? errorDetails;
  void Function(FlutterErrorDetails)? _originalOnError;

  @override
  void initState() {
    super.initState();
    _originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      if (!mounted) return;

      // Schedule state update for the next frame to avoid build phase conflicts
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            hasError = true;
            errorDetails = details;
          });
        }
      });

      // Still call the original handler if it exists
      if (_originalOnError != null) {
        _originalOnError!(details);
      }
    };
  }

  @override
  void dispose() {
    // Restore the original error handler
    if (_originalOnError != null) {
      FlutterError.onError = _originalOnError;
    }
    super.dispose();
  }

  void _resetError() {
    if (!mounted) return;

    setState(() {
      hasError = false;
      errorDetails = null;
    });

    // Use a post-frame callback to ensure we're not in a build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (hasError) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: SafeArea(
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 48),
                  SizedBox(height: 16),
                  Text(
                    'Oops! Something went wrong',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  if (errorDetails != null) ...[
                    Text(
                      errorDetails!.exception.toString(),
                      style: TextStyle(fontSize: 14, color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                  ],
                  ElevatedButton(
                    onPressed: _resetError,
                    child: Text('Go Back'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return widget.child;
  }
}
