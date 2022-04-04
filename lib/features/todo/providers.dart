import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/extensions.dart';
import '../../../features/todo/models.dart';
import '../../../features/todo/repository.dart';

enum TodoFilter {
  none,
  today,
  week,
}

final todoFilterProvider = StateProvider((ref) => TodoFilter.none);

final filteredTodoListProvider = Provider<List<Todo>>((ref) {
  final filter = ref.watch(todoFilterProvider);
  final todos = ref.watch(todoListProvider);

  switch (filter) {
    case TodoFilter.none:
      return todos;
    case TodoFilter.today:
      return todos.where((todo) => todo.dueDate.isToday).toList();
    case TodoFilter.week:
      return todos.where((todo) => todo.dueDate.isThisWeek).toList();
  }
});

final todoListProvider = StateNotifierProvider<TodoListNotifier, List<Todo>>((ref) {
  final _repo = ref.watch(todoRepositoryProvider);
  // final _todos = ref.watch(todoListFutureProvider);
  return TodoListNotifier(_repo);
  // return TodoListNotifier(_todos.asData?.value ?? [], _repo);
});

// final todoListFutureProvider = FutureProvider<List<Todo>>((ref) async {
//   final _repo = ref.watch(todoRepositoryProvider);
//   return await _repo.todos();
// });

final todoRepositoryProvider = Provider<TodoRepository>((ref) => throw UnimplementedError());

class TodoListNotifier extends StateNotifier<List<Todo>> {
  TodoListNotifier(this._repo) : super([]) {
    _load();
  }

  TodoListNotifier.create(List<Todo> state, this._repo) : super(state);

  final TodoRepository _repo;

  List<Todo> get todos => state;

  Future<void> add(Todo todo) async {
    state = [...state, todo];
    await _repo.save(state);
  }

  Future<void> updateAt(int index, Todo todo) async {
    var newState = state;
    newState[index] = todo;
    state = [...newState];
    await _repo.save(state);
  }

  Future<void> removeAt(int index) async {
    var newState = state;
    newState.removeAt(index);
    state = [...newState];
    await _repo.save(state);
  }

  Future<void> _load() async {
    state = await _repo.todos();
  }
}
