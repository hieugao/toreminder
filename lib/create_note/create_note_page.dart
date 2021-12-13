import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../common/utils.dart';
import './models.dart';
import './repository.dart';

class CreateNotePage extends StatefulWidget {
  const CreateNotePage({Key? key}) : super(key: key);

  @override
  State<CreateNotePage> createState() => _CreateNotePageState();
}

class _CreateNotePageState extends State<CreateNotePage> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  late Future<NotionDatabase> _futureNotionDatabase;

  List<NotionTag> _categories = [];
  NotionTag? _dueString;
  NotionTag? _priority;
  NotionTag? _type;

  @override
  void initState() {
    super.initState();
    _futureNotionDatabase = CreateNoteRepository.loadDatabase();
    _syncDB();
  }

  Future<void> _syncDB() async {
    if (await hasNetwork()) {
      _futureNotionDatabase = CreateNoteRepository.fetchDatabase();
      final db = await _futureNotionDatabase;
      CreateNoteRepository.saveDatabase(db);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  bool get _isEmptyLabels {
    return _dueString == null && _priority == null && _type == null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backwardsCompatibility: false,
        systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: Colors.grey[850]),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: TextField(
                controller: _titleController,
                maxLines: null,
                style: Theme.of(context).textTheme.headline6,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.all(0),
                  hintText: 'Write the title...',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey[800],
              ),
              child: FutureBuilder<NotionDatabase>(
                future: _futureNotionDatabase,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final NotionDatabase db = snapshot.data!;

                    // return _ListViewSearch(tags: snapshot.data!.categories);
                    return Column(
                      children: [
                        GestureDetector(
                          // Source: https://stackoverflow.com/a/54850948/16553764
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              elevation: 16,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              builder: (context) => Container(
                                height: MediaQuery.of(context).size.height * 0.75,
                                padding: const EdgeInsets.all(16),
                                child: _ListViewSearch(
                                  tags: db.categories,
                                  onTap: (tags) => setState(() => _categories = tags),
                                ),
                              ),
                            );
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              const Text('Categories'),
                              const SizedBox(width: 8),
                              _categories.isEmpty
                                  ? const _TagPropertyAddButton()
                                  : Row(children: [
                                      for (final NotionTag tag in _categories)
                                        _TagProperty(tag: tag),
                                    ]),
                              // for (final category in _categories)
                              //     _TagProperty(tag: category),
                              // FutureBuilder<NotionDatabase>(
                              //   future: _futureNotionDatabase,
                              //   builder: (context, snapshot) {
                              //     if (snapshot.hasData) {
                              //       // final children = snapshot.data!.categories.map((category) {
                              //       //   return _TagProperty(tag: category);
                              //       // }).toList();
                              //       //
                              //       // return Row(children: children);
                              //       return Container();
                              //     } else if (snapshot.hasError) {
                              //       return Text('${snapshot.error}');
                              //     }

                              //     // By default, show a loading spinner.
                              //     return const CircularProgressIndicator();
                              //   },
                              // ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              elevation: 16,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              builder: (context) => Container(
                                height: MediaQuery.of(context).size.height * 0.85,
                                padding: const EdgeInsets.all(16),
                                child: ListView(
                                  children: [
                                    const Text('Lorem ipsum how uina supoin'),
                                    Row(
                                      children: [],
                                    ),
                                    const SizedBox(height: 16),
                                    const Text('Due string'),
                                    const SizedBox(height: 4),
                                    _GridTagLabel(
                                        tags: snapshot.data!.dueStrings,
                                        onTap: (tag) => setState(() => _dueString = tag)),
                                    const SizedBox(height: 16),
                                    const Text('Due string'),
                                    const SizedBox(height: 4),
                                    _GridTagLabel(
                                        tags: snapshot.data!.priorities,
                                        onTap: (tag) => setState(() => _priority = tag)),
                                    const SizedBox(height: 16),
                                    const Text('Due string'),
                                    const SizedBox(height: 4),
                                    _GridTagLabel(
                                        tags: snapshot.data!.types,
                                        onTap: (tag) => setState(() => _type = tag)),
                                  ],
                                ),
                              ),
                            );
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              const Text('Labels'),
                              const SizedBox(width: 8),
                              _isEmptyLabels
                                  ? const _TagPropertyAddButton()
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                          _dueString != null
                                              ? _TagProperty(tag: _dueString!)
                                              : Container(),
                                          _priority != null
                                              ? _TagProperty(tag: _priority!)
                                              : Container(),
                                          _type != null ? _TagProperty(tag: _type!) : Container(),
                                        ]),
                              // FutureBuilder<NotionDatabase>(
                              //   future: _futureNotionDatabase,
                              //   builder: (context, snapshot) {
                              //     if (snapshot.hasData) {
                              //       // final children = snapshot.data!.categories.map((category) {
                              //       //   return _TagProperty(tag: category);
                              //       // }).toList();
                              //       //
                              //       // return Row(children: children);
                              //       return Container();
                              //     } else if (snapshot.hasError) {
                              //       return Text('${snapshot.error}');
                              //     }

                              //     // By default, show a loading spinner.
                              //     return const CircularProgressIndicator();
                              //   },
                              // ),
                            ],
                          ),
                        ),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Text('${snapshot.error}');
                  }

                  // By default, show a loading spinner.
                  // return const CircularProgressIndicator();
                  return Container();
                },
              ),
            ),
            const SizedBox(height: 8),
            Card(
              margin: const EdgeInsets.all(0),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height * 0.25,
                ),
                child: TextField(
                  controller: _bodyController,
                  decoration: const InputDecoration(
                    hintText: 'Write the content...',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigator.pushNamed(context, Routes.createNote),
          //   void _sendDataBack(BuildContext context) {
          //     String textToSendBack = textFieldController.text;
          //     Navigator.pop(context, textToSendBack);
          //   }

          final note = Note(
            id: Random().nextInt(10000),
            title: _titleController.text,
            body: _bodyController.text,
            categories: _categories,
            dueString: _dueString,
            priority: _priority,
            type: _type,
            createdAt: DateTime.now(),
          );

          Navigator.pop(context, note);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// class _NoteProperty extends StatelessWidget {
//   const _NoteProperty({Key? key}) : super(key: key);

//   final String title;
//   final List<NotionTag> tags;

//   @override
//   Widget build(BuildContext context) {
//     return Container();
//   }
// }

class _TagPropertyAddButton extends StatelessWidget {
  const _TagPropertyAddButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey[800],
      ),
      child: const Icon(Icons.add),
    );
  }
}

class _TagProperty extends StatelessWidget {
  const _TagProperty({
    Key? key,
    required this.tag,
  }) : super(key: key);

  final NotionTag tag;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey[800],
      ),
      child: Text(tag.name,
          style: Theme.of(context).textTheme.bodyText2!.apply(color: tag.color.toColor())),
    );
  }
}

// Source: https://karthikponnam.medium.com/flutter-search-in-listview-1ffa40956685
// Source: https://www.kindacode.com/article/how-to-create-a-filter-search-listview-in-flutter
class _ListViewSearch extends StatefulWidget {
  const _ListViewSearch({
    Key? key,
    required this.tags,
    required this.onTap,
  }) : super(key: key);

  final List<NotionTag> tags;
  final Function(List<NotionTag>) onTap;

  @override
  _ListViewSearchState createState() => _ListViewSearchState();
}

class _ListViewSearchState extends State<_ListViewSearch> {
  TextEditingController editingController = TextEditingController();

  late List<String> _tagNames;
  List<String> _foundTags = [];
  List<NotionTag> _selectedTags = [];

  @override
  void initState() {
    _tagNames = widget.tags.map((tag) => tag.name).toList();
    _foundTags.addAll(_tagNames);
    super.initState();
  }

  void _filter(String keyword) {
    List<String> results = [];

    if (keyword.isEmpty) {
      results = _tagNames;
    } else {
      results =
          _tagNames.where((tag) => tag.toLowerCase().contains(keyword.toLowerCase())).toList();
    }

    setState(() => _foundTags = results);
  }

  void _onTap(int index) {
    final NotionTag tag = widget.tags[index];
    final bool isSelected = _selectedTags.contains(tag);

    if (!isSelected) {
      setState(() {
        _selectedTags.add(tag);
      });
      widget.onTap(_selectedTags);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: (value) {
              _filter(value);
            },
            controller: editingController,
            decoration: const InputDecoration(
                labelText: "Search",
                hintText: "Search",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(25.0)))),
          ),
        ),
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _foundTags.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_foundTags[index]),
                onTap: () => _onTap(index),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TagLabel extends StatelessWidget {
  const _TagLabel({
    Key? key,
    required this.tag,
    required this.onTap,
    this.isSelected = false,
    this.emojiOnly = false,
  }) : super(key: key);

  final NotionTag tag;
  final Function(NotionTag) onTap;
  final bool isSelected;
  final bool emojiOnly;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(tag),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isSelected ? tag.color.toColor().withOpacity(0.6) : Colors.grey[800],
            ),
            child: Text(tag.emoji,
                style: Theme.of(context).textTheme.bodyText2!.apply(color: tag.color.toColor())),
          ),
          const SizedBox(width: 6),
          Text(tag.content,
              style: Theme.of(context).textTheme.bodyText2!.apply(color: tag.color.toColor())),
        ],
      ),
    );
  }
}

class _GridTagLabel extends StatefulWidget {
  const _GridTagLabel({
    Key? key,
    required this.tags,
    required this.onTap,
  }) : super(key: key);

  final List<NotionTag> tags;
  final Function(NotionTag) onTap;

  @override
  State<_GridTagLabel> createState() => _GridTagLabelState();
}

class _GridTagLabelState extends State<_GridTagLabel> {
  NotionTag? _selectedTag;

  @override
  Widget build(BuildContext context) {
    // return Container(
    //   padding: const EdgeInsets.all(8),
    //   decoration: BoxDecoration(
    //     borderRadius: BorderRadius.circular(16),
    //     color: Colors.grey[800],
    //   ),
    //   child: GridView.count(
    //     physics: const NeverScrollableScrollPhysics(),
    //     crossAxisCount: 3,
    //     children: tags.map((tag) => _TagLabel(tag: tag, onTap: onTap)).toList(),
    //   ),
    // );
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      itemCount: widget.tags.length,
      itemBuilder: (context, index) {
        return _TagLabel(
          tag: widget.tags[index],
          onTap: (tag) {
            setState(() {
              _selectedTag = widget.tags[index];
            });
            widget.onTap(tag);
          },
          isSelected: _selectedTag == widget.tags[index],
        );
      },

      // crossAxisCount: 3,
      // crossAxisSpacing: 1.0,
      // mainAxisSpacing: 1.0,
      // padding: const EdgeInsets.all(0),
      // children: tags.map((tag) => _TagLabel(tag: tag, onTap: onTap)).toList(),
    );
  }
}

// class FirstScreen extends StatefulWidget {
//   @override
//   _FirstScreenState createState() {
//     return _FirstScreenState();
//   }
// }

// class _FirstScreenState extends State<FirstScreen> {

//   String text = 'Text';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('First screen')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [

//             Padding(
//               padding: const EdgeInsets.all(32.0),
//               child: Text(
//                 text,
//                 style: TextStyle(fontSize: 24),
//               ),
//             ),

//             RaisedButton(
//               child: Text(
//                 'Go to second screen',
//                 style: TextStyle(fontSize: 24),
//               ),
//               onPressed: () {
//                 _awaitReturnValueFromSecondScreen(context);
//               },
//             )

//           ],
//         ),
//       ),
//     );
//   }

//   void _awaitReturnValueFromSecondScreen(BuildContext context) async {

//     // start the SecondScreen and wait for it to finish with a result
//     final result = await Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => SecondScreen(),
//         ));

//     // after the SecondScreen result comes back update the Text widget with it
//     setState(() {
//       text = result;
//     });
//   }
// }

// class SecondScreen extends StatefulWidget {
//   @override
//   _SecondScreenState createState() {
//     return _SecondScreenState();
//   }
// }

// class _SecondScreenState extends State<SecondScreen> {
//   // this allows us to access the TextField text
//   TextEditingController textFieldController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Second screen')),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [

//           Padding(
//             padding: const EdgeInsets.all(32.0),
//             child: TextField(
//               controller: textFieldController,
//               style: TextStyle(
//                 fontSize: 24,
//                 color: Colors.black,
//               ),
//             ),
//           ),

//           RaisedButton(
//             child: Text(
//               'Send text back',
//               style: TextStyle(fontSize: 24),
//             ),
//             onPressed: () {
//               _sendDataBack(context);
//             },
//           )

//         ],
//       ),
//     );
//   }

//   // get the text in the TextField and send it back to the FirstScreen
//   void _sendDataBack(BuildContext context) {
//     String textToSendBack = textFieldController.text;
//     Navigator.pop(context, textToSendBack);
//   }
// }