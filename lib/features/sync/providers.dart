import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../notion/providers/notion_providers.dart';
import '../todo/providers.dart';

final weatherProvider = FutureProvider<void>((ref) async {
  final todos = ref.watch(todoListProvider);
  final todoRepo = ref.read(todoRepositoryProvider);
  final notionRepo = ref.read(notionRepositoryProvider);

  todoRepo.save(todos);
  notionRepo.createNotionPage(todos.first);
});
