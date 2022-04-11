import 'dart:async';

import 'package:flutter/material.dart';

// import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grouped_list/grouped_list.dart';
// import 'package:responsive_framework/responsive_framework.dart';

import '../../common/extensions.dart';
import '../../features/todo/models.dart';
import '../features/todo/providers.dart';

final addTodoKey = UniqueKey();
final addButtonKey = UniqueKey();
final todayTodoCountKey = UniqueKey();

const _kBottomBarHeight = 64.0;

_textEditingDecoration(String hint) => InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.all(0),
      hintText: hint, // 'Write text here...',
      border: InputBorder.none,
    );

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> with TickerProviderStateMixin {
  final _isCreatingTodo = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    //   ..addListener(() {
    //     setState(() {/* Reload `_TabBarItem` */});
    //   });
  }

  @override
  Widget build(BuildContext context) {
    final todayTodos = ref.watch(todayTodosFilteredProvider);
    final weekTodos = ref.watch(weekTodosFilteredProvider);
    final todos = ref.watch(todoListProvider);

    final theme = Theme.of(context);
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Hello, Rosie',
          style: theme.textTheme.headline6!.copyWith(fontFamily: 'Bree'),
        ),
        actions: const [_UserAvatar()],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: SizedBox(
                height: height * 0.175,
                child: _StatsBoard(
                  completed: todayTodos.where((todo) => todo.done).length,
                  total: todayTodos.length,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 40,
                child: TabBar(
                  isScrollable: true,
                  controller: _tabController,
                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: theme.primaryColor,
                  ),
                  tabs: [
                    _TodoTabBarItem(
                      icon: Icons.calendar_today,
                      label: 'Today',
                      isSelected: _tabController.index == 0,
                    ),
                    _TodoTabBarItem(
                      icon: Icons.calendar_view_week,
                      label: 'Next 7 days',
                      isSelected: _tabController.index == 1,
                    ),
                    _TodoTabBarItem(
                      icon: Icons.calendar_month,
                      label: 'Incoming',
                      isSelected: _tabController.index == 2,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                // TODO: Sort todos based on hour and minute.
                child: TabBarView(controller: _tabController, children: <Widget>[
                  todayTodos.isNotEmpty
                      ? _TodoListView(
                          todayTodos,
                          onChanged: (index, value) => ref
                              .read(todoListProvider.notifier)
                              .updateAt(index, todos[index].copyWith(done: value)),
                          onDeleted: (index) => ref.read(todoListProvider.notifier).removeAt(index),
                        )
                      : const Center(child: Text('No todos for today')),
                  weekTodos.isNotEmpty
                      ? GroupedListView(
                          elements: weekTodos,
                          groupBy: (Todo todo) =>
                              DateTime(todo.dueDate.year, todo.dueDate.month, todo.dueDate.day),
                          groupSeparatorBuilder: (DateTime dt) => Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            child: Text(dt.toRelative()),
                          ),
                          indexedItemBuilder: (context, Todo todo, index) => Card(
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: _TodoListTile(
                              todo,
                              onChanged: (value) => ref
                                  .read(todoListProvider.notifier)
                                  .updateAt(index, todos[index].copyWith(done: value)),
                              onDeleted: () => ref.read(todoListProvider.notifier).removeAt(index),
                            ),
                          ),
                        )
                      : const Center(child: Text('No todos for next 7 days')),
                  const Center(
                    child: Text("This is a future feature!"),
                  )
                ]),
              ),
            ),
          ],
        ),
      ),
      // TODO: Add Bottom Navigation Bar.
      // bottomNavigationBar: null,
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _isCreatingTodo
          ? null
          : FloatingActionButton(
              child: Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle, // circular shape
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    // stops: [0.1, 0.5],
                    colors: [
                      // Color(0xFF9400d3),
                      // Color(0xFFff8b00),
                      // Color.fromRGBO(251, 112, 71, 1),
                      // Color.fromRGBO(255, 190, 32, 1),
                      Theme.of(context).primaryColor,
                      Colors.orange,
                    ],
                  ),
                  // color: Theme.of(context).primaryColor,
                ),
                child: const Icon(FontAwesomeIcons.plus, size: 24, color: Colors.white70),
              ),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  elevation: 16,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  builder: (context) => Container(
                    height: MediaQuery.of(context).size.height * 0.65,
                    // padding: const EdgeInsets.all(16),
                    child: Consumer(builder: (context, ref, child) {
                      return _CreateTodoMBS(
                        onAdded: (todo) {
                          ref.read(todoListProvider.notifier).add(todo);
                          ScaffoldMessenger.of(context).showSnackBar(_snackBar(context));
                        },
                      );
                    }),
                  ),
                );
              },
            ),
    );
  }
}

// TODO: Desktop support.
// class _SideMenu extends StatelessWidget {
//   const _SideMenu({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       backgroundColor: const Color(0xFF202427),
//       child: ListView(
//         children: const [
//           _TodoTabBarItem(
//             icon: Icons.calendar_today,
//             label: 'Today',
//             isSelected: true,
//             // isSelected: _tabController.index == 0,
//           ),
//         ],
//       ),
//     );
//   }
// }

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Center(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).primaryColor,
              ),
            ),
            Image.asset(
              'assets/user-avatar.png',
              height: 32,
              width: 32,
            ),
          ],
        ),
      ),
    );
  }
}

// TODO: Horizontal Calendar.
// CalendarTimeline(
//   // initialDate: DateTime(2020, 4, 20),
//   // firstDate: DateTime(2019, 1, 15),
//   // lastDate: DateTime(2020, 11, 20),
//   initialDate: _selectedDate!,
//   // firstDate: _selectedDate!.subtract(const Duration(days: 14)),
//   // lastDate: _selectedDate!.add(const Duration(days: 14)),
//   firstDate: DateTime(2022, 02, 20),
//   lastDate: DateTime(2022, 03, 20),
//   onDateSelected: (date) => setState(() {
//     _selectedDate = date;
//   }),
//   leftMargin: 0,
//   monthColor: theme.disabledColor,
//   dayColor: theme.textTheme.bodyText1!.color!.withOpacity(0.6),
//   activeDayColor: theme.textTheme.bodyText1!.color,
//   activeBackgroundDayColor: const Color(0xFF5d4efe),
//   dotsColor: const Color(0xFF333A47),
//   selectableDayPredicate: (date) => date.day != 23,
//   locale: 'en_ISO',
// ),
// const SizedBox(height: 16),

class _StatsBoard extends StatefulWidget {
  const _StatsBoard({
    Key? key,
    required this.completed,
    required this.total,
  }) : super(key: key);

  final int completed;
  final int total;

  @override
  State<_StatsBoard> createState() => _StatsBoardState();
}

class _StatsBoardState extends State<_StatsBoard> {
  bool showLineChart = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Theme.of(context).colorScheme.secondary,
          ),
          child: !showLineChart
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      key: todayTodoCountKey,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Today',
                          style: Theme.of(context)
                              .textTheme
                              .caption!
                              .apply(color: Colors.white.withOpacity(0.6)),
                        ),
                        Text(
                          '${widget.completed}/${widget.total} todo${widget.total != 1 ? 's' : ""}',
                          style: Theme.of(context).textTheme.headline6!,
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        'assets/dartboard.webp',
                        height: 128,
                        width: 128,
                      ),
                    ),
                  ],
                )
              // : _WeekLineChart(),
              : const Center(child: Text('This is a future feature!')),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              // color: showLineChart ? Colors.purple.shade300 : Colors.red.shade300,
              color: Colors.orange,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 4,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            child: IconButton(
              padding: const EdgeInsets.all(0),
              onPressed: () => setState(() => showLineChart = !showLineChart),
              icon: Icon(
                showLineChart ? FontAwesomeIcons.clipboardCheck : FontAwesomeIcons.chartArea,
                size: 14,
              ),
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        )
      ],
    );
  }
}

// TODO: Add Weekly Statistics.
// class _WeekLineChart extends StatelessWidget {
//   const _WeekLineChart({Key? key}) : super(key: key);

//   static const List<Color> gradientColors = [
//     Color(0xff23b6e6),
//     Color(0xff02d39a),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return LineChart(
//       LineChartData(
//         gridData: FlGridData(
//           show: true,
//           drawVerticalLine: true,
//           horizontalInterval: 1,
//           verticalInterval: 1,
//           getDrawingHorizontalLine: (value) {
//             return FlLine(
//               color: const Color(0xff37434d),
//               strokeWidth: 1,
//             );
//           },
//           getDrawingVerticalLine: (value) {
//             return FlLine(
//               color: const Color(0xff37434d),
//               strokeWidth: 1,
//             );
//           },
//         ),
//         titlesData: FlTitlesData(
//           show: true,
//           rightTitles: SideTitles(showTitles: false),
//           topTitles: SideTitles(showTitles: false),
//           bottomTitles: SideTitles(
//             showTitles: true,
//             reservedSize: 22,
//             interval: 1,
//             getTextStyles: (context, value) => const TextStyle(
//                 color: Color(0xff68737d), fontWeight: FontWeight.bold, fontSize: 16),
//             getTitles: (value) {
//               switch (value.toInt()) {
//                 case 2:
//                   return 'MAR';
//                 case 5:
//                   return 'JUN';
//                 case 8:
//                   return 'SEP';
//               }
//               return '';
//             },
//             margin: 8,
//           ),
//           leftTitles: SideTitles(
//             showTitles: true,
//             interval: 1,
//             getTextStyles: (context, value) => const TextStyle(
//               color: Color(0xff67727d),
//               fontWeight: FontWeight.bold,
//               fontSize: 15,
//             ),
//             getTitles: (value) {
//               switch (value.toInt()) {
//                 case 1:
//                   return '10k';
//                 case 3:
//                   return '30k';
//                 case 5:
//                   return '50k';
//               }
//               return '';
//             },
//             reservedSize: 32,
//             margin: 12,
//           ),
//         ),
//         borderData:
//             FlBorderData(show: true, border: Border.all(color: const Color(0xff37434d), width: 1)),
//         minX: 0,
//         maxX: 11,
//         minY: 0,
//         maxY: 6,
//         lineBarsData: [
//           LineChartBarData(
//             spots: const [
//               FlSpot(0, 3),
//               FlSpot(2.6, 2),
//               FlSpot(4.9, 5),
//               FlSpot(6.8, 3.1),
//               FlSpot(8, 4),
//               FlSpot(9.5, 3),
//               FlSpot(11, 4),
//             ],
//             isCurved: true,
//             colors: gradientColors,
//             barWidth: 5,
//             isStrokeCapRound: true,
//             dotData: FlDotData(
//               show: false,
//             ),
//             belowBarData: BarAreaData(
//               show: true,
//               colors: gradientColors.map((color) => color.withOpacity(0.3)).toList(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class _TodoTabBarItem extends StatelessWidget {
  const _TodoTabBarItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.isSelected,
  }) : super(key: key);

  final IconData icon;
  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    const color = Colors.white70;

    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.subtitle2!.copyWith(color: color)),
      ],
    );
  }
}

class _TodoListView extends StatelessWidget {
  const _TodoListView(
    this.todos, {
    Key? key,
    required this.onChanged,
    required this.onDeleted,
  }) : super(key: key);

  final List<Todo> todos;
  final Function(int, bool) onChanged;
  final Function(int) onDeleted;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: _TodoListTile(
            todos[index],
            onChanged: (value) => onChanged(index, value),
            onDeleted: () => onDeleted(index),
          ),
        );
      },
    );
  }
}

// FIXME: Convert to StatelessWidget.
class _TodoListTile extends StatefulWidget {
  const _TodoListTile(
    this.todo, {
    Key? key,
    required this.onChanged,
    required this.onDeleted,
  }) : super(key: key);

  final Todo todo;
  final Function(bool) onChanged;
  final VoidCallback onDeleted;

  @override
  __TodoListTileState createState() => __TodoListTileState();
}

class __TodoListTileState extends State<_TodoListTile> {
  bool _isChecked = false;

  @override
  void initState() {
    super.initState();
    _isChecked = widget.todo.done;
  }

  @override
  void didUpdateWidget(_TodoListTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.todo != widget.todo) {
      _isChecked = widget.todo.done;
    }
  }

  void _onChanged() {
    setState(() => _isChecked = !_isChecked);
    widget.onChanged(_isChecked);
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      // Specify a key if the Slidable is dismissible.
      key: ValueKey(widget.todo.id),
      endActionPane: ActionPane(
        extentRatio: 0.4,
        openThreshold: 0.1,
        closeThreshold: 0.1,
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: null,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.grey[700],
            icon: Icons.edit,
          ),
          SlidableAction(
            onPressed: (context) => widget.onDeleted(),
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.red,
            icon: Icons.delete_forever,
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 8),
        key: Key(widget.todo.id),
        // dense: true,
        horizontalTitleGap: 0,
        leading: Checkbox(
          checkColor: Theme.of(context).primaryColor,
          // fillColor:  // MaterialStateProperty.resolveWith(Colors.transparent),
          // activeColor: Colors.grey.shade500.withOpacity(0.38),
          activeColor: Colors.transparent,
          // value: _selectedTags.contains(_foundTags[index]),
          visualDensity: VisualDensity.compact,
          value: _isChecked,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          side: MaterialStateBorderSide.resolveWith(
            (states) => BorderSide(
              width: 1.75,
              color: _isChecked ? Colors.transparent : Colors.white60,
            ),
          ),
          onChanged: (_) => _onChanged(),
        ),
        title: Text(widget.todo.title, style: Theme.of(context).textTheme.subtitle1),
        onTap: _onChanged,
      ),
    );
  }
}

class _CreateTodoMBS extends StatefulWidget {
  const _CreateTodoMBS({Key? key, required this.onAdded}) : super(key: key);

  final Function(Todo) onAdded;

  @override
  State<_CreateTodoMBS> createState() => _CreateTodoMBSState();
}

class _CreateTodoMBSState extends State<_CreateTodoMBS> {
  DateTimeRange dateRange = DateTimeRange(
    start: DateTime.now(),
    end: DateTime.now(),
  );

  Timer? _debounce;
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  final DateTime _now = DateTime.now();
  late DateTime _selectedDate = DateTime(_now.year, _now.month, _now.day);

  @override
  void dispose() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onAdded() {
    widget.onAdded(Todo.initial(_titleController.text, _contentController.text, _selectedDate));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  key: addTodoKey,
                  autofocus: true,
                  controller: _titleController,
                  decoration: _textEditingDecoration('Enter the title...'),
                  style:
                      Theme.of(context).textTheme.subtitle1!.copyWith(fontWeight: FontWeight.w500),
                  onChanged: (_) {
                    if (_debounce?.isActive ?? false) _debounce?.cancel();

                    _debounce = Timer(const Duration(milliseconds: 300), () => setState(() {}));
                  },
                ),
              ),
              _selectedDate != null
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(FontAwesomeIcons.clock, size: 14, color: theme.disabledColor),
                          const SizedBox(width: 6),
                          Text(
                            _selectedDate.toRelative(),
                            style: theme.textTheme.caption!.copyWith(color: theme.disabledColor),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(),
              // TODO: Support Todo's note.
              // Padding(
              //   padding: const EdgeInsets.symmetric(vertical: 8.0),
              //   child: TextField(
              //     autofocus: true,
              //     controller: _contentController,
              //     decoration: _textEditingDecoration('Enter your todo\' notes here...'),
              //     style: Theme.of(context)
              //         .textTheme
              //         .subtitle2!
              //         .copyWith(color: theme.textTheme.subtitle2!.color!.withOpacity(0.6)),
              //     onChanged: (value) {},
              //   ),
              // ),
              // const Spacer(),
            ],
          ),
        ),
        Positioned(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(width: 1, color: Colors.grey.shade700),
              ),
            ),
            height: _kBottomBarHeight,
            child: Row(
              children: [
                IconButton(
                  onPressed: () async {
                    // TODO: Support Date Range Picker.
                    // final picked = await showDateRangePicker(
                    //   context: context,
                    //   lastDate: dateRange.start,
                    //   firstDate: new DateTime(2019),
                    // );
                    // if (picked != null) {
                    //   // print(picked);
                    //   setState(
                    //     () {
                    //       dateRange = DateTimeRange(start: picked.start, end: picked.end);
                    //       // Below have methods that runs once a date range is picked
                    //       //
                    //       // allWaterBillsFuture = _getAllWaterBillsFuture(
                    //       //     picked.start.toIso8601String(),
                    //       //     picked.end
                    //       //         .add(new Duration(hours: 24))
                    //       //         .toIso8601String());
                    //     },
                    //   );
                    // }
                    final date = await showDatePicker(
                      context: context,
                      helpText: 'Help text here',
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now().subtract(const Duration(days: 15)),
                      lastDate: DateTime(2025),
                    );
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(date),
                      );
                      if (time != null) {
                        setState(() {
                          _selectedDate =
                              DateTime(date.year, date.month, date.day, time.hour, time.minute);
                        });
                      } else {
                        setState(() {
                          _selectedDate = DateTime(date.year, date.month, date.day);
                        });
                      }
                    }
                  },
                  icon: Icon(
                    Icons.calendar_month,
                    color: _selectedDate != null ? Theme.of(context).primaryColor : Colors.white,
                  ),
                ),
                const IconButton(onPressed: null, icon: Icon(Icons.repeat)),
                const IconButton(onPressed: null, icon: Icon(Icons.location_on)),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: ElevatedButton(
                    key: addButtonKey,
                    onPressed: _titleController.text.isEmpty ? null : _onAdded,
                    child: Text('ADD',
                        style: Theme.of(context).textTheme.button!.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

_snackBar(BuildContext context) => SnackBar(
      elevation: 12,
      // behavior: SnackBarBehavior.floating,
      // margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      backgroundColor: Colors.grey.shade700,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: Container(
        padding: const EdgeInsets.only(left: 8),
        // decoration: BoxDecoration(
        //   color: Colors.grey.shade700,
        //   borderRadius: BorderRadius.circular(8),
        // ),
        child: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.green, size: 32),
            const SizedBox(width: 8),
            Text(
              'Todo Added!',
              style: Theme.of(context).textTheme.subtitle1!.copyWith(
                    fontSize: 16,
                  ),
            ),
          ],
        ),
      ),
    );

// TODO: Bottom Navigation Bar.
// bottomNavigationBar: SizedBox(
//   height: _kBottomBarHeight,
//   child: BottomAppBar(
//     elevation: 8,
//     shape: const CircularNotchedRectangle(),
//     child: Row(
//       mainAxisSize: MainAxisSize.max,
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: <Widget>[
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             SizedBox(width: 16),
//             IconButton(
//               icon: Icon(
//                 Icons.home,
//                 color: Theme.of(context).disabledColor,
//               ),
//               onPressed: () {},
//             ),
//             SizedBox(width: 16),
//             IconButton(
//               icon: Icon(
//                 Icons.settings,
//                 color: Theme.of(context).disabledColor,
//               ),
//               onPressed: () {},
//             ),
//           ],
//         ),
//         // SizedBox(width: 48.0),
//         Padding(
//           padding: const EdgeInsets.only(right: 40),
//           child: IconButton(
//             icon: Icon(
//               Icons.search,
//               color: Theme.of(context).disabledColor,
//             ),
//             onPressed: () {},
//           ),
//         ),
//       ],
//     ),
//   ),
// ),
