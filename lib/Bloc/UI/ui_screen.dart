//ملف واجهة المستخدم
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/app_events.dart';
import '../bloc/app_states.dart';
import '../bloc/app_bloc.dart';

class MyBlocPage extends StatefulWidget {
  const MyBlocPage({Key? key}) : super(key: key);

  @override
  State<MyBlocPage> createState() => _MyBlocPageState();
}

class _MyBlocPageState extends State<MyBlocPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mobeasy task"),
      ),
      body: buildBloc(),
    );
  }

//ارجاع ويدجت في كل حالة وفقا لبيئة العمل بلوك
  Widget buildBloc() {
    return BlocBuilder<AppBloc, AppStates>(builder: (context, state) {

      //حالة لوحة المتصدرين
      if (state is LeaderboardState) {
        return leaderboardWidget(context, state.querySnapshot!.docs, state.idNameInBoard);
      }
      //حالة انهاء الامتحان واظهار النتيجة
      if (state is FinishMatchState) {
        return finishMatchWidget(context, state.document, state.listAnswers, state.score);
      }
      //حالة جلب الأسئلة
      if (state is LoadingMatchState) {
        return loadingMatchWidget(context, state.data, state.listAnswers);
      }
      //حالة الترحيب قبل الامتحان
      if (state is WelcomeState) {
        return welcomeWidget(context, state.user.displayName);
      }
      //حالة حدوث خطأ
      if (state is FailureState) {
        return failureWidget(context);
      }
      //حالة الانتظار
      if (state is LoadingState) {
        return loadingWidget(context);
      }

      return signGoogleWidget(context);
    });
  }
}

//--------الحالة الأساسية وهي تسجيل الدخول باستخدام جوجل------//
Widget signGoogleWidget(BuildContext context) {
  return Center(
      child: Column(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      ElevatedButton(
          onPressed: () {
            context.read<AppBloc>().add(SignGoogleEvent());//اضافة حدث تسجيل الدخول الى  البلوك
          },
          child: const Text('Google  تسجيل الدخول باستخدام')),
    ],
  ));
}

//-----------حالة الانتظار-------//
Widget loadingWidget(BuildContext context) {
  return const Center(
    child: CircularProgressIndicator(),//اظهار دائرة الانتظار
  );
}

//------------حالة حدوث خطأ-----------//
Widget failureWidget(BuildContext context) {
  return const Text(
    'حدث خطأ ما',
    style: TextStyle(color: Colors.red, fontSize: 40),
  );
}

//------------حالة الترحيب-------------//
//يتم جلب اسم المستخدم من حسابه من جوجل
Widget welcomeWidget(BuildContext context, String? name) {
  return Center(
      child: Column(
    children: [
      Text(
        'Welcome $name',
        style: const TextStyle(fontSize: 20),
      ),
      const Divider(),
      ElevatedButton(
          onPressed: () {
            context.read<AppBloc>().add(LoadingMathcEvent());//بدأ الامتحان
          },
          child: const Text('ابدأ الامتحان')),
    ],
  ));
}

//----------------------------حالة تحميل الامتحان-------------------------------------//
Widget loadingMatchWidget(BuildContext context, Map<String, dynamic> data, List<String> listAnswers) {
  List<Widget> listButtonsAnswers = [];//تجهيز قائمة بأزرار الإجابات
  for (int i = 0; i < (data['ans'] as List<dynamic>).length; i++) {
    //اضافة الأزرار إلى القائمة بحيث يكون النص هو الإجابة
    listButtonsAnswers.add(ElevatedButton(
        onPressed: () {
          listAnswers.add(data['ans'][i]);
          context.read<AppBloc>().add(LoadingMathcEvent());//من أجل تحميل السؤال التالي أو إنهاء الامتحان
        },
        child: Text(data['ans'][i])));
  }
  return Center(
      child: Column(
    mainAxisAlignment: MainAxisAlignment.start,
    children: <Widget>[
          Text(
            data['ques'] + ' = ?',//اظهار السؤال
            style: const TextStyle(fontSize: 20),
          ),
        ] +
        listButtonsAnswers,//الإجابات
  ));
}

//------------------------------------حالة انتهاء الامتحان وعرض النتيجة----------------------------------//
Widget finishMatchWidget(BuildContext context, Map<String, dynamic> document, List<String> listAnswers, int score) {
  List<Widget> listText = [];//تجهيز قائمة الإجابات
  //فحص الإجابات وعرض النتيجة
  for (int i = 0; i < listAnswers.length; i++) {
    if (listAnswers[i] == document['answers'][i].toString()) {
      listText.add(Text(
        '${listAnswers[i]}  Correct',//في حال كانت الإجابة صحيحة
        style: const TextStyle(fontSize: 20, color: Colors.green),
      ));
      score++;
    } else {
      listText.add(Text('${listAnswers[i]}  Wrong', style: const TextStyle(fontSize: 20, color: Colors.red)));//في حال كانت خاطئة
    }
  }
  return Center(
    child: Column(
        children: listText +
            [
              const Divider(),
              Text(
                '$score   عدد الإجابات الصحيحة',
                style: const TextStyle(fontSize: 18),
              ),
              const Divider(),
              ElevatedButton(
                  onPressed: () {
                    scoreBoard = score;//تم حفظ النتيجة في متغير مستقل من أجل تجنب خطأ في الإرسال إلى قاعدة البيانات
                    context.read<AppBloc>().add(SendAndShowBoardEvent());//اضافة حدث ارسال البيانات واظهار لوحة المتصدرين الى البلوك
                  },
                  child: const Text('إرسال إلى لوحة المتصدرين'))
            ]),
  );
}


//------------------------------------حالة لوحة المتصدرين-------------------------------------------//
//يتم بناء قائمة بأسماء المتصدرين مع النتائج وفقا لالمستندات المرتبة تنازليا وفقا للنتيجة والتاريخ
Widget leaderboardWidget(BuildContext context, List<QueryDocumentSnapshot> queryDocuments, String idNameInBoard) {
  ListView listView = ListView.builder(
    itemCount: queryDocuments.length,
    itemBuilder: (context, index) {
      // استخراج بيانات الوثيقة
      Map<String, dynamic> data = queryDocuments[index].data() as Map<String, dynamic>;
      //في حالة كانت الوثيقة هي نفسها النتيجة المرسلة أي نتيجة الامتحان فيتم تخصيصها بألوان مختلفة لتمييزها
      //يتم التعرف عليها من خلال المعرف العشوائي الذي تضيفه فايرستور لكل وثيقة
      //إضافة نتيجة الامتحان إلى القائمة
      if (queryDocuments[index].id == idNameInBoard) {
        return Column(
          children: [
            //من أجل إضافة زر إعادة البرنامج في أعلى القائمة
            if (index == 0)
              ElevatedButton(
                  onPressed: () {
                    context.read<AppBloc>().add(RestartEvent());
                  },
                  child: const Text('تسجيل الخروج و إعادة تشغيل البرنامج')),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Spacer(),
              Text(
                data['name'] + '   ' + data['score'].toString(),
                style: const TextStyle(fontSize: 20, color: Colors.green),
              ),
              const Spacer(),
            ]),
            const Divider(),
          ],
        );
        //إضافة النتائج الأخرى
      } else {
        return Column(
          children: [
            //من أجل إضافة زر إعادة البرنامج في أعلى القائمة
            if (index == 0)
              ElevatedButton(
                  onPressed: () {
                    context.read<AppBloc>().add(RestartEvent());
                  },
                  child: const Text('تسجيل الخروج و إعادة تشغيل البرنامج')),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Spacer(),
              Text(
                data['name'] + '   ' + data['score'].toString(),
                style: const TextStyle(fontSize: 18),
              ),
              const Spacer(),
            ]),
            const Divider(),
          ],
        );
      }
    },
  );
  return listView;
}
