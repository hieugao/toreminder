import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/note/models.dart';
import '../../features/note/services.dart';
import '../../services/connectivity_service.dart';

final notionDatabaseProvider =
    StateNotifierProvider.autoDispose<NotionDatabaseViewModel, NotionDatabase>(
        (ref) => NotionDatabaseViewModel(ref));

final noteProvider = StateProvider((_) => Note.initial());

// TODO: Should I use StateProvider or FutureProvider instead?
class NotionDatabaseViewModel extends StateNotifier<NotionDatabase> {
  NotionDatabaseViewModel(this._ref) : super(NotionDatabase());

  final Ref _ref;

  NotionDatabaseService get _service => _ref.read(notionDatabaseServiceProvider);

  Future<void> init() async {
    state = await _service.loadDatabase();

    final hasNetwork = await _ref.read(connectivityServiceProvider.future);

    if (hasNetwork == ConnectivityStatus.connected) {
      state = await _service.fetchDatabase();
      _service.saveDatabase(state);
    }
  }
}
