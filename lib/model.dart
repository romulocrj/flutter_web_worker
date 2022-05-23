//https://medium.com/@yuankuan/web-worker-and-dart-ef76eab562e6

@JS()
library model;

import 'package:js/js.dart';

@JS()
@anonymous
class WkAction {
  static const echo = "echo";
  static const progress = "progress";
  static const start = "start";
  static const end = "end";
  external String get kind;
  external num get value;

  external factory WkAction({String kind, num value});
}
