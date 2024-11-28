import { Component, OnInit } from '@angular/core';
import { Firestore, collectionData, collection, addDoc, deleteDoc, doc, updateDoc } from '@angular/fire/firestore';
import { Observable } from 'rxjs';
import { FormsModule } from '@angular/forms';
import { CommonModule } from '@angular/common';
import * as bootstrap from 'bootstrap';
import { AddTodoFormComponent } from './add-todo-form/add-todo-form.component';
import { TodoActionsComponent } from './todo-actions/todo-actions.component';
import { AuthService } from '../../services/auth.service';

@Component({
  selector: 'app-todolist',
  standalone: true,
  imports: [FormsModule, CommonModule, AddTodoFormComponent, TodoActionsComponent],
  templateUrl: './todolist.component.html',
  styleUrls: ['./todolist.component.scss']
})
export class TodolistComponent {
  todos$: Observable<any[]>;
  newTodo: string = '';
  newText: string = '';
  newDueDate: string = '';
  selectedTodo: any = null;

  constructor(private firestore: Firestore, private authService: AuthService) {
    const todosCollection = collection(this.firestore, 'todos');
    this.todos$ = collectionData(todosCollection, { idField: 'id' });
  }

  openAddTodoModal() {
    const addTodoModal = new bootstrap.Modal(document.getElementById('addTodoModal')!);
    addTodoModal.show();
  }

  openDescriptionModal(todo: any) {
    this.selectedTodo = todo;
    const descriptionModal = new bootstrap.Modal(document.getElementById('descriptionModal')!);
    descriptionModal.show();
  }

  async addTodo(todoData: { title: string; text: string; dueDate: string; assignedTo: string }) {
    const todosCollection = collection(this.firestore, 'todos');
    const currentUserEmail = this.authService.getCurrentUserEmail();
    const participants = [currentUserEmail];
    await addDoc(todosCollection, {
      title: todoData.title,
      text: todoData.text,
      dateAdded: new Date(),
      dueDate: todoData.dueDate ? new Date(todoData.dueDate) : null,
      completed: false,
      assignedTo: todoData.assignedTo || currentUserEmail,
      participants: participants,
      createdBy: currentUserEmail
    });
    const addTodoModalElement = document.getElementById('addTodoModal');
    if (addTodoModalElement) {
      const addTodoModal = bootstrap.Modal.getInstance(addTodoModalElement);
      addTodoModal?.hide();
    }
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