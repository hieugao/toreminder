// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../models.dart';
// import '../repositories/connectivity_repo.dart';

// final noteProvider = StateProvider<Note>((ref) => Note.initial());

// final noteServiceProvider = Provider<NoteRepository>((ref) => throw UnimplementedError());

// final noteListProvider = StateNotifierProvider<NoteListViewModel, List<Note>>((ref) {
//   return NoteListViewModel(ref);
// });

// Return a stream of sync status (true if sync is in progress).
// class NoteListViewModel extends StateNotifier<List<Note>> {
//   NoteListViewModel(this._ref, [List<Note>? initialTodos]) : super(initialTodos ?? []) {
//     _init();
//     // _sync();
//   }

//   final Ref _ref;

//   List<Note> get notes => state;
//   int get numberUnsyncedNotes => state.where((note) => !note.isSynced).length;

//   Future<void> add(Note note) async {
//     if (note.isEmpty) return;

//     try {
//       final isCreated = await NotionDatabaseService.createNotionPage(note);
//       if (isCreated) note = note.copyWith(isSynced: true);
//     } catch (e) {
//       throw ('Printing out the message: $e');
//     } finally {
//       state = [...state, note];
//       await _service.saveNotes(state);
//     }
//   }

//   Future<void> updateAt(int index, Note note) async {
//     var newState = state;
//     newState[index] = note;
//     state = newState;
//     await _service.saveNotes(state);
//   }

//   Future<void> set(List<Note> notes) async {
//     state = notes;
//     await _service.saveNotes(state);
//   }

//   Future<void> removeAt(int index) async {
//     state.removeAt(index);
//     await _service.saveNotes(state);
//   }

//   NoteService get _service => _ref.read(noteServiceProvider);

//   Future<void> _init() async {
//     state = await _service.loadNotes();

//     // TODO: User `_ref.listen()` instead?
//     // final asyncValue = _ref.watch(connectivityServiceProvider);

//     // FIXME: Should I check the internet here or inside NotionDatabaseService?
//     // asyncValue.whenData((value) async {
//     //   if (value == ConnectivityStatus.connected) {
//     //     _ref.read(isSyncingProvider.notifier).state = true;

//     //     for (var i = 0; i < state.length; i++) {
//     //       if (!state[i].isSynced) {
//     //         try {
//     //           if (await NotionDatabaseService.createNotionPage(state[i])) {
//     //             state[i] = state[i].copyWith(isSynced: true);
//     //             await _service.saveNotes(state);
//     //           }
//     //         } catch (e) {
//     //           // TODO: Handle error, unsynced note, logging?
//     //           print(e);
//     //           continue;
//     //         }
//     //       }
//     //     }
//     //   }

//     //   _ref.read(isSyncingProvider.notifier).state = false;
//     // });
//   }

//   // FIXME: Something wrong, it works fine, but the state is not watch.
//   // Future<void> _sync() async {
//   //   final conStatus = await _ref.watch(connectivityServiceProvider.future);

//   //   if (conStatus == ConnectivityStatus.connected) {
//   //     _ref.read(isSyncingProvider.notifier).state = true;

//   //     for (var i = 0; i < state.length; i++) {
//   //       if (!state[i].isSynced) {
//   //         try {
//   //           if (await NotionDatabaseService.createNotionPage(state[i])) {
//   //             await Future.delayed(const Duration(seconds: 5));
//   //             state[i] = state[i].copyWith(isSynced: true);
//   //             await _service.saveNotes(state);
//   //             print('Sync $i');
//   //           }
//   //         } catch (e) {
//   //           // TODO: Handle error, unsynced note, logging?
//   //           print(e);
//   //           continue;
//   //         }
//   //       }
//   //     }
//   //   }

//   //   _ref.read(isSyncingProvider.notifier).state = false;
//   // }

//   // void set(List<Note> notes) {
//   //   state = notes;
//   // }

// }
