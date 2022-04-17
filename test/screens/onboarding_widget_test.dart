import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockingjay/mockingjay.dart';
import 'package:mocktail/mocktail.dart';

import 'package:toreminder/app.dart';
// import 'package:toreminder/common/constants.dart';
import 'package:toreminder/features/onboarding/providers.dart';
import 'package:toreminder/features/todo/providers.dart';
import 'package:toreminder/screens/dashboard/dashboard_screen.dart';

import '../common.dart';
import '../providers/todo_list_test.dart';
import 'dashboard_widget_test.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class FakeRouteDynamic extends Fake implements Route<dynamic> {}

Widget createWidgetUnderTest() => createAppWidget([]);

void main() {
  late NavigatorObserver mockNavigationObserver;
  late MockSharedPrefs mockSharedPrefs;
  late MockTodoRepository mockTodoRepository;

  setUpAll(() async {
    registerFallbackValue(FakeRouteDynamic());
    TestWidgetsFlutterBinding.ensureInitialized();
    mockNavigationObserver = MockNavigatorObserver();
    mockSharedPrefs = MockSharedPrefs();
    mockTodoRepository = MockTodoRepository();

    when(() => mockSharedPrefs.setBool(any(), any())).thenAnswer((_) async => true);

    when(() => mockTodoRepository.save(any())).thenAnswer((_) async => Future.value());

    // when(() => mockNavigationObserver.didPop(
    //       any(that: isRoute<String?>(named: Routes.home)),
    //       any(that: isRoute<String?>(named: Routes.onboarding)),
    //     )).thenAnswer((_) async => Routes.home);
  });

  tearDownAll(() async {});

  testWidgets('Onboarding Skipping', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        onBoardingProvider.overrideWithValue(OnBoardingNotifier.create(false, mockSharedPrefs)),
        todoListProvider.overrideWithProvider(mocktodoListProvider),
      ],
      child: MyApp(
        navigatorObservers: [mockNavigationObserver],
      ),
    ));
    await tester.pump();

    await tester.tap(find.ancestor(
      of: find.text('Skip'),
      matching: find.byType(ElevatedButton),
    ));
    await tester.pumpAndSettle();

    // verify(() => mockNavigationObserver.didPush(
    //       any(that: isRoute<String?>(whereName: equals(Routes.home))),
    //       any(that: isRoute<String?>(whereName: equals(Routes.onboarding))),
    //     ));

    expect(find.byType(DashboardScreen), findsOneWidget);

    // await expectLater(find.byType(MyApp), matchesGoldenFile('onboarding.png'));
  });

  // test('Onboarding Completing', () {});
}
