import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddTodoModal extends StatefulWidget {
  const AddTodoModal({super.key});

  @override
  State<AddTodoModal> createState() => _AddTodoModalState();
}

class _AddTodoModalState extends State<AddTodoModal> {
  final _titleController = TextEditingController();
  final _textController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _assignedTo = '';
  final _currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';

  Stream<QuerySnapshot> getUsers() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('email', isNotEqualTo: _currentUserEmail)
        .snapshots();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
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
        initialTime: TimeOfDay.now(),
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

  void _addTodo() {
    final String newTitle = _titleController.text.trim();
    final String newText = _textController.text.trim();

    if (newTitle.isNotEmpty) {
      List<String> participants = [_currentUserEmail];
      if (_assignedTo.isNotEmpty && _assignedTo != _currentUserEmail) {
        participants.add(_assignedTo);
      }
      FirebaseFirestore.instance.collection('todos').add({
        'title': newTitle,
        'text': newText,
        'completed': false,
        'dateAdded': Timestamp.now(),
        'dueDate': Timestamp.fromDate(_selectedDate),
        'assignedTo': _assignedTo,
        'createdBy': _currentUserEmail,
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
                } else {
                  List<DropdownMenuItem<String>> userItems =
                      snapshot.data!.docs.map((doc) {
                    String email = doc['email'];
                    return DropdownMenuItem(
                      value: email,
                      child: Text(email),
                    );
                  }).toList();

                  return DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Assign to',
                    ),
                    value: _assignedTo.isEmpty ? null : _assignedTo,
                    items: userItems,
                    onChanged: (value) {
                      setState(() {
                        _assignedTo = value ?? '';
                      });
                    },
                  );
                }
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
                  onPressed: _addTodo,
                  child: const Text('Add Todo'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
