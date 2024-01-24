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

  Future<List<String>> buscarSubcategorias(String subcategoria) async {
    printInfo('Buscando sugestões para', {'subcategoria': subcategoria});

    if (subcategoria.isEmpty) {
      return [];
    }

    // Certifique-se de que 'subcategoria' não é null
    if (subcategoria == null) {
      printInfo('A subcategoria é null', {});
      return [];
    }

    // Acesse o documento com base na subcategoria fornecida
    DocumentSnapshot categoriaDoc = await FirebaseFirestore.instance
        .collection('categorias')
        .doc(subcategoria)
        .get();

    printInfo('Dados do DocumentSnapshot', {'data': categoriaDoc.data()});

    if (!categoriaDoc.exists) {
      printInfo('O documento da subcategoria não existe', {});
      return [];
    }

    Map<String, dynamic> campos = categoriaDoc.data() as Map<String, dynamic>;

    if (campos == null) {
      printInfo('Os dados no documento estão vazios', {});
      return [];
    }

    // Obtenha todas as chaves do mapa e atribua à lista de sugestões
    List<String> sugestoes = campos.keys.toList();

    printInfo('Sugestões', {'sugestoes': sugestoes});

    return sugestoes;
  }

  void printInfo(String message, Map<String, dynamic> data) {
    print('[$message] $data');
  }
}
