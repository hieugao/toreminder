import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'models.freezed.dart';
part 'models.g.dart';

@freezed
class Todo with _$Todo {
  const Todo._();
  factory Todo({
    required String id,
    required String title,
    @Default('') String content,
    required DateTime dueDate,
    @Default(false) bool done,
    @Default(false) isSynced,
    String? notionId,
  }) = _Todo;

  factory Todo.initial(String title, String content, DateTime dueDate) =>
      Todo(id: UniqueKey().toString(), title: title, content: content, dueDate: dueDate);

  factory Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);
}
