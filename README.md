# Lista de tarefas com Flutter e Firestore

Exemplo didático para adicionar, listar em tempo real, marcar como concluída e excluir tarefas. Usa `setState` para o estado da tela e `StreamBuilder` para acompanhar o Firestore.

## Configurar e executar

O projeto inclui Android, iOS e Web. Para começar, a Web é a opção mais simples. É necessário ter Flutter instalado e acesso a um projeto Firebase. A configuração real do Firebase ainda não está incluída.

1. No [Console Firebase](https://console.firebase.google.com/), crie ou selecione um projeto.
2. Em **Authentication → Sign-in method**, habilite o provedor **Anônimo**.
3. Em **Firestore Database**, crie um banco **Standard**, com ID `(default)`, e escolha a região. Comece no modo de produção.
4. Na aba **Regras** do Firestore, substitua o conteúdo pelo arquivo `firestore.rules` deste projeto e clique em **Publicar**. Essas regras limitam cada lista ao seu proprietário.
5. Instale a [Firebase CLI](https://firebase.google.com/docs/cli), caso ainda não tenha. Depois, no terminal:

```sh
firebase login
dart pub global activate flutterfire_cli
```

6. Na pasta `lista_tarefas`, execute:

```sh
flutter pub get
flutterfire configure
```

Selecione o projeto e as plataformas desejadas. Permita substituir `lib/firebase_options.dart`: o arquivo atual é apenas um marcador que exibe uma orientação de configuração. Se `flutterfire` não for encontrado, adicione a pasta de executáveis do Pub ao PATH (`$HOME/.pub-cache/bin` no Linux/macOS).

7. Execute:

```sh
flutter run -d chrome
```

Para Android, inicie um emulador ou conecte um aparelho e use `flutter run`. Para iOS, é necessário macOS com Xcode e a configuração de assinatura apropriada.

O fluxo de configuração segue a [documentação oficial do Firebase para Flutter](https://firebase.google.com/docs/flutter/setup).

## Como ler o código

- `lib/main.dart`: inicializa o Firebase, recupera/cria a sessão anônima e abre a tela.
- `lib/tarefas_page.dart`: campo de texto, botões e lista; apresenta carregamento, lista vazia e erros.
- `lib/tarefas_service.dart`: concentra `add`, `snapshots`, `update` e `delete`.
- `lib/firebase_options.dart`: configuração gerada pelo FlutterFire CLI.
- `firestore.rules`: regras de acesso e validação dos documentos.

Fluxo: a tela chama o serviço → o serviço grava no Firestore → `snapshots()` emite os documentos → `StreamBuilder` atualiza a lista. Não é necessário consultar o banco manualmente após cada alteração.

## Estrutura do banco

```text
usuarios/{uid}/tarefas/{idGerado}
  titulo: "Estudar Flutter"        (string)
  concluida: false                 (boolean)
  criadaEm: horário do servidor    (timestamp)
```

A coleção surge na primeira gravação; não é preciso criá-la manualmente. As tarefas aparecem da mais recente para a mais antiga. O título aceita até 120 caracteres.

A autenticação anônima mantém a sessão no dispositivo/navegador. Outro navegador terá outra lista. Limpar os dados do aplicativo ou perder a sessão pode impedir o acesso à lista anterior. Para acesso entre dispositivos, uma evolução seria vincular a conta anônima a email/senha ou Google.

## Verificação manual após configurar

1. Adicione uma tarefa e confirme o documento no console do Firestore.
2. Marque e desmarque a tarefa; confira o campo `concluida`.
3. Recarregue o aplicativo no mesmo navegador e confira a persistência.
4. Exclua a tarefa e confira sua remoção no console.
5. Tente adicionar apenas espaços: a tela deve pedir um título.
6. Abra uma janela anônima: ela deve ter uma lista separada.

`flutter analyze` verifica o código. `flutter test` verifica a mensagem inicial de configuração com o arquivo provisório de opções; após conectar um Firebase real, substitua esse teste por testes com Firebase simulado ou emuladores. A integração real precisa da configuração acima para ser validada.
