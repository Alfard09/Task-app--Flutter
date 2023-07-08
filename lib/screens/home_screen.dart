import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/task.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const routeName = '/home-screen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _taskController;
  late List<Task> _tasks;
  late List<bool> _taskDone;

  void saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Task t = Task.fromString(_taskController.text);
    String? tasks = prefs.getString('task');
    List list = (tasks == null) ? [] : json.decode(tasks);
    print(list);
    list.add(json.encode(t.getMap()));
    print(list);
    prefs.setString('task', json.encode(list));
    _taskController.text = '';
    Navigator.of(context).pop();
  }

  void _getTask() async {
    _tasks = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Task t = Task.fromString(_taskController.text);
    String? tasks = prefs.getString('task');
    List list = (tasks == null) ? [] : json.decode(tasks);

    for (dynamic d in list) {
      _tasks.add(Task.fromMap(json.decode(d)));
    }
    _taskDone = List.generate(_tasks.length, (index) => false);
    // print(_tasks);
    setState(() {});
  }

  void updatePrintingTaskList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Task> pendingList = [];
    for (var i = 0; i < _tasks.length; i++) {
      if (!_taskDone[i]) pendingList.add(_tasks[i]);
    }
    var pendingListEncoded = List.generate(
        pendingList.length, (i) => json.encode(pendingList[i].getMap()));
    prefs.setString('task', json.encode(pendingListEncoded));
    _getTask();
  }

  @override
  void initState() {
    _taskController = TextEditingController();
    _getTask();
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          "Task Manager",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: updatePrintingTaskList,
            icon: Icon(
              Icons.save,
              color: Colors.yellow,
            ),
          ),
          IconButton(
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setString(
                'task',
                json.encode([]),
              );
              _getTask();
            },
            icon: Icon(
              Icons.delete,
              color: Colors.yellow,
            ),
          )
        ],
        centerTitle: true,
        backgroundColor: Colors.purple[900],
      ),
      body: (_tasks == null)
          ? Center(
              child: Text("No task added yet"),
            )
          : Column(
              children: _tasks
                  .map((e) => Container(
                        height: 70,
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        padding: const EdgeInsets.only(left: 10),
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: Colors.black, width: 0.5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              e.task,
                              style: GoogleFonts.montserrat(),
                            ),
                            Checkbox(
                              value: _taskDone[_tasks.indexOf(e)],
                              key: GlobalKey(),
                              onChanged: (val) {
                                setState(() {
                                  _taskDone[_tasks.indexOf(e)] = val!;
                                });
                              },
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(
          Icons.add,
          color: Color.fromARGB(255, 175, 0, 0),
        ),
        //backgroundColor: const Color.fromARGB(255, 95, 8, 110),
        onPressed: () => showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          builder: (BuildContext context) => Container(
            padding: const EdgeInsets.all(10.0),
            height: MediaQuery.of(context).size.height / 2.5 +
                MediaQuery.of(context).viewInsets.bottom,
            //width: 500,
            color: const Color.fromARGB(255, 96, 44, 105),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add Task',
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Icon(Icons.close),
                    ),
                  ],
                ),
                Divider(thickness: 2),
                SizedBox(height: 20),
                TextField(
                  controller: _taskController,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 233, 7, 7)),
                    ),
                    fillColor: const Color.fromARGB(207, 255, 235, 59),
                    filled: true,
                    hintText: 'Enter Task',
                    hintStyle: GoogleFonts.montserrat(),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: (MediaQuery.of(context).size.width / 2) - 20,
                        child: ElevatedButton(
                          // style: ElevatedButton.styleFrom(
                          //   backgroundColor:
                          //       const Color.fromARGB(255, 158, 158, 158),
                          // ),
                          onPressed: () {
                            _taskController.text = "";
                          },
                          child: Text(
                            'RESET',
                            style: GoogleFonts.montserrat(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: (MediaQuery.of(context).size.width / 2) - 20,
                        child: ElevatedButton(
                          onPressed: () => saveData(),
                          child: Text(
                            'ADD',
                            style: GoogleFonts.montserrat(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
