import 'package:financas/Home.dart';
import 'package:financas/interface/DespesasProvider.dart';
import 'package:financas/telas/AbaResumoGeral.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importe o pacote provider
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Certifique-se de ter configurado corretamente este arquivo
import 'Despesas.dart'; // Importe o arquivo despesas.dart aqui

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebaseApp();
  runApp(Financas());
}

Future<void> initializeFirebaseApp() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class Financas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Inicialize as informações de localização para 'pt_BR'
    initializeDateFormatting('pt_BR');
    return ChangeNotifierProvider(
      // Esta linha deve funcionar agora após a importação correta
      create: (context) => DespesasProvider(),
      child: MaterialApp(
        home: const Home(), // Ajuste o nome da sua tela de login se necessário
        navigatorObservers: [routeObserver],
        theme: ThemeData(
          primaryColor: const Color(0xFFB8D9A0), // Cor primária (verde)
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFB8D9A0), // Cor primária (verde)
            secondary: Color(0xFFF29A2E), // Cor secundária (laranja)
          ),
          inputDecorationTheme: InputDecorationTheme(
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFFB8D9A0)),
              borderRadius: BorderRadius.circular(100),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide:
                  const BorderSide(color: Color.fromARGB(255, 82, 190, 86)),
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('pt', 'BR'), // Português Brasil
        ],
        routes: {
          '/despesas': (context) => Home(),
          '/resumo-geral': (context) => AbaResumoGeral(
                onUpdate: () {},
                onDespesaAdicionada: () {},
              ),
        },
      ),
    );
  }
}


// chave de acesso api de financas
// FOSHDAEXRB0SLCQ7

// cor de alerta 
// cor de alerta"