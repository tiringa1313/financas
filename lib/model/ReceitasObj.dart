class ReceitasObj {
  late int _id;
  late int _idUsuario;
  late String _tipoReceita;
  late String _valorReceita; // Alterado para double
  late String _dataReceita;

  // Construtor padrão
  ReceitasObj(this._idUsuario, this._tipoReceita, this._valorReceita,
      this._dataReceita);

  // Construtor nomeado para criar uma instância da classe a partir de um mapa
  ReceitasObj.fromMap(Map<String, dynamic> map)
      : _id = map['id'],
        _idUsuario = map['idUsuario'],
        _tipoReceita = map['tipoReceita'],
        _valorReceita = map['valorReceita'], // Converte para double
        _dataReceita = map['dataReceita'];

  // Getter e Setter para id
  get id => this._id;

  set id(value) => this._id = value;

  // Getter e Setter para idUsuario
  get idUsuario => this._idUsuario;

  set idUsuario(value) => this._idUsuario = value;

  // Getter e Setter para tipoReceita
  get tipoReceita => this._tipoReceita;

  set tipoReceita(value) => this._tipoReceita = value;

  // Getter e Setter para valorReceita
  get valorReceita => this._valorReceita;

  set valorReceita(value) => this._valorReceita = value;

  // Getter e Setter para dataReceita
  get dataReceita => this._dataReceita;

  set dataReceita(value) => this._dataReceita = value;
}
