import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AbaEducacao extends StatefulWidget {
  const AbaEducacao({super.key});

  @override
  State<AbaEducacao> createState() => _AbaEducacaoState();
}

class _AbaEducacaoState extends State<AbaEducacao> {
  String? selectedValue;
  List<String> subcategories = []; // Lista de subcategorias

  // Mapa que liga os nomes das categorias aos seus IDs no Firebase
  final Map<String, String> categoriaParaId = {
    'Educação': 'educacao', // Substitua 'lazerId' pelo ID real no Firebase
    'Outros Gastos':
        'outrosGastosEducacao', // Substitua 'outrosLivresId' pelo ID real no Firebase
    // Adicione outros mapeamentos aqui se necessário
  };

  void buscarSubcategorias(String categoriaSelecionada) async {
    String? docId = categoriaParaId[categoriaSelecionada];
    if (docId == null) {
      print(
          "ID do documento não encontrado para a categoria: $categoriaSelecionada");
      return;
    }

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference documentoCategoria =
        firestore.collection('categoriasOrganizadas').doc(docId);

    try {
      DocumentSnapshot docSnapshot = await documentoCategoria.get();
      if (docSnapshot.exists) {
        Map<String, dynamic> dados = docSnapshot.data() as Map<String, dynamic>;
        List<String> tempSubcategorias = dados.keys.toList();
        setState(() {
          subcategories = tempSubcategorias;
        });
      } else {
        print("Documento não encontrado: $docId");
      }
    } catch (e) {
      print("Erro ao buscar subcategorias: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> dropdownItems = [
      'Educação',
      'Outros Gastos',
    ];

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFF496634)),
                borderRadius: BorderRadius.circular(25.0),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: selectedValue,
                  hint: Text("Selecione uma subcategoria"),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedValue = newValue;
                      buscarSubcategorias(newValue!);
                    });
                  },
                  items: dropdownItems
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    );
                  }).toList(),
                  style: TextStyle(color: Colors.black, fontSize: 16),
                  icon: Icon(Icons.arrow_drop_down, color: Colors.grey),
                  iconSize: 24.0,
                  dropdownColor: Colors.white,
                  elevation: 16,
                ),
              ),
            ),
          ),
          // Espaço entre o menu de seleção e a listagem de subcategorias
          SizedBox(height: 12), // Ajuste este valor conforme necessário
          // Listagem de Subcategorias com borda
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 10.0), // Margem lateral
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFF496634)), // Cor da borda
                borderRadius: BorderRadius.circular(25.0), // Raio da borda
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                    25.0), // Raio da borda para o ListView
                child: ListView.builder(
                  itemCount: subcategories.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(subcategories[index]),
                    );
                  },
                ),
              ),
            ),
          ),

          // Botão para adicionar subcategoria
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 35.0, vertical: 30.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Aqui você deve adicionar a lógica para adicionar uma nova subcategoria
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, color: Colors.black),
                    SizedBox(width: 5),
                    Text('Subcategoria', style: TextStyle(color: Colors.black)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
