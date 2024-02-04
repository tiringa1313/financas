import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financas/interface/FirebaseServiceBase.dart';

class FirebaseService implements FirebaseServiceBase {
  late CollectionReference _collectionReference;

  FirebaseService(String collectionName) {
    _collectionReference =
        FirebaseFirestore.instance.collection(collectionName);
  }

  // Adicione essa propriedade
  String get currentCollection => _collectionReference.id;

  CollectionReference getUsuariosCollectionReference() {
    // Retorna a colecao de usuarios
    return FirebaseFirestore.instance.collection('usuarios');
  }

  @override
  Future<DocumentReference> adicionarItem(Map<String, dynamic> item) async {
    return await _collectionReference.add(item);
  }

  @override
  Future<List<Map<String, dynamic>>> obterTodosItens() async {
    QuerySnapshot querySnapshot = await _collectionReference.get();
    return querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // Adiciona o ID ao mapa
      return data;
    }).toList();
  }

  @override
  Future<void> atualizarItem(String id, Map<String, dynamic> item) async {
    await _collectionReference.doc(id).update(item);
  }

  Future<void> atualizarSaldo(String idUsuario, String novoSaldo,
      CollectionReference collectionReference) async {
    try {
      // Adicione um print para exibir a coleção
      print('Coleção: ${collectionReference.path}');

      DocumentSnapshot documentSnapshot =
          await collectionReference.doc(idUsuario).get();

      if (documentSnapshot.exists) {
        // O documento existe, então podemos atualizar o saldo

        await collectionReference.doc(idUsuario).update({
          'saldoGeral': novoSaldo,
        });
      } else {
        printInfo('Documento do usuário não encontrado', {});
      }
    } catch (e) {
      printInfo('Erro ao atualizar o saldo do usuário: $e', {});
      throw e;
    }
  }

  Future<String> buscarSaldoGeralUsuario(String idUsuario) async {
    try {
      // Acesse o documento do usuário com base no ID fornecido
      DocumentSnapshot usuarioDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(idUsuario)
          .get();

      if (!usuarioDoc.exists) {
        // O documento do usuário não existe
        printInfo('O documento do usuário não existe', {});
        return '0.0'; // ou qualquer valor padrão que você queira retornar como string
      }

      // Obtenha o valor de 'saldoGeral' do documento do usuário como uma string
      Map<String, dynamic> usuarioData =
          usuarioDoc.data() as Map<String, dynamic>;
      String saldoGeral = usuarioData['saldoGeral']?.toString() ?? '0.00';

      //printInfo('Saldo Geral do Usuário', {'saldoGeral': saldoGeral});

      return saldoGeral;
    } catch (e) {
      // Lidar com erros, se necessário
      printInfo('Erro ao buscar o saldo geral do usuário: $e', {});
      throw e; // ou retorne um valor padrão, dependendo da lógica do seu aplicativo
    }
  }

// Este método retorna uma lista de Mapas contendo as últimas 4 despesas ordenadas por data de forma descendente.
  Future<List<Map<String, dynamic>>> obterUltimasDespesas() async {
    QuerySnapshot querySnapshot = await _collectionReference
        .orderBy('data', descending: true)
        .limit(4)
        .get();

    return querySnapshot.docs.map((doc) {
      Map<String, dynamic> despesaData = doc.data() as Map<String, dynamic>;
      despesaData['id'] = doc.id; // Adiciona o ID do documento ao mapa
      return despesaData;
    }).toList();
  }

  Future<void> adicionarRastreamentoDespesa(
      Map<String, dynamic> rastreamentoData) async {
    await FirebaseFirestore.instance
        .collection('rastreamentoDespesas')
        .add(rastreamentoData);
  }

  Future<void> atualizarRastreamentoDespesa(
      String idRastreamento, Map<String, dynamic> rastreamentoData) async {
    await FirebaseFirestore.instance
        .collection(
            'rastreamentoDespesas') // Substitua 'suaColecao' pelo nome real da coleção
        .doc(idRastreamento)
        .update(rastreamentoData);
  }

  @override
  Future<void> deletarItem(String id) async {
    await _collectionReference.doc(id).delete();
    try {
      DocumentReference docReferencia =
          FirebaseFirestore.instance.collection(currentCollection).doc(id);

      print('Id FirebaseService: $id');
      print('Collecao: $currentCollection');

      // Verifica se o documento existe antes de tentar deletar
      DocumentSnapshot documentSnapshot = await docReferencia.get();

      if (documentSnapshot.exists) {
        await docReferencia.delete();
      } else {
        printInfo('Documento não encontrado na coleção', {});
      }
    } catch (e) {
      printInfo('Erro ao excluir item: $e', {});
      throw e;
    }
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
