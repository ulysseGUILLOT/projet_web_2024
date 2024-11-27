import { Routes } from '@angular/router';
import { TodolistComponent } from './component/todolist/todolist.component';
import { SignupComponent } from './component/signup/signup.component';
import { SigninComponent } from './component/signin/signin.component';
import { AuthGuard } from './guard/auth.guard';

export const routes: Routes = [
    { path: '', component: TodolistComponent, canActivate: [AuthGuard] },
    { path: 'signup', component: SignupComponent },
    { path: 'login', component: SigninComponent }
];