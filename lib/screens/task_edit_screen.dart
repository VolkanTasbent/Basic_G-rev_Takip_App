import 'package:flutter/material.dart';
import '../models/task.dart';
import '../utils/db_helper.dart';

class TaskEditScreen extends StatefulWidget {
  final Task? task;

  TaskEditScreen({this.task});

  @override
  _TaskEditScreenState createState() => _TaskEditScreenState();
}

class _TaskEditScreenState extends State<TaskEditScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
    }
  }

  void _saveTask() async {
    final db = DBHelper.instance;
    if (widget.task == null) {
      await db.createTask(
        Task(
          title: _titleController.text,
          description: _descriptionController.text,
        ),
      );
    } else {
      await db.updateTask(
        Task(
          id: widget.task!.id,
          title: _titleController.text,
          description: _descriptionController.text,
        ),
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Görev Düzenle')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Başlık'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Açıklama'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveTask,
              child: Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}
