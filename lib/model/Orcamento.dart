class Orcamento {
  // ignore: non_constant_identifier_names
  late int Id;
  late int usuarioId;
  late String despesasPessoais;
  late String gastosEducacao;
  late String gastosLivres;
  late String meusProjetos;
  late String mesReferencia;

  get getId => this.Id;

  set setId(Id) => this.Id = Id;

  get getUsuarioId => this.usuarioId;

  set setUsuarioId(usuarioId) => this.usuarioId = usuarioId;

  get getDespesasPessoais => this.despesasPessoais;

  set setDespesasPessoais(despesasPessoais) =>
      this.despesasPessoais = despesasPessoais;

  get getGastosEducacao => this.gastosEducacao;

  set setGastosEducacao(gastosEducacao) => this.gastosEducacao = gastosEducacao;

  get getGastosLivres => this.gastosLivres;

  set setGastosLivres(gastosLivres) => this.gastosLivres = gastosLivres;

  get getMeusProjetos => this.meusProjetos;

  set setMeusProjetos(meusProjetos) => this.meusProjetos = meusProjetos;

  get getMesReferencia => this.mesReferencia;

  set setMesReferencia(mesReferencia) => this.mesReferencia = mesReferencia;
}
