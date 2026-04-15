import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  // --- MODULES ---
  // Adds a new module (e.g., "Compiler Design")
  Future<void> addModule(String name, int coef) async {
    await _db.collection('users').doc(uid).collection('modules').add({
      'name': name,
      'coefficient': coef,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // --- CHAPTERS ---
  // Adds a chapter inside a specific module
  Future<void> addChapter(String moduleId, String chapterTitle) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('modules')
        .doc(moduleId) // We need the specific module's ID
        .collection('chapters')
        .add({
      'title': chapterTitle,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // --- VAULT ITEMS (The Sheets & Corrections) ---
  // Adds the TD and its correction link inside a chapter
  Future<void> addVaultItem(String moduleId, String chapterId, String label, String tdUrl, String correctionUrl) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('modules')
        .doc(moduleId)
        .collection('chapters')
        .doc(chapterId)
        .collection('vault_items')
        .add({
      'label': label,
      'tdUrl': tdUrl,
      'correctionUrl': correctionUrl,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}