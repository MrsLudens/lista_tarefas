
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'tarefas_service.dart';

class TarefasPage extends StatefulWidget {
  const TarefasPage({super.key, required this.usuarioId});

  final String usuarioId;

  @override
  State<TarefasPage> createState() => _TarefasPageState();
}

class _TarefasPageState extends State<TarefasPage> {
  final _tituloController = TextEditingController();
  late final _service = TarefasService(widget.usuarioId);
  late final _tarefasStream = _service.listar();

  DateTime? _prazoSelecionado;
  bool _salvando = false;

  String _formatarData(DateTime data) =>
      '${data.day.toString().padLeft(2, '0')}/'
      '${data.month.toString().padLeft(2, '0')}/${data.year}';

  @override
  void dispose() {
    _tituloController.dispose();
    super.dispose();
  }

  void _mostrarErro(String mensagem) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  Future<void> _selecionarPrazo() async {
    final hoje = DateTime.now();

    final data = await showDatePicker(
      context: context,
      initialDate: _prazoSelecionado ?? hoje,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Selecione o prazo da tarefa',
    );

    if (data != null && mounted) {
      setState(() => _prazoSelecionado = data);
    }
  }

  Future<void> _adicionar() async {
    if (_salvando) return;

    final titulo = _tituloController.text.trim();

    if (titulo.isEmpty) {
      _mostrarErro('Digite uma tarefa.');
      return;
    }

    if (_prazoSelecionado == null) {
      _mostrarErro('Selecione o prazo da tarefa.');
      return;
    }

    setState(() => _salvando = true);

    try {
      await _service.adicionar(titulo, _prazoSelecionado!);

      if (mounted) {
        _tituloController.clear();
        setState(() => _prazoSelecionado = null);
      }
    } catch (_) {
      _mostrarErro('Não foi possível salvar a tarefa.');
    } finally {
      if (mounted) {
        setState(() => _salvando = false);
      }
    }
  }

  Future<void> _alterarConclusao(String id, bool concluida) async {
    try {
      await _service.alterarConclusao(id, concluida);
    } catch (_) {
      _mostrarErro('Não foi possível atualizar a tarefa.');
    }
  }

  Future<void> _excluir(String id) async {
    try {
      await _service.excluir(id);
    } catch (_) {
      _mostrarErro('Não foi possível excluir a tarefa.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final hoje = DateTime.now();
    final inicioHoje = DateTime(hoje.year, hoje.month, hoje.day);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas tarefas'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _tituloController,
                  enabled: !_salvando,
                  maxLength: 120,
                  decoration: const InputDecoration(
                    labelText: 'Nova tarefa',
                    hintText: 'Ex.: estudar Flutter',
                    border: OutlineInputBorder(),
                  ),
                ),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _salvando ? null : _selecionarPrazo,
                        icon: const Icon(Icons.calendar_month),
                        label: Text(
                          _prazoSelecionado == null
                              ? 'Selecionar prazo'
                              : 'Prazo: ${_formatarData(_prazoSelecionado!)}',
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    FilledButton.icon(
                      onPressed: _salvando ? null : _adicionar,
                      icon: const Icon(Icons.add),
                      label: const Text('Adicionar'),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: StreamBuilder<
                      QuerySnapshot<Map<String, dynamic>>>(
                    stream: _tarefasStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Center(
                          child: Text('Erro ao carregar tarefas.'),
                        );
                      }

                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final tarefas = snapshot.data!.docs;

                      if (tarefas.isEmpty) {
                        return const Center(
                          child: Text('Nenhuma tarefa cadastrada.'),
                        );
                      }

                      return ListView.builder(
                        itemCount: tarefas.length,
                        itemBuilder: (context, index) {
                          final documento = tarefas[index];
                          final dados = documento.data();

                          final concluida =
                              dados['concluida'] == true;

                          final titulo =
                              dados['titulo'] as String? ?? '';

                          final prazoValor = dados['prazo'];

                          final prazo = prazoValor is Timestamp
                              ? prazoValor.toDate()
                              : null;

                          // Verifica se a tarefa está atrasada.
                          final atrasada = !concluida &&
                              prazo != null &&
                              DateTime(
                                prazo.year,
                                prazo.month,
                                prazo.day,
                              ).isBefore(inicioHoje);

                          return Card(
                            key: ValueKey(documento.id),

                            // Destaca tarefas atrasadas.
                            color: atrasada
                                ? Theme.of(context)
                                    .colorScheme
                                    .errorContainer
                                : null,

                            child: ListTile(
                              leading: Checkbox(
                                value: concluida,
                                onChanged: (valor) {
                                  if (valor != null) {
                                    _alterarConclusao(
                                      documento.id,
                                      valor,
                                    );
                                  }
                                },
                              ),

                              title: Text(
                                titulo,
                                style: TextStyle(
                                  decoration: concluida
                                      ? TextDecoration.lineThrough
                                      : null,
                                  fontWeight: atrasada
                                      ? FontWeight.bold
                                      : null,
                                ),
                              ),

                              // Exibe a data de conclusão.
                              subtitle: Text(
                                prazo == null
                                    ? 'Prazo não informado'
                                    : 'Prazo: ${_formatarData(prazo)}'
                                      '${atrasada ? ' • Atrasada' : ''}',
                              ),

                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Ícone de alerta para atrasadas.
                                  if (atrasada)
                                    const Tooltip(
                                      message: 'Tarefa atrasada',
                                      child: Icon(
                                        Icons.warning_amber_rounded,
                                        color: Colors.red,
                                      ),
                                    ),

                                  IconButton(
                                    tooltip: 'Excluir tarefa',
                                    icon: const Icon(
                                      Icons.delete_outline,
                                    ),
                                    onPressed: () =>
                                        _excluir(documento.id),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
