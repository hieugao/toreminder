import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
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
  void call(AsyncValue<void>? previous, AsyncValue<void> value);
}

void main() {
  late MockTodoRepository mockTodoRepo;
  late http.Client client;
  late NotionRepository notionRepo;

  setUp(() {
    mockTodoRepo = MockTodoRepository();
    client = MockClient((request) async => http.Response(
          '{"id": "e7f60d5b-9d47-4d9d-ba09-1c1bb173d75b"}',
          200,
        ));
    notionRepo = NotionRepository(client);
  });

  ProviderContainer overrideValue() => ProviderContainer(overrides: [
        todoRepositoryProvider.overrideWithValue(mockTodoRepo),
        notionRepositoryProvider.overrideWithValue(notionRepo),
        todoListProvider.overrideWithProvider(mocktodoListProvider),
      ]);

  void arrangeTodoRepository() {
    when(() => mockTodoRepo.save(any())).thenAnswer((_) async => Future.value());
  }

  test('Defaults to loading and notify listeners when value changes', () async {
    dotenv.testLoad(fileInput: File('.env').readAsStringSync());

    final container = overrideValue();
    addTearDown(container.dispose);
    final listener = Listener();

    container.listen<AsyncValue<void>>(syncProvider, listener, fireImmediately: true);

    verify(() => listener(null, const AsyncValue.data(null))).called(1);
    verifyNoMoreInteractions(listener);

    expect(container.read(todoListProvider).length, todos.length);

    // Sync a new todo:
    arrangeTodoRepository();

    // Loading state.
    final future = container.read(todoListProvider.notifier).add(newTodo);
    verify(() => listener(const AsyncValue.data(null), const AsyncLoading())).called(1);
    verifyNoMoreInteractions(listener);

    // Success state.
    await future;
    verify(() => listener(const AsyncLoading(), const AsyncValue.data(null))).called(1);
    verifyNoMoreInteractions(listener);
  });
}
