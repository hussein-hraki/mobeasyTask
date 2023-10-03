//ملف تسجيل الدخول باستخدام جوجل
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

//تسجيل الدخول باستخدام جوجل
class SignGoogle {
  final FirebaseAuth _auth = FirebaseAuth.instance;//تهيئة المصادقة
  final GoogleSignIn googleSignIn = GoogleSignIn();
//تسجيل الدخول
  Future<User?> signGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      final UserCredential authResult = await _auth.signInWithCredential(credential);
      final User? user = authResult.user;//ارجاع متغير من نوع يوزر لأخذ المعلومات مثل اسم الحساب
      return user;
    } catch (error) {
      print(error);
      return null;
    }
  }

  //تسجيل الخروج
  Future<void> outGoogle() async {
     await googleSignIn.signOut();
  }
}
