import 'package:financas/Categorias.dart';
import 'package:financas/Login.dart';
import 'package:financas/Receitas.dart';
import 'package:financas/model/AuthManager.dart';
import 'package:financas/Despesas.dart';
import 'package:financas/model/FirebaseService.dart';
import 'package:flutter/material.dart';
import 'package:financas/Categorias.dart';
import 'package:financas/Login.dart';
import 'package:financas/Receitas.dart';
import 'package:financas/model/AuthManager.dart';
import 'package:financas/Despesas.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

import 'package:flutter/material.dart';

class AbaResumoGeral extends StatefulWidget {
  final VoidCallback onUpdate; // Definição do callback onUpdate

  const AbaResumoGeral({Key? key, required this.onUpdate}) : super(key: key);

  @override
  State<AbaResumoGeral> createState() => _AbaResumoGeralState();
}

class _AbaResumoGeralState extends State<AbaResumoGeral> with RouteAware {
  double? _saldoGeral;
  double? _totalEssenciais;
  double? _totalEducacao;
  double? _totalLivres;
  final FocusNode _focusNode = FocusNode();
  double percentSpentEssenciais = 0.0; // Inicialize com 0.0
  double percentSpentEducacao = 0.0; // Inicialize com 0.0
  double percentSpentLivre = 0.0; // Inicialize com 0.0

  @override
  void initState() {
    super.initState();
    // Chama o método para buscar o saldo geral quando o estado do widget é inicializado
    buscarSaldoGeral();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Registra o observador de rota
    RouteObserver<PageRoute>()
        .subscribe(this, ModalRoute.of(context)! as PageRoute<dynamic>);
  }

  @override
  void dispose() {
    // Cancela o registro do observador de rota
    RouteObserver<PageRoute>().unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Chama o método para buscar o saldo geral quando voltar para esta tela
    buscarSaldoGeral();
  }

  // Método para buscar saldo geral
  void buscarSaldoGeral() async {
    String? userId = AuthManager.userId;

    if (userId == null) {
      print('Usuário não autenticado!');
      return;
    }

    try {
      FirebaseService firebaseService = FirebaseService('usuarios');

      // Busca o saldo geral do usuário
      String saldoGeralString =
          await firebaseService.buscarSaldoGeralUsuario(userId);
      _saldoGeral = double.parse(saldoGeralString);

      // Busca os totais de despesas
      String totalEssenciaisString = await firebaseService.buscarTotalDespesas(
          userId, "despesasEssenciais");
      double totalEssenciais = double.parse(totalEssenciaisString);

      String totalEducacaoString =
          await firebaseService.buscarTotalDespesas(userId, "despesasEducacao");
      double totalEducacao = double.parse(totalEducacaoString);

      String totalLivresString =
          await firebaseService.buscarTotalDespesas(userId, "despesasLivres");
      double totalLivres = double.parse(totalLivresString);

      // Todos os cálculos e atualizações de estado são realizados dentro do setState para garantir que a interface reflita as mudanças.

      setState(() {
        // Calcula o orçamento
        _totalEssenciais = 0.55 * _saldoGeral!;
        _totalEducacao = 0.05 * _saldoGeral!;
        _totalLivres = 0.10 * _saldoGeral!;

        // Calcula a porcentagem de despesas
        percentSpentEssenciais = (totalEssenciais / _totalEssenciais!) * 100;
        percentSpentEducacao = (totalEducacao / _totalEducacao!) * 100;
        percentSpentLivre = (totalLivres / _totalLivres!) * 100;

        // Garante que o percentual não seja superior a 100%
        percentSpentEssenciais = percentSpentEssenciais.clamp(0, 100);
        percentSpentEducacao = percentSpentEducacao.clamp(0, 100);
        percentSpentLivre = percentSpentLivre.clamp(0, 100);

        // Chama o callback para atualizar a aba
        widget.onUpdate();
      });
    } catch (e) {
      print('Erro ao buscar o saldo geral do usuário: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Margem superior para a barra de progresso
          SizedBox(height: 24.0),

          // Adicione um texto acima da barra de progresso
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'Gastos Essenciais:',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF425932),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Container(
            margin: EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 6.0), // Ajuste a margem vertical conforme necessário
            child: LinearProgressIndicator(
              value: percentSpentEssenciais / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC6E3AF)),
              minHeight: 22,
              borderRadius: BorderRadius.circular(24),
            ),
          ),

          // Margem superior para a barra de progresso
          SizedBox(height: 16.0),

          // Adicione um texto acima da barra de progresso
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'Gastos Educação:',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF425932),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Container(
            margin: EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 6.0), // Ajuste a margem vertical conforme necessário
            child: LinearProgressIndicator(
              value: percentSpentEducacao / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC6E3AF)),
              minHeight: 22,
              borderRadius: BorderRadius.circular(24),
            ),
          ),

          // Margem superior para a barra de progresso
          SizedBox(height: 16.0),

          // Adicione um texto acima da barra de progresso
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'Gastos Livres:',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF425932),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Container(
            margin: EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 6.0), // Ajuste a margem vertical conforme necessário
            child: LinearProgressIndicator(
              value: percentSpentLivre / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC6E3AF)),
              minHeight: 22,
              borderRadius: BorderRadius.circular(24),
            ),
          ),

          // Espaçamento entre a barra de progresso e os Cards
          SizedBox(height: 12),
          // Adicione um espaço flexível para empurrar o Card para a parte inferior
          Expanded(child: Container()),

          Container(
            height:
                150, // Ajuste a altura dos Cards inferiores conforme necessário
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // Primeiro Card
                GestureDetector(
                  onTap: () async {
                    // Remove o foco para ocultar o teclado
                    _focusNode.unfocus();
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Receitas()),
                    );
                    // Após voltar da tela de receitas, atualize os dados
                    buscarSaldoGeral();
                  },
                  child: Card(
                    child: Container(
                      width: 150,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: Image.asset(
                                'assets/receitas.png',
                                width: 45,
                                height: 45,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Receitas',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Segundo Card
                GestureDetector(
                  onTap: () {
                    // Remove o foco para ocultar o teclado
                    _focusNode.unfocus();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Despesas(
                                onUpdate: () {},
                              )),
                    );
                  },
                  child: Card(
                    child: Container(
                      width: 150,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: Image.asset(
                                'assets/despesas.png',
                                width: 50,
                                height: 50,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Despesas',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Espaçamento entre os Cards
                SizedBox(width: 6),

                // Card Categorias
                GestureDetector(
                  onTap: () {
                    // Remove o foco para ocultar o teclado
                    _focusNode.unfocus();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Categorias()),
                    );
                  },
                  child: Card(
                    child: Container(
                      width: 150,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: Image.asset(
                                'assets/categorias.png',
                                width: 48,
                                height: 45,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Categorias',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Espaçamento entre os Cards
                SizedBox(width: 6),

                // Card Metas/Projetos
                GestureDetector(
                  onTap: () {
                    // Remove o foco para ocultar o teclado
                  },
                  child: Card(
                    child: Container(
                      width: 150,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: Image.asset(
                                'assets/metas.png',
                                width: 48,
                                height: 45,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Projetos',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Espaçamento entre os Cards
                SizedBox(width: 6),

                // Quarto Card
                GestureDetector(
                  onTap: () {
                    // Substitua pelo widget desejado ao clicar
                  },
                  child: Card(
                    child: Container(
                      width: 150,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: Image.asset(
                                'assets/transferencia.png',
                                width: 50,
                                height: 50,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Transferências',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Espaçamento entre os Cards
                SizedBox(width: 6),

                // Quinto Card
                GestureDetector(
                  onTap: () async {
                    await AuthManager.signOut();
                    // Após o logout, redirecione o usuário para a tela de login ou inicial
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                          builder: (context) =>
                              Login()), // Substitua TelaDeLogin pela sua tela de login
                    );
                  },
                  child: Card(
                    child: Container(
                      width: 150,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: Image.asset(
                                'assets/sair.png',
                                width: 50,
                                height: 50,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Sair',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
