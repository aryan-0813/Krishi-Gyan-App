import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:krishi_gyan/constants/exceptions.dart';

class Login with ChangeNotifier {
  final FirebaseAuth auth = FirebaseAuth.instance;
  User? user;

  Stream<User?> get userChange {
    return auth.authStateChanges();
  }

  User? get currentUser => auth.currentUser;

  Future<User> register(
      String email, String password, String name, String mobile) async {
    try {
      UserCredential result = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      user = auth.currentUser;
      notifyListeners();
      _createNewUserInFirestore(name, email, mobile);
      return user!;
    } on FirebaseAuthException catch (e) {
      String message = '';

      switch (e.code) {
        case 'email-already-in-use':
          message = 'An account already exists with this email';
          break;
        case 'invalid-email':
          message = 'Invalid email';
          break;
        case 'weak-password':
          message = 'Password is too weak';
          break;
        default:
          message = 'An unknown error occurred';
          break;
      }

      throw ResgistrationException(message);
    }
  }

  Future signOutFunction() async{
    try {
 
      return await (auth.signOut());
    } catch (e) {
      throw Exception('');
    }
  }

  Future<User> signIn(String email, String password) async {
    try {
      UserCredential result = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      user = result.user;
      notifyListeners();
      return user!;
    } on FirebaseAuthException catch (e) {
      String message = '';
      switch (e.code) {
        case 'invalid-email':
          message = 'Invalid login credentials';
          break;
        case 'user-not-found':
          message = 'No such user found';
          break;
        case 'wrong-password':
          message = 'Incorrect login credentials';
          break;
        default:
          message = 'An unknown error occurred';
          break;
      }
      throw SignInException(message);
    }
  }

  void _createNewUserInFirestore(String name, String email, String mobile) {
    final CollectionReference<Map<String, dynamic>> usersRef =
        FirebaseFirestore.instance.collection('users');
    usersRef.doc(user?.uid).set({
      'id': user?.uid,
      'name': name,
      'email': email,
      'mobile': mobile,
      // 'timestamp': documentIdFromCurrentDate(),
    });
  }
}
