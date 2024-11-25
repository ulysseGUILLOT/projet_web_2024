import { Component, OnInit } from '@angular/core';
import { Firestore, collectionData, collection, addDoc, deleteDoc, doc } from '@angular/fire/firestore';
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

  constructor(private firestore: Firestore) {
    const todosCollection = collection(this.firestore, 'todos');
    this.todos$ = collectionData(todosCollection, { idField: 'id' });
  }

  ngOnInit(): void {}

  addTodo() {
    const todosCollection = collection(this.firestore, 'todos');
    addDoc(todosCollection, { text: this.newTodo });
    this.newTodo = '';
  }

  deleteTodo(id: string) {
    const todoDoc = doc(this.firestore, `todos/${id}`);
    deleteDoc(todoDoc);
  }
}