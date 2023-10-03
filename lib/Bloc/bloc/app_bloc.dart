//الملف المسؤول عن معالجة الأحداث وتمرير الحالات
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobeasy/Bloc/data/firestore_service.dart';
import 'package:mobeasy/Bloc/data/sign_google.dart';

import 'app_events.dart';
import 'app_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


int scoreBoard = 0;//متغير حفظ درجة الامتحان من أجل إرسالها إلى لوحة المتصدرين في فايرستور
class AppBloc extends Bloc<AppEvents, AppStates> {
  //-------المتغيرات الأساسية في البرنامج-------//
  int indexQ = -1; //رقم السؤال
  List<String> listAnswers = []; //قائمة إجابات المستخدم
  int score = 0; //درجة الامتحان
  String name = ''; //اسم المستخدم يتم جلبه من حساب جوجل
  String idNameInBoard = ''; //معرف النتيجة في قائمة المتصدرين لتمييزها عن باقي النتائج
  List<Map<String, dynamic>>? documents; //مستندات الامتحان سيتم احضارها من فايربيز
  
//---------------------------------------------//

  AppBloc() : super(InitialState()) {
    on<SignGoogleEvent>(_signGoogle);
    on<LoadingMathcEvent>(_loadingMatch);
    on<SendAndShowBoardEvent>(_showBoard);
    on<RestartEvent>(_restart);
  }

//حدث تسجيل الدخول إلى جوجل
//يقوم بتسجيل الدخول ثم جلب اسم المستخدم
  FutureOr<void> _signGoogle(SignGoogleEvent event, Emitter<AppStates> emit) async {
    emit(LoadingState());
    try {
      User? user = await SignGoogle().signGoogle();
      name = user!.displayName.toString();
      emit(WelcomeState(user));
    } catch (error) {
      print(error);
      emit(FailureState());
    }
  }

//حدث تحميل الامتحان
//يقوم بجلب الامتحان ثم تمرير الأسئلة
  FutureOr<void> _loadingMatch(LoadingMathcEvent event, Emitter<AppStates> emit) async {
    emit(LoadingState());
    try {
      //جلب الامتحان من فايرستور مرة واحدة ثم تمرير الأسئلة
      //ملاحظة:يتم جلب الأسئلة كمستند كامل ثم تمرير الأسئلة مما يعطي سرعة بالأداء أفضل من جلبها سؤال سؤال
      //القيمة الأساسية ل انديكس رقم السؤال تكون -1 لتجنب بعض من الأخطاء
      indexQ++;
      if (indexQ == 0) {
        FirestoreService firestoreService = FirestoreService();
        documents = await firestoreService.getDocuments('questions');
      }
      //اذا كان لايزال هناك أسئلة فالانتقال إلى السؤال التالي وإلا انهاء الامتحان وجلب الأجوبة الصحيحة من قاعدة البيانات
      if (indexQ < documents!.length) {
        final data = documents![indexQ];
        emit(LoadingMatchState(data, listAnswers));
      } else {
        try {
          //جلب الأجوبة الصحيحة من قاعدة البيانات
          FirestoreService firestoreService = FirestoreService();
          Map<String, dynamic>? document = await firestoreService.getDocumentById('answers', 'answers');
          emit(FinishMatchState(document!, listAnswers, score));
        } catch (error) {
          print(error);
          emit(FailureState());
        }
      }
    } catch (error) {
      print(error);
      emit(FailureState());
    }
  }

//إرسال نتيجة الامتحان مع اسم المستخدم مع تاريخ الامتحان إلى قاعدة البيانات ثم عرضها على شكل لوحة المتصدرين
//يتم إرسال التاريخ فقط من أجل ترتيب المستخدمين في لوحة المتصدرين بحيث إذا حصل اثنان على نفس النتيجة يكون الأقدم في الأعلى
  FutureOr<void> _showBoard(SendAndShowBoardEvent event, Emitter<AppStates> emit) async {
    emit(LoadingState());
    try {
      Map<String, dynamic> newData = {'name': name, 'score': scoreBoard, 'date': DateTime.now().toUtc()};//تجهيز اليانات
      FirestoreService firestoreService = FirestoreService();
      DocumentReference? documentReference = await firestoreService.getDocumentReference(newData);//ارسال البيانات وارجاع مستند البيانات من أجل الحصول على معرف النتيجة
      idNameInBoard = documentReference!.id;//معرف المستند -النتيجة في لوحة المتصدرين-
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await firestoreService.fetchAndOrderByData();//جلب قائمة المتصدرين مرتبة ترتيب تنازلي بالنسبة للنتيجة
      emit(LeaderboardState(querySnapshot, idNameInBoard));
    } catch (error) {
      print(error);
      emit(FailureState());
    }
  }

//تسجيل الخروج والبدأ من أول التطبيق من جديد
  FutureOr<void> _restart(RestartEvent event, Emitter<AppStates> emit) async {
    SignGoogle().outGoogle();
    //تصفير المتغيرات
    score = 0;
    indexQ = -1;
    listAnswers.clear();
    emit(InitialState());
  }
}
