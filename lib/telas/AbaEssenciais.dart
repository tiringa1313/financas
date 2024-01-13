import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AbaEssenciais extends StatefulWidget {
  const AbaEssenciais({Key? key}) : super(key: key);

  @override
  State<AbaEssenciais> createState() => _AbaEssenciaisState();
}

class _AbaEssenciaisState extends State<AbaEssenciais> {
  String? selectedValue;
  List<String> subcategories = [];

  // Mapa que liga os nomes das categorias aos seus IDs no Firebase
  final Map<String, String> categoriaParaId = {
    'Habitação': 'habitacao',
    'Transporte': 'transporte',
    'Saúde': 'saude',
    'Despesas Pessoais': 'despesasPessoais',
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
                  items: categoriaParaId.keys.map((String categoria) {
                    return DropdownMenuItem<String>(
                      value: categoria,
                      child: Text(categoria,
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
          SizedBox(height: 12),
          // Listagem de Subcategorias com borda
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 10.0),
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFF496634)),
                borderRadius: BorderRadius.circular(25.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25.0),
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
                    Text('Adicionar Subcategoria',
                        style: TextStyle(color: Colors.black)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Aqui você pode implementar o método _buscarSubcategorias
  // e qualquer outra lógica que você precisa.
}
