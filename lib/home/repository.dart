import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../create_note/models.dart';

class HomeRepository {
  static Future<void> saveNotes(List<Note> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = json.encode(notes);
    prefs.setString('notes', notesJson);
  }

  static Future<List<Note>> getNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getString('notes');
    if (notesJson == null) {
      return [];
    }
    final notes = json.decode(notesJson);
    return notes.map<Note>((note) => Note.fromJson(note)).toList();
  }
}
