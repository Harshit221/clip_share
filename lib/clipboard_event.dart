import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';


class ClipboardStream {

  String _data;
  Timer _timer;
  final _controller = StreamController<String>.broadcast();

  ClipboardStream() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      _data = (await Clipboard.getData('text/plain')).text;
      _controller.add(_data);
    });
  }

  Stream get clipboardStream => _controller.stream;

  void dispose() {
    _timer.cancel();
    _controller.close();
  }
}

class ClipboardEvent{
  String _data = "";
  final Function onClipboardDataChange;
  final clipboardStream = ClipboardStream();

  void setData(String data) {
    if(_data != data) {
      print('Set clipboard: $_data');
      _data = data;
      Clipboard.setData(ClipboardData(text: _data));
    }

  }

  ClipboardEvent({@required this.onClipboardDataChange}) {
    clipboardStream.clipboardStream.listen((event) {
      if(event != _data) {
        _data = event;
        onClipboardDataChange.call(_data);
      }
    });
  }

  void dispose() {
    clipboardStream.dispose();
  }
}