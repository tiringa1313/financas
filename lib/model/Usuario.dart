class Usuario {
  String _nome;
  String _email;
  String _senha;
  String _saldoGeral;

  // Construtor principal
  Usuario(this._nome, this._email, this._senha, this._saldoGeral);

  // Construtor nomeado para criar um usuário sem especificar o nome
  Usuario.semNome(this._email, this._senha, this._saldoGeral) : _nome = '';

  // Método para criar um mapa a partir dos atributos da classe
  Map<String, dynamic> toMap() {
    return {
      "nome": _nome,
      "email": _email,
      "senha": _senha,
      "saldoGeral": _saldoGeral,
    };
  }

  // Getters
  String get nome => _nome;

  String get email => _email;

  String get senha => _senha;

  String get saldoGeral => _saldoGeral;

  // Setters
  set nome(String value) {
    _nome = value;
  }

  set email(String value) {
    _email = value;
  }

  set senha(String value) {
    _senha = value;
  }

  set saldoGeral(String value) {
    _saldoGeral = value;
  }
}
