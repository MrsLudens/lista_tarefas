import 'package:flutter/material.dart';
import 'package:lista_tarefas/tarefas_page.dart';

class TarefasApp extends StatelessWidget {
  const TarefasApp({super.key, required this.usuarioId});

  final String usuarioId;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minhas tarefas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: TarefasPage(usuarioId: usuarioId),
    );
  }
}
