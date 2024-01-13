import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financas/model/AuthManager.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class Orcamento {
  late double saldoGeral;

  // Construtor
  Orcamento({required this.saldoGeral});
}

class AbaOrcamento extends StatefulWidget {
  const AbaOrcamento({Key? key}) : super(key: key);

  @override
  State<AbaOrcamento> createState() => _AbaOrcamentoState();
}

class _AbaOrcamentoState extends State<AbaOrcamento> {
  late String mesCorrente;
  late Orcamento orcamento;

  double orcamentoEssenciais = 0.00;
  double orcamentoEducacao = 0.00;
  double orcamentoLivres = 0.00;
  double orcamentoProjetos = 0.00;
  double saldo = 0.00;

  bool dataCarregada = false; // Adicione esta flag

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('pt_BR', null);
    mesCorrente = capitalizeFirstLetter(
        DateFormat('MMMM', 'pt_BR').format(DateTime.now()));
    orcamento = Orcamento(saldoGeral: 0.0); // Inicialize o saldo geral

    // Carrega os dados automaticamente ao iniciar a tela
    _consultaFirebase();
    _calculaPercentuais();
    dataCarregada = true; // Define a flag para true

    // Oculta o teclado ao abrir a aba
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if (dataCarregada) {
        FocusManager.instance.primaryFocus?.unfocus();
      }
    });
  }

  String capitalizeFirstLetter(String text) {
    return text[0].toUpperCase() + text.substring(1);
  }

  _consultaFirebase() async {
    // Obter o userId da classe AuthManager
    String? userId = AuthManager.userId;

    try {
      // Substitua 'usuarios' pelo nome da sua coleção no Firestore
      DocumentSnapshot orcamentoDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userId) // Substitua pelo ID do usuário logado
          .get();

      // Verifica se o documento existe antes de acessar o campo 'saldoGeral'
      if (orcamentoDoc.exists) {
        // Converta o valor do campo 'saldoGeral' para double
        double saldoGeral =
            double.tryParse(orcamentoDoc['saldoGeral']?.toString() ?? '0.0') ??
                0.0;

        saldo = saldoGeral;
        _calculaPercentuais();

        // Atualize o objeto 'orcamento' com o novo saldo
        setState(() {
          orcamento = Orcamento(saldoGeral: saldoGeral);
        });

        // Adicionando um print para verificar o saldo geral
        print('Saldo Geral Consultado: ${orcamento.saldoGeral}');
      }
    } catch (e) {
      print('Erro ao consultar o Firebase: $e');
    }
  }

  _calculaPercentuais() async {
    orcamentoEssenciais = 0.55 * saldo;
    orcamentoEducacao = 0.05 * saldo;
    orcamentoLivres = 0.10 * saldo;
    orcamentoProjetos = 0.30 * saldo;
  }

  @override
  Widget build(BuildContext context) {
    // Oculta o teclado
    FocusScope.of(context).unfocus();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 1),
                    child: Column(
                      children: [
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(width: 20),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Mês de referência:  $mesCorrente',
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.start,
                                    ),
                                    SizedBox(height: 100),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(25),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Substitua o ícone pela imagem
                                Image.asset(
                                  'assets/essenciais.png',
                                  width:
                                      60.0, // Ajuste a largura conforme necessário
                                  height:
                                      60.0, // Ajuste a altura conforme necessário
                                ),
                                SizedBox(
                                    width:
                                        20), // Espaçamento entre a imagem e os textos
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Despesas Essenciais:',
                                      style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.start,
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      'R\$ ${orcamentoEssenciais.toStringAsFixed(2)}', // Exibe o valor de orcamentoEssenciais com duas casas decimais
                                      style: TextStyle(fontSize: 16.0),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(25),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Substitua o ícone pela imagem
                                Image.asset(
                                  'assets/educacao.png',
                                  width:
                                      60.0, // Ajuste a largura conforme necessário
                                  height:
                                      60.0, // Ajuste a altura conforme necessário
                                ),
                                SizedBox(
                                    width:
                                        20), // Espaçamento entre a imagem e os textos
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Gastos com Educação:',
                                      style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.start,
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      'R\$ ${orcamentoEducacao.toStringAsFixed(2)}', // Exibe o valor de orcamentoEssenciais com duas casas decimais
                                      style: TextStyle(fontSize: 16.0),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(25),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Substitua o ícone pela imagem
                                Image.asset(
                                  'assets/livres.png',
                                  width:
                                      60.0, // Ajuste a largura conforme necessário
                                  height:
                                      60.0, // Ajuste a altura conforme necessário
                                ),
                                SizedBox(
                                    width:
                                        20), // Espaçamento entre a imagem e os textos
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Gastos Livres:',
                                      style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.start,
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      'R\$ ${orcamentoLivres.toStringAsFixed(2)}', // Exibe o valor de orcamentoEssenciais com duas casas decimais
                                      style: TextStyle(fontSize: 16.0),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(25),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Substitua o ícone pela imagem
                                Image.asset(
                                  'assets/projetos.png',
                                  width:
                                      60.0, // Ajuste a largura conforme necessário
                                  height:
                                      60.0, // Ajuste a altura conforme necessário
                                ),
                                SizedBox(
                                    width:
                                        20), // Espaçamento entre a imagem e os textos
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Meus Projetos:',
                                      style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.start,
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      'R\$ ${orcamentoProjetos.toStringAsFixed(2)}', // Exibe o valor de orcamentoEssenciais com duas casas decimais
                                      style: TextStyle(fontSize: 16.0),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
