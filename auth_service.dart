import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Login
  Future<void> loginUser(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw Exception("Login Error: $e");
    }
  }

  // Create User in Auth and Firestore
  Future<void> registerUser(String email, String password, String username, String university) async {
    try {
      // 1. Create the user in Auth
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Create the linked document in the 'user' collection
      if (credential.user != null) {
        String userid = credential.user!.uid;

        await _db.collection('users').doc(userid).set({
          'userid': userid,
          'username': username,
          'e-mail': email,
          'university': university,
          'createdAt': FieldValue.serverTimestamp(),
          'level' : '1',
        });
      }
    } catch (e) {
      throw Exception("Registration Error: $e");
    }
  }

  // Fetch the data back
  Future<Map<String, dynamic>?> getUserData(String userid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(userid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print("Fetch Error: $e");
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}