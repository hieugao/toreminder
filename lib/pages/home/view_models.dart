import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/note/services.dart';
import '/services/connectivity_service.dart';

import '../../features/note/models.dart';

final noteListProvider = StateNotifierProvider.autoDispose<NoteListViewModel, List<Note>>((ref) {
  final service = ref.watch(noteServiceProvider);
  return NoteListViewModel(service, ref);
});

final isSyncingProvider = StateProvider<bool>((ref) => false);

class NoteListViewModel extends StateNotifier<List<Note>> {
  // TODO: Replace _service with ref.watch?
  NoteListViewModel(this._service, this._ref, [List<Note>? initialTodos])
      : super(initialTodos ?? []);

  final NoteService _service;
  final AutoDisposeStateNotifierProviderRef _ref;

  Future<void> init() async {
    state = await _service.loadNotes();

    // TODO: _ref.listen instead?
    final asyncValue = _ref.watch(connectivityServiceProvider);

    // FIXME: Should I check the internet here or inside NotionDatabaseService?
    asyncValue.whenData((value) async {
      if (value == ConnectivityStatus.connected) {
        _ref.read(isSyncingProvider.notifier).state = true;

        for (var i = 0; i < state.length; i++) {
          if (!state[i].isSynced) {
            try {
              if (await NotionDatabaseService.createNotionPage(state[i])) {
                state[i] = state[i].copyWith(isSynced: true);
                await _service.saveNotes(state);
              }
            } catch (e) {
              // TODO: Handle error, unsynced note, logging?
              print(e);
              continue;
            }
          }
        }
      }

      _ref.read(isSyncingProvider.notifier).state = false;
    });
  }

  Future<void> add(Note note) async {
    final hasNetwork = await _ref.read(connectivityServiceProvider.future);

    try {
      if (hasNetwork == ConnectivityStatus.connected) {
        if (await NotionDatabaseService.createNotionPage(note)) {
          note = note.copyWith(isSynced: true);
        }
      }
    } catch (e) {
      throw ('Printing out the message: $e');
    } finally {
      state.add(note);
      await _service.saveNotes(state);
    }
  }

  Future<void> removeAt(int index) async {
    state.removeAt(index);
    await _service.saveNotes(state);
  }
}
