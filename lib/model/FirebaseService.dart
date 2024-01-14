import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final CollectionReference _collectionReference =
      FirebaseFirestore.instance.collection('suaColecao');

  Future<void> adicionarItem(Map<String, dynamic> item) async {
    await _collectionReference.add(item);
  }

  /*Future<List<Map<String, dynamic>>> obterTodosItens() async {
    QuerySnapshot querySnapshot = await _collectionReference.get();
    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }*/

  Future<void> atualizarItem(String id, Map<String, dynamic> item) async {
    await _collectionReference.doc(id).update(item);
  }

  Future<void> deletarItem(String id) async {
    await _collectionReference.doc(id).delete();
  }
}
