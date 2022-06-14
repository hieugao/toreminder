import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/extensions.dart';
import '../../../features/notion/providers/notion_providers.dart';
import '../../../features/notion/repositories/connectivity_repo.dart';
import '../../../features/todo/models.dart';
import '../../../features/todo/repository.dart';

typedef TodoListNSP = StateNotifierProvider<TodoList, List<Todo>>;

enum FilterType {
  today,
  week,
}

Provider<List<Todo>> filteredTodosProvider(FilterType type) => Provider<List<Todo>>((ref) {
      final todos = ref.watch(todosProvider);

      switch (type) {
        case FilterType.today:
          return todos.where((todo) => todo.dueDate.isToday).toList();
        case FilterType.week:
          return todos.where((todo) => todo.dueDate.isThisWeek).toList();
        default:
          return todos;
      }
    });

final todosProvider = TodoList.provider();

class TodoList extends StateNotifier<List<Todo>> {
  TodoList(this._reader, [List<Todo>? todos]) : super(todos ?? []) {
    if (todos == null) _init();
  }

  // TodoListNotifier.create(List<Todo> state, this._repo) : super(state);

  static TodoListNSP provider([List<Todo>? todos]) =>
      TodoListNSP((ref) => TodoList(ref.read, todos));

  final Reader _reader;

  Todo? _deleted;

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

enum SyncStatus {
  synced,
  syncing,
  unsynced,
  offline,
}

enum Action { create, archive }

final syncStatusProvider = FutureProvider<SyncStatus>((ref) {
  final sync = ref.watch(syncProvider);
  final network = ref.watch(connectivityServiceProvider.future);

  return sync.when(
    data: (data) async {
      if (await network == ConnectivityStatus.connected) {
        return SyncStatus.synced;
      } else {
        return SyncStatus.offline;
      }
    },
    loading: () => SyncStatus.syncing,
    error: (e, st) => SyncStatus.unsynced,
  );
});

final syncProvider = StateNotifierProvider<SyncNotifier, AsyncValue<void>>((ref) {
  return SyncNotifier(ref);
});

class SyncNotifier extends StateNotifier<AsyncValue<void>> {
  SyncNotifier(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  late final notionRepo = _ref.watch(notionRepositoryProvider);

  Future<String> sync(Todo todo, Action action) async {
    state = const AsyncValue.loading();

    try {
      switch (action) {
        case Action.create:
          final id = await notionRepo.createPage(todo);
          return id;
        case Action.archive:
          await notionRepo.archivePage(todo);
          return '';
      }
    } catch (e) {
      state = AsyncValue.error(e);
      throw Exception(e);
    } finally {
      state = const AsyncValue.data(null);
    }
  }
}

// No need `autoDispose` because it will run the whole time.
final connectivityServiceProvider = StreamProvider<ConnectivityStatus>((ref) {
  return WifiConnectivityRepository().connectivityStreamController.stream;
});

// FIXME: I think `connectivityStatus` shouldn't belong here.
// class SyncData {
//   SyncData([
//     this.status = SyncStatus.synced,
//     this.connectivity = ConnectivityStatus.disconnected,
//   ]);

//   final SyncStatus status;
//   final ConnectivityStatus connectivity;
// }