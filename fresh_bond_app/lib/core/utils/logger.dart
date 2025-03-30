import 'package:flutter/foundation.dart';
import 'package:fresh_bond_app/core/config/app_config.dart';
import 'package:logger/logger.dart' as logger_pkg;

enum LogLevel { verbose, debug, info, warning, error, wtf, nothing }

class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  static AppLogger get instance => _instance;
  
  late final logger_pkg.Logger _logger;
  
  factory AppLogger() {
    return _instance;
  }
  
  AppLogger._internal() {
    _logger = logger_pkg.Logger(
      printer: logger_pkg.PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: true,
      ),
      level: AppConfig.instance().isDevelopment 
          ? logger_pkg.Level.verbose 
          : logger_pkg.Level.info,
    );
  }
  
  void v(String message, {dynamic error, StackTrace? stackTrace}) {
    if (!kReleaseMode) _logger.v(message, error: error, stackTrace: stackTrace);
  }
  
  void d(String message, {dynamic error, StackTrace? stackTrace}) {
    if (!kReleaseMode) _logger.d(message, error: error, stackTrace: stackTrace);
  }
  
  void i(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }
  
  void w(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }
  
  void e(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
  
  void wtf(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.wtf(message, error: error, stackTrace: stackTrace);
  }
}
