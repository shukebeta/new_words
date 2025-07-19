import 'package:new_words/utils/app_logger_interface.dart';

/// Mock implementation of AppLoggerInterface for testing
class MockAppLogger implements AppLoggerInterface {
  final List<String> _infoLogs = [];
  final List<String> _debugLogs = [];
  final List<String> _errorLogs = [];
  
  bool _initialized = false;

  @override
  Future<void> initialize() async {
    _initialized = true;
  }

  @override
  void i(String message) {
    _infoLogs.add(message);
  }

  @override
  void d(String message) {
    _debugLogs.add(message);
  }

  @override
  void e(String message) {
    _errorLogs.add(message);
  }

  // Test helpers
  List<String> get infoLogs => List.unmodifiable(_infoLogs);
  List<String> get debugLogs => List.unmodifiable(_debugLogs);
  List<String> get errorLogs => List.unmodifiable(_errorLogs);
  bool get isInitialized => _initialized;

  void clear() {
    _infoLogs.clear();
    _debugLogs.clear();
    _errorLogs.clear();
    _initialized = false;
  }
}