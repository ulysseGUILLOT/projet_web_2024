import { Component, OnInit } from '@angular/core';
import { Firestore, collectionData, collection, addDoc, deleteDoc, doc, updateDoc } from '@angular/fire/firestore';
import { Observable } from 'rxjs';
import { FormsModule } from '@angular/forms';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-todolist',
  standalone: true,
  imports: [FormsModule, CommonModule],
  templateUrl: './todolist.component.html',
  styleUrl: './todolist.component.scss'
})
export class TodolistComponent implements OnInit {
  todos$: Observable<any[]>;
  newTodo: string = '';
  newText: string = '';
  newDueDate: string = '';
  minDate: string = '';

  constructor(private firestore: Firestore) {
    const todosCollection = collection(this.firestore, 'todos');
    this.todos$ = collectionData(todosCollection, { idField: 'id' });
  }

  ngOnInit(): void {
    this.setMinDate();
  }

  setMinDate() {
    const today = new Date();
    const year = today.getFullYear();
    const month = (today.getMonth() + 1).toString().padStart(2, '0');
    const day = today.getDate().toString().padStart(2, '0');
    this.minDate = `${year}-${month}-${day}`;
  }

  addTodo() {
    const todosCollection = collection(this.firestore, 'todos');
    addDoc(todosCollection, { title: this.newTodo, text: this.newText, dateAdded: new Date(), dueDate: new Date(this.newDueDate), completed: false });
    this.newTodo = '';
    this.newText = '';
    this.newDueDate = '';
  }

  deleteTodo(id: string) {
    const todoDoc = doc(this.firestore, `todos/${id}`);
    deleteDoc(todoDoc);
  }

  toggleTodoStatus(todo: any) {
    const todoDoc = doc(this.firestore, `todos/${todo.id}`);
    updateDoc(todoDoc, { completed: !todo.completed });
  }

  editTodo(todo: any) {
    todo.editing = true;
  }

  saveTodo(todo: any) {
    const todoDoc = doc(this.firestore, `todos/${todo.id}`);
    updateDoc(todoDoc, { title: todo.title, text: todo.text });
    todo.editing = false;
  }

  isDueSoon(dueDate: Date): boolean {
    const today = new Date();
    const timeDiff = dueDate.getTime() - today.getTime();
    const daysDiff = Math.ceil(timeDiff / (1000 * 3600 * 24));
    return daysDiff === 1;
  }

  isDueDatePassed(dueDate: Date): boolean {
    const today = new Date();
    return dueDate < today;
  }
}