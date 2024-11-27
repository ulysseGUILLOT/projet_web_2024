import { Component, Output, EventEmitter, OnInit } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { AuthService } from '../../../services/auth.service';

@Component({
  selector: 'app-add-todo-form',
  standalone: true,
  imports: [FormsModule, CommonModule],
  templateUrl: './add-todo-form.component.html',
  styleUrl: './add-todo-form.component.scss'
})
export class AddTodoFormComponent implements OnInit {
  newTodo: string = '';
  newText: string = '';
  newDueDate: string = '';
  assignedTo: string = '';
  users: any[] = [];

  @Output() addTodo = new EventEmitter<any>();

  constructor(private authService: AuthService) {}

  async ngOnInit() {
    this.users = await this.authService.getUsers();
  }

  onSubmit() {
    this.addTodo.emit({ title: this.newTodo, text: this.newText, dueDate: this.newDueDate, assignedTo: this.assignedTo });
    this.newTodo = '';
    this.newText = '';
    this.newDueDate = '';
    this.assignedTo = '';
  }
}