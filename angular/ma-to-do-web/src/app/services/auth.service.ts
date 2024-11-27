import { Injectable } from '@angular/core';
import { Auth, UserCredential, signInWithEmailAndPassword, createUserWithEmailAndPassword } from '@angular/fire/auth';
import { Firestore, doc, setDoc, collection, getDocs } from '@angular/fire/firestore';
import { Router } from '@angular/router';

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  constructor(private auth: Auth, private firestore: Firestore, private router: Router) { }

  async registerWithEmailAndPassword(email: string, password: string): Promise<UserCredential> {
    try {
      const userCredential = await createUserWithEmailAndPassword(this.auth, email, password);
      await setDoc(doc(this.firestore, 'users', userCredential.user!.uid), {
        email: email,
        createdAt: new Date()
      });
      localStorage.setItem('user', JSON.stringify(userCredential.user));
      return userCredential;
    } catch (error) {
      throw (error as any).message ?? 'An error occurred during registration';
    }
  }

  async signInWithEmailAndPassword(email: string, password: string): Promise<UserCredential> {
    try {
      const userCredential = await signInWithEmailAndPassword(this.auth, email, password);
      localStorage.setItem('user', JSON.stringify(userCredential.user));
      return userCredential;
    } catch (error) {
      throw (error as any).message ?? 'An error occurred during sign in';
    }
  }

  signOut(): void {
    this.auth.signOut().then(() => {
      localStorage.removeItem('user');
      this.router.navigate(['/login']);
    });
  }

  isAuthenticated(): boolean {
    return localStorage.getItem('user') !== null;
  }

  getCurrentUserEmail(): string {
    const user = JSON.parse(localStorage.getItem('user') || '{}');
    return user?.email || '';
  }

  async getUsers(): Promise<any[]> {
    const usersCollection = collection(this.firestore, 'users');
    const usersSnapshot = await getDocs(usersCollection);
    return usersSnapshot.docs.map(doc => doc.data());
  }
}