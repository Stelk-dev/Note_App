import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'notes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Directory dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);
  await Hive.openBox<List>("notes");
  await Hive.openBox<List>("list");
  runApp(MaterialApp(
    home: MyApp(),
    title: 'Hive Database',
    debugShowCheckedModeBanner: false,
  ));
}

class FileNotes {
  String name;
  String content;
  FileNotes({this.name, this.content});
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  //Note
  Box<List> boxHive;
  String title;
  String content;
  String month;

  //Cose da fare
  Box<List> boxHiveList;
  bool checkIcon = false;

//Mese in nome
  void actualityMonth() {
    setState(() {
      if (DateTime.now().month == 1)
        month = 'January';
      else if (DateTime.now().month == 2)
        month = 'February';
      else if (DateTime.now().month == 3)
        month = 'March';
      else if (DateTime.now().month == 4)
        month = 'April';
      else if (DateTime.now().month == 5)
        month = 'May';
      else if (DateTime.now().month == 6)
        month = 'June';
      else if (DateTime.now().month == 7)
        month = 'July';
      else if (DateTime.now().month == 8)
        month = 'August';
      else if (DateTime.now().month == 9)
        month = 'September';
      else if (DateTime.now().month == 10)
        month = 'October';
      else if (DateTime.now().month == 11)
        month = 'November';
      else
        month = 'December';
    });
  }

  @override
  void initState() {
    super.initState();
    boxHive = Hive.box<List>("notes");
    boxHiveList = Hive.box<List>("list");
  }

  bool pressed = false;
  int counter = 0;
  void onDown(int index, Box<List> boxDB, PointerEvent details) async {
    setState(() {
      pressed = true;
    });
    while (pressed) {
      setState(() {
        counter++;
      });

      if (counter > 2.5) {
        pressed = false;
        counter = 0;
        dialogEliminate(index, boxDB);
      }
      await Future.delayed(Duration(milliseconds: 200));
    }
  }

  // ignore: missing_return
  Widget dialogEliminate(int index, Box<List> boxDB) {
    showDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          content: Container(
            height: 48,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                FlatButton(
                  onPressed: () {
                    setState(() {
                      boxDB.deleteAt(index);
                      Navigator.of(context).pop();
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Delete',
                        style: TextStyle(color: Colors.red, fontSize: 25),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget listNotes() {
    return ListView.builder(
      itemCount: boxHive.length,
      itemBuilder: (context, index) {
        index = (boxHive.length - 1) - index; // Index
        return Listener(
          onPointerDown: (event) {
            onDown(index, boxHive, event);
          },
          onPointerUp: (event) {
            setState(() {
              pressed = false;
              counter = 0;
            });
          },
          child: Card(
            child: FlatButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => InterfaceNote(
                    id: index,
                    title: boxHive.getAt(index)[0],
                    content: boxHive.getAt(index)[1],
                  ),
                ));
              },
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 12.0, 0, 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        boxHive.getAt(index)[0].length < 27
                            ? Text(
                                '${boxHive.getAt(index)[0]}',
                                style: TextStyle(fontSize: 20),
                              )
                            : Text(
                                '${boxHive.getAt(index)[0].substring(0, 26)}...',
                                style: TextStyle(fontSize: 20),
                              ),
                        SizedBox(
                          height: 5,
                        ),
                        boxHive.getAt(index)[1].length < 40
                            ? Text(
                                '${boxHive.getAt(index)[1]}',
                                style:
                                    TextStyle(fontSize: 15, color: Colors.grey),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              )
                            : Text(
                                '${boxHive.getAt(index)[1].substring(0, 39)}...',
                                style:
                                    TextStyle(fontSize: 15, color: Colors.grey),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                          width: 320,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '${boxHive.getAt(index)[2]} ${boxHive.getAt(index)[3]}',
                                style: TextStyle(color: Colors.blueGrey),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget floatButtonNotes() {
    return FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          return showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Create note'),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        TextField(
                          decoration: InputDecoration(hintText: 'Title'),
                          onChanged: (value) {
                            setState(() {
                              title = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Go back'),
                      color: Colors.red,
                    ),
                    //Creazione Nota
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        actualityMonth();
                        setState(() {
                          boxHive.add([
                            title != null
                                ? title
                                : 'Note ' + boxHive.length.toString(),
                            content = '',
                            DateTime.now().day,
                            month,
                            boxHive.length
                          ]);
                        });
                      },
                      child: Text('Create'),
                      color: Colors.blue,
                    )
                  ],
                );
              });
        });
  }

  Widget listList() {
    return ListView.builder(
      itemCount: boxHiveList.length,
      itemBuilder: (context, index) {
        index = (boxHiveList.length - index) - 1;
        return Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 8, 8, 0),
            child: Row(
              children: [
                Listener(
                  onPointerDown: (event) {
                    onDown(index, boxHiveList, event);
                  },
                  onPointerUp: (event) {
                    setState(() {
                      pressed = false;
                      counter = 0;
                    });
                  },
                  child: Container(
                    color: boxHiveList.getAt(index)[1]
                        ? Colors.grey[300]
                        : Colors.white,
                    width: MediaQuery.of(context).size.width * 0.95,
                    padding: EdgeInsets.fromLTRB(13, 5, 0, 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: Text(
                            boxHiveList.getAt(index)[0].length < 35
                                ? boxHiveList.getAt(index)[0]
                                : boxHiveList.getAt(index)[0],
                            style: TextStyle(
                                fontSize: 18,
                                decoration: boxHiveList.getAt(index)[1]
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none),
                          ),
                        ),
                        IconButton(
                          icon: boxHiveList.getAt(index)[1]
                              ? Icon(Icons.check_box)
                              : Icon(Icons.check_box_outline_blank),
                          onPressed: () {
                            setState(() {
                              boxHiveList.getAt(index)[1] =
                                  !boxHiveList.getAt(index)[1];
                            });
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ));
      },
    );
  }

  Widget floatButtonList() {
    return FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.redAccent,
        onPressed: () {
          return showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Create to-do list'),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        TextField(
                          decoration: InputDecoration(hintText: 'Title'),
                          onChanged: (value) {
                            setState(() {
                              title = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Go back'),
                      color: Colors.red,
                    ),
                    //Creazione Nota
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        actualityMonth();
                        setState(() {
                          boxHiveList.add([
                            title != null
                                ? title
                                : 'To do ' + boxHive.length.toString(),
                            false,
                            DateTime.now().day,
                            month,
                            boxHive.length
                          ]);
                        });
                      },
                      child: Text('Create'),
                      color: Colors.blue,
                    )
                  ],
                );
              });
        });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Note App'),
      ),
      body: PageView(
        children: [
          //Note
          Scaffold(
              body: boxHive.length == 0
                  ? Center(
                      child: Text(
                        'Add note',
                        style: TextStyle(fontSize: 30),
                      ),
                    )
                  : RefreshIndicator(
                      child: listNotes(),
                      onRefresh: () async {
                        await Future.delayed(Duration(milliseconds: 200));
                        setState(() {
                          listNotes();
                        });
                      }),
              floatingActionButton: floatButtonNotes()),
          //Disegni
          Scaffold(
            body: boxHiveList.length == 0
                ? Container(
                    color: Colors.lightBlueAccent,
                    child: Center(
                      child: Text(
                        'Add to-do list',
                        style: TextStyle(fontSize: 25),
                      ),
                    ),
                  )
                : RefreshIndicator(
                    child: Container(
                      color: Colors.lightBlueAccent,
                      child: listList(),
                    ),
                    onRefresh: () async {
                      await Future.delayed(Duration(milliseconds: 200));
                      setState(() {
                        listList();
                      });
                    }),
            floatingActionButton: floatButtonList(),
          )
        ],
      ),
    );
  }
}
