// ignore_for_file: avoid_print, avoid_web_libraries_in_flutter
//https://qiita.com/kyorohiro/items/8dda45cde3078ae42f92
//dart compile js lib/wk.dart -o web/wk.dart.js

import 'package:flutter_web_worker/model.dart';
import 'package:js/js.dart';

@anonymous
@JS()
abstract class MessageEvent {
  external dynamic get data;
}

@JS('postMessage')
external void postMessage(obj);

@JS('onmessage')
external set onMessage(f);

main() {
  const length = 9900000;

  onMessage = allowInterop((event) {
    var e = event as MessageEvent;
    var action = e.data as WkAction;
    print(
        'worker: got ${action.kind} from master, raising it from ${action.value}...');
    if (action.kind == WkAction.echo) {
      postMessage(WkAction(kind: WkAction.echo, value: action.value + 1));
    } else if (action.kind == WkAction.start) {
      // start a long running action
      for (var i = 0; i < length; i++) {
        if (i % 1002 == 0) {
          //feedback
          postMessage(WkAction(kind: WkAction.progress, value: (i / length)));
        }
      }
      //end
      postMessage(WkAction(kind: WkAction.end, value: action.value + 1));
    }
  });
}
