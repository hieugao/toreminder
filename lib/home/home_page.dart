import 'dart:async';
import 'dart:ui' as ui;

// import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:lottie/lottie.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/material.dart';

import '../common/constants.dart';
import '../common/utils.dart';
import '../create_note/models.dart';
import '../create_note/repository.dart';
import './bookmark_section.dart';
import './repository.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final Future<List<Note>> _futureNotes;
  List<Note> _notes = [];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    // _futureNotes = _NoteRepository.getNotes();
    _futureNotes = HomeRepository.getNotes();
    final notes = await _futureNotes;

    setState(() => _notes = notes);
  }

  void _awaitReturnValueFromSecondScreen() async {
    var result = await Navigator.pushNamed(context, Routes.createNote) as Note;

    try {
      if (await hasNetwork()) {
        final successfullyCreated = await CreateNoteRepository.createNotionPage(result);

        if (successfullyCreated) {
          result = result.copyWith(isSynced: true);
        }
      }
    } catch (e) {
      throw ('Printing out the message: $e');
    } finally {
      setState(() => _notes.add(result));
      HomeRepository.saveNotes(_notes);
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey[850],
        title: Text(
          'Notes',
          style: Theme.of(context).textTheme.headline6,
        ),
      ),
      body: _notes.isEmpty
          ? const Center(child: _EmptyNotesIllustration())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    constraints: BoxConstraints(maxHeight: height * 0.5),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _notes.length,
                      itemBuilder: (context, index) {
                        // final note = snapshot.data![index];

                        return Dismissible(
                          key: Key(_notes[index].id.toString()),
                          onDismissed: (direction) {
                            setState(() {
                              _notes.removeAt(index);
                            });
                            HomeRepository.saveNotes(_notes);
                          },
                          child: _NoteCard(
                            note: _notes[index],
                            onTap: () {},
                          ),
                        );
                      },
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
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            _awaitReturnValueFromSecondScreen(), // Navigator.pushNamed(context, Routes.createNote),
        child: const Icon(Icons.add),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
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
                  Text(
                    timeago.format(note.createdAt),
                    style: Theme.of(context).textTheme.caption!.apply(color: Colors.white38),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(note.title),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _LabelsBlock(type: note.type, dueString: note.dueString, priority: note.priority),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Column(children: [
                      note.body.isEmpty
                          ? Text(
                              note.body,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  Theme.of(context).textTheme.caption!.apply(color: Colors.white38),
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
    return categories.isNotEmpty
        ? RichText(
            text: TextSpan(
              children: <InlineSpan>[
                WidgetSpan(
                  // Source: https://stackoverflow.com/a/61489854/16553764
                  alignment: ui.PlaceholderAlignment.middle,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: categories[0].color.toColor(),
                    ),
                    child: Text(
                      categories[0].emoji,
                      style: Theme.of(context).textTheme.caption!.copyWith(fontSize: 10),
                    ),
                  ),
                ),
                const TextSpan(text: '  '),
                for (var i = 0; i < categories.length; i++)
                  ..._buildCategoryWidget(context, categories[i], i == categories.length - 1),
              ],
            ),
            // text: WidgetSpan(
            // // children: <TextSpan>[
            // // ],
            // ),
          )
        : const SizedBox();
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
      padding: EdgeInsets.all(6),
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
              // const SizedBox(width: 4),
              // Text(type?.emoji ?? '', style: Theme.of(context).textTheme.caption!),
              // const SizedBox(width: 2),
              // Text(dueString?.emoji ?? '', style: Theme.of(context).textTheme.caption!),
              // const SizedBox(width: 2),
              // Text(priority?.content ?? '', style: Theme.of(context).textTheme.caption!),
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
        ]);
  }
}

class _NoteRepository {
  static Future<List<Note>> getNotes() async {
    await Future.delayed(const Duration(seconds: 1));
    // return [
    //   Note(
    //     id: 1,
    //     title: 'A very long title text that should wrap and be very long',
    //     body: 'This is the first note',
    //     categories: const [
    //       NotionTag(name: '💻 Computer', color: Colors.blue),
    //       NotionTag(name: '📱 Android', color: Colors.red),
    //       NotionTag(name: '🐦 Flutter', color: Colors.green),
    //     ],
    //     createdAt: DateTime.now().subtract(const Duration(days: 2)),
    //   ),
    //   Note(
    //     id: 2,
    //     title: 'Second note',
    //     body: 'This is the second note',
    //     priority: const NotionTag(name: '📛 High', color: Colors.red),
    //     createdAt: DateTime.now(),
    //   ),
    //   Note(
    //     id: 3,
    //     title: 'God damn it you idiot as fuck',
    //     body: 'This is the third note',
    //     type: const NotionTag(name: '💡 Idea', color: Colors.yellow),
    //     dueString: const NotionTag(name: '🥕 Tomorrow', color: Colors.green),
    //     priority: const NotionTag(name: '🚦 Low', color: Colors.blue),
    //     createdAt: DateTime.now().subtract(const Duration(days: 1)),
    //   ),
    //   Note(
    //     id: 4,
    //     title: 'A very long title text that should wrap and be very long',
    //     body: 'This is the first note',
    //     categories: const [
    //       NotionTag(name: '🖌️ Digital Art', color: Colors.orange),
    //       NotionTag(name: '🎹 Music', color: Colors.purple),
    //     ],
    //     createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    //   ),
    //   Note(
    //     id: 3,
    //     title: 'God damn it you idiot as fuck',
    //     body: 'This is the third note',
    //     type: const NotionTag(name: '✨ Event', color: Colors.red),
    //     dueString: const NotionTag(name: '🍍 Upcoming', color: Colors.yellow),
    //     createdAt: DateTime.now().subtract(const Duration(days: 5)),
    //   ),
    // ];
    return [];
  }
}
