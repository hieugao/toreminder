import 'dart:async';

import 'package:flutter/material.dart';

import 'package:calendar_timeline/calendar_timeline.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _isCreatingTodo = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(child: Consumer(
        builder: (context, ref, child) {
          final todos = ref.watch(todoListProvider);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // CalendarTimeline(
                //   initialDate: DateTime(2020, 4, 20),
                //   firstDate: DateTime(2019, 1, 15),
                //   lastDate: DateTime(2020, 11, 20),
                //   onDateSelected: (date) => print(date),
                //   leftMargin: 20,
                //   monthColor: Colors.blueGrey,
                //   dayColor: Colors.teal[200],
                //   activeDayColor: Colors.white,
                //   activeBackgroundDayColor: Colors.redAccent[100],
                //   dotsColor: Color(0xFF333A47),
                //   selectableDayPredicate: (date) => date.day != 23,
                //   locale: 'en_ISO',
                // ),
                // const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'TODAY\'S TO-DO${todos.isNotEmpty ? 'S' : ""}',
                    style: Theme.of(context).textTheme.caption!.copyWith(
                          fontWeight: FontWeight.w500,
                          color: theme.disabledColor,
                        ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: todos.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        child: ListTile(
                          // contentPadding: EdgeInsets.zero,
                          dense: true,
                          leading: Checkbox(
                            checkColor: Colors.orange.shade500,
                            // fillColor:  // MaterialStateProperty.resolveWith(Colors.transparent),
                            activeColor: Colors.transparent,
                            // value: _selectedTags.contains(_foundTags[index]),
                            value: false,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            onChanged: (bool? value) {},
                          ),
                          title: Text(todos[index].title,
                              style: Theme.of(context).textTheme.subtitle1),
                          subtitle: const Text(''),
                          onTap: () {},
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
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
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.show_chart,
                  color: Theme.of(context).disabledColor,
                ),
                onPressed: () {},
              ),
              SizedBox(width: 48.0),
              IconButton(
                icon: Icon(
                  Icons.filter_list,
                  color: Theme.of(context).disabledColor,
                ),
                onPressed: () {},
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
