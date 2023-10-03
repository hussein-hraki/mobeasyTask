//ملف الحالات
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AppStates {}

//الحالة الأساسية
class InitialState extends AppStates {}

//حالة الانتظار
class LoadingState extends AppStates {}

//حالة الترحيب بعد تسجيل الدخول
class WelcomeState extends AppStates {
  User user;
  WelcomeState(this.user);
}

//حالة تحميل الأسئلة
class LoadingMatchState extends AppStates {
  Map<String, dynamic> data;
  List<String> listAnswers;
  LoadingMatchState(this.data, this.listAnswers);
}

//حالة انتهاء الأسئلة وعرض النتيجة
class FinishMatchState extends AppStates {
  Map<String, dynamic> document;
  List<String> listAnswers;
  int score;
  FinishMatchState(this.document, this.listAnswers, this.score);
}

//حالة لوحة المتصدرين
class LeaderboardState extends AppStates {
  QuerySnapshot? querySnapshot;
  String idNameInBoard;
  LeaderboardState(this.querySnapshot,this.idNameInBoard);
}

//حالة حدوث خطأ
class FailureState extends AppStates {}
