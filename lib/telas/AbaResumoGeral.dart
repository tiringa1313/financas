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

class AbaResumoGeral extends StatefulWidget {
  const AbaResumoGeral({Key? key}) : super(key: key);

  @override
  State<AbaResumoGeral> createState() => _AbaResumoGeralState();
}

class _AbaResumoGeralState extends State<AbaResumoGeral> {
  double? _saldoGeral;
  double? _totalEssenciais;
  double? _totalEducacao;
  double? _totalLivres;
  final FocusNode _focusNode = FocusNode();
  double percentSpentpercentSpentEssenciais = 0.0; // Inicialize com 0.0
  double percentSpentpercentSpentEducacao = 0.0; // Inicialize com 0.0
  double percentSpentpercentSpentLivre = 0.0; // Inicialize com 0.0

  @override
  void initState() {
    super.initState();
    // Chama o método para buscar o saldo geral quando o estado do widget é inicializado
    buscarSaldoGeral();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Chama o método para buscar o saldo geral sempre que as dependências do widget mudarem
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
      // Criar uma instância do seu serviço Firebase
      FirebaseService firebaseService =
          FirebaseService('usuarios'); // Use 'usuarios' como coleção

      // Buscar o saldo geral do usuário
      // obs: utilizar um MAP para buscar os totais somente em uma chamada para otimizar o tempo
      String saldoGeralString =
          await firebaseService.buscarSaldoGeralUsuario(userId);

      String totalEssenciais = await firebaseService.buscarTotalDespesas(
          userId, "despesasEssenciais");
      String totalEducacao =
          await firebaseService.buscarTotalDespesas(userId, "despesasEducacao");
      String totalLivres =
          await firebaseService.buscarTotalDespesas(userId, "despesasLivres");

      // Converte o saldoGeral String para Double
      _saldoGeral = double.parse(saldoGeralString);

      //converte o total despesas para Double

      _totalEssenciais = double.parse(totalEssenciais);
      _totalEducacao = double.parse(totalEducacao);
      _totalLivres = double.parse(totalLivres);

      print('Saldo Geral Retornado Pelo Firebase $_saldoGeral');

      // Atualizar o percentual de despesas
      // Exemplo: Suponha que você tenha uma variável com o valor total das despesas

      // Calcula o percentual de despesas em relação ao saldo geral

      percentSpentpercentSpentEssenciais =
          (_totalEssenciais! / _saldoGeral!) * 100;
      percentSpentpercentSpentEducacao = (_totalEducacao! / _saldoGeral!) * 100;
      percentSpentpercentSpentLivre = (_totalLivres! / _saldoGeral!) * 100;

      // Garante que o percentual não seja superior a 100%
      percentSpentpercentSpentEssenciais =
          percentSpentpercentSpentEssenciais > 100
              ? 100
              : percentSpentpercentSpentEssenciais;
      percentSpentpercentSpentEducacao = percentSpentpercentSpentEducacao > 100
          ? 100
          : percentSpentpercentSpentEducacao;
      percentSpentpercentSpentLivre = percentSpentpercentSpentLivre > 100
          ? 100
          : percentSpentpercentSpentLivre;

      setState(() {}); // Notifique o Flutter para reconstruir a interface
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
          SizedBox(height: 16.0),

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
              value: percentSpentpercentSpentEssenciais / 100,
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
              value: percentSpentpercentSpentEducacao / 100,
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
              value: percentSpentpercentSpentEducacao / 100,
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
                  onTap: () {
                    // Remove o foco para ocultar o teclado
                    _focusNode.unfocus();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Receitas()),
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

                // Espaçamento entre os Cards
                SizedBox(width: 6),

                // Segundo Card
                GestureDetector(
                  onTap: () {
                    // Remove o foco para ocultar o teclado
                    _focusNode.unfocus();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Despesas()),
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
