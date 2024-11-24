import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter POST Request Example',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  ggg createState() => ggg();
}

class ggg extends State<HomePage> {
  final apiUrl = "http://192.168.0.42/notificaions/send_notification.php";
  TextEditingController titleController = TextEditingController();
  TextEditingController bodyController = TextEditingController();

  Future<void> sendPostRequest() async {
    var response = await http.post(apiUrl as Uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "message": "jkjj",
          "title": 'jhjh',
          "device_token": 'eFFwJl_FQ-SALzv4kvU9k2:APA91bHeCNXBlux7i5ICibGjZ4nTH-49_fB7mgLrCLISn9uhYSLh5wPU0uxah26ynQsGQKa0K28afrVsN2_Y6D2hTQ5kfcB0xsbQ_wQeYs7d6GaiYG_Ji7k',
        }));

    if (response.statusCode == 200) {
   print("Post created successfully!");
    } else {
      print("Failed to create post!");

    }

    }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter POST Request Example'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(onTap: (){
              sendPostRequest();
            },child: Text(""))
          ],
        ),
      ),
    );
  }
  }

