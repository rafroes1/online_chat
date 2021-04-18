import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:online_chat/ChatScreen.dart';

void main() {
  runApp(MyApp());
  //Firestore.instance.collection("col").document("doc2").setData({"text":"rafael2"});
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        iconTheme: IconThemeData(
          color: Colors.blue
        )
      ),
      home: ChatScreen(),
    );
  }
}
