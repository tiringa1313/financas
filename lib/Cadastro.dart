import 'package:financas/Home.dart';
import 'package:financas/model/Usuario.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Cadastro extends StatefulWidget {
  const Cadastro({super.key});

  @override
  State<Cadastro> createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
// Controladores responsaveis para capturar o que vai ser digitado pelo usuario

  TextEditingController _controllerNome = TextEditingController();
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();
  // ignore: unused_field
  String _mensagemErro = "";

//************************ metodo para validar os campos ***********************************
  _validarCampos() {
    //Recupera dados dos campos
    String nome = _controllerNome.text;
    String email = _controllerEmail.text;
    String senha = _controllerSenha.text;

    // inicia validacao
    if (nome.isNotEmpty && nome.length > 3) {
      // se o nome nao for vazio e nome menor que 3 caracterres
      if (email.isNotEmpty && email.contains("@")) {
        // se o email nao for vazio e email contem o "@"
        if (senha.isNotEmpty && senha.length > 6) {
          // se senha nao for vazia e tamanho menor q 6 caracteres

          Usuario usuario =
              Usuario(nome, email, senha, ""); // cria um objeto usuario
          usuario.nome = nome;
          usuario.email = email;
          usuario.senha = senha;

          // chama o metodo para cadastrar um usuario no Firebase
          _cadastrarUsuario(usuario);

          setState(() {
            _mensagemErro =
                "Cadastro realizado com sucesso!!"; // exibe a mgs que deu certo o cadastro
          });
        } else {
          // caso a senha esteja vazia exibe a msg para o usuario
          setState(() {
            _mensagemErro =
                "Campo senha obrigatorio!! digite mais de 6 caracteres!";
          });
        }
      } else {
        // caso o email esteja vazia exibe a msg para o usuario
        setState(() {
          _mensagemErro = "Utilize um email valido";
        });
      }
    } else {
      // caso o nome esteja vazia exibe a msg para o usuario
      setState(() {
        _mensagemErro = "Preencha o campo Nome";
      });
    }
  }

  // metodo responsavel para cadastrar o usuario no firebase passando o objeto Usuario por parametro

  _cadastrarUsuario(Usuario usuario) {
    FirebaseAuth auth = FirebaseAuth.instance;

    auth
        .createUserWithEmailAndPassword(
            email: usuario.email, password: usuario.senha)
        .then((firebaseUser) {
      FirebaseFirestore db = FirebaseFirestore.instance;

      // Inclua o campo 'saldoGeral' no mapa antes de salvar no Firestore
      Map<String, dynamic> dadosUsuario = usuario.toMap();
      dadosUsuario['saldoGeral'] = '0,00';

      db.collection("usuarios").doc(firebaseUser.user?.uid).set(dadosUsuario);

      Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
    }).catchError((error) {
      setState(() {
        _mensagemErro = "Erro ao realizar cadastro";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cadastro"),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFB8D9A0),
        ),
        padding: const EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.only(bottom: 35),
                  child: Image(
                      image: AssetImage('assets/cadastro.png'),
                      width: 300,
                      height: 250),
                ),
                Padding(
                  // campo de texto nome
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: _controllerNome,
                    autofocus: true,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: "Informe seu nome",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: _controllerEmail,
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
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: _controllerSenha,
                    autofocus: true,
                    obscureText: true,
                    keyboardType: TextInputType.text,
                    style: const TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: "Crie uma senha",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 10),
                  child: ElevatedButton(
                    // ignore: sort_child_properties_last
                    child: const Text(
                      "Cadastrar",
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
                      //cria- se um metodo para validar os campos informados pelo usuario
                      _validarCampos();
                      // acao quando clicar no botao entrar
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
