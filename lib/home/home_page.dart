import 'dart:async';
import 'dart:ui' as ui;

// import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:lottie/lottie.dart';
import 'package:notion_capture/home/bookmark_section.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/material.dart';

import '../common/constants.dart';
import '../create_note/models.dart';
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
    final result = await Navigator.pushNamed(context, Routes.createNote);
    // Navigator.pushNamed(context, Routes.createNote),
    setState(() => _notes.add(result as Note));
    HomeRepository.saveNotes(_notes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey[850],
        // title: Text(widget.title),
      ),
      body: _notes.isEmpty
          ? const Center(child: _EmptyNotesIllustration())
          : Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Flexible(
                    flex: 50,
                    child: ListView.builder(
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
                    )

                    // child: FutureBuilder<List<Note>>(
                    //   future: _futureNotes,
                    //   builder: (context, snapshot) {
                    //     if (snapshot.hasData) {
                    //       // return Text(snapshot.data!.title);
                    //       // return const _EmptyNotesIllustration();
                    //       if (snapshot.data != null && snapshot.data!.isEmpty) {
                    //         return const _EmptyNotesIllustration();
                    //       }

                    //       return ListView.builder(
                    //           itemCount: snapshot.data?.length ?? 0,
                    //           itemBuilder: (context, index) {
                    //             final note = snapshot.data![index];

                    //             return _NoteCard(
                    //               note: note,
                    //               onTap: () {},
                    //             );
                    //           });
                    //     } else if (snapshot.hasError) {
                    //       return Text('${snapshot.error}');
                    //     }

                    //     // By default, show a loading spinner.
                    //     return const CircularProgressIndicator();
                    //   },
                    // ),
                    ),
                const Spacer(),
                const Flexible(flex: 45, child: BookmarkSection()),
              ],
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CategoriesBlock(categories: note.categories ?? []),
                  Text(
                    timeago.format(note.createdAt),
                    style: Theme.of(context).textTheme.caption!.apply(color: Colors.white38),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Column(children: [
                      Text(note.title),
                      const SizedBox(height: 8),
                      note.body != null
                          ? Text(
                              note.body!,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  Theme.of(context).textTheme.caption!.apply(color: Colors.white38),
                            )
                          : Container(),
                    ]),
                  ),
                  const SizedBox(width: 8),
                  _ArrangementBlock(
                      type: note.type, dueString: note.dueString, priority: note.priority)
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

  // String _tagName(String string) {
  //   if (string.length > 12 && string.length > 2) {
  //     return string.substring(0, 12) + '...';
  //   } else {
  //     return string;
  //   }
  // }

  // String _titleText(String string) {
  //   if (['', null].contains(string)) {
  //     return _contentText(note.content!);
  //   } else {
  //     if (string.split(' ').length > 10) {
  //       return CantonMethods.addDotsToString(note.title!, 10);
  //     } else {
  //       return string;
  //     }
  //   }
  // }

  // String _contentText(String string) {
  //   if (note.content!.split(' ').length > 10) {
  //     return CantonMethods.addDotsToString(note.content!, 10);
  //   } else {
  //     if (!(note.content! == '')) {
  //       return note.content!;
  //     } else {
  //       return 'No additional text';
  //     }
  //   }
  // }

  // Widget _body(BuildContext context) {
  //   // Creates tags on the note card.
  //   List<Widget> _tags = [];

  //   for (var tag in note.tags!) {
  //     _tags.add(
  //       Card(
  //         color: Theme.of(context).primaryColor,
  //         shape: SquircleBorder(radius: BorderRadius.circular(15)),
  //         child: Padding(
  //           padding: const EdgeInsets.all(4.0),
  //           child: Text(
  //             _tagName(tag.name!),
  //             style: Theme.of(context).textTheme.bodyText2?.copyWith(color: CantonColors.white),
  //           ),
  //         ),
  //       ),
  //     );
  //   }

  //   if (_tags.length > 3) {
  //     _tags.removeRange(3, _tags.length);
  //     _tags.add(
  //       Card(
  //         color: Theme.of(context).primaryColor,
  //         shape: SquircleBorder(radius: BorderRadius.circular(15)),
  //         child: Padding(
  //           padding: const EdgeInsets.all(4.0),
  //           child: Text(
  //             'more',
  //             style: Theme.of(context).textTheme.bodyText2?.copyWith(color: CantonColors.white),
  //           ),
  //         ),
  //       ),
  //     );
  //   }

  //   return Row(
  //     children: <Widget>[
  //       [null, false].contains(note.pinned)
  //           ? Container()
  //           : Icon(
  //               CupertinoIcons.pin_fill,
  //               size: 15,
  //               color: Theme.of(context).colorScheme.secondaryVariant,
  //             ),
  //       SizedBox(width: 7),
  //       Expanded(
  //         flex: 10,
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(_titleText(note.title!), style: Theme.of(context).textTheme.headline6!),
  //             const SizedBox(height: 7),
  //             note.tags!.length > 0
  //                 ? Row(
  //                     children: _tags,
  //                   )
  //                 : Container(),
  //             note.tags!.length > 0 ? const SizedBox(height: 7) : Container(),
  //             Text(_contentText(note.content!), style: Theme.of(context).textTheme.bodyText1!),
  //           ],
  //         ),
  //       ),
  //       Spacer(),
  //       Text(
  //         ListNote.dateTimeString(note.lastEditDate!).substring(6),
  //         textAlign: TextAlign.right,
  //         style: Theme.of(context).textTheme.bodyText2!.copyWith(color: CantonColors.textTertiary),
  //       ),
  //     ],
  //   );
  // }

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
                      borderRadius: BorderRadius.circular(8),
                      // color: Theme.of(context).colorScheme.secondary,
                      color: Colors.grey[700],
                    ),
                    child: Text(
                      categories[0].content,
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                  ),
                ),
                for (var i = 0; i < categories.length; i++)
                  ...getCategoryWidget(context, categories[i], i == categories.length - 1),
              ],
            ),
            // text: WidgetSpan(
            // // children: <TextSpan>[
            // // ],
            // ),
          )
        : const SizedBox();
  }

  List<TextSpan> getCategoryWidget(BuildContext context, NotionTag category,
      [bool isLast = false]) {
    return [
      TextSpan(
        text: ' ' + category.content,
        // style: Theme.of(context).textTheme.caption!.apply(color: category.color),
      ),
      !isLast
          ? TextSpan(
              text: ',',
              style: Theme.of(context)
                  .textTheme
                  .bodyText2!
                  .apply(color: Theme.of(context).disabledColor),
            )
          : const TextSpan(text: ''),
    ];
  }
}

class _ArrangementBlock extends StatelessWidget {
  const _ArrangementBlock({
    Key? key,
    this.type,
    this.dueString,
    this.priority,
  }) : super(key: key);

  final NotionTag? type;
  final NotionTag? dueString;
  final NotionTag? priority;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[700],
      ),
      child: Column(
        children: [
          Text(type?.content ?? '', style: Theme.of(context).textTheme.caption!),
          Text(dueString?.content ?? '', style: Theme.of(context).textTheme.caption!),
          Text(priority?.content ?? '', style: Theme.of(context).textTheme.caption!),
        ],
      ),
    );
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
