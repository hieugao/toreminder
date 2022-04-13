import 'package:flutter_test/flutter_test.dart';

import 'package:riverpod/riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:toreminder/features/onboarding/providers.dart';

import '../screens/dashboard_widget_test.dart';

class Listener extends Mock {
  void call(bool? previous, bool value);
}

void main() {
  late MockSharedPrefs mockSharedPrefs;

  setUp(() {
    mockSharedPrefs = MockSharedPrefs();
  });

  ProviderContainer overrideValue() => ProviderContainer(overrides: [
        onBoardingProvider.overrideWithValue(OnBoardingNotifier.create(false, mockSharedPrefs))
      ]);

  void arrangeSharedPrefs() {
    when(() => mockSharedPrefs.setBool(any(), any())).thenAnswer((_) async => true);
  }

  test('Onboarding Completed', () {
    final container = overrideValue();
    addTearDown(container.dispose);
    final listener = Listener();

    container.listen<bool>(onBoardingProvider, listener, fireImmediately: true);

    verify(() => listener(null, false)).called(1);
    verifyNoMoreInteractions(listener);

    arrangeSharedPrefs();
    container.read(onBoardingProvider.notifier).setOnBoardingComplete();

    verify(() => listener(false, true)).called(1);
    verifyNoMoreInteractions(listener);
  });
}
