import 'package:riverpod/riverpod.dart';

import '../repositories/connectivity_repo.dart';

// FIXME: I don't like the way that this works, `connectivityStatus` shouldn't belong
// here.
class SyncStatus {
  SyncStatus([
    this.isSyncing = false,
    this.connectivity = ConnectivityStatus.disconnected,
  ]);

  final bool isSyncing;
  final ConnectivityStatus connectivity;
}

// No need `autoDispose` because it will run the whole time.
final connectivityServiceProvider = StreamProvider<ConnectivityStatus>((ref) {
  return WifiConnectivityRepository().connectivityStreamController.stream;
});

final isSyncingProvider = StateProvider<bool>((ref) => false);

// final noteSyncProvider = StreamProvider.autoDispose<SyncStatus>((ref) async* {
//   // final note = ref.watch(noteListProvider.state);
//   // return note.map((note) => note.first);

//   // final service = ref.watch(noteServiceProvider);
//   final connectivityStream = ref.watch(connectivityServiceProvider.stream);
//   // final connectivityStatus = await ref.watch(connectivityServiceProvider.future);

//   // final noteList = ref.read(noteListProvider);
//   // int unSyncedNumber() => noteList.where((note) => !note.isSynced).length;

//   // yield SyncNote(
//   //   unSyncedNumber: unSyncedNumber(),
//   //   isSyncing: false,
//   //   connectivityStatus: ConnectivityStatus.disconnected,
//   // );

//   // Initial status.
//   yield SyncStatus(false, ConnectivityStatus.disconnected);

//   await for (final status in connectivityStream) {
//     // Initial status.
//     // yield SyncStatus(false, status);

//     if (status == ConnectivityStatus.connected) {
//       // Start syncing so indicate the listener.
//       yield SyncStatus(true, status);

//       var notes = ref.watch(noteListProvider);
//       // var isUpdated = false;

//       // int unSyncedNumber() => notes.where((note) => !note.isSynced).length;

//       // yield SyncNote(
//       //   unSyncedNumber: unSyncedNumber(),
//       //   isSyncing: true,
//       //   connectivityStatus: ConnectivityStatus.connected,
//       // );

//       // Start syncing so indicate the listener.
//       // yield true;

//       for (var i = 0; i < notes.length; i++) {
//         if (!notes[i].isSynced) {
//           try {
//             if (await NotionDatabaseService.createNotionPage(notes[i])) {
//               // await Future.delayed(const Duration(seconds: 10));

//               // print('Sync $i');
//               // yield unSyncedNumber;
//               // isUpdated = true;

//               // FIXME: This is not working.
//               ref.watch(noteListProvider.notifier).updateAt(i, notes[i].copyWith(isSynced: true));
//               // notes[i] = notes[i].copyWith(isSynced: true);
//             }
//           } catch (e) {
//             // FIXME: Handle error, unsynced note, logging?
//             //       I got an error when I tried to sync the note (the first one)
//             //       HandshakeException: Connection terminated during handshake
//             //       How to recall it to create note?
//             print(e);
//             continue;
//           } finally {
//             // yield SyncNote(
//             //   unSyncedNumber: unSyncedNumber(),
//             //   isSyncing: true,
//             //   connectivityStatus: ConnectivityStatus.connected,
//             // );
//             // yield SyncStatus(false, status);
//           }
//         }
//       }

//       // ref.watch(noteListProvider.notifier).set(notes);
//       yield SyncStatus(false, status);

//       // if (isUpdated) {
//       //   ref.read(noteListProvider.notifier).set(notes);
//       //   await service.saveNotes(notes);
//       // }
//     }

//     // ? Should I remove this because it's kind of useless.
//     // yield SyncStatus(false, connectivityStatus);

//     // yield SyncNote(
//     //   unSyncedNumber: unSyncedNumber(),
//     //   isSyncing: false,
//     //   connectivityStatus: ConnectivityStatus.disconnected,
//     // );
//   }

//   // yield SyncNote(
//   //   unSyncedNumber: 12,
//   //   isSyncing: false,
//   //   connectivityStatus: ConnectivityStatus.disconnected,
//   // );
// });
