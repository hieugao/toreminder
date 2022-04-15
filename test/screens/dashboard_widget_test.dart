import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:toreminder/app.dart';
import 'package:toreminder/features/notion/providers/notion_providers.dart';
import 'package:toreminder/features/notion/repositories/notion_repo.dart';
import 'package:toreminder/features/onboarding/providers.dart';
import 'package:toreminder/features/todo/providers.dart';
import 'package:toreminder/screens/dashboard/dashboard_screen.dart';

import '../providers/todo_list_test.dart';

class MockSharedPrefs extends Mock implements SharedPreferences {}

void main() {
  final addTodo = find.byKey(addTodoKey);

  late MockTodoRepository mockTodoRepository;
  late http.Client client;
  late NotionRepository repo;

  setUp(() {
    mockTodoRepository = MockTodoRepository();
    client = MockClient((request) async => http.Response('', 200));
    repo = NotionRepository(client);
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        onBoardingProvider.overrideWithValue(OnBoardingNotifier.create(true, MockSharedPrefs())),
        todoListProvider.overrideWithValue(TodoListNotifier.create(
          List.from(todos),
          mockTodoRepository,
        )),
        todoRepositoryProvider.overrideWithValue(mockTodoRepository),
        notionRepositoryProvider.overrideWithValue(repo),
      ],
      child: const MyApp(),
    );
  }

  void arrangeTodoRepository() {
    when(() => mockTodoRepository.save(any())).thenAnswer((_) async => Future.value());
  }

  testWidgets('Todos are displayed', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    for (final todo in todos) {
      expect(find.text(todo.title), findsOneWidget);
    }

    expect(
      find.descendant(
        of: find.byKey(todayTodoCountKey),
        matching: find.text('0/3 todos'),
      ),
      findsOneWidget,
    );

    // await expectLater(find.byType(MyApp), matchesGoldenFile('initial_state.png'));
  });

  testWidgets('Add a todo', (tester) async {
    arrangeTodoRepository();

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();

    await tester.enterText(addTodo, newTodo.title);

    expect(
      find.descendant(
        of: addTodo,
        matching: find.text(newTodo.title),
      ),
      findsOneWidget,
    );

    await tester.ensureVisible(find.byKey(addButtonKey));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(addButtonKey));
    await tester.pump();

    expect(find.text('0/4 todos'), findsOneWidget);

    // await expectLater(find.byType(MyApp), matchesGoldenFile('new_todo.png'));
  });

  // TODO: Todo Checkbox.

  // testWidgets('Remove a todo', (tester) async {
  //   arrangeTodoRepository();

  //   await tester.pumpWidget(createWidgetUnderTest());
  //   await tester.pump();

  //   await tester.ensureVisible(find.byKey(addButtonKey));
  //   await tester.pumpAndSettle();
  //   await tester.tap(find.byKey(addButtonKey));
  //   await tester.pump();

  //   expect(find.text('0/2 todos'), findsOneWidget);
  // });
}
