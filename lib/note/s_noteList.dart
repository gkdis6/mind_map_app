import 'package:flutter/material.dart';
import 'package:mind_map_app/node/m_node.dart';

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
      node: NodeModel(id: '0', title: 'New Note ${notes.length + 1}'),
      id: newId,
    );

    // ID 증가
    await NoteStorage.incrementId();
    await NoteStorage.saveNote(newNote);
    setState(() {
      notes.add(newNote);
    });
  }

  void _openNote(Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MainScreen(note: note),
      ),
    ).then((_) => _loadNotes());
  }

  void _deleteNote(Note note) {
    NoteStorage.deleteNoteById(note.id);
    setState(() {
      notes.remove(note);
    });
  }

  void _editNoteName(Note note) async {
    TextEditingController _editController =
        TextEditingController(text: note.title);

    final updatedTitle = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Note Name'),
          content: TextField(
            controller: _editController,
            decoration: InputDecoration(
              labelText: 'Note Name',
              hintText: 'Enter new name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null), // 취소
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final newName = _editController.text.trim();
                if (newName.isNotEmpty) {
                  Navigator.pop(context, newName); // 입력된 이름 반환
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );

    if (updatedTitle != null && updatedTitle.isNotEmpty) {
      // 노트 이름 업데이트
      note.title = updatedTitle;
      await NoteStorage.saveNote(note); // 변경사항 저장
      setState(() {});
    }
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
            trailing: Row(
              mainAxisSize: MainAxisSize.min, // Row의 크기를 최소화
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _editNoteName(notes[index]),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteNote(notes[index]),
                ),
              ],
            ),
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
