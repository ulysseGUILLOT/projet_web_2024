import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/todo.dart';

class EditTodoModal extends StatefulWidget {
  const EditTodoModal({super.key, required this.todo});

  final Todo todo;

  @override
  State<EditTodoModal> createState() => _EditTodoModalState();
}

class _EditTodoModalState extends State<EditTodoModal> {
  late TextEditingController _titleController;
  late TextEditingController _textController;
  DateTime? _selectedDate;
  String _assignedTo = '';
  final String _currentUserEmail =
      FirebaseAuth.instance.currentUser?.email ?? '';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo.title);
    _textController = TextEditingController(text: widget.todo.text);
    _selectedDate = widget.todo.dueDate;
    _assignedTo = widget.todo.assignedTo ?? '';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot> getUsers() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('email', isNotEqualTo: _currentUserEmail)
        .snapshots();
  }

  Future<void> _selectDueDate() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
    );

    if (!mounted) return;

    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate ?? DateTime.now()),
      );

      if (!mounted) return;

      if (time != null) {
        setState(() {
          _selectedDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _saveTodo() {
    final Map<String, dynamic> updateData = {
      'title': _titleController.text.trim(),
      'text': _textController.text.trim(),
      'assignedTo': _assignedTo,
    };

    if (_selectedDate != null) {
      updateData['dueDate'] = Timestamp.fromDate(_selectedDate!);
    }

    FirebaseFirestore.instance
        .collection('todos')
        .doc(widget.todo.id)
        .update(updateData);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              autofocus: true,
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Todo Title',
                hintText: 'Enter your todo title',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Todo Description',
                hintText: 'Enter your todo description',
              ),
            ),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: getUsers(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final List<DropdownMenuItem<String>> userItems = [
                  DropdownMenuItem(
                    value: _currentUserEmail,
                    child: const Text('Me'),
                  ),
                ];

                for (var doc in snapshot.data!.docs) {
                  final String email = doc['email'] as String;
                  if (email != _currentUserEmail) {
                    userItems.add(DropdownMenuItem(
                      value: email,
                      child: Text(email),
                    ));
                  }
                }

                _assignedTo =
                    _assignedTo.isEmpty ? _currentUserEmail : _assignedTo;

                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Assign to',
                    border: OutlineInputBorder(),
                  ),
                  value: _assignedTo,
                  items: userItems,
                  onChanged: (value) {
                    setState(() {
                      _assignedTo = value ?? _currentUserEmail;
                    });
                  },
                );
              },
            ),
            ListTile(
              title: const Text('Due Date'),
              subtitle: Text(DateFormat('dd/MM/yyyy HH:mm')
                  .format(_selectedDate ?? DateTime.now())),
              trailing: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: _selectDueDate,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _saveTodo,
                  child: const Text('Update Todo'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
