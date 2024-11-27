import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/todo.dart';

class EditTodoModal extends StatefulWidget {
  const EditTodoModal({Key? key, required this.todo}) : super(key: key);

  final Todo todo;

  @override
  State<EditTodoModal> createState() => _EditTodoModalState();
}

class _EditTodoModalState extends State<EditTodoModal> {
  late TextEditingController _titleController;
  late TextEditingController _textController;
  late DateTime _selectedDate;
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
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
    );

    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );

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

  void _updateTodo() {
    final String updatedTitle = _titleController.text.trim();
    final String updatedText = _textController.text.trim();

    if (updatedTitle.isNotEmpty) {
      List<String> participants = [_currentUserEmail];
      if (_assignedTo.isNotEmpty && _assignedTo != _currentUserEmail) {
        participants.add(_assignedTo);
      }

      FirebaseFirestore.instance
          .collection('todos')
          .doc(widget.todo.id)
          .update({
        'title': updatedTitle,
        'text': updatedText,
        'dueDate': Timestamp.fromDate(_selectedDate),
        'assignedTo': _assignedTo,
        'participants': participants,
      });

      Navigator.pop(context);
    }
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

                // Create items list with "Unassigned" option
                final List<DropdownMenuItem<String>> userItems = [
                  DropdownMenuItem(
                    value: _currentUserEmail, // Default to current user
                    child: const Text('Me'),
                  ),
                ];

                // Add other users (excluding current user)
                for (var doc in snapshot.data!.docs) {
                  final String email = doc['email'] as String;
                  if (email != _currentUserEmail) {
                    userItems.add(DropdownMenuItem(
                      value: email,
                      child: Text(email),
                    ));
                  }
                }

                // Default to current user if no assignment
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
                      _assignedTo = value ??
                          _currentUserEmail; // Default to current user if null
                    });
                  },
                );
              },
            ),
            ListTile(
              title: const Text('Due Date'),
              subtitle:
                  Text(DateFormat('dd/MM/yyyy HH:mm').format(_selectedDate)),
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
                  onPressed: _updateTodo,
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
