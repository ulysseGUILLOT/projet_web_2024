import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  final String id;
  final String title;
  final String text;
  final bool completed;
  final DateTime dateAdded;
  final DateTime dueDate;
  final String? assignedTo;
  final List<String>? participants;
  final String createdBy;

  Todo({
    required this.id,
    required this.title,
    required this.text,
    required this.completed,
    required this.dateAdded,
    required this.dueDate,
    this.assignedTo,
    this.participants,
    required this.createdBy,
  });

  factory Todo.fromFirestore(Map<String, dynamic> data, String id) {
    return Todo(
      id: id,
      title: data['title'] ?? '',
      text: data['text'] ?? '',
      completed: data['completed'] ?? false,
      dateAdded: (data['dateAdded'] as Timestamp).toDate(),
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      assignedTo: data['assignedTo'],
      participants: List<String>.from(data['participants'] ?? []),
      createdBy: data['createdBy'] ?? '',
    );
  }
}
