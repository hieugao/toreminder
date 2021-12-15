import 'dart:ui' as ui;

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/material.dart';

import '../../common/constants.dart' show Routes;
import '../../features/note/models.dart';
import '../../services/connectivity_service.dart';

import 'bookmark_section.dart';
import 'view_models.dart';

// class _MyHomePageState extends State<MyHomePage> {
//   late final Future<List<Note>> _futureNotes;
//   late StreamSubscription<ConnectivityResult> _connectivitySubscription;
//   ConnectivityResult _connectionStatus = ConnectivityResult.none;
//   bool _isSyncing = false;
//   List<Note> _notes = [];

//   @override
//   void initState() {
//     super.initState();
//     _init();
//     _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
//       setState(() => _connectionStatus = result);
//       _syncNotes(result);
//     });
//   }

//   @override
//   void dispose() {
//     _connectivitySubscription.cancel();
//     super.dispose();
//   }

//   Future<void> _init() async {
//     // _futureNotes = _NoteRepository.getNotes();
//     _futureNotes = HomeRepository.getNotes();
//     final noteList = await _futureNotes;

//     setState(() => _notes = noteList);
//   }

//   Future<void> _syncNotes(ConnectivityResult result) async {
//     // final ConnectivityResult result = await Connectivity().checkConnectivity();
//     if (result == ConnectivityResult.wifi || result == ConnectivityResult.mobile) {
//       setState(() => _isSyncing = true);

//       for (var i = 0; i < _notes.length; i++) {
//         if (!_notes[i].isSynced) {
//           try {
//             final isCreated = await CreateNoteRepository.createNotionPage(_notes[i]);

//             if (isCreated) {
//               setState(() => _notes[i] = _notes[i].copyWith(isSynced: true));
//               HomeRepository.saveNotes(_notes);
//             }
//           } catch (e) {
//             // TODO: Handle error, unsynced note, logging?
//             print(e);
//             continue;
//           }
//         }
//       }

//       setState(() => _isSyncing = false);
//     }

//     HomeRepository.saveNotes(_notes);
//   }

//   void _awaitReturnValueFromSecondScreen() async {
//     final result = await Navigator.pushNamed(context, Routes.createNote);
//     // Navigator.pushNamed(context, Routes.createNote),
//     setState(() => _notes.add(result as Note));
//     NoteService.saveNotes(_notes);
//   }

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    print('Rebuilt check!');

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey[850],
        title: Text(
          'Notes',
          style: Theme.of(context).textTheme.headline6,
        ),
        actions: [
          Consumer(
            builder: (context, ref, child) {
              WidgetsBinding.instance?.addPostFrameCallback((_) {
                ref.read(noteListProvider.notifier).init();
              });
              final notes = ref.watch(noteListProvider);
              final asyncValue = ref.watch(connectivityServiceProvider);
              final isSyncing = ref.watch(isSyncingProvider);
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: _SyncIndicator(
                    notes: notes,
                    status: asyncValue.when(
                      data: (status) => status,
                      loading: () => ConnectivityStatus.disconnected,
                      error: (_, __) => ConnectivityStatus.disconnected,
                    ),
                    isSyncing: isSyncing,
                  ),
                ),
              );
            },
          )
        ],
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final notes = ref.watch(noteListProvider);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(children: <Widget>[
              Container(
                constraints: BoxConstraints(maxHeight: height * 0.5),
                child: notes.isEmpty
                    ? const Center(child: _EmptyNotesIllustration())
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: notes.length,
                        itemBuilder: (context, index) => Dismissible(
                          key: Key(notes[index].id.toString()),
                          onDismissed: (direction) =>
                              ref.read(noteListProvider.notifier).removeAt(index),
                          child: _NoteCard(note: notes[index], onTap: () {}),
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 6.0, top: 12.0, bottom: 8.0),
                child: Text(
                  'Bookmarks',
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              const Expanded(child: BookmarkSection()),
            ]),
          );
        },
      ),
      floatingActionButton: Consumer(builder: (context, ref, child) {
        return FloatingActionButton(
          onPressed: () async {
            Navigator.pushNamed(context, Routes.createNote);
            // _awaitReturnValueFromSecondScreen(), // Navigator.pushNamed(context, Routes.createNote),
            // final result = await Navigator.pushNamed(context, Routes.createNote);
            // ref.read(noteListProvider.notifier).add;
          },
          child: const Icon(Icons.add),
        );
      }),
    );
  }
}

class _SyncIndicator extends StatelessWidget {
  const _SyncIndicator({
    Key? key,
    required this.notes,
    required this.status,
    this.isSyncing = false,
  }) : super(key: key);

  final List<Note> notes;
  final ConnectivityStatus status;
  final bool isSyncing;

  @override
  Widget build(BuildContext context) {
    final unSyncNumber = notes.where((note) => !note.isSynced).length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[700],
      ),
      child: Row(
        children: [
          _buildSyncDot(),
          const SizedBox(width: 6),
          Text(
              isSyncing
                  ? 'Syncing... ($unSyncNumber)'
                  : status == ConnectivityStatus.disconnected
                      ? 'Unsynced ($unSyncNumber)'
                      : 'Synced',
              style: Theme.of(context).textTheme.caption),
        ],
      ),
    );
  }

  Widget _buildSyncDot() {
    return Container(
      width: 5,
      height: 5,
      decoration: BoxDecoration(
        color: isSyncing
            ? Colors.yellow
            : status == ConnectivityStatus.disconnected
                ? Colors.red
                : Colors.green,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({
    Key? key,
    required this.note,
    required this.onTap,
  }) : super(key: key);

  final Note note;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      // child: Slidable(
      //   // No need, because Dismissible isn't used.
      //   // key: Key(note.id.toString()),
      //   actionPane: SlidableDrawerActionPane(),
      //   actionExtentRatio: 0.25,
      //   dismissal: SlidableDismissal(
      //     child: SlidableDrawerDismissal(),
      //     dismissThresholds: <SlideActionType, double>{SlideActionType.primary: 1.0},
      //     onDismissed: (direction) {
      //       if (direction == SlideActionType.secondary)
      //         setState(() {
      //           context.read(noteProvider.notifier).removeNote(note);
      //         });
      //     },
      //   ),
      //   actions: <Widget>[PinNoteAction(note, setState)],
      //   secondaryActions: <Widget>[DeleteNoteAction(note, setState)],
      //   child: Card(
      //     elevation: 0,
      //     child: Padding(
      //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      //       child: _body(context),
      //     ),
      //   ),
      // ),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: DottedBorder(
          strokeCap: StrokeCap.round,
          // color: note.isSynced ? Colors.transparent : Colors.red[700]!.withOpacity(0.6),
          color: Colors.transparent,
          strokeWidth: 0,
          // dashPattern: const [6, 6, 2, 6],
          borderType: BorderType.RRect,
          radius: const Radius.circular(16),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(flex: 5, child: _CategoriesBlock(categories: note.categories)),
                    Row(children: [
                      Text(
                        note.createdAt != null ? timeago.format(note.createdAt!) : '',
                        style: Theme.of(context).textTheme.caption!.apply(color: Colors.white38),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: note.isSynced ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ])
                  ],
                ),
                const SizedBox(height: 8),
                Text(note.title),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _LabelsBlock(
                        type: note.type, dueString: note.dueString, priority: note.priority),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Column(children: [
                        note.body.isEmpty
                            ? Text(
                                note.body,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .caption!
                                    .apply(color: Colors.white38),
                              )
                            : Container(),
                      ]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoriesBlock extends StatelessWidget {
  const _CategoriesBlock({
    Key? key,
    required this.categories,
  }) : super(key: key);

  final List<NotionTag> categories;

  @override
  Widget build(BuildContext context) {
    return categories.isEmpty
        ? const SizedBox()
        : RichText(
            text: TextSpan(children: <InlineSpan>[
            WidgetSpan(
              // Source: https://stackoverflow.com/a/61489854/16553764
              alignment: ui.PlaceholderAlignment.middle,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: categories[0].color.fg,
                ),
                child: Text(
                  categories[0].emoji ?? '',
                  style: Theme.of(context).textTheme.caption!.copyWith(fontSize: 10),
                ),
              ),
            ),
            const TextSpan(text: '  '),
            for (var i = 0; i < categories.length; i++)
              ..._buildCategoryWidget(context, categories[i], i == categories.length - 1),
          ]));
  }

  List<TextSpan> _buildCategoryWidget(BuildContext context, NotionTag category,
      [bool isLast = false]) {
    return [
      TextSpan(
        text: ' ' + category.content,
        style: Theme.of(context).textTheme.caption,
      ),
      !isLast
          ? TextSpan(
              text: ',', style: Theme.of(context).textTheme.bodyText2!.apply(color: Colors.white))
          : const TextSpan(text: ''),
    ];
  }
}

class _LabelsBlock extends StatelessWidget {
  const _LabelsBlock({
    Key? key,
    this.dueString,
    this.priority,
    this.type,
  }) : super(key: key);

  final NotionTag? dueString;
  final NotionTag? priority;
  final NotionTag? type;

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      color: Colors.black,
      strokeWidth: 1,
      borderType: BorderType.RRect,
      radius: const Radius.circular(12),
      padding: const EdgeInsets.all(6),
      child: ClipRRect(
        // borderRadius: BorderRadius.all(Radius.circular(12)),
        child: Container(
          // padding: const EdgeInsets.all(4),
          // decoration: BoxDecoration(
          //   borderRadius: BorderRadius.circular(12),
          //   color: Colors.grey[700],
          // ),
          child: Row(
            children: [
              Text('Labels: ',
                  style: Theme.of(context).textTheme.caption!.apply(color: Colors.white38)),
              ..._buildLabel(context, dueString),
              ..._buildLabel(context, priority),
              ..._buildLabel(context, type),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildLabel(BuildContext context, NotionTag? label) {
    if (label != null) {
      return [
        const SizedBox(width: 2),
        Text(type?.emoji ?? '', style: Theme.of(context).textTheme.caption!),
      ];
    }
    return [const SizedBox()];
  }
}

class _EmptyNotesIllustration extends StatelessWidget {
  const _EmptyNotesIllustration({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: Lottie.asset('assets/astronaut-light-theme-lottie.json')),
        const SizedBox(height: 16),
        Text(
          "It's quite empty here, don't you think?",
          style: Theme.of(context).textTheme.bodyText2!.apply(color: Colors.white38),
        )
      ],
    );
  }
}
