import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/modules/new_tasks/new_tasks_screen.dart';
import 'package:todo_app/shared/components/components.dart';

import '../modules/archive_tasks/archived_tasks_screen.dart';
import '../modules/done_tasks/done_tasks_screen.dart';
import '../shared/components/constants.dart';

class TodoLayout extends StatefulWidget {
  const TodoLayout({Key? key}) : super(key: key);

  @override
  State<TodoLayout> createState() => _TodoLayoutState();
}

class _TodoLayoutState extends State<TodoLayout> {
  // variables {
  IconData fabIcon = Icons.edit;
  bool? isBottomSheet = false;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  int? currentIndex = 0;
  Database? dataBase;
  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();

// }

  // Lists to toggle between screens & appBars {
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

// }
  @override
  void initState() {
    super.initState();
    createDataBase();
  }

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
              insertDataBase(
                title: titleController.text,
                date: dateController.text,
                time: timeController.text,
              ).then((value) {
                getDataFromDataBase(dataBase).then((value) {
                  Navigator.pop(context);
                  setState(() {
                    isBottomSheet = false;
                    fabIcon = Icons.edit;
                    tasks = value;
                    print(value);
                  });
                }).catchError((error) {});
              });
            }
          } else {
            // To open showBottomSheet
            scaffoldKey.currentState!
                .showBottomSheet(
                  elevation: 20,
                  // The design in showBottomSheet
                  (context) => Container(
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
                              ).then((value) {
                                dateController.text =
                                    DateFormat.yMMMd().format(value!);
                              });
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
                )
                .closed
                .then((value) {
              isBottomSheet = false;
              setState(() {
                fabIcon = Icons.edit;
              });
            });
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
      body: ConditionalBuilder(
        condition: tasks!.length > 0,
        builder: (context) => screens[currentIndex!],
        fallback: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
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
        getDataFromDataBase(database).then((value) {
          tasks = value;
          print(value);
        }).catchError((error) {});
        print('open database');
      },
    );
  }

  // Insert data in DataBase
  Future insertDataBase({
    String? title,
    String? time,
    String? date,
  }) async {
    return await dataBase!.transaction((txn) {
      return txn
          .rawInsert(
              'INSERT INTO tasks(title , date , time , status) VALUES("f$title","$date","$time","new")')
          .then((value) {
        print('$value is inserted successfully');
      }).catchError((error) {
        print('Error when Inserting New Record ${error.toString()}');
      });
    });
  }

  Future<List<Map>> getDataFromDataBase(database) async {
    return await database!.rawQuery('SELECT * FROM tasks');
  }
}
