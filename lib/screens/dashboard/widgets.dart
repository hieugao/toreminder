import 'dart:async';

// import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../common/extensions.dart';
import '../../features/todo/models.dart';
import '../../gen/assets.gen.dart';

import 'dashboard_screen.dart';

const _kBottomBarHeight = 64.0;

_textEditingDecoration(String hint) => InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.all(0),
      hintText: hint, // 'Write text here...',
      border: InputBorder.none,
    );

class UserAvatar extends StatelessWidget {
  const UserAvatar({Key? key}) : super(key: key);

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
            Assets.userAvatar.image(height: 32, width: 32),
          ],
        ),
      ),
    );
  }
}

class StatsBoard extends StatefulWidget {
  const StatsBoard({
    Key? key,
    required this.completed,
    required this.total,
  }) : super(key: key);

  final int completed;
  final int total;

  @override
  State<StatsBoard> createState() => _StatsBoardState();
}

class _StatsBoardState extends State<StatsBoard> {
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
                      child: Assets.dartboard.image(height: 128, width: 128),
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

class TodoTabBarItem extends StatelessWidget {
  const TodoTabBarItem({
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

class TodoListView extends StatelessWidget {
  const TodoListView(
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
          child: TodoListTile(
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
class TodoListTile extends StatefulWidget {
  const TodoListTile(
    this.todo, {
    Key? key,
    required this.onChanged,
    required this.onDeleted,
  }) : super(key: key);

  final Todo todo;
  final Function(bool) onChanged;
  final VoidCallback onDeleted;

  @override
  _TodoListTileState createState() => _TodoListTileState();
}

class _TodoListTileState extends State<TodoListTile> {
  bool _isChecked = false;

  @override
  void initState() {
    super.initState();
    _isChecked = widget.todo.done;
  }

  @override
  void didUpdateWidget(TodoListTile oldWidget) {
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

class CreateTodoMBS extends StatefulWidget {
  const CreateTodoMBS({Key? key, required this.onAdded}) : super(key: key);

  final Function(Todo) onAdded;

  @override
  State<CreateTodoMBS> createState() => _CreateTodoMBSState();
}

class _CreateTodoMBSState extends State<CreateTodoMBS> {
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

addingSnackBar(BuildContext context) => SnackBar(
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

removingSnackBar(BuildContext context, VoidCallback onPressed) => SnackBar(
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
            const Icon(Icons.delete_forever, color: Colors.red, size: 32),
            const SizedBox(width: 8),
            Text(
              'Todo is removed!',
              style: Theme.of(context).textTheme.subtitle1!.copyWith(
                    fontSize: 16,
                  ),
            ),
          ],
        ),
      ),
      action: SnackBarAction(
        label: 'UNDO',
        textColor: Colors.red,
        onPressed: onPressed,
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
