import 'dart:convert';
import 'dart:io' show HttpHeaders, SocketException;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../../todo/models.dart';

class ToreminderErr implements Exception {
  ToreminderErr(this.term);

  final String term;

  @override
  String toString() => 'Toreminder Error: $term';
}

class NotionRepository {
  NotionRepository([http.Client? httpClient]) : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  static const String _baseUrl = 'https://api.notion.com/v1/';
  static const String _pagesPath = 'pages/';

  Future<String> createPage(Todo todo) async {
    const url = _baseUrl + _pagesPath;

    try {
      final response = await _httpClient.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Notion-Version': '${dotenv.env['NOTION_VERSION']}',
          HttpHeaders.authorizationHeader: 'Bearer ${dotenv.env['TOKEN']}',
        },
        body: json.encode(_creatingPayload(todo)),
      );

      if (response.statusCode != 200) {
        throw ToreminderErr('Failed to create page! - ${response.body}');
      }

      return json.decode(response.body)['id'];
    } on SocketException catch (e) {
      throw Exception('Socket Error: $e');
    } on Error catch (e) {
      throw Exception('General Error: $e');
    }
  }

  Future<void> archivePage(Todo todo) async {
    final url = _baseUrl + _pagesPath + '${todo.notionId}';

    try {
      final response = await _httpClient.patch(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Notion-Version': '${dotenv.env['NOTION_VERSION']}',
          HttpHeaders.authorizationHeader: 'Bearer ${dotenv.env['TOKEN']}',
        },
        body: json.encode(_archivingPayload(todo)),
      );

      if (response.statusCode != 200) {
        throw ToreminderErr('Failed to archive page! - ${response.body}');
      }
    } on SocketException catch (e) {
      throw Exception('Socket Error: $e');
    } on Error catch (e) {
      throw Exception('General Error: $e');
    }
  }

  static Map<String, dynamic> _creatingPayload(Todo todo) {
    return {
      'parent': {
        'database_id': dotenv.env['DB_ID'],
      },
      'properties': {
        'Name': {
          'title': [
            {
              'text': {
                'content': todo.title,
              }
            },
          ]
        },
      },
    };
  }

  static Map<String, dynamic> _archivingPayload(Todo todo) {
    return {
      'archived': true,
    };
  }
}
