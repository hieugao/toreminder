import 'package:flutter_test/flutter_test.dart';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';

import 'package:riverpod/riverpod.dart';
import 'package:toreminder/features/notion/providers/notion_providers.dart';
import 'package:toreminder/features/notion/repositories/notion_repo.dart';
import 'package:toreminder/features/sync/providers.dart';
import 'package:toreminder/features/todo/providers.dart';

import 'todo_list_test.dart';

class Listener extends Mock {
  void call(AsyncValue<SyncStatus>? previous, AsyncValue<SyncStatus> value);
}

void main() {
  late MockTodoRepository mockTodoRepository;
  late http.Client client;
  late NotionRepository repo;

  setUp(() {
    mockTodoRepository = MockTodoRepository();
    client = MockClient((request) async => http.Response('', 200));
    repo = NotionRepository(client);
  });

  ProviderContainer overrideValue() => ProviderContainer(overrides: [
        todoRepositoryProvider.overrideWithValue(mockTodoRepository),
        notionRepositoryProvider.overrideWithValue(repo),
        todoListProvider
            .overrideWithValue(TodoListNotifier.create(List.from(todos), mockTodoRepository)),
      ]);

  void arrangeTodoRepository() {
    when(() => mockTodoRepository.save(any())).thenAnswer((_) async => Future.value());
  }

  test('Defaults to loading and notify listeners when value changes', () {
    final container = overrideValue();
    addTearDown(container.dispose);
    final listener = Listener();

    container.listen<AsyncValue<SyncStatus>>(syncProvider, listener, fireImmediately: true);

    verify(() => listener(null, const AsyncLoading())).called(1);
    verifyNoMoreInteractions(listener);

    // expect(container.read(todoListProvider).length, todos.length);

    // // Sync a new todo.
    // arrangeTodoRepository();
    // container.read(todoListProvider.notifier).add(newTodo);
    // verify(() => listener(const AsyncLoading(), const AsyncData(SyncStatus.synced))).called(1);
    // verifyNoMoreInteractions(listener);
  });
}
