abstract class FirebaseServiceBase {
  Future<void> adicionarItem(Map<String, dynamic> item);
  Future<List<Map<String, dynamic>>> obterTodosItens();
  Future<void> atualizarItem(String id, Map<String, dynamic> item);
  Future<void> deletarItem(String id);
}
