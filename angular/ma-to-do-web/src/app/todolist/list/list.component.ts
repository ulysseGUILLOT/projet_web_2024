import { Component, Input, Output, EventEmitter } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'app-list',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './list.component.html',
  styleUrl: './list.component.scss'
})
export class ListComponent {
  @Input() todos: any[] = [];
  @Output() toggleStatus = new EventEmitter<any>();
  @Output() deleteTodo = new EventEmitter<string>();
  @Output() editTodo = new EventEmitter<any>();
  @Output() saveTodo = new EventEmitter<any>();
  @Output() openDescriptionModal = new EventEmitter<any>();

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
