import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// import 'package:calendar_timeline/calendar_timeline.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:timeago/timeago.dart' as timeago;

import '../../features/todo/models.dart';
import 'view_models.dart';

const _kBottomBarHeight = 64.0;

_textEditingDecoration(String hint) => InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.all(0),
      hintText: hint, // 'Write text here...',
      border: InputBorder.none,
    );

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _isCreatingTodo = false;
  DateTime? _selectedDate = DateTime.now();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final todosNotifier = ref.watch(todoListProvider.notifier);

    final theme = Theme.of(context);
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text('Hello, Rosie', style: theme.textTheme.headline6),
        actions: const [_Avatar()],
      ),
      body: SafeArea(child: Consumer(
        builder: (context, ref, child) {
          final todos = ref.watch(todoListProvider);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              SizedBox(
                height: height * 0.175,
                child: _StatsBoard(
                  completed: todosNotifier.completed,
                  total: todos.length,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                height: 56,
                // margin: EdgeInsets.only(left: 60),
                child: TabBar(
                  tabs: const [
                    _TodoTabBarItem(
                      icon: Icons.calendar_today,
                      label: 'Today',
                    ),
                    _TodoTabBarItem(
                      icon: Icons.calendar_view_week,
                      label: '7 days',
                    ),
                    _TodoTabBarItem(
                      icon: Icons.calendar_month,
                      label: 'Calendar',
                    ),
                  ],
                  // unselectedLabelColor: const Color(0xffacb3bf),
                  // labelColor: Colors.black,
                  // indicatorColor: Colors.transparent,
                  // indicatorSize: TabBarIndicatorSize.tab,
                  // indicatorWeight: 3.0,
                  // indicatorPadding: EdgeInsets.all(10),
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: _tabController.index == 0 ? theme.primaryColor : Colors.transparent,
                  ),
                  isScrollable: false,
                  controller: _tabController,
                ),
              ),
              Expanded(
                // height: 100,
                child: TabBarView(controller: _tabController, children: <Widget>[
                  _TodoListView(
                    todos,
                    onDeleted: (index) => ref.read(todoListProvider.notifier).remove(todos[index]),
                  ),
                  Container(
                    color: Colors.yellow,
                    child: Text("7 days"),
                  ),
                  Container(
                    color: Colors.blue,
                    child: Text("calnedar"),
                  )
                ]),
              ),
            ],
          );
        },
      )),
      bottomNavigationBar: SizedBox(
        height: _kBottomBarHeight,
        child: BottomAppBar(
          elevation: 8,
          shape: const CircularNotchedRectangle(),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(width: 16),
                  IconButton(
                    icon: Icon(
                      Icons.home,
                      color: Theme.of(context).disabledColor,
                    ),
                    onPressed: () {},
                  ),
                  SizedBox(width: 16),
                  IconButton(
                    icon: Icon(
                      Icons.settings,
                      color: Theme.of(context).disabledColor,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
              // SizedBox(width: 48.0),
              Padding(
                padding: const EdgeInsets.only(right: 40),
                child: IconButton(
                  icon: Icon(
                    Icons.search,
                    color: Theme.of(context).disabledColor,
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _isCreatingTodo
          ? null
          : FloatingActionButton(
              child: const Icon(Icons.add),
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
                        onAdded: (todo) => ref.read(todoListProvider.notifier).add(todo),
                      );
                    }),
                  ),
                );
              },
            ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.all(8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          'assets/avatar.png',
          // height: 40,
          // width: 40,
        ),
      ),
    );
  }
}

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
            borderRadius: BorderRadius.circular(16),
            color: Colors.grey.shade700,
          ),
          child: !showLineChart
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          'Today',
                          style: Theme.of(context)
                              .textTheme
                              .caption!
                              .apply(color: Theme.of(context).disabledColor),
                        ),
                        Text(
                          '${widget.completed}/${widget.total} todo${widget.total != 1 ? 's' : ""}',
                          style: Theme.of(context).textTheme.headline6!,
                        ),
                      ],
                    ),
                    Image.asset(
                      'assets/dartboard.webp',
                      height: 128,
                      width: 128,
                    ),
                  ],
                )
              : _WeekLineChart(),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.withOpacity(0.38),
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
              icon: const Icon(Icons.show_chart, size: 16),
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        )
      ],
    );
  }
}

class _WeekLineChart extends StatelessWidget {
  const _WeekLineChart({Key? key}) : super(key: key);

  static const List<Color> gradientColors = [
    Color(0xff23b6e6),
    Color(0xff02d39a),
  ];

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 1,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: const Color(0xff37434d),
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: const Color(0xff37434d),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: SideTitles(showTitles: false),
          topTitles: SideTitles(showTitles: false),
          bottomTitles: SideTitles(
            showTitles: true,
            reservedSize: 22,
            interval: 1,
            getTextStyles: (context, value) => const TextStyle(
                color: Color(0xff68737d), fontWeight: FontWeight.bold, fontSize: 16),
            getTitles: (value) {
              switch (value.toInt()) {
                case 2:
                  return 'MAR';
                case 5:
                  return 'JUN';
                case 8:
                  return 'SEP';
              }
              return '';
            },
            margin: 8,
          ),
          leftTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTextStyles: (context, value) => const TextStyle(
              color: Color(0xff67727d),
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            getTitles: (value) {
              switch (value.toInt()) {
                case 1:
                  return '10k';
                case 3:
                  return '30k';
                case 5:
                  return '50k';
              }
              return '';
            },
            reservedSize: 32,
            margin: 12,
          ),
        ),
        borderData:
            FlBorderData(show: true, border: Border.all(color: const Color(0xff37434d), width: 1)),
        minX: 0,
        maxX: 11,
        minY: 0,
        maxY: 6,
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(0, 3),
              FlSpot(2.6, 2),
              FlSpot(4.9, 5),
              FlSpot(6.8, 3.1),
              FlSpot(8, 4),
              FlSpot(9.5, 3),
              FlSpot(11, 4),
            ],
            isCurved: true,
            colors: gradientColors,
            barWidth: 5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: false,
            ),
            belowBarData: BarAreaData(
              show: true,
              colors: gradientColors.map((color) => color.withOpacity(0.3)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _TodoTabBarItem extends StatelessWidget {
  const _TodoTabBarItem({
    Key? key,
    required this.icon,
    required this.label,
  }) : super(key: key);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}

class _TodoListView extends StatelessWidget {
  const _TodoListView(this.todos, {Key? key, required this.onDeleted}) : super(key: key);

  final List<Todo> todos;
  final Function(int) onDeleted;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: _TodoListTile(todos[index], onDeleted: () => onDeleted(index)),
        );
      },
    );
  }
}

class _TodoListTile extends StatefulWidget {
  const _TodoListTile(this.todo, {Key? key, this.onDeleted}) : super(key: key);

  final Todo todo;
  final VoidCallback? onDeleted;

  @override
  __TodoListTileState createState() => __TodoListTileState();
}

class __TodoListTileState extends State<_TodoListTile> {
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Slidable(
      // Specify a key if the Slidable is dismissible.
      key: ValueKey(widget.todo.id),

      // The start action pane is the one at the left or the top side.
      // startActionPane: ActionPane(
      //   // A motion is a widget used to control how the pane animates.
      //   motion: const ScrollMotion(),

      //   // A pane can dismiss the Slidable.
      //   dismissible: DismissiblePane(onDismissed: () {}),

      //   // All actions are defined in the children parameter.
      //   children: const [
      //     // A SlidableAction can have an icon and/or a label.
      //     SlidableAction(
      //       onPressed: null,
      //       // backgroundColor: Color(0xFFFE4A49),
      //       foregroundColor: Colors.white,
      //       icon: Icons.delete,
      //       label: 'Delete',
      //     ),
      //     SlidableAction(
      //       onPressed: null,
      //       // backgroundColor: Color(0xFF21B7CA),
      //       foregroundColor: Colors.white,
      //       icon: Icons.share,
      //       label: 'Share',
      //     ),
      //   ],
      // ),

      // The end action pane is the one at the right or the bottom side.
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            // An action can be bigger than the others.
            onPressed: null,
            backgroundColor: Colors.transparent,
            // foregroundColor: Colors.amber,
            foregroundColor: Colors.grey[700],
            icon: Icons.edit,
            // label: 'Archive',
          ),
          SlidableAction(
            onPressed: (_) => widget.onDeleted?.call(),
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.red,
            icon: Icons.delete_forever,
            // label: 'Save',
          ),
        ],
      ),

      // The child of the Slidable is what the user sees when the
      // component is not dragged.
      child: ListTile(
        // contentPadding: EdgeInsets.zero,
        key: Key(widget.todo.id),
        // dense: true,
        leading: Checkbox(
          checkColor: Colors.orange.shade500,
          // fillColor:  // MaterialStateProperty.resolveWith(Colors.transparent),
          activeColor: Colors.transparent,
          // value: _selectedTags.contains(_foundTags[index]),
          value: _isChecked,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          onChanged: (bool? value) {
            // setState(() {
            //   _isChecked = value;
            // });
          },
        ),
        title: Text(widget.todo.title, style: Theme.of(context).textTheme.subtitle1),
        onTap: () {
          setState(() {
            _isChecked = !_isChecked;
          });
        },
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
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                autofocus: true,
                controller: _titleController,
                decoration: _textEditingDecoration('Enter the title...'),
                style: Theme.of(context).textTheme.subtitle1!.copyWith(fontWeight: FontWeight.w500),
                onChanged: (_) {
                  if (_debounce?.isActive ?? false) _debounce?.cancel();

                  _debounce = Timer(const Duration(milliseconds: 300), () => setState(() {}));
                },
              ),
              // TODO: Add date here.
              // Text(timeago.format(selectedDate)),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(_selectedDate.toString(),
                    style: theme.textTheme.caption!.copyWith(color: theme.disabledColor)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  autofocus: true,
                  controller: _contentController,
                  decoration: _textEditingDecoration('Enter your todo\' notes here...'),
                  style: Theme.of(context)
                      .textTheme
                      .subtitle2!
                      .copyWith(color: theme.textTheme.subtitle2!.color!.withOpacity(0.6)),
                  onChanged: (value) {},
                ),
              ),
              const Spacer(),
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
//                       final picked = await showDateRangePicker(
//                         context: context,
//                         lastDate: dateRange.start,
//                         firstDate: new DateTime(2019),
//                       );
//                       if (picked != null) {
//                         // print(picked);
//                         setState(
//                           () {
//                             dateRange = DateTimeRange(
//                                 start: picked.start, end: picked.end);
// //below have methods that runs once a date range is picked
//                             // allWaterBillsFuture = _getAllWaterBillsFuture(
//                             //     picked.start.toIso8601String(),
//                             //     picked.end
//                             //         .add(new Duration(hours: 24))
//                             //         .toIso8601String());
//                           },
//                         );
//                      }
                    final date = await showDatePicker(
                      context: context,
                      helpText: 'Help text here',
                      initialDate: _selectedDate,
                      firstDate: DateTime(2015, 8),
                      lastDate: DateTime(2101),
                    );
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(_selectedDate),
                      );
                      if (time != null) {
                        setState(() {
                          _selectedDate = DateTime(date.year, date.month, time.hour, time.minute);
                        });
                      } else {
                        setState(() {
                          _selectedDate = DateTime(date.year, date.month);
                        });
                      }
                    }
                  },
                  icon: Icon(Icons.calendar_month),
                ),
                const IconButton(onPressed: null, icon: Icon(Icons.repeat)),
                const IconButton(onPressed: null, icon: Icon(Icons.location_on)),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: ElevatedButton(
                    onPressed: _titleController.text.isEmpty
                        ? null
                        : () {
                            widget.onAdded(Todo.initial(
                                _titleController.text, _contentController.text, _selectedDate));
                            Navigator.pop(context);
                          },
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

// class _TodoScreenState extends State<TodoScreen> {
//   @override
//   Widget build(BuildContext context) {
//   }
// }

// class DashboardCalendarTimeline extends StatefulWidget {
//   @override
//   _DashboardCalendarTimeline createState() => _DashboardCalendarTimeline();
// }

// class _DashboardCalendarTimeline extends State<DashboardCalendarTimeline> {
//   late DateTime _selectedDate;

//   @override
//   void initState() {
//     super.initState();
//     _resetSelectedDate();
//   }

//   void _resetSelectedDate() {
//     _selectedDate = DateTime.now().add(Duration(days: 5));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFF333A47),
//       body: SafeArea(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Text(
//                 'Calendar Timeline',
//                 style:
//                     Theme.of(context).textTheme.headline6!.copyWith(color: Colors.tealAccent[100]),
//               ),
//             ),
//             CalendarTimeline(
//               showYears: true,
//               initialDate: _selectedDate,
//               firstDate: DateTime.now(),
//               lastDate: DateTime.now().add(Duration(days: 365 * 4)),
//               onDateSelected: (date) {
//                 setState(() {
//                   _selectedDate = date ?? DateTime.now();
//                 });
//               },
//               leftMargin: 20,
//               monthColor: Colors.white70,
//               dayColor: Colors.teal[200],
//               dayNameColor: Color(0xFF333A47),
//               activeDayColor: Colors.white,
//               activeBackgroundDayColor: Colors.redAccent[100],
//               dotsColor: Color(0xFF333A47),
//               selectableDayPredicate: (date) => date.day != 23,
//               locale: 'en',
//             ),
//             SizedBox(height: 20),
//             Padding(
//               padding: const EdgeInsets.only(left: 16),
//               child: TextButton(
//                 style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.teal[200])),
//                 child: Text('RESET', style: TextStyle(color: Color(0xFF333A47))),
//                 onPressed: () => setState(() => _resetSelectedDate()),
//               ),
//             ),
//             SizedBox(height: 20),
//             Center(
//                 child:
//                     Text('Selected date is $_selectedDate', style: TextStyle(color: Colors.white)))
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _DateRangeWidget extends StatefulWidget {
//   _DateRangeWidget({Key? key}) : super(key: key);

//   @override
//   State<_DateRangeWidget> createState() => _DateRangeWidgetState();
// }

// class _DateRangeWidgetState extends State<_DateRangeWidget> {
//   DateTimeRange dateRange = DateTimeRange(
//     start: DateTime(2021, 11, 5),
//     end: DateTime(2022, 12, 10),
//   );
//   @override
//   Widget build(BuildContext context) {
//     final start = dateRange.start;
//     final end = dateRange.end;

//     return Column(children: [
//       const Text(
//         'Date Range',
//         style: TextStyle(fontSize: 16),
//       ),
//       Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             child: ElevatedButton(
//               child: Text(
//                 '${start.year}/${start.month}/${start.day}',
//               ),
//               onPressed: pickDateRange,
//             ),
//           ),
//           Container(
//             margin: EdgeInsets.only(left: 20),
//             child: ElevatedButton(
//               child: Text(
//                 '${end.year}/${end.month}/${end.day}',
//               ),
//               onPressed: pickDateRange,
//             ),
//           ),
//         ],
//       )
//     ]);
//   }

//   Future pickDateRange() async {
//     DateTimeRange? newDateRange = await showDateRangePicker(
//       context: context,
//       initialDateRange: dateRange,
//       firstDate: DateTime(2019),
//       lastDate: DateTime(2023),
//     );
//     setState(() {
//       dateRange = newDateRange ?? dateRange;

//       // if (newDateRange == null) return;
//       // setState(() => dateRange = newDateRange);
//     });
//   }
// }

// class _BottomNavBar extends StatelessWidget {
//   _BottomNavBar({Key? key, required this.isCreatingTodo}) : super(key: key);

//   final bool isCreatingTodo;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 64,
//       child: BottomAppBar(
//         shape: isCreatingTodo ? null : const CircularNotchedRectangle(),
//         notchMargin: 8.0,
//         child: isCreatingTodo ? _createTodoNavBar : _navBar(context),
//       ),
//     );
//   }

//   Widget _createTodoNavBar = Container();

//   Widget _navBar(BuildContext context) {
//     return Row(
//       mainAxisSize: MainAxisSize.max,
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: <Widget>[
//         IconButton(
//           icon: Icon(
//             Icons.show_chart,
//             color: Theme.of(context).disabledColor,
//           ),
//           onPressed: () {},
//         ),
//         SizedBox(width: 48.0),
//         IconButton(
//           icon: Icon(
//             Icons.filter_list,
//             color: Theme.of(context).disabledColor,
//           ),
//           onPressed: () {},
//         ),
//       ],
//     );
//   }
// }
