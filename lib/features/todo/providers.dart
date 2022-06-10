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

final todoRepositoryProvider =
    Provider<TodoSharedPrefsRepository>((ref) => throw UnimplementedError());

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
    try {
      final id = await _syncNotifier.sync(todo, Action.create);
      todo = todo.copyWith(notionId: id, isSynced: true);
    } catch (e) {
      print(e);
    } finally {
      updateAt(0, todo);
    }
  }

  void updateAt(int index, Todo todo) {
    var newState = state.toList();
    newState[index] = todo;
    state = newState;
    _todoRepo.save(state);
  }

  Future<void> removeAt(int index) async {
    var newState = state.toList();
    _deleted = newState[index];
    newState.removeAt(index);
    state = newState;

    try {
      await _syncNotifier.sync(_deleted!, Action.archive);
    } catch (e) {
      print(e);
    } finally {
      _todoRepo.save(state);
    }
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
