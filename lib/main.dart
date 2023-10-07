import 'package:firebase_core/firebase_core.dart';
import 'package:mobeasy/Bloc/UI/ui_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'Bloc/bloc/app_bloc.dart';

void main() async {
  // تهيئة بيئة البرنامج للربط مع الفير بيس والشبكة
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //تفعيل الإشعارات عبر ون سيجنال
  OneSignal.initialize("9337fe7f-9556-42a6-afd6-8fd06919d49e");
  runApp(const Mobeasy());
}

class Mobeasy extends StatelessWidget {
  const Mobeasy({Key? key}) : super(key: key);
//تهيئة بيئة العمل بلوك
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (context) => AppBloc(),
        child: const MyBlocPage(),
      ),
    );
  }
}
