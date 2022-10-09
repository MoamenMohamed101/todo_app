import 'package:flutter/material.dart';
import 'package:todo_app/modules/new_tasks/new_tasks_screen.dart';

import '../modules/archive_tasks/archived_tasks_screen.dart';
import '../modules/done_tasks/done_tasks_screen.dart';

class TodoLayout extends StatefulWidget {
  const TodoLayout({Key? key}) : super(key: key);

  @override
  State<TodoLayout> createState() => _TodoLayoutState();
}

class _TodoLayoutState extends State<TodoLayout> {
  int? currentIndex = 0;
  List screens = [
    const NewTasksScreen(),
    const DoneTasksScreen(),
    const ArchivedTasksScreen(),
  ];
  List<String> titles = [
    'New Tasks',
    'Done Tasks',
    'Archived Tasks',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[currentIndex!]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
          print(currentIndex);
        },
        type: BottomNavigationBarType.fixed,
        elevation: 0.0,
        currentIndex: currentIndex!,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Tasks'),
          BottomNavigationBarItem(
              icon: Icon(Icons.check_box_outlined), label: 'Done'),
          BottomNavigationBarItem(
              icon: Icon(Icons.archive_outlined), label: 'Archived'),
        ],
      ),
      body: screens[currentIndex!],
    );
  }
}
