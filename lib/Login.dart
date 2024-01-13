import 'package:financas/Cadastro.dart';
import 'package:financas/Home.dart';
import 'package:financas/model/AuthManager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'model/Usuario.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _controllerEmail = TextEditingController();
  // ignore: prefer_final_fields
  TextEditingController _controllerSenha = TextEditingController();
  String _mensagemErro = "";

  _validarCampos() {
    // Recupera dados dos campos
    String email = _controllerEmail.text;
    String senha = _controllerSenha.text;
    //String saldoGeral = _controllerSenha.text;

    // Inicia validação
    if (email.isNotEmpty && email.contains("@")) {
      // Se o email não for vazio e contém o "@"
      if (senha.isNotEmpty) {
        // Se a senha não for vazia

        // Cria um objeto Usuario utilizando o construtor nomeado semNome
        Usuario usuario = Usuario.semNome(email, senha, "");

        // Chama o método para logar o usuário
        _logarUsuario(usuario);

        /*setState(() {
          _mensagemErro = "Login realizado com sucesso!!";
        });*/
      } else {
        // Caso a senha esteja vazia, exibe a mensagem para o usuário
        setState(() {
          _mensagemErro =
              "Campo senha obrigatório!! Digite mais de 6 caracteres!";
        });
      }
    } else {
      // Caso o email esteja vazio, exibe a mensagem para o usuário
      setState(() {
        _mensagemErro = "Utilize um email válido";
      });
    }
  }

  // Modifique o método _logarUsuario para receber um objeto Usuario
  _logarUsuario(Usuario usuario) async {
    await AuthManager.loginUser(usuario);
    if (AuthManager.userId != null) {
      // Realiza o login e abre a tela Home do app
      Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
    } else {
      setState(() {
        _mensagemErro = "Erro ao realizar login!";
      });
    }
  }

  // verifica se o usuario ja esta logado no app

  Future _verificarUsuarioLogado() async {
    await AuthManager.checkLoggedInUser();

    String? userId = AuthManager.userId;

    if (userId != null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
    }
  }

  @override
  void initState() {
    _verificarUsuarioLogado();
    super.initState();
  }
// ***************************************************Estrutura Layout ****************************************
//*********************************************************************************************************** */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Estilo de fundo para o contêiner
        decoration: const BoxDecoration(
          color: Color(0xFFB8D9A0),
        ),
        padding: const EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Logo da aplicação
                const Padding(
                  padding: EdgeInsets.only(bottom: 35),
                  child: Image(
                      image: AssetImage('assets/logo.png'),
                      width: 250,
                      height: 200),
                ),
                // Campo de texto para inserção do e-mail
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: _controllerEmail,
                    autofocus: true,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: "Informe seu e-mail",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                ),
                // Campo de texto para inserção da senha
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: _controllerSenha,
                    obscureText: true,
                    keyboardType: TextInputType.text,
                    style: const TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: "Senha",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                ),
                // Botão elevado para a ação de login
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 10),
                  child: ElevatedButton(
                    child: const Text(
                      "Entrar",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          const Color(0xFF75BF7A)),
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        const EdgeInsets.fromLTRB(32, 16, 32, 16),
                      ),
                      shape: MaterialStateProperty.all<OutlinedBorder?>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                    ),
                    onPressed: () {
                      // Ação a ser executada quando o botão de login for pressionado
                      _validarCampos();
                    },
                  ),
                ),
                Center(
                  // Texto e ação para "Não possui uma conta? Cadastre-se"
                  child: GestureDetector(
                    child: const Text(
                      "Não possui uma conta? Cadastre-se",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    onTap: () {
                      // Navegação para a tela de cadastro ao tocar no texto
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Cadastro()));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Center(
                    child: Text(
                      _mensagemErro,
                      style: const TextStyle(
                          color: Color.fromARGB(255, 226, 112, 18),
                          fontSize: 20),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
