class DespesasObj {
  late int _id;
  late int _idUsuario;
  late String _tipoDespesa;
  late String _valorDespesa; // Alterado para double
  late String _dataDespesa;

  // Construtor padrão
  DespesasObj(this._idUsuario, this._tipoDespesa, this._valorDespesa,
      this._dataDespesa);

  // Construtor nomeado para criar uma instância da classe a partir de um mapa
  DespesasObj.fromMap(Map<String, dynamic> map)
      : _id = map['id'],
        _idUsuario = map['idUsuario'],
        _tipoDespesa = map['tipoDespesa'],
        _valorDespesa = map['valorDespesa'], // Converte para double
        _dataDespesa = map['dataDespesa'];

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
}
