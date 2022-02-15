import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:notion_capture/common/widgets.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../common/constants.dart' show Routes;
import '../../features/note/models.dart';
import '../../services/connectivity_service.dart';

import 'bookmark_section.dart';
import 'view_models.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  // FIXME: [HIGH] Prevent this to rebuilt everytime I move to the Create Note page and after
  // I created a page.
  // * Tap on title field (both manual and `autofocus`)
  // * Tap on Categories field
  // * Finish choosing Categories
  // * Finish creating note - `Consumer` should rebuild not this
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
              final numberUnsyncedNotes = ref.watch(noteListProvider.notifier).numberUnsyncedNotes;
              final syncAsyncValue = ref.watch(noteSyncProvider);

              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: syncAsyncValue.when(
                    data: (syncStatus) => _SyncIndicator(numberUnsyncedNotes, status: syncStatus),
                    error: (_, __) => Text('Error',
                        style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.red)),
                    loading: () =>
                        const SizedBox(width: 12, height: 12, child: CircularProgressIndicator()),
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
                        // FIXME: Unhandled Exception: RangeError (index): Invalid value: Not in inclusive range 0..1: 2
                        // FIXME: I don't think this is a "proper" way to delete a note.
                        itemBuilder: (context, index) => Dismissible(
                          key: Key(notes[index].id.toString()),
                          onDismissed: (direction) =>
                              ref.read(noteListProvider.notifier).removeAt(index),
                          child: _NoteCard(note: notes[index], onTap: () {}),
                        ),
                      ),
              ),
            ]),
          );
        },
      ),
      floatingActionButton: Consumer(builder: (context, ref, child) {
        return FloatingActionButton(
          onPressed: () async {
            Navigator.pushNamed(context, Routes.createNote);
          },
          child: const Icon(Icons.add),
        );
      }),
    );
  }
}

// enum SyncStatus { synced, syncing, unsynced }

// TODO: Add loading indicator (while stream is loading) not syncing.
class _SyncIndicator extends StatelessWidget {
  const _SyncIndicator(
    this.numberUnsyncedNote, {
    required this.status,
    Key? key,
    // this.connectivityStatus = ConnectivityStatus.disconnected,
    // this.isSyncing = false,
  }) : super(key: key);

  final int numberUnsyncedNote;
  // final ConnectivityStatus connectivityStatus;
  // FIXME: Do I really need it? I only need it to indicate the user that the app is offline.
  final SyncStatus status;
  // final bool isSyncing;

  bool get _isSynced =>
      status.connectivity == ConnectivityStatus.connected && numberUnsyncedNote == 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[700],
      ),
      child: Row(
        children: [
          _buildSyncDot(),
          const SizedBox(width: 6),
          Text(
              status.isSyncing
                  ? 'Syncing... ($numberUnsyncedNote)'
                  // : _isSynced
                  : numberUnsyncedNote == 0
                      ? 'Synced'
                      : 'Unsynced ($numberUnsyncedNote)',
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
        color: status.isSyncing
            ? Colors.yellow
            // : _isSynced
            : numberUnsyncedNote == 0
                ? Colors.green
                : Colors.red,
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
                Text(note.title, style: Theme.of(context).textTheme.subtitle1),

                const SizedBox(height: 8),

                // Note's labels.
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    for (var label in note.labels) ...[
                      TagProperty(tag: label),
                      const SizedBox(width: 4),
                    ],
                    const Spacer(),
                    StackedWidgets(
                      children: [
                        note.dueString != null
                            ? TagIcon(tag: note.dueString!, isSelected: true)
                            : const SizedBox(),
                        note.dueString != null
                            ? TagIcon(tag: note.priority!, isSelected: true)
                            : const SizedBox(),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // _LabelsBlock(type: note.type, dueString: note.dueString, priority: note.priority),
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
                    const Spacer(),
                    note.createdAt != null
                        ? Text(
                            timeago.format(note.createdAt!),
                            style:
                                Theme.of(context).textTheme.caption!.apply(color: Colors.white38),
                          )
                        : const SizedBox(),
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

// Source https://www.youtube.com/watch?v=ut9CeTQRax0
class StackedWidgets extends StatelessWidget {
  final List<Widget> children;
  final TextDirection direction;
  final double size;
  final double xShift;

  const StackedWidgets({
    Key? key,
    required this.children,
    this.direction = TextDirection.ltr,
    this.size = 32,
    this.xShift = 4,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final allItems = children
        .asMap()
        .map((index, item) {
          final left = size - xShift;

          final value = Container(
            width: size,
            height: size,
            child: item,
            margin: EdgeInsets.only(left: left * index),
          );

          return MapEntry(index, value);
        })
        .values
        .toList();

    return Stack(
      children: direction == TextDirection.ltr ? allItems.reversed.toList() : allItems,
    );
  }
}
