import 'package:flutter/material.dart';

/// A widget that catches errors in its child widget tree and displays a fallback UI.
class ErrorBoundary extends StatefulWidget {
  /// The child widget that might throw an error.
  final Widget child;

  /// Optional custom error widget to display when an error occurs.
  final Widget Function(FlutterErrorDetails)? errorBuilder;

  /// Callback that's called when an error occurs.
  final void Function(FlutterErrorDetails)? onError;

  /// Creates an error boundary.
  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
    this.onError,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  FlutterErrorDetails? _error;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(_error!);
      }

      // Default error UI
      return Material(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              const SizedBox(height: 16),
              const Text(
                'Something went wrong',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'The application encountered an error.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _error = null;
                  });
                },
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    return _ErrorBoundaryWidget(
      onError: (errorDetails) {
        setState(() {
          _error = errorDetails;
        });
        widget.onError?.call(errorDetails);
      },
      child: widget.child,
    );
  }
}

class _ErrorBoundaryWidget extends StatefulWidget {
  final Widget child;
  final Function(FlutterErrorDetails) onError;

  const _ErrorBoundaryWidget({
    required this.child,
    required this.onError,
  });

  @override
  State<_ErrorBoundaryWidget> createState() => _ErrorBoundaryWidgetState();
}

class _ErrorBoundaryWidgetState extends State<_ErrorBoundaryWidget> {
  late final Widget Function(FlutterErrorDetails) _originalErrorBuilder;

  @override
  void initState() {
    super.initState();
    _originalErrorBuilder = ErrorWidget.builder;
    ErrorWidget.builder = _handleError;
  }

  @override
  void dispose() {
    ErrorWidget.builder = _originalErrorBuilder;
    super.dispose();
  }

  Widget _handleError(FlutterErrorDetails details) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onError(details);
      }
    });
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Extension method to add error boundary to any widget
extension ErrorBoundaryExtension on Widget {
  /// Wraps the widget with an error boundary
  Widget withErrorBoundary({
    Widget Function(FlutterErrorDetails)? errorBuilder,
    void Function(FlutterErrorDetails)? onError,
  }) {
    return ErrorBoundary(
      errorBuilder: errorBuilder,
      onError: onError,
      child: this,
    );
  }
}
