import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'login.dart'; // Importe seu arquivo de login1
import 'firebase_options.dart'; // Importe suas opções de Firebase

// Defina o RouteObserver
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
    return MaterialApp(
      home: const Login(),
      navigatorObservers: [routeObserver], // Adicione o RouteObserver aqui
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
    );
  }
}

// chave de acesso api de financas
// FOSHDAEXRB0SLCQ7

// cor de alerta 
// cor de alerta"