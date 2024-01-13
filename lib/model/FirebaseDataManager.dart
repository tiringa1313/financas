import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseDataManager {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;

  FirebaseDataManager(this.userId);

  Future<void> saveData(
      String collectionName, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collectionName).doc(userId).set(data);
    } catch (error) {
      print("Erro ao salvar dados: $error");
    }
  }

  Future<void> updateData(String collectionName, String documentId,
      Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(collectionName)
          .doc(userId)
          .collection(collectionName)
          .doc(documentId)
          .update(data);
    } catch (error) {
      print("Erro ao atualizar dados: $error");
    }
  }

  Future<void> deleteData(String collectionName, String documentId) async {
    try {
      await _firestore
          .collection(collectionName)
          .doc(userId)
          .collection(collectionName)
          .doc(documentId)
          .delete();
    } catch (error) {
      print("Erro ao excluir dados: $error");
    }
  }

  Stream<QuerySnapshot> getDataStream(String collectionName) {
    return _firestore
        .collection(collectionName)
        .doc(userId)
        .collection(collectionName)
        .snapshots();
  }
}
