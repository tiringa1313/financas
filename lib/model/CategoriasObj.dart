class CategoriasObj {
  late String habitacaoEssenciais;
  late String dividasEssenciais;
  late String transporteEssenciais;
  late String saudeEssenciais;
  late String despesasEssenciais;
  late String outrosEssenciais;
  late String lazerLivres;
  late String vestuarioLivres;
  late String outrosLivres;
  late String educacaoEducacao;
  late String outrosEducacao;

  // Construtor
  CategoriasObj({
    required this.habitacaoEssenciais,
    required this.dividasEssenciais,
    required this.transporteEssenciais,
    required this.saudeEssenciais,
    required this.despesasEssenciais,
    required this.outrosEssenciais,
    required this.lazerLivres,
    required this.vestuarioLivres,
    required this.outrosLivres,
    required this.educacaoEducacao,
    required this.outrosEducacao,
  });

  // Getters
  String get getHabitacaoEssenciais => habitacaoEssenciais;
  String get getDividasEssenciais => dividasEssenciais;
  String get getTransporteEssenciais => transporteEssenciais;
  String get getSaudeEssenciais => saudeEssenciais;
  String get getDespesasEssenciais => despesasEssenciais;
  String get getOutrosEssenciais => outrosEssenciais;
  String get getLazerLivres => lazerLivres;
  String get getVestuarioLivres => vestuarioLivres;
  String get getOutrosLivres => outrosLivres;
  String get getEducacaoEducacao => educacaoEducacao;
  String get getOutrosEducacao => outrosEducacao;

  // Setters
  set setHabitacaoEssenciais(String valor) => habitacaoEssenciais = valor;
  set setDividasEssenciais(String valor) => dividasEssenciais = valor;
  set setTransporteEssenciais(String valor) => transporteEssenciais = valor;
  set setSaudeEssenciais(String valor) => saudeEssenciais = valor;
  set setDespesasEssenciais(String valor) => despesasEssenciais = valor;
  set setOutrosEssenciais(String valor) => outrosEssenciais = valor;
  set setLazerLivres(String valor) => lazerLivres = valor;
  set setVestuarioLivres(String valor) => vestuarioLivres = valor;
  set setOutrosLivres(String valor) => outrosLivres = valor;
  set setEducacaoEducacao(String valor) => educacaoEducacao = valor;
  set setOutrosEducacao(String valor) => outrosEducacao = valor;
}
