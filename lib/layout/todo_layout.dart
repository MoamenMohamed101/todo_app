import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/modules/new_tasks/new_tasks_screen.dart';
import 'package:todo_app/shared/components/components.dart';

import '../modules/archive_tasks/archived_tasks_screen.dart';
import '../modules/done_tasks/done_tasks_screen.dart';

class TodoLayout extends StatefulWidget {
  const TodoLayout({Key? key}) : super(key: key);

  @override
  State<TodoLayout> createState() => _TodoLayoutState();
}

class _TodoLayoutState extends State<TodoLayout> {
  IconData fabIcon = Icons.edit;
  bool? isBottomSheet = false;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
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

  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(titles[currentIndex!]),
      ),
      floatingActionButton: FloatingActionButton(
        // To toggle Between open and close showBottomSheet
        onPressed: () async {
          // To close showBottomSheet
          if (isBottomSheet == true) {
            if (formKey.currentState!.validate()) {
              Navigator.pop(context);
              isBottomSheet = false;
              setState(() {
                fabIcon = Icons.edit;
              });
            }
          } else {
            // To open showBottomSheet
            scaffoldKey.currentState!.showBottomSheet(
              // The design in showBottomSheet
              (context) => Container(
                color: Colors.grey[100],
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      defaultFormField(
                        controller: titleController,
                        keyboard: TextInputType.text,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter title';
                          }
                          return null;
                        },
                        text: 'Task title',
                        prefixIcon: Icons.title,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      defaultFormField(
                        onTap: () {
                          showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          ).then((value) {
                            timeController.text = value!.format(context);
                            print(value.format(context));
                          });
                        },
                        controller: timeController,
                        keyboard: TextInputType.datetime,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter time';
                          }
                          return null;
                        },
                        text: 'Task Time',
                        prefixIcon: Icons.watch_later_outlined,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      defaultFormField(
                        controller: dateController,
                        keyboard: TextInputType.datetime,
                        onTap: () {
                          showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.parse('2023-12-01'),
                          ).then((value) {});
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter Date';
                          }
                          return null;
                        },
                        text: 'Task Date',
                        prefixIcon: Icons.calendar_today,
                      ),
                    ],
                  ),
                ),
              ),
            );
            isBottomSheet = true;
            setState(() {
              fabIcon = Icons.add;
            });
          }
        },
        child: Icon(fabIcon),
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

  // Insert data in DataBase
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
