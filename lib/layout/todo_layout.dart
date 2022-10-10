import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
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
  void initState() {
    super.initState();
    createDataBase();
  }

  Database? dataBase;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[currentIndex!]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          insertDataBase();
        },
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

  Future<String> getName() async {
    return 'Moamen mohamed';
  }

  // To Create New DataBase and Create Tables in it
  void createDataBase() async {
    dataBase = await openDatabase(
      'todo.db',
      version: 1,
      onCreate: (database, version) async {
        print('create database');
        // To create tables in database
        database
            .execute(
                'CREATE TABLE tasks (id INTEGER PRIMARY KEY , title TEXT,date TEXT,time TEXT,status TEXT)')
            .then((value) {
          print('table created');
        }).catchError((error) {
          print('Error when creating table ${error.toString()}');
        });
      },
      // To open database
      onOpen: (database) {
        print('open database');
      },
    );
  }

  void insertDataBase() {
    dataBase!.transaction((txn) {
      return txn
          .rawInsert(
              'INSERT INTO tasks(title , date , time , status) VALUES("first task","02222","654","new")')
          .then((value) {
        print('$value is inserted successfully');
      }).catchError((error) {
        print('Error when Inserting New Record ${error.toString()}');
      });
    });
  }
}
