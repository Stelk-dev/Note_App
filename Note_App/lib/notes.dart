import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class InterfaceNote extends StatefulWidget {
  int id;
  String title;
  String content;
  InterfaceNote({this.id, this.title, this.content});

  @override
  InterfaceNoteState createState() => InterfaceNoteState();
}

class InterfaceNoteState extends State<InterfaceNote> {
  Box<List> boxHive;

  @override
  void initState() {
    super.initState();
    boxHive = Hive.box<List>("notes");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: TextFormField(
          style: TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          initialValue: widget.title,
          decoration: InputDecoration(
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() {
              boxHive.putAt(widget.id, [
                value,
                widget.content,
                boxHive.getAt(widget.id)[2],
                boxHive.getAt(widget.id)[3],
                boxHive.getAt(widget.id)[4]
              ]);
            });
          },
        ),
      ),
      body: Container(
        child: TextFormField(
          maxLines: null,
          initialValue: widget.content,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: InputBorder.none,
          ),
          style: TextStyle(fontSize: 20, color: Colors.black),
          onChanged: (value) {
            setState(() {
              boxHive.putAt(widget.id, [
                widget.title,
                value,
                boxHive.getAt(widget.id)[2],
                boxHive.getAt(widget.id)[3],
                boxHive.getAt(widget.id)[4]
              ]);
            });
          },
        ),
      ),
    );
  }
}
