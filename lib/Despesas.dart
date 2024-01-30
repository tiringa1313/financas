import 'dart:ffi';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financas/model/AuthManager.dart';
import 'package:financas/model/DespesasObj.dart';
import 'package:financas/model/FirebaseService.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class Despesas extends StatefulWidget {
  const Despesas({super.key});

  @override
  State<Despesas> createState() => _DespesasState();
}

Map<String, String> categoriasMapa = {
  'Gastos Essenciais': 'despesasEssenciais',
  'Gastos Livres': 'despesasLivres',
  'Gastos com Educação': 'despesasEducacao',
  // Adicione mais mapeamentos conforme necessário
};

class _DespesasState extends State<Despesas> {
// Todos os controladores aqui *************************************************
  TextEditingController _controllerValorDespesa =
      TextEditingController(); // recebe o valor da despesa
  TextEditingController _controllerData =
      TextEditingController(); // recebe a data selecionada no  picker

  TextEditingController _controllerAutocomplete = TextEditingController();

//Todas as variaveis aqui      *************************************************

  int? _idUsuario;
  String? categoriaFrontEnd;
  String? categoriaSelecionada;
  DateTime? _dataSelecionada = DateTime.now();
  String? _tipoDespesa;
  double? _valorDespesa;
  double? _saldoGeral;

//Todos os metodos deverao ser implementados aqui ******************************

  @override
  void initState() {
    super.initState();
    buscarSaldoGeral();
    _dataSelecionada = DateTime.now();
  }

  void _mostrarMensagem(String mensagem, {bool erro = false}) {
    final snackBar = SnackBar(
      content: Text(mensagem),
      duration: Duration(seconds: 3),
      backgroundColor: erro ? Colors.red : Colors.green,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<String?> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _dataSelecionada) {
      setState(() {
        _dataSelecionada = picked;
        _controllerData.text = DateFormat('dd/MM/yyyy', 'pt_BR').format(picked);
      });

      return DateFormat('dd/MM/yyyy', 'pt_BR').format(picked);
    }

    return null; // Retorna null se nenhuma data for selecionada
  }

  String _formatCurrency(String value) {
    if (value.isEmpty) {
      return '0.00';
    }

    value = value.replaceAll(RegExp('[^0-9]'), '');
    value = value.replaceFirst(RegExp('^0+'), '');

    while (value.length < 3) {
      value = '0$value';
    }

    return '${value.substring(0, value.length - 2)}.${value.substring(value.length - 2)}';
  }

  void buscarSaldoGeral() async {
    String? userId = AuthManager.userId;

    if (userId == null) {
      print('Usuário não autenticado!');
      return;
    }

    try {
      // Criar uma instância do seu serviço Firebase
      FirebaseService firebaseService =
          FirebaseService('usuarios'); // Use 'usuarios' como coleção

      // Buscar o saldo geral do usuário
      String saldoGeralString =
          await firebaseService.buscarSaldoGeralUsuario(userId);
      // Converte o saldoGeral String para Double
      _saldoGeral = double.parse(saldoGeralString);
    } catch (e) {
      print('Erro ao buscar o saldo geral do usuário: $e');
    }
  }

  buscarUltimasDespesasSalvas() {}

  void OrganizaDadosParaSalvar() async {
    String? userId = AuthManager.userId;
    double? _valorDespesa;

    if (_controllerValorDespesa.text.isEmpty) {
      _mostrarMensagem('Informe um valor válido!!', erro: true);
      return;
    }

    _valorDespesa = double.tryParse(_controllerValorDespesa.text);
    if (_valorDespesa == null || _valorDespesa == 0.00) {
      _mostrarMensagem('Informe um valor válido!!', erro: true);
      return;
    }

    // Certifique-se de que as variáveis necessárias foram preenchidas
    if (userId == null ||
        categoriaSelecionada == null ||
        _tipoDespesa == null ||
        _dataSelecionada == null) {
      _mostrarMensagem('Preencha todos os campos!!', erro: true);
      return;
    }

    // Criar uma instância de DespesasObj
    DespesasObj despesa = DespesasObj(
      userId,
      _tipoDespesa!, // Substituído por _tipoDespesa ao invés de categoriaSelecionada
      _valorDespesa,
      _dataSelecionada!,
    );

    try {
      // Criar uma instância do seu serviço Firebase
      FirebaseService firebaseService = FirebaseService(categoriaSelecionada!);

      // Subtrai o valor da despesa ao valor do saldo geral
      double novoSaldo = _saldoGeral! - _valorDespesa;

      // chama o metodo para atualizar o saldo geral do usuario

      firebaseService.atualizarSaldo(
          userId, novoSaldo, firebaseService.getUsuariosCollectionReference());

      // Converter o objeto DespesasObj para um mapa
      Map<String, dynamic> despesaMap = despesa.toMap();

      // Adicionar o item ao Firestore
      await firebaseService.adicionarItem(despesaMap);

      // Limpar os campos após o salvamento bem-sucedido
      _controllerValorDespesa.clear();
      _tipoDespesa = null;
      _dataSelecionada = DateTime.now();

      setState(() {
        _controllerValorDespesa.clear();
        _tipoDespesa = null;
        _dataSelecionada = DateTime.now();
        categoriaFrontEnd = null;
        categoriaSelecionada = null;
      });

      String textoAtual = _controllerAutocomplete.text;
      print('Texto atual do Autocomplete: $textoAtual');

      _controllerAutocomplete.clear();

      // Exibir mensagem de dados salvos
      _mostrarMensagem('Despesa salva com sucesso!');
    } catch (e) {
      print('Erro ao salvar os dados no Firebase: $e');
    }
  }

//*****************************************************************************/
//*********************** Inicio do Layout ************************************/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Despesas",
          style: TextStyle(
            color: Color.fromARGB(160, 0, 0, 0),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Color.fromARGB(
            255, 248, 76, 76), // Alterado para corresponder à cor do CardView
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 5),
              Card(
                color: Color.fromARGB(255, 248, 76, 76),
                margin: EdgeInsets.all(0),
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Valor da Despesa:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'R\$',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 35,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                textSelectionTheme: TextSelectionThemeData(
                                  selectionHandleColor: Colors
                                      .white, // Cor dos handles de seleção
                                ),
                              ),
                              child: TextField(
                                controller: _controllerValorDespesa,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 35,
                                ),
                                cursorColor: Colors.white, // Cor do cursor
                                onChanged: (value) {
                                  String formattedValue =
                                      _formatCurrency(value);
                                  _controllerValorDespesa.value =
                                      _controllerValorDespesa.value.copyWith(
                                    text: formattedValue,
                                    selection: TextSelection.collapsed(
                                        offset: formattedValue.length),
                                  );
                                },
                                decoration: InputDecoration(
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  hintText: '0,00',
                                  hintStyle: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 35,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 25),
              //********************************************Menu Categoria ************************ */
              //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
              //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
              DropdownButton<String>(
                value:
                    categoriaFrontEnd, // categoria que vai ser apresentada ao usuario
                hint: Text(
                  'Escolha uma categoria',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                isExpanded: true,
                items: categoriasMapa.keys
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    categoriaFrontEnd = newValue;
                    categoriaSelecionada = categoriasMapa[newValue];

                    // print('Categoria Firebase $categoriaSelecionada');
                    //print('Categoria Front End $categoriaFrontEnd');
                  });
                },
                underline: Container(
                  height: 2,
                  color: Color.fromARGB(255, 250, 92, 92),
                ),
              ),

              SizedBox(height: 05),
              Padding(
                padding: const EdgeInsets.only(left: 10),
              ),

              SizedBox(height: 25),

//**************************************** Campo de Autocomplete ************
              TypeAheadField<String>(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: _controllerAutocomplete,
                  decoration: InputDecoration(
                    hintText: 'Buscar subcategoria',
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: _controllerAutocomplete.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              size:
                                  20, // Ajuste o tamanho do ícone conforme necessário
                              color: Colors
                                  .red, // Ajuste a cor do ícone conforme necessário
                            ),
                            onPressed: () {
                              setState(() {
                                _controllerAutocomplete.clear();
                                _tipoDespesa = null;
                              });
                            },
                          )
                        : null,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(
                        color: Colors.red,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
                suggestionsCallback: (pattern) async {
                  if (pattern.isEmpty || categoriaSelecionada == null) {
                    return const Iterable<String>.empty();
                  }

                  // Busca as subcategorias com base na categoriaSelecionada no Firebase
                  List<String> subcategorias =
                      await FirebaseService('categorias')
                          .buscarSubcategorias(categoriaSelecionada!);

                  // Filtra as subcategorias com base no texto inserido no campo de texto
                  return subcategorias.where((String option) {
                    return option.toLowerCase().contains(pattern.toLowerCase());
                  });
                },
                itemBuilder: (context, String suggestion) {
                  return ListTile(
                    title: Text(suggestion),
                  );
                },
                onSuggestionSelected: (String suggestion) {
                  setState(() {
                    _controllerAutocomplete.text = suggestion;
                    _tipoDespesa = suggestion;
                  });
                },
                // Defina um widget personalizado para a mensagem "No items found"
                noItemsFoundBuilder: (context) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Buscando itens...',
                      style: TextStyle(fontSize: 14),
                    ),
                  );
                },
              ),

              SizedBox(height: 25),

              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Row(
                  children: [
                    Text(
                      'Data:',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 20),
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today),
                          SizedBox(width: 5),
                          Text(
                            _dataSelecionada != null
                                ? DateFormat('dd/MM/yyyy', 'pt_BR')
                                    .format(_dataSelecionada!)
                                : 'Selecione a Data',
                            style: TextStyle(
                              fontSize: 20,
                              color: Color.fromARGB(255, 248, 76, 76),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(left: 10, top: 20),
                child: Text(
                  'Últimas transações:',
                  style: TextStyle(
                    color: Color.fromARGB(164, 0, 0, 0),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

//********** */ lista devera ser implementada aqui ****************************/

//***********/ FIM DO LISTVIEW ********************************************** */
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text(
          'Salvar Despesa',
          style: TextStyle(fontSize: 18),
        ),
        icon: Icon(
          Icons.check,
          size: 30,
        ),
        backgroundColor: Color.fromARGB(255, 248, 76, 76),
        onPressed: () {
          OrganizaDadosParaSalvar();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}




/*

 TextEditingController _controllerData = TextEditingController();
  TextEditingController _controllerValorDespesa = TextEditingController();
  TextEditingController _controllerSelecao = TextEditingController();
  TextEditingController _controllerBuscar = TextEditingController();

  ValueKey<String> autocompleteKey = ValueKey("autocomplete1");
  // Adicione esta linha
  Map<String, String> despesaIdParaNomeColecao = {};
  List<Map<String, dynamic>> ultimasDespesas = []; // Lista de últimas despesas

  DateTime? _dataSelecionada = DateTime.now();

  String? categoriaSelecionadaNomeAmigavel;
  String? userId = AuthManager.userId;
  String? _despesaEditandoId;
  String? _editandoDespesa = '0';

  @override
  void initState() {
    super.initState();

    despesaIdParaNomeColecao = {};
    // ... outras inicializações ...
    _controllerValorDespesa.addListener(() {
      final text = _formatCurrency(_controllerValorDespesa.text);
      _controllerValorDespesa.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    });
  }

  void _mostrarMensagem(String mensagem, {bool erro = false}) {
    final snackBar = SnackBar(
      content: Text(mensagem),
      duration: Duration(seconds: 3),
      backgroundColor: erro ? Colors.red : Colors.green,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  String _formatCurrency(String value) {
    if (value.isEmpty) {
      return '0.00';
    }

    value = value.replaceAll(RegExp('[^0-9]'), '');
    value = value.replaceFirst(RegExp('^0+'), '');

    while (value.length < 3) {
      value = '0$value';
    }

    return '${value.substring(0, value.length - 2)}.${value.substring(value.length - 2)}';
  }

//********************Salvar Despesa******************************************* */
//********************Salvar Despesa******************************************* */
  void _salvarDespesa() async {
    if (userId == null) {
      _mostrarMensagem(
          'Usuário não autenticado. Faça login antes de salvar a despesa.',
          erro: true);
      return;
    }

    try {
      String valorDespesaUser =
          _controllerValorDespesa.text.replaceAll(',', '.');
      double valorDespesa = double.tryParse(valorDespesaUser) ?? 0.0;
      String categoria = categoriaSelecionadaNomeAmigavel ?? "Sem Categoria";
      String subcategoria = _controllerSelecao.text;
      String? nomeColecaoFirebase =
          categoriasMapa[categoriaSelecionadaNomeAmigavel];

      if (valorDespesa == 0.00 || subcategoria.isEmpty) {
        _mostrarMensagem('Verifique todos os campos!', erro: true);
        return;
      }
      if (nomeColecaoFirebase == null) {
        _mostrarMensagem('Escolha uma categoria', erro: true);
        return;
      }

      _controllerData.text = DateFormat('dd/MM/yyyy', 'pt_BR')
          .format(_dataSelecionada ?? DateTime.now());

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userId)
          .get();
      double saldoGeral = double.parse(userDoc['saldoGeral'].toString());

      Map<String, dynamic> dadosDespesa = {
        'idUsuario': userId,
        'categoria': categoria,
        'subcategoria': subcategoria,
        'valor': valorDespesa.toString(),
        'data': Timestamp.fromDate(_dataSelecionada!)
      };

      String mensagemSucesso;
      if (_despesaEditandoId != null) {
        await FirebaseFirestore.instance
            .collection(nomeColecaoFirebase)
            .doc(_despesaEditandoId)
            .update(dadosDespesa);

        _despesaEditandoId = null;
        mensagemSucesso = 'Edição realizada com sucesso!';
      } else {
        await FirebaseFirestore.instance
            .collection(nomeColecaoFirebase)
            .add(dadosDespesa);

        mensagemSucesso = 'Despesa salva com sucesso!';
      }

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userId)
          .update({'saldoGeral': saldoGeral.toString()});

      _mostrarMensagem(mensagemSucesso);

      // Ocultar o teclado
      FocusScope.of(context).unfocus();

      _controllerValorDespesa.clear();
      _controllerData.clear();
      _controllerSelecao.clear();
      setState(() {
        categoriaSelecionadaNomeAmigavel = null;
        categoriaSelecionada = null;
        _dataSelecionada = DateTime.now();
        autocompleteKey = ValueKey("autocomplete${DateTime.now()}");
      });
    } catch (e) {
      print('Erro ao salvar despesa: $e');
      _mostrarMensagem('Erro ao salvar a despesa. Tente novamente.',
          erro: true);
    }
  }

  void _carregarDadosParaEdicao(Map<String, dynamic> transacao) {
    String idDespesa = transacao['id'];
    _despesaEditandoId = idDespesa;
    _editandoDespesa = '1';

    double valorDespesa = double.tryParse(transacao['valor'].toString()) ?? 0.0;
    _controllerValorDespesa.text = valorDespesa.toStringAsFixed(2);

    String categoriaDespesa = transacao['categoria'];
    String subcategoriaDespesa = transacao['subcategoria'];
    Timestamp timestamp = transacao['data'];
    DateTime dataDespesa = timestamp.toDate();

    Map<String, String> categoriaMap = {
      'despesasEssenciais': 'Gastos Essenciais',
      'despesasLivres': 'Gastos Livres',
      'despesasEducacao': 'Gastos com Educação'
      // Adicione mais mapeamentos conforme necessário
    };

    String categoriaMapeada =
        categoriaMap[categoriaDespesa] ?? categoriaDespesa;
    categoriaSelecionadaNomeAmigavel = categoriaMapeada;
    categoriaSelecionada = categoriaMap.entries
        .firstWhere((entry) => entry.value == categoriaMapeada,
            orElse: () => MapEntry('', ''))
        .key;

    // Converter o Timestamp para DateTime e atualizar _dataSelecionada para o DatePicker
    _dataSelecionada = (transacao['data'] as Timestamp).toDate();
    _controllerSelecao.text = subcategoriaDespesa;

    setState(() {});
  }

// Editar despesas ****************************************************************
  void _editarDespesa(String id, double valor, String categoria,
      String subcategoria, DateTime data) {
    // Atualizando os controladores com os valores da despesa
    _controllerValorDespesa.text =
        valor.toString(); // Formata o valor para duas casas decimais
    _controllerSelecao.text = subcategoria; // Atualiza o campo subcategoria

    // Para categoria, você precisa fazer a conversão reversa para selecionar o valor correto no Dropdown
    categoriaSelecionadaNomeAmigavel = categoria;
    categoriaSelecionada = categoriasMapa.entries
        .firstWhere((entry) => entry.key == categoria,
            orElse: () => MapEntry('', ''))
        .value;

    _controllerData.text = DateFormat('dd/MM/yyyy')
        .format(data); // Formata a data para o formato desejado

    // Aqui, você pode mudar para a tela de edição ou exibir os campos de edição
    // Dependendo da sua UI, você pode querer chamar setState para atualizar a tela
    // Atualize a lista de despesas e a interface do usuário
    _carregarUltimasDespesas().then((_) {
      setState(() {
        // Atualizações da interface do usuário
      });
    });
  }

//********************Excluir Despesas***************************************** */
  //********************Excluir Despesas***************************************** */
  void _excluirDespesa(String idDespesa, String nomeCategoriaDespesa,
      double valorDespesa) async {
    try {
      if (userId == null) {
        _mostrarMensagem('Usuário não autenticado.', erro: true);
        return;
      }

      // Excluir a despesa
      await FirebaseFirestore.instance
          .collection(nomeCategoriaDespesa)
          .doc(idDespesa)
          .delete();

      // Atualizar a lista de rastreamento removendo a despesa excluída
      DocumentReference rastreamentoRef = FirebaseFirestore.instance
          .collection('rastreamentoDespesas')
          .doc(userId);

      DocumentSnapshot rastreamentoDoc = await rastreamentoRef.get();
      if (rastreamentoDoc.exists) {
        Map<String, dynamic> rastreamentoData =
            rastreamentoDoc.data() as Map<String, dynamic>;
        List<dynamic> despesasList =
            rastreamentoData[nomeCategoriaDespesa] ?? [];
        despesasList.remove(idDespesa); // Remove a despesa pelo ID
        await rastreamentoRef.update({nomeCategoriaDespesa: despesasList});
      }

      // Atualizar o saldo geral do usuário após a exclusão da despesa
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userId)
          .get();

      double saldoGeral = double.parse(userDoc['saldoGeral'].toString());
      saldoGeral += valorDespesa;

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userId)
          .update({'saldoGeral': saldoGeral.toStringAsFixed(2)});

      _mostrarMensagem('Despesa excluída com sucesso! Saldo atualizado.');

      // Atualizar a lista de últimas despesas
      await _carregarUltimasDespesas();
    } catch (e) {
      _mostrarMensagem('Erro ao excluir a despesa. Tente novamente.',
          erro: true);
      print('Erro ao excluir despesa: $e');
    }
  }

//********************Carregar Ultimas Despesas******************************** */
  Future<void> _carregarUltimasDespesas() async {
    var novasUltimasDespesas = await buscarUltimasDespesas();
    if (mounted) {
      setState(() {
        ultimasDespesas = novasUltimasDespesas;
      });
    }
  }

// ****************Buscar  Ultimas Despesas *************************************

  Future<List<Map<String, dynamic>>> buscarUltimasDespesas() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    DocumentSnapshot rastreamentoDoc =
        await firestore.collection('rastreamentoDespesas').doc(userId).get();

    if (!rastreamentoDoc.exists || rastreamentoDoc.data() == null) {
      return [];
    }

    // Agora nós temos certeza que data() não é null, então podemos usar '!' para desembrulhar o valor
    Map<String, dynamic> rastreamentoData =
        rastreamentoDoc.data()! as Map<String, dynamic>;

    List<Map<String, dynamic>> ultimasDespesas = [];
    // Agora nós iteramos sobre as chaves do mapa, que correspondem aos nomes das coleções
    for (String categoria in rastreamentoData.keys) {
      var despesasIds = rastreamentoData[categoria];
      if (despesasIds is List) {
        // Verifica se o valor é uma lista
        for (var despesaId in despesasIds) {
          if (despesaId is String) {
            // Verifica se o ID da despesa é uma String
            DocumentSnapshot despesaDoc =
                await firestore.collection(categoria).doc(despesaId).get();
            if (despesaDoc.exists) {
              Map<String, dynamic> despesa =
                  despesaDoc.data() as Map<String, dynamic>;
              despesa['id'] = despesaDoc.id; // Adicionando o ID do documento
              despesa['categoria'] = categoria; // Adicionando a categoria
              ultimasDespesas.add(despesa);
            }
          }
        }
      }
    }

    // Ordenar as despesas pela data, da mais recente para a mais antiga
    ultimasDespesas.sort((a, b) {
      Timestamp dataA = a['data'] as Timestamp;
      Timestamp dataB = b['data'] as Timestamp;
      return dataB.compareTo(dataA);
    });

    return ultimasDespesas;
  }

//**************************Data***************************************************** */
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  Future<String?> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _dataSelecionada) {
      setState(() {
        _dataSelecionada = picked;
        _controllerData.text = DateFormat('dd/MM/yyyy', 'pt_BR').format(picked);
      });

      return DateFormat('dd/MM/yyyy', 'pt_BR').format(picked);
    }

    return null; // Retorna null se nenhuma data for selecionada
  }

//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
//>>>>>>>>>>>>>>>>>>>> >>>Buscar sugestoes no Firebase >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  Future<List<String>> buscarSugestoes(String query) async {
    print('Buscando sugestões para: $query');
    print('Categoria selecionada Amigavel: $categoriaSelecionadaNomeAmigavel');
    print('Categoria selecionada é: $categoriaSelecionadaNomeAmigavel');
    if (query.isEmpty) {
      return [];
    }

    // Certifique-se de que 'categoriaSelecionadaNomeAmigavel' não é null
    if (categoriaSelecionadaNomeAmigavel == null) {
      print('A categoria selecionada é null');
      return [];
    }

    // Acesse o documento com base na categoria selecionada pelo usuário
    DocumentSnapshot categoriaDoc = await FirebaseFirestore.instance
        .collection('categorias')
        .doc(categoriaSelecionada) // Use a variável correta aqui
        .get();

    if (!categoriaDoc.exists) {
      print('O documento da categoria selecionada não existe');
      return [];
    }

    Map<String, dynamic> campos = categoriaDoc.data() as Map<String, dynamic>;

    List<String> sugestoes = campos.keys
        .where((key) => key.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return sugestoes;
  }*/