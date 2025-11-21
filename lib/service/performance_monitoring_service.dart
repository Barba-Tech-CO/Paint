import 'package:firebase_performance/firebase_performance.dart';
import '../utils/logger/app_logger.dart';

class PerformanceMonitoringService {
  final FirebasePerformance _performance;
  final AppLogger _logger;
  final Map<String, Trace> _activeTraces = {};

  PerformanceMonitoringService(
    this._performance,
    this._logger,
  );

  /// Start a custom trace for performance monitoring
  Future<void> startTrace(String traceName) async {
    try {
      if (_activeTraces.containsKey(traceName)) {
        _logger.warning('Trace $traceName is already active');
        return;
      }

      final trace = _performance.newTrace(traceName);
      await trace.start();
      _activeTraces[traceName] = trace;
      _logger.info('Started performance trace: $traceName');
    } catch (e) {
      _logger.error('Error starting trace $traceName: $e', e);
    }
  }

  /// Stop a custom trace
  Future<void> stopTrace(String traceName) async {
    try {
      final trace = _activeTraces[traceName];
      if (trace == null) {
        _logger.warning('Trace $traceName not found');
        return;
      }

      await trace.stop();
      _activeTraces.remove(traceName);
      _logger.info('Stopped performance trace: $traceName');
    } catch (e) {
      _logger.error('Error stopping trace $traceName: $e', e);
    }
  }

  /// Add a metric to an active trace
  void setMetric(String traceName, String metricName, int value) {
    try {
      final trace = _activeTraces[traceName];
      if (trace == null) {
        _logger.warning('Trace $traceName not found for metric $metricName');
        return;
      }

      trace.setMetric(metricName, value);
      _logger.info('Set metric $metricName=$value for trace $traceName');
    } catch (e) {
      _logger.error(
        'Error setting metric $metricName for trace $traceName: $e',
        e,
      );
    }
  }

  /// Increment a metric in an active trace
  void incrementMetric(String traceName, String metricName, int incrementBy) {
    try {
      final trace = _activeTraces[traceName];
      if (trace == null) {
        _logger.warning('Trace $traceName not found for metric $metricName');
        return;
      }

      trace.incrementMetric(metricName, incrementBy);
      _logger.info(
        'Incremented metric $metricName by $incrementBy for trace $traceName',
      );
    } catch (e) {
      _logger.error(
        'Error incrementing metric $metricName for trace $traceName: $e',
        e,
      );
    }
  }

  /// Add a custom attribute to an active trace
  void setAttribute(String traceName, String attributeName, String value) {
    try {
      final trace = _activeTraces[traceName];
      if (trace == null) {
        _logger.warning(
          'Trace $traceName not found for attribute $attributeName',
        );
        return;
      }

      trace.putAttribute(attributeName, value);
      _logger.info('Set attribute $attributeName=$value for trace $traceName');
    } catch (e) {
      _logger.error(
        'Error setting attribute $attributeName for trace $traceName: $e',
        e,
      );
    }
  }

  /// Execute a function with automatic trace timing
  Future<T> trace<T>(
    String traceName,
    Future<T> Function() operation, {
    Map<String, String>? attributes,
  }) async {
    await startTrace(traceName);

    try {
      if (attributes != null) {
        attributes.forEach((key, value) {
          setAttribute(traceName, key, value);
        });
      }

      final result = await operation();
      return result;
    } catch (e) {
      setAttribute(traceName, 'error', e.toString());
      rethrow;
    } finally {
      await stopTrace(traceName);
    }
  }

  /// Create and start an HTTP metric for network requests
  HttpMetric newHttpMetric(String url, HttpMethod method) {
    return _performance.newHttpMetric(url, method);
  }

  /// Clean up all active traces (useful for testing)
  Future<void> cleanupActiveTraces() async {
    final traces = List<String>.from(_activeTraces.keys);
    for (final traceName in traces) {
      await stopTrace(traceName);
    }
  }
}
