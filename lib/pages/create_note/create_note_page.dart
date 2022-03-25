import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../common/widgets.dart';
import '../../features/note/models.dart';
import '../home_note/view_models.dart';
import './view_models.dart';

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

    final bool isEmptyTime =
        note.dueString == null && note.priority == null; // && note.type == null;

    print('Rebuilt check - Create Note page');

    return Scaffold(
      // appBar: AppBar(
      //   // backwardsCompatibility: false,
      //   // title: const Text('Create Note'),
      //   systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: Colors.grey[850]),
      //   automaticallyImplyLeading: false,
      //   elevation: 0,
      //   backgroundColor: Colors.transparent,
      // ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 32, 16, 0),
          child: Column(
            children: [
              // Title block.
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: _TextEditingBlock(
                  // TODO: Will use controller when editing feature is implemented.
                  // controller: _titleController,
                  hintText: "Untitled",
                  autofocus: true,
                  style:
                      Theme.of(context).textTheme.headline6!.copyWith(fontWeight: FontWeight.w500),
                  onChanged: (value) =>
                      ref.read(noteProvider.state).state = note.copyWith(title: value),
                ),
              ),

              const SizedBox(height: 16),

              // ! Labels Block.
              _NoteProperty(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16), bottom: Radius.circular(4)),
                tags: note.labels,
                mbsChild: asyncDb.when(
                  data: (db) => _LabelsListViewSearch(
                    tags: db.labels,
                    onCompleted: (tags) =>
                        ref.read(noteProvider.state).state = note.copyWith(labels: tags),
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const Center(child: Text('Error')),
                ),
              ),

              const SizedBox(height: 4),

              // ! Due string.
              _NoteProperty(
                borderRadius: BorderRadius.circular(4),
                tags: note.dueString != null ? [note.dueString!] : [],
                mbsChild: asyncDb.when(
                  data: (db) => _DueStringandPriorityMBS(
                    dueStrings: db.dueStrings,
                    priorities: db.priorities,
                    onCompleted: (dueString, priority, type) => {
                      ref.read(noteProvider.state).state = note.copyWith(
                        dueString: dueString,
                        priority: priority,
                      ),
                    },
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const Center(child: Text('Error')),
                ),
                mbsHeightPercentage: 0.75,
                icon: const Icon(FontAwesomeIcons.calendarWeek, size: 13),
                label: 'Due string',
              ),

              const SizedBox(height: 4),

              // ! Priority.
              _NoteProperty(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4), bottom: Radius.circular(16)),
                tags: note.priority != null ? [note.priority!] : [],
                mbsChild: asyncDb.when(
                  data: (db) => _DueStringandPriorityMBS(
                    dueStrings: db.dueStrings,
                    priorities: db.priorities,
                    onCompleted: (dueString, priority, type) => {
                      ref.read(noteProvider.state).state = note.copyWith(
                        dueString: dueString,
                        priority: priority,
                      ),
                    },
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const Center(child: Text('Error')),
                ),
                mbsHeightPercentage: 0.75,
                icon: const Icon(FontAwesomeIcons.solidFlag, size: 13),
                label: 'Priority',
              ),

              const SizedBox(height: 20),

              // FIXME: Use Expanded instead!
              // Note's content.
              Container(
                padding: const EdgeInsets.only(left: 8),
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height * 0.25,
                ),
                child: _TextEditingBlock(
                  hintText: 'Enter note\'s content here...',
                  style: Theme.of(context).textTheme.bodyText1!.apply(color: Colors.white70),
                  onChanged: (value) =>
                      ref.read(noteProvider.state).state = note.copyWith(body: value),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onPressed(context, note, ref),
        child: Icon(note.title.isEmpty ? Icons.arrow_back : Icons.add),
      ),
    );
  }

  void _onPressed(BuildContext context, Note note, WidgetRef ref) {
    ref.read(noteListProvider.notifier).add(note);
    ref.read(noteProvider.state).state = Note.initial();
    Navigator.pop(context, note);
  }
}

// Source: https://stackoverflow.com/a/52930197/16553764
class _TextEditingBlock extends StatefulWidget {
  const _TextEditingBlock({
    Key? key,
    required this.style,
    required this.hintText,
    required this.onChanged,
    this.autofocus = false,
  }) : super(key: key);

  final TextStyle style;
  final String hintText;
  final Function(String) onChanged;
  final bool autofocus;

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

    _debounce = Timer(const Duration(milliseconds: 500), () => widget.onChanged(query));
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      // TODO: Will use controller when editing feature is implemented.
      // controller: _titleController,
      autofocus: widget.autofocus,
      onChanged: _onSearchChanged,
      maxLines: null,
      style: widget.style,
      // Theme.of(context).textTheme.headline6,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.all(0),
        hintText: widget.hintText, // 'Write text here...',
        border: InputBorder.none,
      ),
    );
  }
}

class _NoteProperty extends StatelessWidget {
  const _NoteProperty({
    Key? key,
    required this.borderRadius,
    required this.tags,
    required this.mbsChild,
    this.mbsHeightPercentage = 0.85,
    this.icon = const Icon(FontAwesomeIcons.tags, size: 12),
    this.label = 'Labels',
  }) : super(key: key);

  final BorderRadiusGeometry borderRadius;
  final List<NotionTag> tags;
  final Widget mbsChild;
  final double mbsHeightPercentage;
  final Icon icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: Colors.grey[800],
      ),
      child: GestureDetector(
        // Source: https://stackoverflow.com/a/54850948/16553764
        behavior: HitTestBehavior.translucent,
        onTap: () => _showMBS(context, mbsChild),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          // mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Icon.
            Padding(padding: const EdgeInsets.only(right: 6.0), child: icon),

            // Label.
            Flexible(flex: 250, fit: FlexFit.tight, child: Text(label)),

            // Tag.
            tags.isEmpty
                ? _buildTagPropertyAddButton()
                : Flexible(
                    flex: 550,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        height: 24,
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          physics: const ClampingScrollPhysics(),
                          // physics: const NeverScrollableScrollPhysics(),
                          itemCount: tags.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 4.0),
                              child: TagProperty(
                                tag: tags[index],
                                // onDelete: () => ref.read(noteProvider.state).state =
                                //     note.copyWith(categories: note.categories.where((t) => t != tag).toList()),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagPropertyAddButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey[800],
      ),
      child: const Icon(Icons.add),
    );
  }

  dynamic _showMBS(BuildContext context, Widget child) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      elevation: 16,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * mbsHeightPercentage,
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

// Source: https://karthikponnam.medium.com/flutter-search-in-listview-1ffa40956685
// Source: https://www.kindacode.com/article/how-to-create-a-filter-search-listview-in-flutter
// TODO: Add shimmer for local storage.
// TODO: Add fade popping for web api.
class _LabelsListViewSearch extends StatefulWidget {
  const _LabelsListViewSearch({
    Key? key,
    required this.tags,
    required this.onCompleted,
  }) : super(key: key);

  final List<NotionTag> tags;
  final Function(List<NotionTag>) onCompleted;

  @override
  _LabelsListViewSearchState createState() => _LabelsListViewSearchState();
}

class _LabelsListViewSearchState extends State<_LabelsListViewSearch> {
  TextEditingController editingController = TextEditingController();

  // late List<String> _tagNames;
  List<NotionTag> _foundTags = [];
  final List<NotionTag> _selectedTags = [];

  @override
  void initState() {
    // _tagNames = widget.tags.map((tag) => tag.name).toList();
    // _foundTags.addAll(_tagNames);
    _foundTags = widget.tags;
    super.initState();
  }

  // * Don't have much of items so I'm not worry too much about the performance.
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
  // void _onComplete() {
  //   widget.onCompleted(_selectedTags);
  //   Navigator.of(context).pop();
  // }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Column(children: <Widget>[
        const SizedBox(height: 12),

        Row(children: [
          // Search bar.
          Expanded(
            child: TextField(
              onChanged: _filter,
              controller: editingController,
              textAlignVertical: TextAlignVertical.center,
              style: Theme.of(context).textTheme.subtitle2,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[900],
                focusColor: Theme.of(context).colorScheme.primaryVariant,
                // fillColor: Colors.white,
                // labelText: "Search",
                hintText: "Search tags...",
                hintStyle: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.white38),
                isDense: true,
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                // border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(25.0))),
                // border: InputBorder.none,
              ),
            ),
          ),
        ]),

        const SizedBox(height: 12),

        // Tag list.
        Expanded(
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: _foundTags.length,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemBuilder: (context, index) {
              final emoji = _foundTags[index].emoji;

              return ListTile(
                contentPadding: EdgeInsets.zero,
                minLeadingWidth: 16,
                tileColor: _selectedTags.contains(_foundTags[index])
                    ? Colors.grey.shade900.withOpacity(0.67)
                    : null,
                // _selectedTags.contains(_foundTags[index]) ? _foundTags[index].color.bg!.withOpacity(0.2) : null,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

                leading: emoji != null
                    ? Text(emoji)
                    : Checkbox(
                        checkColor: Colors.orange.shade500,
                        // fillColor:  // MaterialStateProperty.resolveWith(Colors.transparent),
                        activeColor: Colors.transparent,
                        value: _selectedTags.contains(_foundTags[index]),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        onChanged: (bool? value) {
                          // setState(() {
                          //   isChecked = value!;
                          // });
                        },
                      ),
                title: Transform.translate(
                  offset: const Offset(-16, 0),
                  child: Text(
                    _foundTags[index].content,
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1!
                        .copyWith(color: _foundTags[index].color.fg),
                  ),
                ),
                onTap: () => _onTap(_foundTags[index]),
              );
            },
          ),
        ),
      ]),

      // Complete button.
      Positioned(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 0,
          right: 0,
          child: _CompleteAndCancleButtons(onCompleted: () {
            widget.onCompleted(_selectedTags);
            Navigator.of(context).pop();
          }, onCancel: () {
            // widget.onCompleted([]);
            Navigator.of(context).pop();
          })),
    ]);
  }
}

class _CompleteAndCancleButtons extends StatelessWidget {
  const _CompleteAndCancleButtons({
    Key? key,
    required this.onCompleted,
    required this.onCancel,
  }) : super(key: key);

  final VoidCallback onCompleted;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(48, 40),
            padding: const EdgeInsets.symmetric(horizontal: 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          onPressed: onCompleted,
          child: Text(
            "Complete",
            style: Theme.of(context).textTheme.button!.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton(
          onPressed: onCancel,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(48, 40),
            side: const BorderSide(color: Colors.white54, width: 2),
            // padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: const Icon(FontAwesomeIcons.times, size: 16, color: Colors.white70),
        ),
      ],
    );
  }
}

class _DueStringandPriorityMBS extends StatefulWidget {
  const _DueStringandPriorityMBS({
    Key? key,
    required this.dueStrings,
    required this.priorities,
    required this.onCompleted,
  }) : super(key: key);

  final List<NotionTag> dueStrings;
  final List<NotionTag> priorities;
  final Function(NotionTag?, NotionTag?, NotionTag?) onCompleted;

  @override
  State<_DueStringandPriorityMBS> createState() => _DueStringandPriorityMBSState();
}

class _DueStringandPriorityMBSState extends State<_DueStringandPriorityMBS> {
  int _dueStringIndex = 0;
  int _priorityIndex = 0;
  NotionTag? _type;

  @override
  void initState() {
    super.initState();
    // TODO:
    // _dueString = widget.dueString;
    // _priority = widget.priority;
    // _type = widget.type;
  }

  void _onCompleted() {
    widget.onCompleted(
        widget.dueStrings[_dueStringIndex], widget.priorities[_priorityIndex], _type);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Due string block.
          Text('Due string', style: Theme.of(context).textTheme.subtitle1),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              // shrinkWrap: true,
              itemCount: widget.dueStrings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                return _TagListTile(
                  onTap: () => setState(() => _dueStringIndex = index),
                  tag: widget.dueStrings[index],
                  isSelected: _dueStringIndex == index,
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Priority block.
          Text('Priority', style: Theme.of(context).textTheme.subtitle1),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              // shrinkWrap: true,
              itemCount: widget.priorities.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                return _TagListTile(
                  onTap: () => setState(() => _priorityIndex = index),
                  tag: widget.priorities[index],
                  isSelected: _priorityIndex == index,
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Confimation block.
          _CompleteAndCancleButtons(
            onCompleted: () {
              widget.onCompleted(
                  widget.dueStrings[_dueStringIndex], widget.priorities[_priorityIndex], _type);
              Navigator.of(context).pop();
            },
            onCancel: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class _TagListTile extends StatelessWidget {
  const _TagListTile({
    Key? key,
    required this.onTap,
    required this.tag,
    this.isSelected = false,
  }) : super(key: key);

  final VoidCallback onTap;
  final NotionTag tag;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
      contentPadding: const EdgeInsets.only(left: 8),
      tileColor: isSelected ? Colors.grey.shade900.withOpacity(0.67) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      leading: TagIcon(tag: tag, isSelected: isSelected),
      title: Text(tag.content,
          style: Theme.of(context).textTheme.bodyText2!.copyWith(
              color: tag.color.fg, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      onTap: onTap,
      // onTap: () => setState(() => _dueStringIndex = index),
    );
  }
}
