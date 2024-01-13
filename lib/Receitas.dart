import 'dart:async';
import 'dart:ffi';
import 'package:financas/model/AuthManager.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Receitas extends StatefulWidget {
  @override
  _ReceitasState createState() => _ReceitasState();
}

class _ReceitasState extends State<Receitas> {
  TextEditingController _controllerReceita = TextEditingController();
  TextEditingController _controllerValorReceita =
      TextEditingController(); // pega o valor digitado pelo usuario
  TextEditingController _controllerData = TextEditingController();

  String? _tipoReceitaSelecionada;
  DateTime? _dataSelecionada = DateTime.now();

  String? _receitaEditandoId;
  StreamSubscription? _subscription;
  String? salvandoDespesa = '0';

  @override
  void initState() {
    super.initState();
    _dataSelecionada = DateTime.now();
    _tipoReceitaSelecionada = null;
    _escutarUltimasReceitas();
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

  void _salvarReceita() async {
    try {
      String? userId = AuthManager.userId;
      if (userId == null) {
        _mostrarMensagem(
            'Usuário não autenticado. Faça login antes de salvar a receita.',
            erro: true);
        return;
      }

      String idUsuario = userId;
      String tipoReceita = _controllerReceita.text;
      String valorReceitaUser = _controllerValorReceita.text;
      double valorReceita = double.parse(_formatCurrency(valorReceitaUser));

      if (tipoReceita.isEmpty || valorReceita == 0.00) {
        _mostrarMensagem('Verifique todos os campos!!', erro: true);
        return;
      }

      // Atualiza o controlador da data
      _controllerData.text = DateFormat('dd/MM/yyyy', 'pt_BR')
          .format(_dataSelecionada ?? DateTime.now());

      // Consultar o documento do usuário no Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(idUsuario)
          .get();
      double saldoGeral = double.parse(userDoc['saldoGeral'].toString());

      if (_receitaEditandoId != null) {
        // Lógica de edição de receita existente

        // Obter valor antigo da receita
        DocumentSnapshot receitaAntiga = await FirebaseFirestore.instance
            .collection('receitas')
            .doc(_receitaEditandoId)
            .get();
        double valorAntigo = double.parse(receitaAntiga['valor'].toString());

        // Atualizar saldo geral
        saldoGeral = saldoGeral - valorAntigo + valorReceita;

        // Atualizar a receita
        await FirebaseFirestore.instance
            .collection('receitas')
            .doc(_receitaEditandoId)
            .update({
          'tipo': tipoReceita,
          'valor': valorReceita.toString(),
          'data': Timestamp.fromDate(_dataSelecionada!),
        });

        _receitaEditandoId = null;
      } else {
        // Lógica para adicionar uma nova receita
        saldoGeral += valorReceita;

        Map<String, dynamic> dadosReceita = {
          'idUsuario': idUsuario,
          'tipo': tipoReceita,
          'valor': valorReceita.toString(),
          'data': Timestamp.fromDate(_dataSelecionada!),
        };

        await FirebaseFirestore.instance
            .collection('receitas')
            .add(dadosReceita);
      }

      // Atualizar saldo geral do usuário
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(idUsuario)
          .update({'saldoGeral': saldoGeral.toStringAsFixed(2)});

      _mostrarMensagem('Receita salva com sucesso!');

      // Limpar os controladores
      _controllerReceita.clear();
      _controllerValorReceita.clear();
      _tipoReceitaSelecionada = null;
      _dataSelecionada = DateTime.now();
      setState(() {
        _tipoReceitaSelecionada = null;
      });
    } catch (e) {
      print('Erro ao salvar receita: $e');
      _mostrarMensagem('Erro ao salvar a receita. Tente novamente.');
    }
  }

  List<Map<String, dynamic>> cadastros = [];

  void _escutarUltimasReceitas() {
    // Obter o userId da classe AuthManager
    String? userId = AuthManager.userId;

    if (userId == null) {
      _mostrarMensagem(
        'Usuário não autenticado. Faça login antes de acessar as receitas.',
        erro: true,
      );
      return;
    }

    FirebaseFirestore.instance
        .collection('receitas')
        .where('idUsuario', isEqualTo: userId)
        .orderBy('data', descending: true)
        .limit(4)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          cadastros = snapshot.docs
              .map((doc) => {
                    'id': doc.id, // Salvar o ID do documento
                    ...doc.data()
                  })
              .toList();
        });
      }
    });
  }

  void _excluirReceita(String docId, double valorReceita) async {
    try {
      String? userId = AuthManager.userId;
      if (userId == null) {
        _mostrarMensagem('Usuário não autenticado.', erro: true);
        return;
      }

      // Consultar o documento do usuário no Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userId)
          .get();

      // Recuperar o saldo geral e subtrair o valor da receita
      double saldoGeral = double.parse(userDoc['saldoGeral'].toString());
      saldoGeral -= valorReceita;

      // Atualiza o saldo geral no documento do usuário
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userId)
          .update({
        'saldoGeral': saldoGeral.toStringAsFixed(2),
      });

      // Excluir a receita
      await FirebaseFirestore.instance
          .collection('receitas')
          .doc(docId)
          .delete();

      setState(() {
        // Remove o item da lista cadastros baseando-se no ID da receita
        cadastros.removeWhere((receita) => receita['id'] == docId);
        // Atualize o saldo geral e mostre a mensagem de sucesso
        _mostrarMensagem('Receita excluída com sucesso! Saldo atualizado.');
      });
    } catch (e) {
      _mostrarMensagem('Erro ao excluir a receita. Tente novamente.',
          erro: true);
      print('Erro ao excluir receita: $e');
    }
  }

  void _carregarDadosParaEdicao(Map<String, dynamic> receita) {
    setState(() {
      _controllerReceita.text = receita['tipo']; // Carregar tipo da receita
      _controllerValorReceita.text =
          receita['valor']; // Carregar valor da receita
      _controllerData.text = DateFormat('dd/MM/yyyy', 'pt_BR').format(
          (receita['data'] as Timestamp).toDate()); // Carregar data da receita
      _receitaEditandoId =
          receita['id']; // Salvar o ID da receita para saber que está editando

      // Carregar o tipo de receita selecionado para o DropdownButton
      _tipoReceitaSelecionada = receita['tipo'];
      // Converter o Timestamp para DateTime e atualizar _dataSelecionada para o DatePicker
      _dataSelecionada = (receita['data'] as Timestamp).toDate();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel(); // Cancela a subscrição ao sair do widget
    // Outras limpezas, se necessário
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Receitas",
          style: TextStyle(
            color: const Color.fromARGB(160, 0, 0, 0),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 5),
            Card(
              color: Colors.green,
              margin: EdgeInsets.all(0),
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Valor da Receita:',
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
                          child: TextField(
                            controller: _controllerValorReceita,
                            textAlign: TextAlign.end,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 35,
                            ),
                            onChanged: (value) {
                              String formattedValue = _formatCurrency(value);
                              _controllerValorReceita.value =
                                  _controllerValorReceita.value.copyWith(
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
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 25),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    'Receita:',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 25),
                DropdownButton<String>(
                  value: _tipoReceitaSelecionada,
                  onChanged: (String? newValue) {
                    setState(() {
                      _tipoReceitaSelecionada = newValue!;
                      _controllerReceita.text = newValue ?? '';
                    });
                  },
                  items: <String?>[
                    null,
                    'Salário',
                    'Extras',
                    'Décimo Terceiro',
                    'Férias',
                    'Outras Rendas'
                  ].map<DropdownMenuItem<String>>((String? value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value ?? 'Selecione o tipo',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.green,
                        ),
                      ),
                    );
                  }).toList(),
                  dropdownColor: Colors.white,
                ),
              ],
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
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Adicionando o texto "Últimas transações:" aqui
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 30),
              child: Text(
                'Últimas transações:',
                style: TextStyle(
                  color: Color.fromARGB(164, 0, 0, 0),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
//********************************************** */ list vieww*************************************************************
            Expanded(
              child: ListView.builder(
                itemCount: cadastros.length,
                itemBuilder: (context, index) {
                  final cadastro = cadastros[index];
                  return ListTile(
                    title: Text(cadastro['tipo'] ??
                        'Sem tipo'), // Exibe o tipo da receita
                    subtitle: Text(
                        "R\$ ${cadastro['valor']} - ${DateFormat('dd/MM/yyyy', 'pt_BR').format((cadastro['data'] as Timestamp).toDate())}"),
                    // Exibe o valor e a data
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          // icone para edicao das receitas
                          icon: Icon(Icons.edit,
                              color: Color.fromARGB(255, 30, 167, 18)),
                          onPressed: () {
                            _carregarDadosParaEdicao(cadastros[index]);
                          },
                        ),
                        IconButton(
                          // botao para excluir uma receita
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            double valorReceita =
                                double.parse(cadastros[index]['valor']);
                            _excluirReceita(
                                cadastros[index]['id'], valorReceita);
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      // Pode manter a lógica aqui, se necessário
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        height: 65,
        child: FloatingActionButton.extended(
          onPressed: _salvarReceita,
          label: Text(
            'Salvar Receita',
            style: TextStyle(fontSize: 18),
          ),
          icon: Icon(
            Icons.check,
            size: 30,
          ),
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
