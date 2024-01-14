import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financas/interface/FirebaseServiceBase.dart';

class FirebaseService implements FirebaseServiceBase {
  late CollectionReference _collectionReference;

  FirebaseService(String collectionName) {
    _collectionReference =
        FirebaseFirestore.instance.collection(collectionName);
  }

  @override
  Future<void> adicionarItem(Map<String, dynamic> item) async {
    await _collectionReference.add(item);
  }

  @override
  Future<List<Map<String, dynamic>>> obterTodosItens() async {
    QuerySnapshot querySnapshot = await _collectionReference.get();
    return querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  @override
  Future<void> atualizarItem(String id, Map<String, dynamic> item) async {
    await _collectionReference.doc(id).update(item);
  }

  @override
  Future<void> deletarItem(String id) async {
    await _collectionReference.doc(id).delete();
  }

  Future<List<String>> buscarSubcategorias(String categoria) async {
    DocumentSnapshot document = await _collectionReference.doc(categoria).get();

    if (document.exists) {
      // Verifique se o documento existe antes de acessar os dados
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;
      List<String> subcategorias = List<String>.from(data['categorias']);

      print('Metodo Buscar Categorias');
      return subcategorias;
    } else {
      return [];
    }
  }
}
