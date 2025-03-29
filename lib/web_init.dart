// Helper file for web-specific initialization
// This is to handle web-specific setup and avoid compilation errors
import 'dart:js_interop';

import 'package:js/js.dart';

/// Initialize web-specific configuration
void initializeWeb() {
  // Web-specific initialization code here
}

/// JavaScript promise wrapper to handle Firebase promises
@JS()
class PromiseJsImpl<T> {
  external PromiseJsImpl();
}

/// Convert JS promise to Dart Future
@JS('Promise.resolve')
external PromiseJsImpl<T> resolvePromise<T>(T value);

/// Handle interoperability with JavaScript
@JS('Object.keys')
external JSArray getKeysJs(JSObject object);