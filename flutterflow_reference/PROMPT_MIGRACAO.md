# Instruções de Migração: FlutterFlow para Clean Architecture

**Contexto:**
Estamos migrando um projeto legado gerado pelo FlutterFlow (localizado na pasta `./flutterflow_reference`) para uma nova estrutura profissional e limpa na raiz do projeto.

**Objetivo:**
Reescrever o aplicativo utilizando boas práticas, Clean Architecture e Null Safety, removendo todas as dependências proprietárias do FlutterFlow (`flutter_flow_theme.dart`, `flutter_flow_util.dart`, etc.).

**Estrutura do Novo Projeto (Target):**
```text
lib/
├── core/
│   ├── constants/      # Strings, Assets paths
│   ├── theme/          # AppTheme (Cores e Fontes migradas)
│   └── utils/          # Formatadores de data, moeda, validadores
├── data/
│   ├── models/         # Modelos puros (sem dependência de UI)
│   └── services/       # FirebaseService, AuthService, ApiService
├── presentation/
│   ├── widgets/        # Componentes reutilizáveis (Botões, Inputs)
│   └── screens/        # Telas do app (Uma pasta por tela)
│       ├── login/
│       ├── home/
│       └── order_detail/
└── main.dart
```

**Regras de Migração (Estritas):**

1.  **NÃO COPIE E COLE:** Nunca copie arquivos inteiros da pasta `flutterflow_reference`. Leia a lógica e reescreva usando Dart padrão.
2.  **Remova Dependências do FF:**
    *   Substitua `FlutterFlowTheme` por `Theme.of(context)` ou nossa classe `AppTheme`.
    *   Substitua `FlutterFlowIconButton` por `IconButton`.
    *   Substitua `backend.dart` por chamadas diretas ao `FirebaseFirestore` ou nossos Services.
3.  **Null Safety:** Todo o código novo deve ser fortemente tipado e protegido contra nulos. (Ex: Tratar campos opcionais do Firebase).
4.  **Gerenciamento de Estado:** Use `Provider` ou `ValueNotifier` para estados simples. Evite a complexidade desnecessária do código gerado.
5.  **Navegação:** Use `GoRouter` configurado no `main.dart`, ignorando o `nav.dart` antigo.

**Fluxo de Trabalho:**
Quando eu pedir para migrar uma funcionalidade (ex: "Migre a tela de Detalhes do Pedido"):
1.  Analise o arquivo correspondente em `flutterflow_reference/lib/...`.
2.  Identifique quais Models e Services são necessários.
3.  Crie/Atualize os arquivos em `lib/data/`.
4.  Crie a tela em `lib/presentation/screens/` usando Widgets nativos do Flutter (`Column`, `Row`, `Container`, `ListView`).
