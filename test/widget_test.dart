import 'package:flutter_test/flutter_test.dart';
import 'package:lista_tarefas/main.dart' as app;

void main() {
  testWidgets('mostra orientação quando o Firebase não foi configurado', (
    tester,
  ) async {
    // O arquivo provisório de opções lança um erro antes de acessar a rede.
    await app.main();
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Não foi possível conectar ao Firebase'),
      findsOneWidget,
    );
  });
}
