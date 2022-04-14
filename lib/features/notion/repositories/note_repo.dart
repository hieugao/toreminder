// import 'package:shared_preferences/shared_preferences.dart';

// class NoteRepository {
//   NoteRepository(this._prefs);

//   final SharedPreferences _prefs;

//   Future<void> saveNotes(List<Note> notes) async {
//     _prefs.setString('notes', json.encode(notes));
//   }

//   Future<List<Note>> loadNotes() async {
//     // FIXME: https://stackoverflow.com/questions/54466639/json-decode-unexpected-end-of-input-at-character-1
//     final notesJson = _prefs.getString('notes') ?? '[]';
//     return json.decode(notesJson).map<Note>((note) => Note.fromJson(note)).toList();
//   }
// }