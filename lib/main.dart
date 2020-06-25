import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:useallfeatures/home.dart';

void main() {
 // WidgetsFlutterBinding.ensureInitialized();
 // Firestore.instance.settings(timestampsInSnapshotsEnabled :true);



  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
        theme: ThemeData(

          primarySwatch: Colors.deepPurple,
          accentColor: Colors.teal,
        ),
      home: Home(),
    );
  }
}
