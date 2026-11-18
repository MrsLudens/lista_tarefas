import 'package:cloud_firestore/cloud_firestore.dart';

class TarefasService {
  final String usuarioId;
  late final CollectionReference<Map<String, dynamic>> _tarefas;

  TarefasService(this.usuarioId) {
    _tarefas = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(usuarioId)
        .collection('tarefas');
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> listar() {
    return _tarefas.orderBy('titulo', descending: true).snapshots();
  }

  Future<void> adicionar(String titulo, DateTime prazo) async {
    final texto = titulo.trim();

    if (texto.isEmpty || texto.length > 120) {
      throw ArgumentError('O título deve ter entre 1 e 120 caracteres.');
    }

    final data = DateTime(prazo.year, prazo.month, prazo.day);

    await _tarefas.add({
      'titulo': texto,
      'concluida': false,
      'prazo': Timestamp.fromDate(data),
      'criadaEm': FieldValue.serverTimestamp(),
    });
  }

  Future<void> alterarConclusao(String id, bool concluida) {
    return _tarefas.doc(id).update({'concluida': concluida});
  }

  Future<void> excluir(String id) {
    return _tarefas.doc(id).delete();
  }
}