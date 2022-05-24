// https://medium.com/@yuankuan/web-worker-and-dart-ef76eab562e6
//

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_web_worker/model.dart';

main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  bool _showProgress = false;
  double _progress = 0;
  html.Worker? _myWorker;

  @override
  void initState() {
    super.initState();
    _configureWebWorker();
  }

  void _configureWebWorker() {
    if (html.Worker.supported) {
      _myWorker = html.Worker("wk.dart.js");
      _myWorker!.onMessage.listen((event) {
        if (kDebugMode) {
          print("main:receive from worker: ${event.data}");
        }

        var action =
            WkAction(kind: event.data["kind"], value: event.data["value"]);

        if (action.kind == WkAction.end) {
          setState(() {
            _showProgress = false;
          });
        } else if (action.kind == WkAction.progress) {
          setState(() {
            _progress = action.value.toDouble();
          });
        }
      });
      _myWorker!.postMessage(WkAction(kind: WkAction.echo, value: 10));
    } else {
      debugPrint('Your browser doesn\'t support web workers.');
    }
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
    _myWorker!.postMessage(WkAction(kind: WkAction.echo, value: _counter));
  }

  void _startWorker() {
    if (_showProgress) return;
    setState(() {
      _myWorker!.postMessage(WkAction(kind: WkAction.start, value: _counter));
      _showProgress = true;
    });
  }

  void _benchmark() {
    setState(() {
      _showProgress = true;
      _progress = 0;
    });

    for (var i = 0; i < WkAction.maxLoopLength; i++) {
      if (i % 1002 == 0) {
        setState(() {
          _progress = i / WkAction.maxLoopLength;
          if (kDebugMode) {
            print(_progress);
          }
        });
      }
    }
    setState(() {
      _showProgress = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            LinearProgressIndicator(
              value: _progress,
            )
          ],
        ),
      ),
      floatingActionButton:
          Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        _showProgress
            ? const CircularProgressIndicator()
            : FloatingActionButton(
                onPressed: _benchmark,
                tooltip: 'Start Benchmark',
                child: const Icon(Icons.slow_motion_video_outlined),
              ),
        _showProgress
            ? const CircularProgressIndicator()
            : FloatingActionButton(
                onPressed: _startWorker,
                tooltip: 'Start Worker',
                child: const Icon(Icons.play_arrow),
              ),
        FloatingActionButton(
          onPressed: _incrementCounter,
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ),
      ]),
    );
  }
}
