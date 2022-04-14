import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
// import 'package:mocktail/mocktail.dart' show registerFallbackValue;
import 'package:riverpod/riverpod.dart';
import 'package:toreminder/features/notion/providers/notion_providers.dart';
import 'package:toreminder/features/notion/repositories/notion_repo.dart';

import 'todo_list_test.dart';

// class MockHttpClient extends Mock implements http.Client {}

// class MockResponse extends Mock implements http.Response {}

class FakeUri extends Fake implements Uri {}

void main() {
  // late http.Client httpClient;
  late http.Client client;
  late NotionRepository repo;

  // setUpAll(() {
  //   registerFallbackValue(FakeUri());
  // });

  setUp(() {
    // httpClient = MockHttpClient();
    client = MockClient((request) async {
      return http.Response('', 404);
    });
    repo = NotionRepository(client);
  });

  ProviderContainer overrideValue() => ProviderContainer(overrides: [
        notionRepositoryProvider.overrideWithValue(repo),
      ]);

  test('Push todo to Notion Database Failed', () async {
    dotenv.testLoad(fileInput: File('.env').readAsStringSync());

    final container = overrideValue();

    // final response = MockResponse();

    // when(() => client.post(any(), body: any(named: "body")))
    // .thenAnswer((_) async => Future.value(http.Response("", 200)));
    // when(() => response.statusCode).thenReturn(200);
    // when(() => repo.createNotionPage(newTodo)).thenAnswer((_) async {});

    expect(
      () => container.read(notionRepositoryProvider).createNotionPage(newTodo),
      throwsA(isA<ToreminderErr>()),
    );
  });
}
