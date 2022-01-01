import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/note/models.dart';
import '../home/view_models.dart';
import 'view_models.dart';

// TODO: Convert to `StatelessWidget` and use `Consumer` instead, `title` and `body` don't
// have to rebuild.
class CreateNotePage extends ConsumerWidget {
  const CreateNotePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // FIXME: This will be called every time `note` is changed, I only want to call it once
    // when internet is available:
    // 1. Already
    // 2. When internet is available
    // WidgetsBinding.instance?.addPostFrameCallback((_) {
    //   ref.read(notionDatabaseProvider.notifier).init();
    // });

    final note = ref.watch(noteProvider);
    // FIXME: Doesn't rebuild only loading.
    // final asyncDB = ref.watch(notionDatabaseProvider);
    final asyncDb = ref.watch(notionDatabaseProvider);

    final bool isEmptyLabels = note.dueString == null && note.priority == null && note.type == null;

    print('Rebuilt check - Create Note page');

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
              child: _TextEditingBlock(
                // TODO: Will use controller when editing feature is implemented.
                // controller: _titleController,
                style: Theme.of(context).textTheme.headline6!,
                onChanged: (value) =>
                    ref.read(noteProvider.state).state = note.copyWith(title: value),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey[800],
              ),
              child: Column(
                children: [
                  GestureDetector(
                    // Source: https://stackoverflow.com/a/54850948/16553764
                    behavior: HitTestBehavior.translucent,
                    onTap: () => _showMBS(
                      context,
                      asyncDb.when(
                        data: (db) => _ListViewSearch(
                          tags: db.categories,
                          onComplete: (tags) =>
                              ref.read(noteProvider.state).state = note.copyWith(categories: tags),
                        ),
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (_, __) => const Center(child: Text('Error')),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const Text('Categories'),
                        const SizedBox(width: 8),
                        note.categories.isEmpty
                            ? const _TagPropertyAddButton()
                            : SizedBox(
                                height: 24,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  physics: const ClampingScrollPhysics(),
                                  // physics: const NeverScrollableScrollPhysics(),
                                  itemCount: note.categories.length,
                                  itemBuilder: (context, index) {
                                    final tag = note.categories[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 4.0),
                                      child: _TagProperty(
                                        tag: tag,
                                        // onDelete: () => ref.read(noteProvider.state).state =
                                        //     note.copyWith(categories: note.categories.where((t) => t != tag).toList()),
                                      ),
                                    );
                                  },
                                  // children: [
                                  //   for (final NotionTag tag in note.categories)
                                  //     _TagProperty(tag: tag)
                                  // ],
                                ),
                              ),
                        // : Row(children: [
                        //     for (final NotionTag tag in note.categories) _TagProperty(tag: tag),
                        //   ]),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // GestureDetector(
                  //   behavior: HitTestBehavior.translucent,
                  //   onTap: () {
                  //     _showMBS(
                  //       context,
                  //       asyncDB.when(
                  //         data: (db) => _LabelsModal(
                  //           dueStrings: db.dueStrings,
                  //           priorities: db.priorities,
                  //           types: db.types,
                  //           onCompleted: (dueString, priority, type) => {
                  //             ref.read(noteProvider.state).state = note.copyWith(
                  //               dueString: dueString,
                  //               priority: priority,
                  //               type: type,
                  //             ),
                  //           },
                  //         ),
                  //         loading: () => const Center(child: CircularProgressIndicator()),
                  //         error: (_, __) => const Center(child: Text('Error')),
                  //       ),
                  //     );
                  //   },
                  //   child: Row(
                  //     mainAxisSize: MainAxisSize.max,
                  //     children: [
                  //       const Text('Labels'),
                  //       const SizedBox(width: 8),
                  //       isEmptyLabels
                  //           ? const _TagPropertyAddButton()
                  //           : Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                  //               note.dueString != null
                  //                   ? _TagProperty(tag: note.dueString!)
                  //                   : Container(),
                  //               note.priority != null
                  //                   ? _TagProperty(tag: note.priority!)
                  //                   : Container(),
                  //               note.type != null ? _TagProperty(tag: note.type!) : Container(),
                  //             ]),
                  //     ],
                  //   ),
                  // ),
                ],
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
                child: _TextEditingBlock(
                  style: Theme.of(context).textTheme.bodyText1!,
                  onChanged: (value) =>
                      ref.read(noteProvider.state).state = note.copyWith(body: value),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(noteListProvider.notifier).add(note);
          Navigator.pop(context, note);
          ref.read(noteProvider.state).state = Note.initial();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  dynamic _showMBS(BuildContext context, Widget child) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      elevation: 16,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(16),
        child: child,
        // child: asyncDB.when(
        //   data: (db) => _ListViewSearch(
        //     tags: db.categories,
        //     onComplete: (tags) => ref.read(noteProvider.state).state =
        //         note.copyWith(categories: tags),
        //   ),
        //   loading: () => const Center(child: CircularProgressIndicator()),
        //   error: (_, __) => const Center(child: Text('Error')),
        // ),
      ),
    );
  }
}

// Source: https://stackoverflow.com/a/52930197/16553764
class _TextEditingBlock extends StatefulWidget {
  const _TextEditingBlock({Key? key, required this.style, required this.onChanged})
      : super(key: key);

  final TextStyle style;
  final Function(String) onChanged;

  @override
  State<_TextEditingBlock> createState() => _TextEditingBlockState();
}

class _TextEditingBlockState extends State<_TextEditingBlock> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 750), () => widget.onChanged(query));
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      // TODO: Will use controller when editing feature is implemented.
      // controller: _titleController,
      onChanged: _onSearchChanged,
      maxLines: null,
      style: widget.style,
      // Theme.of(context).textTheme.headline6,
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.all(0),
        hintText: 'Write text here...',
        border: InputBorder.none,
      ),
    );
  }
}

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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: tag.color.bg!.withOpacity(0.2),
      ),
      child: Text(
        tag.name,
        style: Theme.of(context).textTheme.bodyText2!.apply(color: tag.color.fg),
      ),
    );
  }
}

// Source: https://karthikponnam.medium.com/flutter-search-in-listview-1ffa40956685
// Source: https://www.kindacode.com/article/how-to-create-a-filter-search-listview-in-flutter
// TODO: Add shimmer for local storage.
// TODO: Add fade popping for web api.
class _ListViewSearch extends StatefulWidget {
  const _ListViewSearch({
    Key? key,
    required this.tags,
    required this.onComplete,
  }) : super(key: key);

  final List<NotionTag> tags;
  final Function(List<NotionTag>) onComplete;

  @override
  _ListViewSearchState createState() => _ListViewSearchState();
}

class _ListViewSearchState extends State<_ListViewSearch> {
  TextEditingController editingController = TextEditingController();

  // late List<String> _tagNames;
  List<NotionTag> _foundTags = [];
  List<NotionTag> _selectedTags = [];

  @override
  void initState() {
    // _tagNames = widget.tags.map((tag) => tag.name).toList();
    // _foundTags.addAll(_tagNames);
    _foundTags = widget.tags;
    super.initState();
  }

  // * Don't have much of items so I'm not worry too much about performance.
  void _filter(String keyword) {
    if (keyword.isEmpty) {
      setState(() => _foundTags = widget.tags);
    } else {
      final results = widget.tags
          .where((tag) => tag.name.toLowerCase().contains(keyword.toLowerCase()))
          .toList();
      setState(() => _foundTags = results);
    }
  }

  void _onTap(NotionTag tag) {
    if (!_selectedTags.contains(tag)) {
      setState(() => _selectedTags.add(tag));
    } else {
      setState(() => _selectedTags.remove(tag));
    }
  }

  // TODO: Add support for `pop` also.
  void _onComplete() {
    widget.onComplete(_selectedTags);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          // mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      _filter(value);
                    },
                    controller: editingController,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[800],
                      focusColor: Theme.of(context).colorScheme.primaryVariant,
                      // fillColor: Colors.white,
                      // labelText: "Search",
                      hintText: "Search",
                      isDense: true,
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      // border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(25.0))),
                      // border: InputBorder.none,
                    ),
                  ),
                ),
                if (_selectedTags.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _selectedTags.length.toString(),
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1!
                          .copyWith(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                ] else
                  const SizedBox(),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _foundTags.length,
                itemBuilder: (context, index) {
                  final emoji = _foundTags[index].emoji;

                  return ListTile(
                    tileColor: _selectedTags.contains(_foundTags[index])
                        ? _foundTags[index].color.bg!.withOpacity(0.2)
                        : null,
                    leading: emoji != null ? Text(emoji) : const SizedBox(),
                    title: Text(_foundTags[index].content),
                    onTap: () => _onTap(_foundTags[index]),
                  );
                },
              ),
            ),
          ],
        ),
        Positioned(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 0,
          right: 0,
          child: ElevatedButton(
            style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                // side: BorderSide(color: Colors.red)
              ),
            )),
            onPressed: _onComplete,
            child: const Text("Complete"),
          ),
        ),
      ],
    );
  }
}

class _LabelsModal extends StatefulWidget {
  const _LabelsModal({
    Key? key,
    required this.dueStrings,
    required this.priorities,
    required this.types,
    // this.dueString,
    // this.priority,
    // this.type,
    required this.onCompleted,
  }) : super(key: key);

  final List<NotionTag> dueStrings;
  final List<NotionTag> priorities;
  final List<NotionTag> types;
  // final NotionTag? dueString;
  // final NotionTag? priority;
  // final NotionTag? type;
  final Function(NotionTag?, NotionTag?, NotionTag?) onCompleted;

  @override
  State<_LabelsModal> createState() => _LabelsModalState();
}

class _LabelsModalState extends State<_LabelsModal> {
  NotionTag? _dueString;
  NotionTag? _priority;
  NotionTag? _type;

  @override
  void initState() {
    super.initState();
    // _dueString = widget.dueString;
    // _priority = widget.priority;
    // _type = widget.type;
  }

  void _onCompleted() {
    widget.onCompleted(_dueString, _priority, _type);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          const Text('Lorem ipsum how uina supoin'),
          const SizedBox(height: 16),
          const Text('Due string'),
          const SizedBox(height: 4),
          _GridTagLabel(
            tags: widget.dueStrings,
            onTap: (tag) => setState(() => _dueString = tag),
            // onTap: (tag) => ref.read(noteProvider.state).state = note.copyWith(dueString: tag),
          ),
          const SizedBox(height: 16),
          const Text('Due string'),
          const SizedBox(height: 4),
          _GridTagLabel(
            tags: widget.priorities,
            onTap: (tag) => setState(() => _priority = tag),
            // onTap: (tag) => ref.read(noteProvider.state).state = note.copyWith(priority: tag),
          ),
          const SizedBox(height: 16),
          const Text('Due string'),
          const SizedBox(height: 4),
          _GridTagLabel(
            tags: widget.types,
            // onTap: (tag) => ref.read(noteProvider.state).state = note.copyWith(type: tag),
            onTap: (tag) => setState(() => _type = tag),
          ),
          TextButton(
            onPressed: _onCompleted,
            child: Text('Complete'),
          )
        ],
      ),
    );

    // child: asyncDB.when(
    //   data: (db) => ListView(
    //     children: [
    //       const Text('Lorem ipsum how uina supoin'),
    //       const SizedBox(height: 16),
    //       const Text('Due string'),
    //       const SizedBox(height: 4),
    //       _GridTagLabel(
    //         tags: db.dueStrings,
    //         onTap: (tag) => ref.read(noteProvider.state).state = note.copyWith(dueString: tag),
    //       ),
    //       const SizedBox(height: 16),
    //       const Text('Due string'),
    //       const SizedBox(height: 4),
    //       _GridTagLabel(
    //         tags: db.priorities,
    //         onTap: (tag) => ref.read(noteProvider.state).state = note.copyWith(priority: tag),
    //       ),
    //       const SizedBox(height: 16),
    //       const Text('Due string'),
    //       const SizedBox(height: 4),
    //       _GridTagLabel(
    //         tags: db.types,
    //         onTap: (tag) => ref.read(noteProvider.state).state = note.copyWith(type: tag),
    //       ),
    //     ],
    //   ),
    //   loading: () => const Center(child: CircularProgressIndicator()),
    //   error: (e, st) => Text('Error: $e'),
    // ));
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
        crossAxisCount: 4,
      ),
      itemCount: widget.tags.length,
      itemBuilder: (context, index) {
        return _TagLabel(
          tag: widget.tags[index],
          isSelected: _selectedTag == widget.tags[index],
          emojiOnly: true,
          onTap: (tag) {
            setState(() => _selectedTag = widget.tags[index]);
            widget.onTap(tag);
          },
        );
      },
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
              color: isSelected ? tag.color.fg.withOpacity(0.6) : Colors.grey[800],
            ),
            child: Text(
              tag.emoji ?? '',
              style: Theme.of(context).textTheme.bodyText2!.apply(color: tag.color.fg),
            ),
          ),
          if (!emojiOnly) ...[
            const SizedBox(width: 6),
            Text(tag.content,
                style: Theme.of(context).textTheme.bodyText2!.apply(color: tag.color.fg)),
          ] else
            const SizedBox(),
        ],
      ),
    );
  }
}
