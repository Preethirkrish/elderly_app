import 'dart:async';

import 'package:elderly_app/models/note.dart';
import 'package:elderly_app/screens/notes/note_edit_screen.dart';
import 'package:elderly_app/widgets/app_default.dart';
import 'package:flutter/material.dart';
import 'package:elderly_app/others/database_helper.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:sqflite/sqflite.dart';

class NoteList extends StatefulWidget {
  static const String id = 'Note_Home_Screen';
  @override
  State<StatefulWidget> createState() {
    return NoteListState();
  }
}

class NoteListState extends State<NoteList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList;
  int count = 0;
  List<StaggeredTile> staggeredTileExtent;
  List<Widget> children;
  @override
  Widget build(BuildContext context) {
    if (noteList == null) {
      noteList = List<Note>();
      updateListView();
    }

    return Scaffold(
      appBar: ElderlyAppBar(),
      drawer: AppDrawer(),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Notes',
              style: TextStyle(fontSize: 30, color: Colors.indigo),
            ),
          ),
          Flexible(
            child: StaggeredGridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 5,
              mainAxisSpacing: 1,
              padding: EdgeInsets.all(8),
              children: getNoteListView(),
              staggeredTiles: staggeredTileExtent,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigateToDetail(Note('', '', 2), 'Add Note');
        },
        tooltip: 'Add Note',
        child: Icon(Icons.add),
      ),
    );
  }

  List<Widget> getNoteListView() {
    staggeredTileExtent = [];
    children = [];

    for (var note in noteList) {
      bool descriptionTrim = false, titleTrim = false;

      if (note.description.length > 50) descriptionTrim = true;
      if (note.title.length > 20) titleTrim = true;
      children.add(Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () {
            navigateToDetail(note, 'Edit Note');
          },
          child: Dismissible(
            onDismissed: (direction) {
              setState(() {
                noteList.remove(note);
                _delete(noteList[noteList.indexOf(note)]);
                updateListView();
              });
            },
            key: Key(note.id.toString()),
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(10),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: titleTrim
                        ? Text(
                            note.title.substring(0, 20),
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          )
                        : Text(
                            note.title,
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Padding(
                      padding: EdgeInsets.all(8),
                      child: descriptionTrim
                          ? Text(note.description.substring(0, 80))
                          : Text(note.description))
                ],
              ),
            ),
          ),
        ),
      ));

      staggeredTileExtent.add(StaggeredTile.extent(1, 220));
    }
    return children;
  }

  // Returns the priority color
  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.yellow;
        break;

      default:
        return Colors.yellow;
    }
  }

  // Returns the priority icon
  Icon getPriorityIcon(int priority) {
    switch (priority) {
      case 1:
        return Icon(Icons.play_arrow);
        break;
      case 2:
        return Icon(Icons.keyboard_arrow_right);
        break;

      default:
        return Icon(Icons.keyboard_arrow_right);
    }
  }

  void _delete(Note note) async {
    int result = await databaseHelper.deleteNote(note.id);
    setState(() {
      noteList.remove(note);
    });

    if (result != 0) {
      updateListView();
    }
  }

  void navigateToDetail(Note note, String title) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteDetail(note, title);
    }));

    if (result == true) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList) {
        setState(() {
          this.noteList = noteList;
          this.count = noteList.length;
        });
      });
    });
  }
}
