import 'dart:convert';
import 'dart:io' show HttpHeaders;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import './models.dart';

class CreateNoteRepository {
  static const String _baseUrl = 'https://api.notion.com/v1/';
  static const String _databaseUrl = 'databases/';

  static Future<NotionDatabase> fetchDatabase() async {
    final url = '$_baseUrl$_databaseUrl${dotenv.env['DB_ID']}';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Notion-Version': '${dotenv.env['NOTION_VERSION']}',
        'Content-Type': 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer ${dotenv.env['TOKEN']}',
      },
    );

    if (response.statusCode == 200) {
      // return await openDatabase(path, version: 1, onCreate: (Database db, int version) async {
      //   await db.execute(
      //       'CREATE TABLE notes(id TEXT PRIMARY KEY, title TEXT, content TEXT, createdAt TEXT, updatedAt TEXT)');
      // });
      return NotionDatabase.fromJson(json.decode(response.body)['properties']);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to retrieve Inbox Database!');
    }
  }

  static Future<void> saveDatabase(NotionDatabase db) async {
    final prefs = await SharedPreferences.getInstance();
    final dbJson = jsonEncode(db.toJsonCustom());
    prefs.setString('database', dbJson);
  }

  static Future<NotionDatabase> loadDatabase() async {
    final prefs = await SharedPreferences.getInstance();
    final dbJson = prefs.getString('database');
    if (dbJson == null) {
      return NotionDatabase();
    }
    final db = json.decode(dbJson);
    final data = NotionDatabase.fromJson(db['properties']);
    return data;
  }
}
