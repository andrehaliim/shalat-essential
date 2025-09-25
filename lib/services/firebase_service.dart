import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static Future<User?> getUserInfo() async {
    return FirebaseAuth.instance.currentUser;
  }

  static Future<String?> loadNickname() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      if (doc.exists) {
        return doc.data()?["nickname"];
      }
    }
    return null;
  }

  static Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }
}