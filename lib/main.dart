import 'dart:async';
import 'dart:math';

import 'package:clip_share/client.dart';
import 'package:clip_share/clipboard_event.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(
        title: Text('ClipShare'),
      ),
      body: Home(),
    ),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  ClipboardEvent event;
  String status = "Not connected";
  Client client;
  String ip,port;
  @override
  void initState() {
    super.initState();
    event = ClipboardEvent(
        onClipboardDataChange: (data){
          client.sendData(data);
        }
    );
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              decoration: InputDecoration(hintText: 'Ip address'),
              onChanged: (data) {
                ip = data;
              },
            ),
            TextField(
              decoration: InputDecoration(hintText: 'port'),
                keyboardType: TextInputType.number,
                onChanged: (data) {
                  port = data;
                }
            ),
            RaisedButton(
              child: Text('Connect'),
              onPressed: () {
                client = Client(ip, port, event.setData, changeStatus);
              },
            ),
            SizedBox(height: 10,),
            Text(status)
          ],
        ),
      ),
    );
  }

  void changeStatus(data) {
    setState(() {
      status = data;
    });
  }

  void closeConnection() {
    client.client.close();
  }
  @override
  void dispose() {
    event.dispose();
    super.dispose();
  }
}
