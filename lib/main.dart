import 'package:flutter/material.dart';
import 'package:todo_app/layout/todo_layout.dart';

main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TodoLayout(),
    ),
  );
}
