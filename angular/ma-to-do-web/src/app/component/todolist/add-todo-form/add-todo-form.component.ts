import { Component, Output, EventEmitter, OnInit } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { AuthService } from '../../../services/auth.service';

@Component({
  selector: 'app-add-todo-form',
  standalone: true,
  imports: [FormsModule, CommonModule],
  templateUrl: './add-todo-form.component.html',
  styleUrls: ['./add-todo-form.component.scss']
})
export class AddTodoFormComponent implements OnInit {
  newTodo: string = '';
  newText: string = '';
  newDueDate: string = '';
  assignedTo: string = '';
  users: any[] = [];
  minDate: string = '';
  dateError: boolean = false;

  @Output() addTodo = new EventEmitter<any>();

  constructor(private authService: AuthService) {
  }

  async ngOnInit() {
    this.setMinDate();
    this.users = await this.authService.getUsers();
  }

  setMinDate() {
    const today = new Date();
    const year = today.getFullYear();
    const month = (today.getMonth() + 1).toString().padStart(2, '0');
    const day = today.getDate().toString().padStart(2, '0');
    this.minDate = `${year}-${month}-${day}`;
  }

  onSubmit() {
    if (new Date(this.newDueDate) < new Date(this.minDate)) {
      this.dateError = true;
      return;
    }

    this.dateError = false;

    this.addTodo.emit({
      title: this.newTodo,
      text: this.newText,
      dueDate: this.newDueDate,
      assignedTo: this.assignedTo,
    });

    // Reset form fields after submission
    this.newTodo = '';
    this.newText = '';
    this.newDueDate = '';
    this.assignedTo = '';
  }
}