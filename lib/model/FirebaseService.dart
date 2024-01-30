import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financas/interface/FirebaseServiceBase.dart';

class FirebaseService implements FirebaseServiceBase {
  late CollectionReference _collectionReference;

  FirebaseService(String collectionName) {
    _collectionReference =
        FirebaseFirestore.instance.collection(collectionName);
  }

  CollectionReference getUsuariosCollectionReference() {
    return FirebaseFirestore.instance.collection('usuarios');
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

  Future<void> atualizarSaldo(String idUsuario, double novoSaldo,
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
      String saldoGeral = usuarioData['saldoGeral']?.toString() ?? '0.0';

      printInfo('Saldo Geral do Usuário', {'saldoGeral': saldoGeral});

      return saldoGeral;
    } catch (e) {
      // Lidar com erros, se necessário
      printInfo('Erro ao buscar o saldo geral do usuário: $e', {});
      throw e; // ou retorne um valor padrão, dependendo da lógica do seu aplicativo
    }
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
