import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../notion/providers/notion_providers.dart';
import '../notion/repositories/connectivity_repo.dart';
import '../todo/models.dart';

enum Action { create }

final syncStatusProvider = FutureProvider<SyncStatus>((ref) {
  final sync = ref.watch(syncProvider);
  final network = ref.watch(connectivityServiceProvider.future);

  return sync.when(
    data: (data) async {
      if (await network == ConnectivityStatus.connected) {
        return SyncStatus.synced;
      } else {
        return SyncStatus.offline;
      }
    },
    loading: () => SyncStatus.syncing,
    error: (e, st) => SyncStatus.unsynced,
  );
});

final syncProvider = StateNotifierProvider<NewSyncNotifier, AsyncValue<void>>((ref) {
  return NewSyncNotifier(ref);
});

class NewSyncNotifier extends StateNotifier<AsyncValue<void>> {
  NewSyncNotifier(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  late final notionRepo = _ref.watch(notionRepositoryProvider);

  Future<void> sync(Todo todo, Action action) async {
    try {
      state = const AsyncValue.loading();
      if (action == Action.create) {
        await notionRepo.createNotionPage(todo);
      }
    } catch (e) {
      state = AsyncValue.error(e);
    } finally {
      state = const AsyncValue.data(null);
    }
  }
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
  offline,
}
