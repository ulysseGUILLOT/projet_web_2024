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
  dateError: boolean = false; // Nouvelle propriété pour gérer l'état d'erreur

  @Output() addTodo = new EventEmitter<any>();

  constructor(private authService: AuthService) {
    this.setMinDate();
  }

  async ngOnInit() {
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
    // Vérification de la validité de la date
    if (new Date(this.newDueDate) < new Date(this.minDate)) {
      this.dateError = true; // Active l'erreur si la date est invalide
      return;
    }

    this.dateError = false; // Réinitialise l'état de l'erreur si la date est valide

    // Émission de l'événement si toutes les validations passent
    this.addTodo.emit({
      title: this.newTodo,
      text: this.newText,
      dueDate: this.newDueDate,
      assignedTo: this.assignedTo,
    });

    // Réinitialisation des champs après la soumission
    this.newTodo = '';
    this.newText = '';
    this.newDueDate = '';
    this.assignedTo = '';
  }
}
