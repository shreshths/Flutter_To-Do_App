import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TodoHomePage(),
    );
  }
}

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key});

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  List<Map<String, dynamic>> _tasks = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksString = prefs.getString('tasks');

    if (tasksString != null) {
      setState(() {
        _tasks = List<Map<String, dynamic>>.from(json.decode(tasksString));
      });
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('tasks', json.encode(_tasks));
  }

  void _addTask() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _tasks.add({
          'title': _controller.text,
          'isCompleted': false,
        });
        _controller.clear();
      });
      _saveTasks();
    }
  }

  void _editTask(int index) {
    _controller.text = _tasks[index]['title'];
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Edit Task'),
            content: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Update your task',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final updatedTask = _controller.text;
                  if (updatedTask.isNotEmpty) {
                    setState(() {
                      _tasks[index]['title'] = updatedTask;
                    });
                    _saveTasks();
                    _controller.clear();
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        });
  }

  void _deletetask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
    _saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('To-Do List')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter a task',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) => _addTask(),
            ),
          ),
          Expanded(
            child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  return Card(
                    child: ListTile(
                      leading: Checkbox(
                          value: task['isCompleted'],
                          onChanged: (bool? value) {
                            setState(() {
                              _tasks[index]['isCompleted'] = value ?? false;
                            });
                            _saveTasks();
                          }),
                      title: Text(
                        task['title'],
                        style: TextStyle(
                          decoration: task['isCompleted']
                              ? TextDecoration.lineThrough
                              : null,
                          color:
                              task['isCompleted'] ? Colors.grey : Colors.black,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => _editTask(index),
                            icon: const Icon(Icons.edit),
                          ),
                          IconButton(
                              onPressed: () => _deletetask(index),
                              icon: const Icon(Icons.delete)),
                        ],
                      ),
                    ),
                  );
                }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        child: const Icon(Icons.add),
      ),
    );
  }
}
