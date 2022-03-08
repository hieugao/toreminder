import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notion_capture/features/todo/repository.dart';

import '../../features/todo/models.dart';

final todoSharedPrefsRepositoryProvider =
    Provider<TodoRepository>((ref) => throw UnimplementedError());

final todoListProvider = StateNotifierProvider<TodoListViewModel, List<Todo>>((ref) {
  final _repo = ref.watch(todoSharedPrefsRepositoryProvider);
  return TodoListViewModel(_repo);
});

class TodoListViewModel extends StateNotifier<List<Todo>> {
  TodoListViewModel(this.repo) : super([]) {
    _loadTodos();
  }

  final TodoRepository repo;

  List<Todo> get todos => state;

  int get completed => todos.where((todo) => todo.done).length;

  Future<void> add(Todo todo) async {
    state = [...state, todo];
    await repo.save(state);
  }

  Future<void> remove(Todo todo) async {
    state = state.where((t) => t.id != todo.id).toList();
    await repo.save(state);
  }

  Future<void> _loadTodos() async {
    state = await repo.todos();
  }
}
