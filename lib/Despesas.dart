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
  final TextEditingController _seuCampoDeTextoController =
      TextEditingController();
  final FocusNode _seuCampoDeTextoFocus = FocusNode();

  List<Map<String, dynamic>> listUltimasDespesas = [];

//Todas as variaveis aqui      *************************************************

  String? categoriaFrontEnd;
  String? categoriaSelecionada;
  String? _categoriaEdicao;
  DateTime? _dataSelecionada = DateTime.now();
  String? _tipoDespesa;
  double? _saldoGeral;
  bool estaEditando = false;
  Map<String, dynamic> despesaEmEdicao = {};

//Todos os metodos deverao ser implementados aqui ******************************

  @override
  void initState() {
    super.initState();
    buscarSaldoGeral();
    _carregarDespesas();
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

  Future<void> _carregarDespesas() async {
    try {
      FirebaseService firebaseService = FirebaseService('rastreamentoDespesas');

      // Obtém as últimas despesas da coleção 'rastreamentoDespesas'
      List<Map<String, dynamic>> despesas =
          await firebaseService.obterUltimasDespesas();

      // Exibe a lista de despesas no console
      //print('Lista de Despesas: $despesas');

      // Atualiza o estado da lista de despesas no widget
      setState(() {
        listUltimasDespesas = despesas;
        buscarSaldoGeral(); // linha importante
      });
    } catch (e) {
      print('Erro ao carregar despesas: $e');
    }
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
      print('Saldo Geral Retornado Pelo Firebase $_saldoGeral');
    } catch (e) {
      print('Erro ao buscar o saldo geral do usuário: $e');
    }
  }

  void excluirDespesa(Map<String, dynamic> despesa) async {
    String idUsuario = despesa['idUsuario'];
    double novoSaldoGeral = 0.00;

    try {
      // Criar uma instância do seu serviço Firebase
      FirebaseService firebaseService = FirebaseService(_categoriaEdicao!);

      // Buscar o saldo geral atual do usuário no Firebase
      String saldoGeralString =
          await firebaseService.buscarSaldoGeralUsuario(idUsuario);

      // Converter o saldoGeralString para double
      double saldoGeral = double.parse(saldoGeralString);

      // Converter o valor da despesa String para Double
      double valorDespesa = double.parse(despesa['valor'].toString());

      // Calcular o novo saldo geral
      novoSaldoGeral = saldoGeral + valorDespesa;

      // Atualizar o saldo geral no Firestore (convertendo para String)
      await firebaseService.atualizarSaldo(
          idUsuario,
          novoSaldoGeral.toString(), // Convertendo para String
          firebaseService.getUsuariosCollectionReference());

      // Deletar a despesa
      await firebaseService.deletarItem(despesa['idDespesa']);

      // Atualizar a lista de despesas após excluir uma
      await _carregarDespesas();

      // Exibir mensagem de exclusão bem-sucedida
      _mostrarMensagem('Despesa excluída com sucesso!');
    } catch (e) {
      print('Erro ao excluir a despesa do Firebase: $e');
    }
  }

  void excluirDespesaRastreamento(Map<String, dynamic> despesa) async {
    try {
      // Criar uma instância do seu serviço Firebase
      FirebaseService firebaseService = FirebaseService('rastreamentoDespesas');
      await firebaseService.deletarItem(despesa['id']);

      // Atualizar a lista de despesas após excluir uma
      await _carregarDespesas();
      // Exibir mensagem de exclusão bem-sucedida
      _mostrarMensagem('Despesa excluída com sucesso!');
    } catch (e) {
      print('Erro ao excluir a despesa do Firebase: $e');
    }
  }

  void _carregarDadosParaEdicao(Map<String, dynamic> despesa) {
    setState(() {
      // Configurar os valores nos campos de edição
      _controllerValorDespesa.text = despesa['valor'].toString();
      categoriaFrontEnd = categoriasMapa.entries
          .singleWhere((entry) => entry.value == despesa['tipo'])
          .key;
      categoriaSelecionada = despesa['tipo'];
      _controllerAutocomplete.text = despesa['subcategorias'] ?? '';
      _dataSelecionada = (despesa['data'] as Timestamp).toDate();
      _controllerData.text =
          DateFormat('dd/MM/yyyy', 'pt_BR').format(_dataSelecionada!);

      // Configurar a variável despesaEmEdicao
      despesaEmEdicao = despesa;

      // Indicar que está editando
      estaEditando = true;
    });
  }

  void _carregarDadosCategoriaDiferente(Map<String, dynamic> despesa) {
    setState(() {
      // Configurar os valores nos campos de edição
      _controllerValorDespesa.text = despesa['valor'].toString();
      categoriaFrontEnd = categoriasMapa.entries
          .singleWhere((entry) => entry.value == despesa['tipo'])
          .key;
      categoriaSelecionada = despesa['tipo'];
      _controllerAutocomplete.clear();
      _dataSelecionada = (despesa['data'] as Timestamp).toDate();
      _controllerData.text =
          DateFormat('dd/MM/yyyy', 'pt_BR').format(_dataSelecionada!);

      // Configurar a variável despesaEmEdicao
      despesaEmEdicao = despesa;

      // Indicar que está editando
      estaEditando = true;
    });
  }

  void _editarDespesa(Map<String, dynamic> despesa) async {
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        String? userId = AuthManager.userId;
        String? idDespesa = despesa['idDespesa'];
        String? idDespesaRastreamento = despesa['id'];
        String? categoriaAnterior = despesa['tipo'];
        double? saldoGeralAtualizado = 0.00;
        double? valorDespesaDouble;

        double? valorDespesaEdicao =
            double.tryParse(_controllerValorDespesa.text);
        String? tipoDespesaEdicao = _controllerAutocomplete.text;
        DateTime? _dataSelecionadaEdicao = _dataSelecionada;

        if (categoriaSelecionada == _categoriaEdicao) {
          DespesasObj despesaEdicao = DespesasObj(
            userId!,
            tipoDespesaEdicao,
            valorDespesaEdicao!,
            _dataSelecionadaEdicao!,
            _categoriaEdicao,
          );

          Map<String, dynamic> rastreamentoEdicao = {
            'idUsuario': userId,
            'tipo': _categoriaEdicao,
            'subcategorias': tipoDespesaEdicao,
            'valor': valorDespesaEdicao,
            'data': _dataSelecionada!,
            'mes': DateFormat.MMMM('pt_BR').format(_dataSelecionada!),
            'idDespesa': idDespesa,
          };

          valorDespesaDouble = double.parse(valorDespesaEdicao.toString());
          double despesaAnterior = double.parse(despesa['valor'].toString());

          _saldoGeral = _saldoGeral! + despesaAnterior;
          saldoGeralAtualizado = _saldoGeral! - valorDespesaDouble;

          String saldoFormatado = saldoGeralAtualizado.toStringAsFixed(2);

          try {
            FirebaseService firebaseService =
                FirebaseService(_categoriaEdicao!);

            Map<String, dynamic> despesaMap = despesaEdicao.toMap();

            await firebaseService.atualizarItem(idDespesa!, despesaMap);
            await firebaseService.atualizarSaldo(userId, saldoFormatado,
                firebaseService.getUsuariosCollectionReference());

            editarDadosRastreamento(idDespesaRastreamento!, rastreamentoEdicao);
            estaEditando = false;
            setState(() {
              _controllerValorDespesa.clear();
              _tipoDespesa = null;
              _dataSelecionada = DateTime.now();
              categoriaFrontEnd = null;
              categoriaSelecionada = null;
            });

            _controllerAutocomplete.clear();

            await _carregarDespesas();

            // Exibir mensagem de dados salvos
            _mostrarMensagem('Despesa editada com sucesso!');
          } catch (e) {
            // Tratar exceção, se necessário
          }
        } else {
          //se categoria for diferente

          valorDespesaDouble = double.parse(valorDespesaEdicao.toString());
          double despesaAnterior = double.parse(despesa['valor'].toString());

          saldoGeralAtualizado = _saldoGeral! + despesaAnterior;
          saldoGeralAtualizado = saldoGeralAtualizado - valorDespesaDouble;

          String saldoFormatado = saldoGeralAtualizado.toStringAsFixed(2);

          DespesasObj despesaEdicao = DespesasObj(
            userId!,
            tipoDespesaEdicao,
            valorDespesaEdicao!,
            _dataSelecionadaEdicao!,
            categoriaSelecionada,
          );

          try {
            FirebaseService firebaseServiceAnterior =
                FirebaseService(categoriaAnterior!);

            // Atualiza o saldo Geral
            await firebaseServiceAnterior.atualizarSaldo(
              userId,
              saldoFormatado,
              firebaseServiceAnterior.getUsuariosCollectionReference(),
            );

            // Deleta a despesa antiga
            await firebaseServiceAnterior.deletarItem(idDespesa!);

            // Adiciona a nova despesa na nova categoria
            FirebaseService firebaseServiceNova =
                FirebaseService(categoriaSelecionada!);

            // Converter o objeto DespesasObj para um mapa
            Map<String, dynamic> despesaMap = despesaEdicao.toMap();

            // Adicionar o item ao Firestore e obter o DocumentReference
            DocumentReference despesaRef =
                await firebaseServiceNova.adicionarItem(despesaMap);

            // Obter o ID da nova despesa a partir do DocumentReference
            idDespesa = despesaRef.id;

            // Exclui a despesa antiga do Rastreamento

            FirebaseService firebaseService =
                FirebaseService('rastreamentoDespesas');
            await firebaseService.deletarItem(despesa['id']);

            // Adicionar o item na lista de rastreamento para listar as últimas transações
            Map<String, dynamic> rastreamentoNovaDespesa = {
              'idUsuario': userId,
              'tipo': categoriaSelecionada,
              'subcategorias': tipoDespesaEdicao,
              'valor': valorDespesaEdicao,
              'data': _dataSelecionada!,
              'mes': DateFormat.MMMM('pt_BR').format(_dataSelecionada!),
              'idDespesa': idDespesa,
            };

            // Chamar o método para salvar as informações de rastreamento de despesas
            await firebaseServiceNova
                .adicionarRastreamentoDespesa(rastreamentoNovaDespesa);

            // Limpar os campos e carregar as despesas
            setState(() {
              _controllerValorDespesa.clear();
              _tipoDespesa = null;
              _dataSelecionada = DateTime.now();
              categoriaFrontEnd = null;
              categoriaSelecionada = null;
            });
            _controllerAutocomplete.clear();

            await _carregarDespesas();
// Exibir mensagem de dados salvos
            _mostrarMensagem('Despesa editada com sucesso!');
          } catch (e) {
            // Tratar exceção, se necessário
          }
        }
      });
    } catch (e) {
      // Tratar exceção, se necessário
      print('Erro durante a transação: $e');
    }
  }

  void editarDadosRastreamento(
      String idRastreamento, Map<String, dynamic> despesasRastreamento) async {
    try {
      FirebaseService firebaseService = FirebaseService('rastreamentoDespesas');
      await firebaseService.atualizarRastreamentoDespesa(
          idRastreamento, despesasRastreamento);

      // Atualizar a lista de despesas após salvar uma nova
      await _carregarDespesas();
    } catch (e) {
      print('Erro ao editar dados de rastreamento: $e');
      // Adicione aqui qualquer outra lógica de tratamento de erro desejada.
    }
  }

  void OrganizaDadosParaSalvar() async {
    if (estaEditando) {
      buscarSaldoGeral();
      _editarDespesa(despesaEmEdicao);
    } else {
      buscarSaldoGeral();

      String? userId = AuthManager.userId;
      double? _valorDespesa;
      double? novoSaldo = 0.00;

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
        categoriaSelecionada,
      );
      try {
        // Criar uma instância do seu serviço Firebase
        FirebaseService firebaseService =
            FirebaseService(categoriaSelecionada!);

        // Subtrai o valor da despesa ao valor do saldo geral
        novoSaldo = _saldoGeral! - _valorDespesa;
        String saldoFormatado = novoSaldo.toStringAsFixed(2);

        // chama o metodo para atualizar o saldo geral do usuario
        await firebaseService.atualizarSaldo(userId, saldoFormatado,
            firebaseService.getUsuariosCollectionReference());

        // Converter o objeto DespesasObj para um mapa
        Map<String, dynamic> despesaMap = despesa.toMap();

        // Adicionar o item ao Firestore e obter o DocumentReference
        DocumentReference despesaRef =
            await firebaseService.adicionarItem(despesaMap);

        // Obter o ID da despesa a partir do DocumentReference
        String idDespesa = despesaRef.id;

        // Adicionar o item na lista de rastreamento para listar as ultimas transacoes
        Map<String, dynamic> rastreamentoData = {
          'idUsuario': userId,
          'tipo': categoriaSelecionada,
          'subcategorias': _tipoDespesa,
          'valor': _valorDespesa,
          'data': _dataSelecionada!,
          'mes': DateFormat.MMMM('pt_BR').format(_dataSelecionada!),
          'idDespesa': idDespesa, // Usando o mesmo ID da despesa
        };

        // chama o metodo para salvar as informacoes de rastreamento de despesas
        await firebaseService.adicionarRastreamentoDespesa(rastreamentoData);

        setState(() {
          _controllerValorDespesa.clear();
          _tipoDespesa = null;
          _dataSelecionada = DateTime.now();
          categoriaFrontEnd = null;
          categoriaSelecionada = null;
        });
        _controllerAutocomplete.clear();

        // Atualizar a lista de despesas após salvar uma nova
        await _carregarDespesas();
        // Exibir mensagem de dados salvos
        _mostrarMensagem('Despesa salva com sucesso!');
      } catch (e) {
        print('Erro ao salvar os dados no Firebase: $e');
      }
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

                    if (categoriaSelecionada != _categoriaEdicao) {
                      _controllerAutocomplete.clear();
                    }

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

              // ********** */ Lista deverá ser implementada aqui ****************************/
              Container(
                height: 200,
                child: ListView.builder(
                  itemCount: listUltimasDespesas.length,
                  itemBuilder: (context, index) {
                    final despesa = listUltimasDespesas[index];
                    final idDespesa =
                        despesa['idDespesa']; // Adicione esta linha

                    return ListTile(
                      title: Text(despesa['subcategorias'] ?? 'Sem tipo'),
                      subtitle: Text(
                        "R\$ ${despesa['valor']} - ${DateFormat('dd/MM/yyyy', 'pt_BR').format((despesa['data'] as Timestamp).toDate())}",
                      ),
                      trailing: Padding(
                        padding: const EdgeInsets.only(
                            right: 1.0), // Ajuste o valor conforme necessário
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.edit,
                                color: Color.fromARGB(255, 30, 167, 18),
                              ),
                              onPressed: () {
                                _categoriaEdicao = despesa['tipo'];
                                estaEditando = true;
                                despesaEmEdicao = despesa;
                                _carregarDadosParaEdicao(despesa);
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                excluirDespesa(despesa);
                                excluirDespesaRastreamento(despesa);
                              },
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        // Pode manter a lógica aqui, se necessário
                      },
                    );
                  },
                ),
              ),
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
          estaEditando = false;
          _seuCampoDeTextoFocus.unfocus();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
