import 'package:flutter/material.dart';

class DespesasProvider with ChangeNotifier {
  List<Map<String, dynamic>> _despesas = [];
  double _saldoGeral = 0.0;

  List<Map<String, dynamic>> get despesas => _despesas;
  double get saldoGeral => _saldoGeral;

  void adicionarDespesa(Map<String, dynamic> despesa) {
    _despesas.add(despesa);
    _atualizarSaldoGeral();
    notifyListeners();
  }

  void editarDespesa(Map<String, dynamic> despesaEditada) {
    int index = _despesas.indexWhere(
        (despesa) => despesa['idDespesa'] == despesaEditada['idDespesa']);
    if (index != -1) {
      _despesas[index] = despesaEditada;
      _atualizarSaldoGeral();
      notifyListeners();
    }
  }

  void _atualizarSaldoGeral() {
    _saldoGeral = _despesas.fold(
        0, (total, despesa) => total + double.parse(despesa['valor']));
  }

  void carregarDespesas(List<Map<String, dynamic>> despesas) {
    _despesas = despesas;
    _atualizarSaldoGeral();
    notifyListeners();
  }
}
