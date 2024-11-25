import { Component } from '@angular/core';
import { AngularFirestore } from '@angular/fire/compat/firestore';

@Component({
  selector: 'app-todolist',
  templateUrl: './todolist.component.html',
  styleUrls: ['./todolist.component.scss']
})
export class TodolistComponent {
  newTodo: string = '';

  constructor(private firestore: AngularFirestore) {}

  addTodo() {
    if (this.newTodo.trim()) {
      this.firestore.collection('todos').add({ task: this.newTodo, completed: false })
        .then(() => {
          console.log('Todo added successfully');
          this.newTodo = '';
        })
        .catch(error => {
          console.error('Error adding todo: ', error);
        });
    }
  }
}