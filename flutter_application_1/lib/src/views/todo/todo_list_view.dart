import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/todo.dart';
import 'todo_list_item.dart';
import 'add_todo_modal.dart';

class TodoListView extends StatefulWidget {
  const TodoListView({super.key});

  static const routeName = '/';

  @override
  State<TodoListView> createState() => _TodoListViewState();
}

class _TodoListViewState extends State<TodoListView> {
  final _currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List - $_currentUserEmail'),
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
            .where('participants', arrayContains: _currentUserEmail)
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

          if (todos.isEmpty) {
            return const Center(child: Text('No todos available.'));
          }

          return ListView.builder(
            itemCount: todos.length,
            itemBuilder: (context, index) {
              final todo = todos[index];
              return TodoListItem(
                todo: todo,
                currentUserEmail: _currentUserEmail,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTodoModal,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTodoModal() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return const AddTodoModal();
      },
    );
  }
}
