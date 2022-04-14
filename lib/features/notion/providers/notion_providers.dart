import 'package:riverpod/riverpod.dart';

import '../repositories/notion_repo.dart';

final notionRepositoryProvider = Provider<NotionRepository>((ref) => NotionRepository());

// final _isFetchedProvider = StateProvider<bool>((ref) => false);

// final notionDatabaseProvider = FutureProvider<NotionDatabase>((ref) async {
//   final _service = ref.watch(notionDatabaseServiceProvider);

//   // FIXME: [LOW PRIORITY] So everytime `connectivityServiceProvider` changes, this will be
//   // re-called, I don't want that.
//   // But I don't think the internet connection will be changed a lot so...
//   var data = await _service.loadDatabase();

//   ref.watch(connectivityServiceProvider.future).then((value) async {
//     try {
//       if (value == ConnectivityStatus.connected && ref.watch(_isFetchedProvider) == false) {
//         data = await _service.fetchDatabase();
//         ref.read(_isFetchedProvider.state).state = true;
//         _service.saveDatabase(data);
//       }
//     } catch (e) {
//       return data;
//     }
//   });

//   return data;
// });