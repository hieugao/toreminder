import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/note/services.dart';
import '/services/connectivity_service.dart';

import '../../features/note/models.dart';

final noteListProvider = StateNotifierProvider<NoteListViewModel, List<Note>>((ref) {
  return NoteListViewModel(ref);
});

// Return a stream of sync status (true if sync is in progress).
final noteSyncProvider = StreamProvider.autoDispose<SyncStatus>((ref) async* {
  // final note = ref.watch(noteListProvider.state);
  // return note.map((note) => note.first);

  // final service = ref.watch(noteServiceProvider);
  final connectivityStream = ref.watch(connectivityServiceProvider.stream);
  // final connectivityStatus = await ref.watch(connectivityServiceProvider.future);

  // final noteList = ref.read(noteListProvider);
  // int unSyncedNumber() => noteList.where((note) => !note.isSynced).length;

  // yield SyncNote(
  //   unSyncedNumber: unSyncedNumber(),
  //   isSyncing: false,
  //   connectivityStatus: ConnectivityStatus.disconnected,
  // );

  // Initial status.
  yield SyncStatus(false, ConnectivityStatus.disconnected);

  await for (final status in connectivityStream) {
    // Initial status.
    // yield SyncStatus(false, status);

    if (status == ConnectivityStatus.connected) {
      // Start syncing so indicate the listener.
      yield SyncStatus(true, status);

      var notes = ref.watch(noteListProvider);
      // var isUpdated = false;

      // int unSyncedNumber() => notes.where((note) => !note.isSynced).length;

      // yield SyncNote(
      //   unSyncedNumber: unSyncedNumber(),
      //   isSyncing: true,
      //   connectivityStatus: ConnectivityStatus.connected,
      // );

      // Start syncing so indicate the listener.
      // yield true;

      for (var i = 0; i < notes.length; i++) {
        if (!notes[i].isSynced) {
          try {
            if (await NotionDatabaseService.createNotionPage(notes[i])) {
              // await Future.delayed(const Duration(seconds: 10));

              // print('Sync $i');
              // yield unSyncedNumber;
              // isUpdated = true;

              // FIXME: This is not working.
              ref.watch(noteListProvider.notifier).updateAt(i, notes[i].copyWith(isSynced: true));
              // notes[i] = notes[i].copyWith(isSynced: true);
            }
          } catch (e) {
            // FIXME: Handle error, unsynced note, logging?
            //       I got an error when I tried to sync the note (the first one)
            //       HandshakeException: Connection terminated during handshake
            //       How to recall it to create note?
            print(e);
            continue;
          } finally {
            // yield SyncNote(
            //   unSyncedNumber: unSyncedNumber(),
            //   isSyncing: true,
            //   connectivityStatus: ConnectivityStatus.connected,
            // );
            // yield SyncStatus(false, status);
          }
        }
      }

      // ref.watch(noteListProvider.notifier).set(notes);
      yield SyncStatus(false, status);

      // if (isUpdated) {
      //   ref.read(noteListProvider.notifier).set(notes);
      //   await service.saveNotes(notes);
      // }
    }

    // ? Should I remove this because it's kind of useless.
    // yield SyncStatus(false, connectivityStatus);

    // yield SyncNote(
    //   unSyncedNumber: unSyncedNumber(),
    //   isSyncing: false,
    //   connectivityStatus: ConnectivityStatus.disconnected,
    // );
  }

  // yield SyncNote(
  //   unSyncedNumber: 12,
  //   isSyncing: false,
  //   connectivityStatus: ConnectivityStatus.disconnected,
  // );
});

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

final isSyncingProvider = StateProvider<bool>((ref) => false);

class NoteListViewModel extends StateNotifier<List<Note>> {
  NoteListViewModel(this._ref, [List<Note>? initialTodos]) : super(initialTodos ?? []) {
    _init();
    // _sync();
  }

  final Ref _ref;

  List<Note> get notes => state;
  int get numberUnsyncedNotes => state.where((note) => !note.isSynced).length;

  Future<void> add(Note note) async {
    if (note.isEmpty) return;

    try {
      final isCreated = await NotionDatabaseService.createNotionPage(note);
      if (isCreated) note = note.copyWith(isSynced: true);
    } catch (e) {
      throw ('Printing out the message: $e');
    } finally {
      state = [...state, note];
      await _service.saveNotes(state);
    }
  }

  Future<void> updateAt(int index, Note note) async {
    var newState = state;
    newState[index] = note;
    state = newState;
    await _service.saveNotes(state);
  }

  Future<void> set(List<Note> notes) async {
    state = notes;
    await _service.saveNotes(state);
  }

  Future<void> removeAt(int index) async {
    state.removeAt(index);
    await _service.saveNotes(state);
  }

  NoteService get _service => _ref.read(noteServiceProvider);

  Future<void> _init() async {
    state = await _service.loadNotes();

    // TODO: User `_ref.listen()` instead?
    // final asyncValue = _ref.watch(connectivityServiceProvider);

    // FIXME: Should I check the internet here or inside NotionDatabaseService?
    // asyncValue.whenData((value) async {
    //   if (value == ConnectivityStatus.connected) {
    //     _ref.read(isSyncingProvider.notifier).state = true;

    //     for (var i = 0; i < state.length; i++) {
    //       if (!state[i].isSynced) {
    //         try {
    //           if (await NotionDatabaseService.createNotionPage(state[i])) {
    //             state[i] = state[i].copyWith(isSynced: true);
    //             await _service.saveNotes(state);
    //           }
    //         } catch (e) {
    //           // TODO: Handle error, unsynced note, logging?
    //           print(e);
    //           continue;
    //         }
    //       }
    //     }
    //   }

    //   _ref.read(isSyncingProvider.notifier).state = false;
    // });
  }

  // FIXME: Something wrong, it works fine, but the state is not watch.
  // Future<void> _sync() async {
  //   final conStatus = await _ref.watch(connectivityServiceProvider.future);

  //   if (conStatus == ConnectivityStatus.connected) {
  //     _ref.read(isSyncingProvider.notifier).state = true;

  //     for (var i = 0; i < state.length; i++) {
  //       if (!state[i].isSynced) {
  //         try {
  //           if (await NotionDatabaseService.createNotionPage(state[i])) {
  //             await Future.delayed(const Duration(seconds: 5));
  //             state[i] = state[i].copyWith(isSynced: true);
  //             await _service.saveNotes(state);
  //             print('Sync $i');
  //           }
  //         } catch (e) {
  //           // TODO: Handle error, unsynced note, logging?
  //           print(e);
  //           continue;
  //         }
  //       }
  //     }
  //   }

  //   _ref.read(isSyncingProvider.notifier).state = false;
  // }

  // void set(List<Note> notes) {
  //   state = notes;
  // }

}
