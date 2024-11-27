import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'm_note.dart';

class NoteStorage {
  static const String _keyCurrentId = 'currentId';
  static const String _keyNoteIds = 'noteIds'; // 모든 노트 ID를 저장하는 키

  // 특정 노트 저장
  static Future<void> saveNote(Note note) async {
    final prefs = await SharedPreferences.getInstance();
    final noteKey = 'note_${note.id}';
    await prefs.setString(noteKey, jsonEncode(note.toJson()));

    // 저장된 노트의 ID를 목록에 추가
    final noteIds = await getAllNoteIds();
    if (!noteIds.contains(note.id)) {
      noteIds.add(note.id);
      await prefs.setStringList(
          _keyNoteIds, noteIds.map((id) => id.toString()).toList());
    }
  }

  // 특정 노트 로드
  static Future<Note?> loadNoteById(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final noteKey = 'note_$id';
    final noteJson = prefs.getString(noteKey);
    if (noteJson != null) {
      return Note.fromJson(jsonDecode(noteJson));
    }
    return null;
  }

  // 모든 노트 ID 로드
  static Future<List<int>> getAllNoteIds() async {
    final prefs = await SharedPreferences.getInstance();
    final noteIds = prefs.getStringList(_keyNoteIds);
    if (noteIds != null) {
      return noteIds.map((id) => int.parse(id)).toList();
    }
    return [];
  }

  // 모든 노트 로드
  static Future<List<Note>> loadNotes() async {
    final noteIds = await getAllNoteIds();
    final notes = <Note>[];
    for (final id in noteIds) {
      final note = await loadNoteById(id);
      if (note != null) {
        notes.add(note);
      }
    }
    return notes;
  }

  // 노트 삭제
  static Future<void> deleteNoteById(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final noteKey = 'note_$id';
    await prefs.remove(noteKey);

    // ID 목록에서 삭제
    final noteIds = await getAllNoteIds();
    noteIds.remove(id);
    await prefs.setStringList(
        _keyNoteIds, noteIds.map((id) => id.toString()).toList());
  }

  // 현재 ID 값 로드
  static Future<int> getCurrentId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyCurrentId) ?? 0; // 기본값 0
  }

  // 현재 ID 값 증가 및 저장
  static Future<void> incrementId() async {
    final prefs = await SharedPreferences.getInstance();
    int currentId = prefs.getInt(_keyCurrentId) ?? 0;
    currentId++;
    await prefs.setInt(_keyCurrentId, currentId);
  }
}
