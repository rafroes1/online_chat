import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// ignore: must_be_immutable
class TextComposer extends StatefulWidget {
  TextComposer(this.sendMessage);

  final Function({String text, File imgFile}) sendMessage;

  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  bool _isComposing = false;
  TextEditingController _controller = TextEditingController();

  void _reset() {
    _controller.clear();
    setState(() {
      _isComposing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.photo_camera),
            onPressed: () {
              _showPicker(context);
            },
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration.collapsed(hintText: "Send a message"),
              onChanged: (text) {
                setState(() {
                  _isComposing = text.isNotEmpty;
                });
              },
              onSubmitted: (text) {
                widget.sendMessage(text: text);
                _reset();
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _isComposing
                ? () {
                    //button is able if typing
                    widget.sendMessage(text: _controller.text);
                    _reset();
                  }
                : null,
          )
        ],
      ),
    );
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Gallery'),
                      onTap: () {
                        ImagePicker picker = ImagePicker();
                        picker
                            .getImage(
                                source: ImageSource.gallery,
                                imageQuality: 100,
                                maxHeight: 140.0,
                                maxWidth: 140.0)
                            .then((value) {
                          if (value == null) return;
                          File imgFile = File(value.path);
                          widget.sendMessage(imgFile: imgFile);
                        });
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      ImagePicker picker = ImagePicker();
                      picker
                          .getImage(
                              source: ImageSource.camera,
                              imageQuality: 100,
                              maxHeight: 140.0,
                              maxWidth: 140.0)
                          .then((value) {
                        if (value == null) return;
                        File imgFile = File(value.path);
                        widget.sendMessage(imgFile: imgFile);
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }
}
