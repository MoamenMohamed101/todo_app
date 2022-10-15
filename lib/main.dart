import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/layout/todo_layout.dart';
import 'package:todo_app/shared/cubit/bloc_observer.dart';

main() {
  Bloc.observer = MyBlocObserver();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TodoLayout(),
    ),
  );
}
