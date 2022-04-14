import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:toreminder/common/widgets.dart';
// import 'package:responsive_framework/responsive_framework.dart';

import '../../common/extensions.dart';
import '../../features/notion/providers/sync_providers.dart';
import '../../features/notion/repositories/connectivity_repo.dart';
import '../../features/todo/models.dart';
import '../../features/todo/providers.dart';
import '../../gen/fonts.gen.dart';

import 'widgets.dart';

final addTodoKey = UniqueKey();
final addButtonKey = UniqueKey();
final todayTodoCountKey = UniqueKey();

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> with TickerProviderStateMixin {
  final _isCreatingTodo = false;
  late TabController _tabController;
  late FToast fToast;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    //   ..addListener(() {
    //     setState(() {/* Reload `_TabBarItem` */});
    //   });
    fToast = FToast();
    fToast.init(context);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<Future<ConnectivityStatus>>(connectivityServiceProvider.future, (prev, next) async {
      if (prev != next) {
        if (await next == ConnectivityStatus.connected) {
          return fToast.showToast(
            child: ToreminderToast(
              icon: const Icon(Icons.network_wifi_outlined, color: Colors.white),
              title: 'You\'re online now',
              subtitle: 'Yay! Internet is connected',
              color: Theme.of(context).primaryColor,
            ),
            gravity: ToastGravity.BOTTOM,
            fadeDuration: 750,
          );
        } else if (await next == ConnectivityStatus.disconnected) {
          return fToast.showToast(
            child: ToreminderToast(
              icon: const Icon(Icons.signal_wifi_off_outlined, color: Colors.white),
              title: 'You\'re offline now',
              subtitle: 'Ooops! Internet is disconnected',
              color: Theme.of(context).disabledColor,
            ),
            gravity: ToastGravity.BOTTOM,
            fadeDuration: 750,
          );
        }
      }
    });

    final theme = Theme.of(context);
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Hello, Rosie',
          style: theme.textTheme.headline6!.copyWith(fontFamily: FontFamily.bree),
        ),
        actions: const [UserAvatar()],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: SizedBox(
                height: height * 0.175,
                child: const _TodayStats(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 40,
                child: _TodoTabBar(_tabController),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                // TODO: Sort todos based on hour and minute.
                child: _TodoTabBarView(_tabController),
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
                      return CreateTodoMBS(
                        onAdded: (todo) {
                          ref.read(todoListProvider.notifier).add(todo);
                          ScaffoldMessenger.of(context).showSnackBar(addingSnackBar(context));
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

class _TodayStats extends ConsumerWidget {
  const _TodayStats({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayTodos = ref.watch(todayTodosFilteredProvider);
    return StatsBoard(
      completed: todayTodos.where((todo) => todo.done).length,
      total: todayTodos.length,
    );
  }
}

class _TodoTabBar extends StatelessWidget {
  const _TodoTabBar(this.controller, {Key? key}) : super(key: key);

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    return TabBar(
      isScrollable: true,
      controller: controller,
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
      indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).primaryColor,
      ),
      tabs: [
        TodoTabBarItem(
          icon: Icons.calendar_today,
          label: 'Today',
          isSelected: controller.index == 0,
        ),
        TodoTabBarItem(
          icon: Icons.calendar_view_week,
          label: 'Next 7 days',
          isSelected: controller.index == 1,
        ),
        TodoTabBarItem(
          icon: Icons.calendar_month,
          label: 'Incoming',
          isSelected: controller.index == 2,
        ),
      ],
    );
  }
}

class _TodoTabBarView extends ConsumerWidget {
  const _TodoTabBarView(this.controller, {Key? key}) : super(key: key);

  final TabController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayTodos = ref.watch(todayTodosFilteredProvider);
    final weekTodos = ref.watch(weekTodosFilteredProvider);
    final todos = ref.watch(todoListProvider);

    return TabBarView(
      controller: controller,
      children: <Widget>[
        todayTodos.isNotEmpty
            ? TodoListView(
                todayTodos,
                onChanged: (index, value) => ref
                    .read(todoListProvider.notifier)
                    .updateAt(index, todos[index].copyWith(done: value)),
                onDeleted: (index) {
                  ref.read(todoListProvider.notifier).removeAt(index);
                  ScaffoldMessenger.of(context).showSnackBar(removingSnackBar(
                    context,
                    () => ref.read(todoListProvider.notifier).undo(index),
                  ));
                },
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
                  child: TodoListTile(
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
      ],
    );
  }
}
