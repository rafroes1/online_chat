import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:online_chat/TextComposer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  void _sendMessage({String text, File imgFile}) async {

    Map<String, dynamic> data ={};

    if (imgFile != null) {
      StorageUploadTask task = FirebaseStorage.instance
          .ref()
          .child(DateTime.now().millisecondsSinceEpoch.toString())
          .putFile(imgFile);

      StorageTaskSnapshot taskSnaptshot = await task.onComplete;
      data["url"] = await taskSnaptshot.ref.getDownloadURL();
    }

    if(text != null) data["text"] = text;

    Firestore.instance.collection("messages").add(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Chat"),
        centerTitle: true,
        elevation: 0,
      ),
      body: TextComposer(_sendMessage),
    );
  }
}
