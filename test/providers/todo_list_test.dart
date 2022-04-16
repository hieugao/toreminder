import 'package:flutter_test/flutter_test.dart';

import 'package:riverpod/riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:toreminder/features/todo/models.dart';
import 'package:toreminder/features/todo/repository.dart';
import 'package:toreminder/features/todo/providers.dart';

class MockTodoRepository extends Mock implements TodoRepository {}

final todos = [
  Todo(id: '1', title: 'Buy milk', dueDate: DateTime.now()),
  Todo(id: '2', title: 'Buy eggs', dueDate: DateTime.now()),
  Todo(id: '3', title: 'Buy cat food', dueDate: DateTime.now()),
];

final newTodo = Todo(id: '4', title: 'Clean living room', dueDate: DateTime.now());

final mocktodoListProvider = TodoListNotifier.provider(List.from(todos));

class Listener extends Mock {
  void call(List<Todo>? previous, List<Todo> value);
}

void main() {
  late MockTodoRepository mockTodoRepository;

  setUp(() {
    mockTodoRepository = MockTodoRepository();
  });

  ProviderContainer overrideValue() => ProviderContainer(
        overrides: [
          todoRepositoryProvider.overrideWithValue(mockTodoRepository),
          todoListProvider.overrideWithProvider(mocktodoListProvider),
        ],
      );

  void arrangeTodoRepository() {
    when(() => mockTodoRepository.save(any())).thenAnswer((_) async => Future.value());
  }

  group('Todo List Notifier', () {
    test('- Defaults to "todos" and notify listeners when value changes', () {
      final container = overrideValue();
      addTearDown(container.dispose);
      final listener = Listener();

      // Observe a provider and spy the changes.
      container.listen<List<Todo>>(todoListProvider, listener, fireImmediately: true);

      // The listener is called immediately with `todos` (the default value).
      verify(() => listener(null, todos)).called(1);
      verifyNoMoreInteractions(listener);

      // Add a todo.
      arrangeTodoRepository();
      container.read(todoListProvider.notifier).add(newTodo);

      // Check.
      verify(() => listener(todos, [newTodo, ...todos])).called(1);
      verifyNoMoreInteractions(listener);
    });

    test('- Add', () {
      final container = overrideValue();
      arrangeTodoRepository();
      container.read(todoListProvider.notifier).add(newTodo);
      expect(container.read(todoListProvider).contains(newTodo), true);
    });

    test('- Update At', () {
      final container = overrideValue();
      arrangeTodoRepository();
      container.read(todoListProvider.notifier).updateAt(0, newTodo);
      expect(container.read(todoListProvider).elementAt(0) != todos[0], true);
    });

    test('- Remove At', () {
      final container = overrideValue();
      arrangeTodoRepository();
      container.read(todoListProvider.notifier).removeAt(0);
      expect(container.read(todoListProvider).contains(todos[0]), false);
    });
  });

  // TODO: Add tests for Todo Repository.
  group('Todo Repository', () {});
}
