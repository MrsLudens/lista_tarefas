import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lista_tarefas/tarefas_app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Reutiliza a sessão salva; cria um usuário anônimo na primeira visita.
    final auth = FirebaseAuth.instance;
    final usuario = auth.currentUser ?? (await auth.signInAnonymously()).user!;
    runApp(TarefasApp(usuarioId: usuario.uid));
  } catch (erro) {
    debugPrint('Falha ao iniciar Firebase: $erro');
    runApp(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Não foi possível conectar ao Firebase.\n'
                'Confira a conexão e siga a configuração no README.\n'
                'Depois, reinicie o aplicativo.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

