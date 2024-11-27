import { Component, Input, Output, EventEmitter } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-todo-actions',
  standalone: true,
  imports: [FormsModule, CommonModule],
  templateUrl: './todo-actions.component.html',
  styleUrl: './todo-actions.component.scss'
})
export class TodoActionsComponent {
  @Input() todo: any;

  @Output() toggleStatus = new EventEmitter<any>();
  @Output() delete = new EventEmitter<string>();
  @Output() edit = new EventEmitter<any>();
  @Output() save = new EventEmitter<any>();

  onToggleStatus() {
    this.toggleStatus.emit(this.todo);
  }

  onDelete() {
    this.delete.emit(this.todo.id);
  }

  onEdit() {
    this.edit.emit(this.todo);
  }

  onSave() {
    this.save.emit(this.todo);
  }
}
