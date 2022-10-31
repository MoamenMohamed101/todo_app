import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/shared/components/components.dart';
import 'package:todo_app/shared/cubit/cubit.dart';
import 'package:todo_app/shared/cubit/states.dart';

class TodoLayout extends StatelessWidget {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();

  // @override
  // void initState() {
  //   super.initState();
  //   createDataBase();
  // }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AppCubit()..createDataBase(),
      child: BlocConsumer<AppCubit, AppStates>(
        builder: (BuildContext context, state) {
          AppCubit cubit = AppCubit.get(context);
          return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              title: Text(
                cubit.titles[cubit.currentIndex!],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              // To toggle Between open and close showBottomSheet
              onPressed: () async {
                // To close showBottomSheet
                if (cubit.isBottomSheet == true) {
                  if (formKey.currentState!.validate()) {
                    cubit.insertDataBase(
                      title: titleController.text,
                      date: dateController.text,
                      time: timeController.text,
                    );
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
                                      timeController.text =
                                          value!.format(context);
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
                    cubit.changeBottomSheet(icon: Icons.edit, isShow: false);
                  });
                  cubit.changeBottomSheet(isShow: true, icon: Icons.add);
                }
              },
              child: Icon(cubit.fabIcon),
            ),
            bottomNavigationBar: BottomNavigationBar(
              onTap: (index) {
                AppCubit.get(context).changeIndex(index);
                print(cubit.currentIndex);
              },
              type: BottomNavigationBarType.fixed,
              elevation: 0.0,
              currentIndex: cubit.currentIndex!,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Tasks'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.check_box_outlined), label: 'Done'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.archive_outlined), label: 'Archived'),
              ],
            ),
            body: ConditionalBuilder(
              condition: state is! AppGetDataBaseLoadingStates,
              builder: (context) => cubit.screens[cubit.currentIndex!],
              fallback: (context) => const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        },
        listener: (BuildContext context, Object? state) {
          if (state is AppInsertDataBaseStates) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
