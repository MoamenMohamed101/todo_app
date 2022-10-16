import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/shared/cubit/states.dart';

import '../../modules/archive_tasks/archived_tasks_screen.dart';
import '../../modules/done_tasks/done_tasks_screen.dart';
import '../../modules/new_tasks/new_tasks_screen.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialStates());
  int? currentIndex = 0;
  Database? dataBase;
  IconData fabIcon = Icons.edit;
  bool? isBottomSheet = false;
  List<Map>? tasks = [];
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

  static AppCubit get(context) => BlocProvider.of(context);

  void changeIndex(index) {
    currentIndex = index;
    emit(AppChangeButtonNavBarStates());
  }

  // To Create New DataBase and Create Tables in it
  void createDataBase() {
    openDatabase(
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
          emit(AppGetDataBaseStates());
          print(value);
        }).catchError((error) {
          print(error);
        });
        print('open database');
      },
    ).then((value) {
      dataBase = value;
      emit(AppCreateDataBaseStates());
    });
  }

  // Insert data in DataBase
  insertDataBase({
    String? title,
    String? time,
    String? date,
  }) async {
    await dataBase!.transaction((txn) {
      return txn
          .rawInsert(
              'INSERT INTO tasks(title , date , time , status) VALUES("$title","$date","$time","new")')
          .then((value) {
        emit(AppInsertDataBaseStates());
        getDataFromDataBase(dataBase).then((value) {
          emit(AppGetDataBaseLoadingStates());
          tasks = value;
          print(tasks);
          emit(AppGetDataBaseStates());
          print(value);
        }).catchError((error) {
          print(error);
        });
        print('$value is inserted successfully');
      }).catchError((error) {
        print('Error when Inserting New Record ${error.toString()}');
      });
    });
  }

  Future<List<Map>> getDataFromDataBase(database) async {
    return await database!.rawQuery('SELECT * FROM tasks');
  }

  void changeBottomSheet({
    IconData? icon,
    bool? isShow,
  }) {
    fabIcon = icon!;
    isBottomSheet = isShow;
    emit(AppChangeBottomSheetStates());
  }
}
