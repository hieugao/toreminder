import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../notion/providers/notion_providers.dart';
import '../notion/repositories/connectivity_repo.dart';
import '../todo/models.dart';
import '../todo/providers.dart';

final syncProvider = StateNotifierProvider<SyncNotifier, AsyncValue<SyncStatus>>((ref) {
  return SyncNotifier(ref);
});

class SyncNotifier extends StateNotifier<AsyncValue<SyncStatus>> {
  SyncNotifier(this._ref) : super(const AsyncLoading()) {
    final todoRepo = _ref.watch(todoRepositoryProvider);
    final notionRepo = _ref.watch(notionRepositoryProvider);

    _ref.listen<List<Todo>>(
      todoListProvider,
      (prev, next) async {
        count++;

        if (count == 1) {
          state = const AsyncData(SyncStatus.synced);
          return;
        }

        try {
          await todoRepo.save(next);
          await notionRepo.createNotionPage(next.first);
          state = const AsyncData(SyncStatus.synced);
        } catch (e) {
          state = AsyncError(e);
        }
      },
    );
  }

  final Ref _ref;
  int count = 0;
}

// No need `autoDispose` because it will run the whole time.
final connectivityServiceProvider = StreamProvider<ConnectivityStatus>((ref) {
  return WifiConnectivityRepository().connectivityStreamController.stream;
});

// FIXME: I think `connectivityStatus` shouldn't belong here.
// class SyncData {
//   SyncData([
//     this.status = SyncStatus.synced,
//     this.connectivity = ConnectivityStatus.disconnected,
//   ]);

//   final SyncStatus status;
//   final ConnectivityStatus connectivity;
// }

enum SyncStatus {
  synced,
  syncing,
  unsynced,
  // offline,
}
