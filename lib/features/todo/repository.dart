import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

class TodoSharedPrefsRepository {
  const TodoSharedPrefsRepository(this._prefs);

  final SharedPreferences _prefs;

  String get _todosKey => 'todos';

  Future<void> save(List<Todo> todos) async {
    _prefs.setString(_todosKey, json.encode(todos));
  }

  Future<List<Todo>> todos() async {
    final todosJson = _prefs.getString(_todosKey) ?? '[]';
    return json.decode(todosJson).map<Todo>((todo) => Todo.fromJson(todo)).toList();
  }
}
