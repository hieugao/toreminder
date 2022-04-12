import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/extensions.dart';
import '../../../features/todo/models.dart';
import '../../../features/todo/repository.dart';

final todayTodosFilteredProvider = Provider<List<Todo>>((ref) {
  final todos = ref.watch(todoListProvider);
  return todos.where((todo) => todo.dueDate.isToday).toList();
});

final weekTodosFilteredProvider = Provider<List<Todo>>((ref) {
  final todos = ref.watch(todoListProvider);
  return todos.where((todo) => todo.dueDate.isThisWeek).toList();
});

final todoListProvider = StateNotifierProvider<TodoListNotifier, List<Todo>>((ref) {
  final _repo = ref.watch(todoRepositoryProvider);
  return TodoListNotifier(_repo);
});

final todoRepositoryProvider = Provider<TodoRepository>((ref) => throw UnimplementedError());

class TodoListNotifier extends StateNotifier<List<Todo>> {
  TodoListNotifier(this._repo) : super([]) {
    _load();
  }

  TodoListNotifier.create(List<Todo> state, this._repo) : super(state);

  final TodoRepository _repo;

  Todo? _deleted;

  List<Todo> get todos => state;

  Future<void> add(Todo todo) async {
    state = [...state, todo];
    await _repo.save(state);
  }

  Future<void> updateAt(int index, Todo todo) async {
    var newState = state.toList();
    newState[index] = todo;
    state = newState;
    await _repo.save(state);
  }

  Future<void> removeAt(int index) async {
    var newState = state.toList();
    _deleted = newState[index];
    newState.removeAt(index);
    state = newState;
    await _repo.save(state);
  }

  Future<void> undo(int index) async {
    var newState = state.toList();
    newState.insert(index, _deleted!);
    state = newState;
    await _repo.save(state);
  }

  Future<void> _load() async {
    state = await _repo.todos();
  }
}
