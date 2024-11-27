import { Component, EventEmitter, Output } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-add-todo-form',
  standalone: true,
  imports: [FormsModule, CommonModule],
  templateUrl: './add-todo-form.component.html',
  styleUrl: './add-todo-form.component.scss'
})
export class AddTodoFormComponent {
  newTodo: string = '';
  newText: string = '';
  newDueDate: string = '';
  minDate: string = '';

  @Output() addTodo = new EventEmitter<{ title: string, text: string, dueDate: string }>();

  constructor() {
    this.setMinDate();
  }

  setMinDate() {
    const today = new Date();
    const year = today.getFullYear();
    const month = (today.getMonth() + 1).toString().padStart(2, '0');
    const day = today.getDate().toString().padStart(2, '0');
    this.minDate = `${year}-${month}-${day}`;
  }

  onSubmit() {
    this.addTodo.emit({ title: this.newTodo, text: this.newText, dueDate: this.newDueDate });
    this.newTodo = '';
    this.newText = '';
    this.newDueDate = '';
  }
}