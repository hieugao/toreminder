import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:characters/characters.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'models.freezed.dart';
part 'models.g.dart';

@freezed
class Note with _$Note {
  const Note._();
  factory Note({
    @Deprecated('Unused') required int id,
    @Default('') String title,
    @Default('') String body,
    @Default([]) List<NotionTag> categories,
    NotionTag? type,
    NotionTag? dueString,
    NotionTag? priority,
    DateTime? createdAt,
    @Default(false) bool isSynced,
    // TODO: Will be supported in the future.
    // final DateTime updatedAt,
  }) = _Note;

  factory Note.initial() => Note(id: Random().nextInt(10000));

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);

  bool isEmpty() => title.isEmpty;
}

@freezed
class NotionDatabase with _$NotionDatabase {
  const NotionDatabase._();

  @CustomListNotionTagConverter()
  factory NotionDatabase({
    // TODO: Fix this annoying warning.
    @JsonKey(name: 'Categories') @Default([]) List<NotionTag> categories,
    @JsonKey(name: 'Due string') @Default([]) List<NotionTag> dueStrings,
    @JsonKey(name: 'Priority') @Default([]) List<NotionTag> priorities,
    @JsonKey(name: 'Type') @Default([]) List<NotionTag> types,
    // TODO: Test an empty field.
  }) = _NotionDatabase;

  factory NotionDatabase.fromJson(Map<String, dynamic> json) => _$NotionDatabaseFromJson(json);

  Map<String, dynamic> toJsonCustom() {
    return {
      'properties': {
        'Categories': {
          'multi_select': {'options': categories}
        },
        'Due string': {
          'select': {'options': dueStrings}
        },
        'Priority': {
          'select': {'options': priorities}
        },
        'Type': {
          'select': {'options': types}
        }
      },
    };
  }
}

class CustomListNotionTagConverter implements JsonConverter<List<NotionTag>, Map<String, dynamic>> {
  const CustomListNotionTagConverter();

  @override
  List<NotionTag> fromJson(Map<String, dynamic> json) {
    final key = json.containsKey('select') ? 'select' : 'multi_select';

    return json[key]['options'].map<NotionTag>((tag) => NotionTag.fromJson(tag)).toList();
  }

  @Deprecated('NEVER USE THIS!!!')
  @override
  Map<String, dynamic> toJson(List<NotionTag> json) => {'options': jsonEncode(json)};
}

@freezed
class NotionTag with _$NotionTag {
  const NotionTag._();
  factory NotionTag({
    required String name,
    // required Color color,
    // TODO: Change to `notionColor` and create `color` getter.
    required NotionColors color,
  }) = _NotionTag;

  String get emoji {
    if (_hasEmoji(name)) {
      return name.characters.first;
    }

    return '';
  }

  String get content {
    if (_hasEmoji(name)) {
      return name.characters.skip(2).toString();
    }

    return name;
  }

  // Source: https://stackoverflow.com/a/62830894/16553764
  static bool _hasEmoji(String text) {
    final RegExp regExp = RegExp(
        r'(?:[\u2700-\u27bf]|(?:\ud83c[\udde6-\uddff]){2}|[\ud800-\udbff][\udc00-\udfff]|[\u0023-\u0039]\ufe0f?\u20e3|\u3299|\u3297|\u303d|\u3030|\u24c2|\ud83c[\udd70-\udd71]|\ud83c[\udd7e-\udd7f]|\ud83c\udd8e|\ud83c[\udd91-\udd9a]|\ud83c[\udde6-\uddff]|\ud83c[\ude01-\ude02]|\ud83c\ude1a|\ud83c\ude2f|\ud83c[\ude32-\ude3a]|\ud83c[\ude50-\ude51]|\u203c|\u2049|[\u25aa-\u25ab]|\u25b6|\u25c0|[\u25fb-\u25fe]|\u00a9|\u00ae|\u2122|\u2139|\ud83c\udc04|[\u2600-\u26FF]|\u2b05|\u2b06|\u2b07|\u2b1b|\u2b1c|\u2b50|\u2b55|\u231a|\u231b|\u2328|\u23cf|[\u23e9-\u23f3]|[\u23f8-\u23fa]|\ud83c\udccf|\u2934|\u2935|[\u2190-\u21ff])');

    if (text.contains(regExp)) {
      return true;
    }

    return false;
  }

  factory NotionTag.fromJson(Map<String, dynamic> json) => _$NotionTagFromJson(json);
}

enum NotionColors {
  defaultColor,
  gray,
  brown,
  orange,
  yellow,
  green,
  blue,
  purple,
  pink,
  red,
}

extension NotionColorsExtension on NotionColors {
  Color toColor() {
    switch (this) {
      case NotionColors.defaultColor:
        return Colors.white60;
      case NotionColors.gray:
        return Colors.grey;
      case NotionColors.brown:
        return Colors.brown;
      case NotionColors.orange:
        return Colors.orange;
      case NotionColors.yellow:
        return Colors.yellow;
      case NotionColors.green:
        return Colors.green;
      case NotionColors.blue:
        return Colors.blue;
      case NotionColors.purple:
        return Colors.purple;
      case NotionColors.pink:
        return Colors.pink;
      case NotionColors.red:
        return Colors.red;
    }
  }
}
