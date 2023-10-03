//ملف الربط بفايرستور
import 'package:cloud_firestore/cloud_firestore.dart';

//كلاس الربط بفايرستور
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // استعلام لجلب مجموعة من الوثائق
  Future<List<Map<String, dynamic>>> getDocuments(String collectionName) async {
    List<Map<String, dynamic>> documents = [];
    try {
      QuerySnapshot querySnapshot = await _firestore.collection(collectionName).get();
      for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
        documents.add(documentSnapshot.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print("حدث خطأ: $e");
    }
    return documents;
  }

  // استعلام لجلب وثيقة واحدة
  Future<Map<String, dynamic>?>? getDocumentById(String collectionName, String documentId) async {
    Map<String, dynamic>? documentData ;
    try {
      DocumentSnapshot documentSnapshot = await _firestore.collection(collectionName).doc(documentId).get();

      if (documentSnapshot.exists) {
        documentData = documentSnapshot.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print("حدث خطأ: $e");
    }
    return documentData;
  }

//ارسال وثيقة وجلب النتيجة
  final CollectionReference _collectionReference = FirebaseFirestore.instance.collection('leaderboard');
  Future<DocumentReference?> getDocumentReference(Map<String, dynamic> data) async {
    DocumentReference? documentReference;
    try {
      documentReference = await _collectionReference.add(data);
    } catch (e) {
      print('Error adding data: $e');
    }
    return documentReference;
  }

//جلب مجموعة من البيانات مرتبة ترتيب معين
//في هذه الحالة تم الترتيب حسب نتيجة الامتحان وتاريخه
  Future<QuerySnapshot<Map<String, dynamic>>> fetchAndOrderByData() async {
    QuerySnapshot<Map<String, dynamic>>? querySnapshot;
    try {
      querySnapshot = await FirebaseFirestore.instance.collection('leaderboard').orderBy('score', descending: true).orderBy('date', descending: false).get();
    } catch (e) {
      print('Error fetching and ordering data: $e');
    }
    return querySnapshot!;
  }
}
