import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HomeworkItem {
  final String title;
  bool isCompleted;

  HomeworkItem({required this.title, this.isCompleted = false});

  Map<String, dynamic> toJson() => {'title': title, 'isCompleted': isCompleted};

  factory HomeworkItem.fromJson(Map<String, dynamic> json) {
    return HomeworkItem(title: json['title'], isCompleted: json['isCompleted']);
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Assignments());
  }
}

class Assignments extends StatefulWidget {
  const Assignments({super.key});

  @override
  State<Assignments> createState() => _AssignmentState();
}

class _AssignmentState extends State<Assignments> {
  List<HomeworkItem> homeworkItems = [
    HomeworkItem(title: 'Finish Math problems'),
    HomeworkItem(title: 'Read ch. 4 for Sci'),
    HomeworkItem(title: 'Work on Programming project'),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Homework')),
      body: ListView(
        children: homeworkItems.map((homework) {
          return Dismissible(
            key: Key(homework.title),
            onDismissed: (direction) {
              setState(() {
                homeworkItems.remove(homework);
                _saveData();
              });
            },
            background: Container(color: Colors.red),
            child: ListTile(
              leading: Checkbox(
                value: homework.isCompleted,
                onChanged: (newValue) {
                  setState(() {
                    homework.isCompleted = newValue!;
                    _saveData();
                  });
                },
              ),
              title: Text(
                homework.title,
                style: homework.isCompleted
                    ? const TextStyle(decoration: TextDecoration.lineThrough)
                    : null,
              ),
            ),
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddHomeworkDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddHomeworkDialog() {
    final TextEditingController textController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Homework'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(hintText: "Enter homework..."),
          ),
          actions: [
            TextButton(
              child: const Text('cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                final newHomework = textController.text;
                Navigator.of(dialogContext).pop(newHomework);
              },
            ),
          ],
        );
      },
    ).then((newHomework) {
      if (newHomework != null && newHomework.isNotEmpty) {
        setState(() {
          homeworkItems.add(HomeworkItem(title: newHomework));
          _saveData();
        });
      }
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    final List<String> homeworkJsonList = homeworkItems.map((item) {
      return jsonEncode(item.toJson());
    }).toList();

    await prefs.setStringList('homeworkItems', homeworkJsonList);
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? homeworkJsonList = prefs.getStringList('homeworkItems');

    if (homeworkJsonList != null) {
      setState(() {
        homeworkItems = homeworkJsonList.map((jsonString) {
          final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
          return HomeworkItem.fromJson(jsonMap);
        }).toList();
      });
    }
  }
}
