import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toreminder/features/notion/repositories/notion_repo.dart';

import '../../../common/extensions.dart';
import '../../../features/todo/models.dart';
import '../../../features/todo/repository.dart';
import '../notion/providers/notion_providers.dart';

final todayTodosFilteredProvider = Provider<List<Todo>>((ref) {
  final todos = ref.watch(todoListProvider);
  return todos.where((todo) => todo.dueDate.isToday).toList();
});

final weekTodosFilteredProvider = Provider<List<Todo>>((ref) {
  final todos = ref.watch(todoListProvider);
  return todos.where((todo) => todo.dueDate.isThisWeek).toList();
});

final todoListProvider = StateNotifierProvider<TodoListNotifier, List<Todo>>((ref) {
  return TodoListNotifier(ref.watch(todoRepositoryProvider));
});

final todoRepositoryProvider = Provider<TodoRepository>((ref) => throw UnimplementedError());

class TodoListNotifier extends StateNotifier<List<Todo>> {
  TodoListNotifier(this._repo, [List<Todo>? todos]) : super(todos ?? []) {
    if (todos != null) _load();
  }

  TodoListNotifier.create(List<Todo> state, this._repo) : super(state);

  static provider(List<Todo>? todos) => StateNotifierProvider<TodoListNotifier, List<Todo>>(
      (ref) => TodoListNotifier(ref.watch(todoRepositoryProvider), todos));

  final TodoRepository _repo;

  Todo? _deleted;

  List<Todo> get todos => state;

  void add(Todo todo) {
    state = [todo, ...state];
  }

  void updateAt(int index, Todo todo) {
    var newState = state.toList();
    newState[index] = todo;
    state = newState;
  }

  void removeAt(int index) {
    var newState = state.toList();
    _deleted = newState[index];
    newState.removeAt(index);
    state = newState;
  }

  void undo(int index) {
    var newState = state.toList();
    newState.insert(index, _deleted!);
    state = newState;
  }

  Future<void> _load() async {
    state = await _repo.todos();
  }
}
