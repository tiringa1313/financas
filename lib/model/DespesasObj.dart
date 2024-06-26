import 'package:cloud_firestore/cloud_firestore.dart';

class DespesasObj {
  late int _id;
  late String _idUsuario;
  late String _tipoDespesa;
  late String _categoriaSelecionada;
  late double _valorDespesa;
  late DateTime _dataDespesa;

  // Construtor padrão
  DespesasObj(this._idUsuario, this._tipoDespesa, this._valorDespesa,
      this._dataDespesa, String? categoriaSelecionada) {
    _categoriaSelecionada =
        categoriaSelecionada ?? ""; // Inicialização padrão para evitar nulo
  }

  // Construtor nomeado para criar uma instância da classe a partir de um mapa
  Map<String, dynamic> toMap() {
    return {
      'idUsuario': _idUsuario,
      'tipoDespesa': _tipoDespesa,
      'valorDespesa': _valorDespesa,
      'dataDespesa': _dataDespesa,
      'categoriaSelecionada': _categoriaSelecionada,
    };
  }

  // Getter e Setter para id
  get id => this._id;

  set id(value) => this._id = value;

  // Getter e Setter para idUsuario
  get idUsuario => this._idUsuario;

  set idUsuario(value) => this._idUsuario = value;

  // Getter e Setter para tipoReceita
  get tipoReceita => this._tipoDespesa;

  set tipoReceita(value) => this._tipoDespesa = value;

  // Getter e Setter para valorReceita
  get valorReceita => this._valorDespesa;

  set valorReceita(value) => this._valorDespesa = value;

  // Getter e Setter para dataReceita
  get dataReceita => this._dataDespesa;

  set dataReceita(value) => this._dataDespesa = value;

  // Getter e Setter para categoriaSelecionada
  get categoriaSelecionada => this._categoriaSelecionada;

  set categoriaSelecionada(value) => this._categoriaSelecionada = value;
}
