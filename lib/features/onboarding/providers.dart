import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final onBoardingProvider = StateNotifierProvider<OnBoardingNotifier, bool>((ref) {
  final _prefs = ref.watch(onBoardingSharedPrefsProvider);
  return OnBoardingNotifier(_prefs);
});

final onBoardingSharedPrefsProvider =
    Provider<SharedPreferences>((ref) => throw UnimplementedError());

class OnBoardingNotifier extends StateNotifier<bool> {
  OnBoardingNotifier(this._prefs) : super(false) {
    state = _prefs.getBool(_key) ?? false;
  }

  OnBoardingNotifier.create(bool state, this._prefs) : super(state);

  final SharedPreferences _prefs;

  String get _key => 'onBoard';

  bool get isOnBoardingComplete => state;

  Future<void> setOnBoardingComplete() async {
    state = true;
    _prefs.setBool(_key, state);
  }
}
