import 'package:financas/model/Usuario.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthManager {
  static String? _userId;

  static String? get userId => _userId;

  static Future<void> loginUser(Usuario usuario) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: usuario.email,
        password: usuario.senha,
      );

      _userId = userCredential.user?.uid;
    } catch (error) {
      print("Erro ao realizar login: $error");
      _userId = null;
    }
  }

  static Future<void> checkLoggedInUser() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? currentUser = auth.currentUser;

    if (currentUser != null) {
      _userId = currentUser.uid;
    } else {
      _userId = null;
    }
  }

  static Future<void> signOut() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();
    _userId = null;
  }
}
