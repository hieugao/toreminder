import 'dart:convert';

import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'models.dart';

abstract class TodoRepository {
  Future<List<Todo>> todos();
  Future<void> add(Todo todo, List<Todo> todos);
  Future<void> remove(Todo todo, List<Todo> todos);
  Future<void> save(List<Todo> todos);
}

class TodoSharedPrefsRepository implements TodoRepository {
  const TodoSharedPrefsRepository(this._prefs);

  final SharedPreferences _prefs;

  String get _todosKey => 'todos';

  @override
  Future<void> save(List<Todo> todos) async {
    _prefs.setString(_todosKey, json.encode(todos));
  }

  @override
  Future<List<Todo>> todos() async {
    final todosJson = _prefs.getString(_todosKey) ?? '[]';
    return json.decode(todosJson).map<Todo>((todo) => Todo.fromJson(todo)).toList();
  }

  @override
  Future<void> add(_, __) async {
    throw UnimplementedError();
  }

  @override
  Future<void> remove(_, __) async {
    throw UnimplementedError();
  }
}

class TodoSqlRepository implements TodoRepository {
  TodoSqlRepository._();
  static final TodoSqlRepository _instance = TodoSqlRepository._();
  static Database? _db;

  static const String databaseName = 'todos';
  static const String tableName = 'todos';

  static TodoSqlRepository get instance => _instance;

  Future<Database> get database async => _db ?? await _init();

  @override
  Future<void> add(Todo todo, _) async {
    final db = await database;

    await db.insert(
      tableName,
      todo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> remove(Todo todo, _) async {
    final db = await database;

    await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  @override
  Future<List<Todo>> todos() async {
    // Get a reference to the database.
    final db = await database;

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query(tableName);

    // Convert the List<Map<String, dynamic> into a List<Todo>.
    return List.generate(maps.length, (i) {
      return Todo(
        id: maps[i]['id'],
        title: maps[i]['title'],
        content: maps[i]['content'],
        dueDate: DateTime.parse(maps[i]['dueDate']),
      );
    });
  }

  @override
  Future<void> save(_) async {
    throw UnimplementedError();
  }

  Future<Database> _init() async {
    return await openDatabase(
      join(await getDatabasesPath(), '$databaseName.db'),
      onCreate: (db, version) {
        final stmt = '''CREATE TABLE IF NOT EXISTS $tableName (
            id TEXT PRIMARY KEY,
            title TEXT,
            content TEXT,
            dueDate TEXT
        )'''
            .trim()
            .replaceAll(RegExp(r'[\s]{2,}'), ' ');
        return db.execute(stmt);
      },
      version: 1,
    );
  }
}
