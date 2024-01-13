import 'package:financas/Categorias.dart';
import 'package:financas/Login.dart';
import 'package:financas/Receitas.dart';
import 'package:financas/model/AuthManager.dart';
import 'package:financas/Despesas.dart';
import 'package:flutter/material.dart';

class AbaResumoGeral extends StatefulWidget {
  const AbaResumoGeral({Key? key}) : super(key: key);

  @override
  State<AbaResumoGeral> createState() => _AbaResumoGeralState();
}

class _AbaResumoGeralState extends State<AbaResumoGeral> {
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Conteúdo principal aqui

          // Adicione um espaço flexível para empurrar o Card para a parte inferior
          Expanded(child: Container()),

          // Lista horizontal de Cards na parte inferior
          Container(
            height: 150, // Ajuste a altura dos Cards conforme necessário
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

                // card categorias
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

                // Card METAS / PROJETOS
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