import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { AngularFireModule } from '@angular/fire/compat';
import { AngularFireAuthModule } from '@angular/fire/compat/auth';
import { AngularFirestoreModule } from '@angular/fire/compat/firestore';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { TodolistComponent } from './todolist/todolist.component';
import { FormsModule } from '@angular/forms';

const firebaseConfig = {
  apiKey: "AIzaSyAUi2uVmKzsquF22MzIUBhp4cu2JQo_hkQ",
  authDomain: "angular-flutter-cloud.firebaseapp.com",
  projectId: "angular-flutter-cloud",
  storageBucket: "angular-flutter-cloud.firebasestorage.app",
  messagingSenderId: "398506827783",
  appId: "1:398506827783:web:2cfddeba315d49f435caa2"
};

@NgModule({
  declarations: [
    AppComponent,
    TodolistComponent,
  ],
  imports: [
    BrowserModule,
    AppRoutingModule,
    AngularFireModule.initializeApp(firebaseConfig),
    AngularFireAuthModule,
    AngularFirestoreModule,
    FormsModule
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }