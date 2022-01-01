import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/connectivity_service.dart';
import '../../features/note/models.dart';
import '../../features/note/services.dart';

final noteProvider = StateProvider<Note>((ref) => Note.initial());

final notionDatabaseProvider = FutureProvider<NotionDatabase>((ref) async {
  final _service = ref.watch(notionDatabaseServiceProvider);

  // FIXME: [LOW PRIORITY] So everytime `connectivityServiceProvider` changes, this will be
  // re-called, I don't want that.
  // But I don't think the internet connection will be changed a lot so...
  var data = await _service.loadDatabase();

  ref.watch(connectivityServiceProvider.future).then((value) async {
    try {
      if (value == ConnectivityStatus.connected && ref.watch(_isFetchedProvider) == false) {
        data = await _service.fetchDatabase();
        ref.read(_isFetchedProvider.state).state = true;
        _service.saveDatabase(data);
      }
    } catch (e) {
      return data;
    }
  });

  return data;
});

final _isFetchedProvider = StateProvider<bool>((ref) => false);
