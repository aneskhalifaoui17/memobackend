//Manages the content the user creates (tasks, threads, etc.)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. CREATE USER PROFILE (The "Business Card")
  Future<void> createUserProfile(String uid, String email, String username) async {
    await _db.collection('users').doc(uid).set({
      'username': username,
      'email': email,
      'joinedAt': FieldValue.serverTimestamp(),
      'reputationScore': 0,
    });
  }

  // 2. ADD CALENDAR TASK (The "Calendar" logic)
  Future<void> addTask(String name, String note, DateTime date) async {
    final String uid = FirebaseAuth.instance.currentUser!.uid;
    await _db.collection('tasks').add({
      'ownerId': uid,
      'name': name,
      'note': note,
      'date': date.toIso8601String(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 3. PUBLISH THREAD (The "Reddit" logic)
  Future<void> publishThread(String title, String content, String authorName) async {
    final String uid = FirebaseAuth.instance.currentUser!.uid;
    await _db.collection('threads').add({
      'authorId': uid,
      'authorName': authorName,
      'title': title,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}