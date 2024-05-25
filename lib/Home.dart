import 'package:financas/telas/AbaOrcamento.dart';
import 'package:financas/telas/AbaResumoGeral.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Importe esta biblioteca

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Minhas Finanças",
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
          labelColor: Color(0xFF425932),
          unselectedLabelColor: Colors.white,
          controller: _tabController,
          indicatorColor: Color(0xFF425932),
          tabs: <Widget>[Tab(text: "Resumo Geral"), Tab(text: "Orçamento")],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          AbaResumoGeral(
            onUpdate: () {
              if (_tabController.index == 0) {
                // Verifica se a aba ativa é "Resumo Geral"
                setState(() {});
              }
            },
            onDespesaAdicionada: () {
              if (_tabController.index == 0) {
                // Verifica se a aba ativa é "Resumo Geral"
                setState(() {});
              }
            },
          ),
          AbaOrcamento(),
        ],
      ),
    );
  }
}
