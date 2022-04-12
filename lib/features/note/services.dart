// import 'dart:async';
// import 'dart:convert';
// import 'dart:io' show HttpHeaders, SocketException;

// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// import 'models.dart';

// final noteServiceProvider = Provider<NoteService>((ref) => throw UnimplementedError());
// final notionDatabaseServiceProvider = Provider<NotionDatabaseService>((ref) => throw UnimplementedError());

// class NoteService {
//   NoteService(this._prefs);

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

// class NotionDatabaseService {
//   NotionDatabaseService(this._prefs);

//   final SharedPreferences _prefs;

//   static const String _baseUrl = 'https://api.notion.com/v1/';
//   static const String _dbPath = 'databases/';
//   static const String _pagesPath = 'pages/';

//   Future<NotionDatabase> fetchDatabase() async {
//     final url = '$_baseUrl$_dbPath${dotenv.env['DB_ID']}';

//     // Source: https://stackoverflow.com/a/61037635
//     // TODO: Create a base (reusable way) - https://stackoverflow.com/questions/60648984
//     // TODO: Or using Dio.
//     try {
//       final response = await http.get(
//         Uri.parse(url),
//         headers: {
//           'Notion-Version': '${dotenv.env['NOTION_VERSION']}',
//           'Content-Type': 'application/json',
//           HttpHeaders.authorizationHeader: 'Bearer ${dotenv.env['TOKEN']}',
//         },
//       );

//       if (response.statusCode == 200) {
//         return NotionDatabase.fromJson(json.decode(response.body)['properties']);
//       } else {
//         throw Exception('Failed to retrieve Inbox Database!');
//       }
//     } on SocketException catch (e) {
//       throw Exception('Socket Error: $e');
//     } on Error catch (e) {
//       throw Exception('General Error: $e');
//     }
//   }

//   Future<void> saveDatabase(NotionDatabase db) async {
//     _prefs.setString('database', jsonEncode(db.toJsonCustom()));
//   }

//   Future<NotionDatabase> loadDatabase() async {
//     final dbJson = _prefs.getString('database');
//     if (dbJson == null) {
//       return NotionDatabase();
//     }
//     final db = json.decode(dbJson);
//     final data = NotionDatabase.fromJson(db['properties']);
//     return data;
//   }

//   static Future<bool> createNotionPage(Note note) async {
//     const url = _baseUrl + _pagesPath;

//     try {
//       final response = await http.post(
//         Uri.parse(url),
//         headers: {
//           'Content-Type': 'application/json',
//           'Notion-Version': '${dotenv.env['NOTION_VERSION']}',
//           HttpHeaders.authorizationHeader: 'Bearer ${dotenv.env['TOKEN']}',
//         },
//         body: json.encode(_getPayload(note)),
//       );

//       if (response.statusCode == 200) {
//         return true;
//       } else {
//         throw Exception('Failed to create page!');
//       }
//     } on SocketException catch (e) {
//       throw Exception('Socket Error: $e');
//     } on Error catch (e) {
//       throw Exception('General Error: $e');
//     }
//   }

//   static Map<String, dynamic> _getPayload(Note note) {
//     return {
//       'parent': {
//         'database_id': dotenv.env['DB_ID'],
//       },
//       'properties': {
//         'Name': {
//           'title': [
//             {
//               'text': {
//                 'content': note.title,
//               }
//             },
//           ]
//         },
//         // note.categories.isNotEmpty ? 'Categories' : {'multi_select': note.categories}: {},
//         // Conditionally add to Map: https://stackoverflow.com/a/65920396/16553764
//         if (note.labels.isNotEmpty)
//           "Labels": {
//             "multi_select": note.labels,
//           },
//         if (note.dueString != null)
//           'Due string': {
//             'select': note.dueString,
//           },
//         if (note.priority != null)
//           'Priority': {
//             'select': note.priority,
//           },
//         // if (note.type != null)
//         //   'Type': {
//         //     'select': note.type,
//         //   },
//       },
//       if (note.body.isNotEmpty)
//         'children': [
//           {
//             "object": "block",
//             "type": "paragraph",
//             "paragraph": {
//               "text": [
//                 {
//                   "type": "text",
//                   "text": {
//                     'content': note.body,
//                     // "content": "Lacinato kale is a variety of kale with a long tradition in Italian cuisine, especially that of Tuscany. It is also known as Tuscan kale, Italian kale, dinosaur kale, kale, flat back kale, palm tree kale, or black Tuscan palm.",
//                     // "link": {
//                     //   "url": "https://en.wikipedia.org/wiki/Lacinato_kale"
//                     // }
//                   }
//                 }
//               ]
//             }
//           }
//         ],
//     };
//   }
// }
