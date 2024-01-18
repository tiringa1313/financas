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

  Future<List<String>> buscarSubcategorias(String categoriaSelecionada) async {
    print('Buscando sugestões para: $categoriaSelecionada');

    if (categoriaSelecionada.isEmpty) {
      return [];
    }

    try {
      // Acesse o documento com base na categoria selecionada pelo usuário
      DocumentSnapshot categoriaDoc = await FirebaseFirestore.instance
          .collection('categorias')
          .doc(categoriaSelecionada) // Use a variável correta aqui
          .get();

      if (!categoriaDoc.exists) {
        print('O documento da categoria selecionada não existe');
        return [];
      }

      Map<String, dynamic>? data = categoriaDoc.data() as Map<String, dynamic>?;

      if (data == null || !data.containsKey('categoriasOrganizadas')) {
        print('Os dados no documento estão vazios ou não contêm subcategorias');
        return [];
      }

      List<String> subcategorias =
          (data['categoriasOrganizadas'] as Map<String, dynamic>).keys.toList();

      return subcategorias = ['teste', 'testando'];
    } catch (e, stackTrace) {
      print('Erro ao buscar subcategorias: $e\n$stackTrace');
      return [];
    }
  }
}
