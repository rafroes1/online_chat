import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io';
import 'package:online_chat/TextComposer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:online_chat/ChatMessage.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  FirebaseUser _currentUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.onAuthStateChanged.listen((user) {
      setState(() {
        _currentUser = user;
      });
    });
  }

  Future<FirebaseUser> _getUser() async {
    if (_currentUser != null) return _currentUser;

    try {
      final GoogleSignInAccount googleSignInAccount =
          await googleSignIn.signIn();

      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);

      final AuthResult authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final FirebaseUser user = authResult.user;
      return user;
    } catch (error) {
      return null;
    }
  }

  void _sendMessage({String text, File imgFile}) async {
    final FirebaseUser user = await _getUser();

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Couldn't login. Please try again."),
        backgroundColor: Colors.redAccent,
      ));
    }

    Map<String, dynamic> data = {
      "uid" : user.uid,
      "senderName" : user.displayName,
      "senderPhotoUrl" : user.photoUrl,
      "time" : Timestamp.now()
    };

    if (imgFile != null) {
      StorageUploadTask task = FirebaseStorage.instance
          .ref()
          .child(user.uid) //each image will be stored in the sender folder
          .child(DateTime.now().millisecondsSinceEpoch.toString()) //img id is the timestamp of when it was sent
          .putFile(imgFile);

      setState(() {
        _isLoading = true;
      });

      StorageTaskSnapshot taskSnaptshot = await task.onComplete;
      data["imgUrl"] = await taskSnaptshot.ref.getDownloadURL();

      setState(() {
        _isLoading = false;
      });
    }

    if (text != null) data["text"] = text;

    Firestore.instance.collection("messages").add(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text( _currentUser != null ? "Hello, ${_currentUser.displayName}" : "My Chat"),
        centerTitle: true,
        elevation: 0,
        actions: <Widget>[
          _currentUser != null ? IconButton(icon: Icon(Icons.exit_to_app), onPressed: (){
            FirebaseAuth.instance.signOut();
            googleSignIn.signOut();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Logged out successfully"),
              backgroundColor: Colors.redAccent,
            ));
          }) : Container()
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder(
              stream: Firestore.instance.collection("messages").orderBy("time").snapshots(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  default:
                    List<DocumentSnapshot> documents =
                        snapshot.data.documents.reversed.toList();

                    return ListView.builder(
                      itemBuilder: (context, index) {
                        //verifies if the message was sent by the current user
                        return ChatMessage(documents[index].data, documents[index].data["uid"] == _currentUser?.uid);
                      },
                      itemCount: documents.length,
                      reverse: true,
                    );
                }
              },
            ),
          ),
          _isLoading ? LinearProgressIndicator() : Container(),
          TextComposer(_sendMessage)
        ],
      ),
    );
  }
}
