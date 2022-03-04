import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notion_capture/features/todo/repository.dart';

import '../../features/todo/models.dart';

final todoSharedPrefsRepositoryProvider =
    Provider<TodoRepository>((ref) => throw UnimplementedError());

final todoListProvider =
    StateNotifierProvider<TodoListViewModel, List<Todo>>((ref) {
  final _repo = ref.watch(todoSharedPrefsRepositoryProvider);
  return TodoListViewModel(_repo);
});

class TodoListViewModel extends StateNotifier<List<Todo>> {
  TodoListViewModel(this.repo) : super([]) {
    _loadTodos();
  }

  final TodoRepository repo;

  List<Todo> get todos => state;

  Future<void> add(Todo todo) async {
    state = [...state, todo];
    await repo.add(todo, state);
  }

  Future<void> _loadTodos() async {
    state = await repo.todos();
  }
}
