import 'package:financas/telas/AbaEducacao.dart';
import 'package:financas/telas/AbaEssenciais.dart';
import 'package:financas/telas/AbaLivres.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Categorias extends StatefulWidget {
  @override
  _CategoriasState createState() => _CategoriasState();
}

class _CategoriasState extends State<Categorias>
    with SingleTickerProviderStateMixin {
  final TextEditingController _categoriaController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Adicione aqui outras inicializações, se necessário.
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _recuperarCategorias() async {
    // Seu código para recuperar categorias
  }

  Future<void> _adicionarCategoria() async {
    // Seu código para adicionar categoria
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Categorias",
          style: TextStyle(
            color: const Color.fromARGB(160, 0, 0, 0),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Color(0xFFB8D9A0),
        bottom: TabBar(
          indicatorWeight: 4,
          labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          labelColor: Color(0xFF496634),
          unselectedLabelColor: Colors.white,
          controller: _tabController,
          indicatorColor: Color(0xFF496634),
          tabs: [
            Tab(text: "Essenciais"),
            Tab(text: "Livres"),
            Tab(text: "Educação"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[AbaEssenciais(), AbaLivres(), AbaEducacao()],
      ),
    );
  }
}
