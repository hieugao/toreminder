import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/note/models.dart';
import '../../features/note/services.dart';
import '../../services/connectivity_service.dart';

final notionDatabaseProvider = StateNotifierProvider<NotionDatabaseViewModel, NotionDatabase>(
    (ref) => NotionDatabaseViewModel(ref.read));

final noteProvider = StateProvider<Note>((ref) => Note.initial());

// TODO: Should I use StateProvider or FutureProvider instead?
class NotionDatabaseViewModel extends StateNotifier<NotionDatabase> {
  NotionDatabaseViewModel(this._read) : super(NotionDatabase());

  final Reader _read;

  NotionDatabaseService get _service => _read(notionDatabaseServiceProvider);

  Future<void> init() async {
    state = await _service.loadDatabase();

    final hasNetwork = await _read(connectivityServiceProvider.future);

    if (hasNetwork == ConnectivityStatus.connected) {
      state = await _service.fetchDatabase();
      _service.saveDatabase(state);
    }
  }
}
