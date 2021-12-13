import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/note/models.dart';
import '../../features/note/services.dart';
// import '../../services/connectivity_service.dart';

// FIXME: Handle offline mode.
final notionDatabaseProvider = FutureProvider<NotionDatabase>((ref) async {
  final _service = ref.watch(notionDatabaseServiceProvider);

  // var futureDB = _service.loadDatabase();

  // try {
  //   futureDB = _service.fetchDatabase();
  //   _service.saveDatabase(await futureDB);
  //   return futureDB;
  // } catch (e) {
  //   throw ("Can't fetch database");
  // }

  return _service.fetchDatabase();
});

final noteProvider = StateProvider<Note>((ref) => Note.initial());

// TODO: Should I use StateProvider or FutureProvider instead?
// class NotionDatabaseViewModel extends StateNotifier<NotionDatabase> {
//   NotionDatabaseViewModel(this._read) : super(NotionDatabase());

//   final Reader _read;

//   NotionDatabaseService get _service => _read(notionDatabaseServiceProvider);

//   NotionDatabaseViewModel.init() async {
//     state = await _service.loadDatabase();

//     try {
//       state = await _service.fetchDatabase();
//       _service.saveDatabase(state);
//     } catch (e) {
//       print(e);
//     }

//     print(state);
//   }
// }
