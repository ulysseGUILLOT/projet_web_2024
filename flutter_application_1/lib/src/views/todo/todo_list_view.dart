import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/todo.dart';

class TodoListView extends StatefulWidget {
  const TodoListView({super.key});

  static const routeName = '/';

  @override
  State<TodoListView> createState() => _SampleItemListViewState();
}

class _SampleItemListViewState extends State<TodoListView> {
  DateTime selectedDate = DateTime.now();
  String selectedUser = '';

  Stream<QuerySnapshot> getUsers() {
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;
    return FirebaseFirestore.instance
        .collection('users')
        .where('email', isNotEqualTo: currentUserEmail)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Todo List'),
            Text(
              currentUserEmail,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('todos')
            .where('participants', arrayContains: currentUserEmail)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final todos = snapshot.data!.docs
              .map((doc) => Todo.fromFirestore(
                  doc.data() as Map<String, dynamic>, doc.id))
              .toList();

          return ListView.builder(
            itemCount: todos.length,
            itemBuilder: (context, index) {
              final todo = todos[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Checkbox(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    activeColor: Colors.green,
                    checkColor: Colors.white,
                    value: todo.completed,
                    onChanged: (bool? value) {
                      FirebaseFirestore.instance
                          .collection('todos')
                          .doc(todo.id)
                          .update({'completed': value});
                    },
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        todo.title,
                        style: TextStyle(
                          decoration: todo.completed
                              ? TextDecoration.lineThrough
                              : null,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        todo.text,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (todo.assignedTo != null &&
                          todo.assignedTo!.isNotEmpty)
                        Text(
                          'Assigned to: ${todo.assignedTo}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      Text(
                        'Due: ${DateFormat('dd MMM yyyy HH:mm').format(todo.dueDate)}',
                        style: TextStyle(
                          color: todo.dueDate.isBefore(DateTime.now())
                              ? Colors.red
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              String updatedTitle = todo.title;
                              return Container(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                      autofocus: true,
                                      controller: TextEditingController(
                                          text: todo.title),
                                      decoration: const InputDecoration(
                                        labelText: 'Update Todo',
                                        hintText: 'Modify your todo',
                                      ),
                                      onChanged: (value) {
                                        updatedTitle = value;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Cancel'),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          onPressed: () {
                                            if (updatedTitle.isNotEmpty) {
                                              FirebaseFirestore.instance
                                                  .collection('todos')
                                                  .doc(todo.id)
                                                  .update(
                                                      {'title': updatedTitle});
                                              Navigator.pop(context);
                                            }
                                          },
                                          child: const Text('Update'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Delete Todo'),
                                content: const Text(
                                    'Are you sure you want to delete this todo?'),
                                actions: [
                                  TextButton(
                                    child: const Text('Cancel'),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  TextButton(
                                    child: const Text('Delete',
                                        style: TextStyle(color: Colors.red)),
                                    onPressed: () {
                                      FirebaseFirestore.instance
                                          .collection('todos')
                                          .doc(todo.id)
                                          .delete();
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              String newTitle = '';
              String newText = '';
              DateTime selectedDate = DateTime.now();
              String assignedTo = '';

              return Container(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        autofocus: true,
                        decoration: const InputDecoration(
                          labelText: 'Todo Title',
                          hintText: 'Enter your todo title',
                        ),
                        onChanged: (value) => newTitle = value,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Todo Description',
                          hintText: 'Enter your todo description',
                        ),
                        onChanged: (value) => newText = value,
                      ),
                      const SizedBox(height: 16),
                      // User selection dropdown
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
                              value: assignedTo.isEmpty ? null : assignedTo,
                              items: userItems,
                              onChanged: (value) {
                                assignedTo = value ?? '';
                              },
                            );
                          }
                        },
                      ),
                      ListTile(
                        title: const Text('Due Date'),
                        subtitle: Text(DateFormat('dd/MM/yyyy HH:mm')
                            .format(selectedDate)),
                        trailing: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            final DateTime? date = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
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
                                  selectedDate = DateTime(
                                    date.year,
                                    date.month,
                                    date.day,
                                    time.hour,
                                    time.minute,
                                  );
                                });
                              }
                            }
                          },
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
                            onPressed: () {
                              if (newTitle.isNotEmpty) {
                                List<String> participants = [currentUserEmail];
                                if (assignedTo.isNotEmpty &&
                                    assignedTo != currentUserEmail) {
                                  participants.add(assignedTo);
                                }
                                FirebaseFirestore.instance
                                    .collection('todos')
                                    .add({
                                  'title': newTitle,
                                  'text': newText,
                                  'completed': false,
                                  'dateAdded': Timestamp.now(),
                                  'dueDate': Timestamp.fromDate(selectedDate),
                                  'assignedTo': assignedTo,
                                  'createdBy': currentUserEmail,
                                  'participants': participants,
                                });
                                Navigator.pop(context);
                              }
                            },
                            child: const Text('Add Todo'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
