
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // JSON işlemleri için
import 'package:intl/intl.dart';
class TasksPage extends StatefulWidget {
  final List<Map<String, dynamic>> initialTasks;

  TasksPage({required this.initialTasks});

  @override
  _TasksPageState createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  List<Map<String, dynamic>> _tasks = [];
  final TextEditingController _taskController = TextEditingController();
  String? _selectedCategory;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  final Map<String, String> _categoryImages = {
    'İş': 'assets/job.png',
    'Gündelik': 'assets/daily.png',
    'Okul': 'assets/school.png',
  };

  @override
  void initState() {
    super.initState();
    _tasks = widget.initialTasks;
  }

  Future<void> _saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String tasksJson = json.encode(_tasks);
    await prefs.setString('tasks', tasksJson);
  }

  void _addTask() {
    _taskController.clear();
    _selectedCategory = null;
    _selectedDate = null;
    _selectedTime = null;
// Yeni görev ekleme kısmında:
    String formattedTime = _selectedTime != null
        ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
        : '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Yeni Görev Ekle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _taskController,
                decoration: InputDecoration(labelText: 'Görev Adı'),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                hint: Text('Kategori Seç'),
                items: _categoryImages.keys
                    .map(
                      (category) => DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  ),
                )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () async {
                      _selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      setState(() {});
                    },
                    child: Text(
                      _selectedDate == null
                          ? 'Tarih Seç'
                          : '${_selectedDate!.toLocal()}'.split(' ')[0],
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      _selectedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      setState(() {});
                    },
                    child: Text(
                      _selectedTime == null
                          ? 'Saat Seç'
                          : '${_selectedTime!.format(context)}',
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_taskController.text.isNotEmpty &&
                    _selectedCategory != null &&
                    _selectedDate != null &&
                    _selectedTime != null) {
                  setState(() {
                    // Tarih ve saat formatlama
                    final DateTime combinedDateTime = DateTime(
                      _selectedDate!.year,
                      _selectedDate!.month,
                      _selectedDate!.day,
                      _selectedTime!.hour,
                      _selectedTime!.minute,
                    );
                    String formattedDateTime =
                    DateFormat('yyyy-MM-dd HH:mm').format(combinedDateTime);

                    _tasks.add({
                      'task': _taskController.text,
                      'category': _selectedCategory,
                      'dateTime': formattedDateTime, // Tarih ve saat birleştirilmiş
                      'completed': false,
                    });
                    _saveTasks();
                  });
                  Navigator.pop(context);
                }
              },

              child: Text('Ekle'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('İptal'),
            ),
          ],
        );
      },
    );
  }

  void _toggleTaskCompletion(int index) {
    setState(() {
      _tasks[index]['completed'] = !_tasks[index]['completed'];
      _saveTasks();
    });
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
      _saveTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Görevler'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addTask,
          ),
        ],
      ),
      body: _tasks.isEmpty
          ? Center(child: Text('Henüz görev eklenmedi.'))
          : GridView.builder(
        padding: EdgeInsets.all(8.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          final category = task['category'];
          final image = _categoryImages[category];

          return Card(
            color: task['completed'] ? Colors.green : Colors.white,
            elevation: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Image.asset(
                    image!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    task['task'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: task['completed']
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    task['dateTime'] ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      color: task['completed'] ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Checkbox(
                      value: task['completed'],
                      onChanged: (value) {
                        _toggleTaskCompletion(index);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteTask(index),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
