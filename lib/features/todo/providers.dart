import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/extensions.dart';
import '../../../features/todo/models.dart';
import '../../../features/todo/repository.dart';
import '../sync/providers.dart';

typedef TodoListNSP = StateNotifierProvider<TodoListNotifier, List<Todo>>;

final todayTodosFilteredProvider = Provider<List<Todo>>((ref) {
  final todos = ref.watch(todoListProvider);
  return todos.where((todo) => todo.dueDate.isToday).toList();
});

final weekTodosFilteredProvider = Provider<List<Todo>>((ref) {
  final todos = ref.watch(todoListProvider);
  return todos.where((todo) => todo.dueDate.isThisWeek).toList();
});

final todoListProvider = TodoListNotifier.provider();

final todoRepositoryProvider = Provider<TodoRepository>((ref) => throw UnimplementedError());

class TodoListNotifier extends StateNotifier<List<Todo>> {
  TodoListNotifier(this._reader, [List<Todo>? todos]) : super(todos ?? []) {
    if (todos == null) _init();
  }

  // TodoListNotifier.create(List<Todo> state, this._repo) : super(state);

  static TodoListNSP provider([List<Todo>? todos]) =>
      TodoListNSP((ref) => TodoListNotifier(ref.read, todos));

  final Reader _reader;

  Todo? _deleted;

  List<Todo> get todos => state;

  late final _todoRepo = _reader(todoRepositoryProvider);
  late final _syncNotifier = _reader(syncProvider.notifier);

  Future<void> add(Todo todo) async {
    state = [todo, ...state];
    _todoRepo.save(state);
    await _syncNotifier.sync(todo, Action.create);
  }

  void updateAt(int index, Todo todo) {
    var newState = state.toList();
    newState[index] = todo;
    state = newState;
    _todoRepo.save(state);
  }

  void removeAt(int index) {
    var newState = state.toList();
    _deleted = newState[index];
    newState.removeAt(index);
    state = newState;
    _todoRepo.save(state);
  }

  void undo(int index) {
    var newState = state.toList();
    newState.insert(index, _deleted!);
    state = newState;
    _todoRepo.save(state);
  }

  Future<void> _init() async {
    state = await _todoRepo.todos();
  }
}
