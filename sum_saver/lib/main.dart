import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Save Operation value to Phone',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(
        storage: Storage(),
      ),
    );
  }
}

class Home extends StatefulWidget {
  final Storage storage;
  Home({Key key, @required this.storage}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController firstValue = TextEditingController();
  TextEditingController secondValue = TextEditingController();
  String result;
  Future<Directory> _appDirectory;

  @override
  void initState() {
    super.initState();
    widget.storage.readData().then((String value) {
      setState(() {
        result = value;
      });
    });
  }

  Future<File> operationData() async {
    setState(() {
      int first = int.parse(firstValue.text);
      int second = int.parse(secondValue.text);
      int total = first + second;
      int multiplication = first * second;
      int subtraction = first - second;
      double division = first / second;
      result = "\n \n \n Sum is: ${total.toString()} \n" +
          "Subtraction is: ${subtraction.toString()} \n" +
          "Multiplication is: ${multiplication.toString()} \n" +
          "Division is: ${division.toString()} \n";
      firstValue.text = "";
      secondValue.text = "";
    });
    return widget.storage.writeData(result);
  }

  void getAppDirectory() {
    setState(() {
      _appDirectory = getApplicationDocumentsDirectory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Opertaion Saver"),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Text('${result ?? "File Is Empty"}'),
            SizedBox(
              height: 20,
            ),
            TextField(
              keyboardType: TextInputType.number,
              controller: firstValue,
              decoration: InputDecoration(hintText: "First Value goes here."),
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              keyboardType: TextInputType.number,
              controller: secondValue,
              decoration: InputDecoration(hintText: "First Value goes here."),
            ),
            RaisedButton(
              onPressed: operationData,
              child: Text("Write Result to file"),
            ),
            SizedBox(
              height: 5,
            ),
            RaisedButton(
              onPressed: getAppDirectory,
              child: Text("Get Directory Path"),
            ),
            FutureBuilder<Directory>(
              future: _appDirectory,
              builder:
                  (BuildContext context, AsyncSnapshot<Directory> snapshot) {
                Text text = Text("");
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    text = Text("Error: ${snapshot.error}");
                  } else if (snapshot.hasData) {
                    text = Text("Path: ${snapshot.data.path}");
                  } else {
                    text = Text("Unavailable");
                  }
                }
                return new Container(
                  child: text,
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

class Storage {
  Future<String> get localPath async {
    final dir = await getExternalStorageDirectory();
    return dir.path;
  }

  Future<File> get localFile async {
    final path = await localPath;
    return File('$path/opertaion.txt');
  }

  Future<String> readData() async {
    try {
      final file = await localFile;
      String body = await file.readAsString();
      return body;
    } catch (e) {
      return e.toString();
    }
  }

  Future<File> writeData(String data) async {
    final file = await localFile;
    return file.writeAsString('$data');
  }
}
