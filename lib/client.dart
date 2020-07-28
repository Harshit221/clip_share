import 'dart:io';

import 'package:flutter/services.dart';

class Client {
  final String ip;
  final String port;
  Socket client;
  Function onData;
  Function status;
  Client(this.ip, this.port, this.onData, this.status) {
    initialize();
  }

  void initialize() async {

    try {
      client = await Socket.connect(ip, int.parse(port), );
      client.setOption(SocketOption.tcpNoDelay, true);
      client.listen((event) {
        String temp = String.fromCharCodes(event);
        if(temp == 'close') {
          status('Not connected');
          client.close();
        }
        else
          onData.call(temp);
      });
      status('Connected');
    } catch(e) {
      print(e);
      status('failed');
    }

  }
  void sendData(String data) {
    print('Sending: $data');
    client.write(data);
  }


}