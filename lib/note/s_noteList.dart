import 'package:flutter/material.dart';

import '../node/s_main.dart';
import 'm_note.dart';
import 'storage_node.dart';

class NoteListScreen extends StatefulWidget {
  @override
  _NoteListScreenState createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  List<Note> notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    notes = await NoteStorage.loadNotes();
    setState(() {});
  }

  Future<void> _addNote() async {
    // 새로운 ID 생성
    final newId = await NoteStorage.getCurrentId();
    final newNote = Note(
      title: 'New Note ${notes.length + 1}',
      content: '',
      id: newId,
    );

    // ID 증가
    await NoteStorage.incrementId();
    await NoteStorage.saveNote(newNote);
    setState(() {});
  }

  void _openNote(Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MainScreen(note: note),
      ),
    ).then((_) => _loadNotes());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notes')),
      body: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(notes[index].title),
            onTap: () => _openNote(notes[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _addNote,
      ),
    );
  }
}
