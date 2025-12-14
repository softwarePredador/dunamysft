# Guia de Migração - FlutterFlow para Clean Architecture

## Status da Migração

### ✅ Estrutura Completa Implementada

A estrutura completa de Clean Architecture foi criada com todos os componentes essenciais:

### 📁 Estrutura de Pastas

```
lib/
├── core/                           ✅ COMPLETO
│   ├── constants/
│   │   ├── api_constants.dart     ✅ Configurações de API e Firebase
│   │   ├── assets.dart            ✅ Paths de assets
│   │   └── strings.dart           ✅ Strings da aplicação
│   ├── theme/
│   │   └── app_theme.dart         ✅ Tema da aplicação
│   └── utils/
│       ├── formatters.dart        ✅ Formatadores de data, moeda, etc.
│       ├── helpers.dart           ✅ Funções auxiliares
│       └── validators.dart        ✅ Validadores de formulário
│
├── data/                           ✅ COMPLETO
│   ├── models/
│   │   ├── reservation_model.dart ✅ Modelo de reservas
│   │   ├── room_model.dart        ✅ Modelo de quartos
│   │   └── user_model.dart        ✅ Modelo de usuário
│   ├── repositories/
│   │   ├── firebase_reservation_repository.dart ✅ Implementação
│   │   └── firebase_user_repository.dart        ✅ Implementação
│   └── services/
│       └── auth_service.dart      ✅ Serviço de autenticação
│
├── domain/                         ✅ COMPLETO
│   ├── entities/
│   │   └── user.dart              ✅ Entidade de negócio
│   └── repositories/
│       ├── reservation_repository.dart ✅ Interface
│       ├── room_repository.dart        ✅ Interface
│       └── user_repository.dart        ✅ Interface
│
├── presentation/                   ✅ COMPLETO
│   ├── providers/
│   │   ├── reservation_provider.dart ✅ State management
│   │   ├── theme_provider.dart       ✅ State management
│   │   └── user_provider.dart        ✅ State management
│   ├── screens/
│   │   ├── home/
│   │   │   └── home_screen.dart      ✅ Tela inicial
│   │   ├── login/
│   │   │   └── login_screen.dart     ✅ Tela de login
│   │   └── splash/
│   │       └── splash_screen.dart    ✅ Tela splash
│   └── widgets/
│       ├── common_widgets.dart       ✅ Widgets comuns
│       ├── custom_button.dart        ✅ Botões customizados
│       └── custom_text_field.dart    ✅ Campos de texto
│
└── main.dart                       ✅ Configuração completa
```

## 🎯 Componentes Implementados

### 1. Core Layer
- **✅ Constants**: Strings, API configs, Assets paths
- **✅ Theme**: Cores e fontes configuradas com Google Fonts
- **✅ Utils**: 
  - Validators (email, senha, CPF, telefone)
  - Formatters (moeda, data, telefone, CPF)
  - Helpers (snackbars, dialogs, verificações de device)

### 2. Data Layer
- **✅ Models** (com null safety):
  - UserModel (fromJson/toJson, copyWith)
  - ReservationModel (com enum de status)
  - RoomModel (com enum de tipo)
- **✅ Repositories**:
  - FirebaseUserRepository
  - FirebaseReservationRepository
- **✅ Services**:
  - AuthService (Google & Apple Sign-In)

### 3. Domain Layer
- **✅ Entities**: User entity (pura, sem dependências)
- **✅ Repository Interfaces**: Contratos para User, Reservation, Room

### 4. Presentation Layer
- **✅ Providers**:
  - UserProvider (gerenciamento de usuário)
  - ReservationProvider (gerenciamento de reservas)
  - ThemeProvider (tema claro/escuro)
- **✅ Screens**:
  - SplashScreen
  - LoginScreen (Google & Apple)
  - HomeScreen (exemplo completo)
- **✅ Widgets Reutilizáveis**:
  - PrimaryButton, SecondaryButton
  - CustomTextField
  - CustomCard
  - LoadingIndicator
  - EmptyState
  - ErrorState

## 📝 Próximos Passos

### Screens a Migrar (Quando disponível código FlutterFlow)

1. **Tela de Quartos** (`rooms_screen.dart`)
   - Listagem de quartos disponíveis
   - Filtros e busca
   - Detalhes do quarto

2. **Tela de Reservas** (`reservations_screen.dart`)
   - Minhas reservas
   - Histórico
   - Detalhes da reserva

3. **Tela de Perfil** (`profile_screen.dart`)
   - Edição de dados
   - Foto de perfil
   - Configurações

### Como Adicionar Novas Telas

1. **Criar a pasta da tela**:
```bash
mkdir -p lib/presentation/screens/nome_tela
```

2. **Criar o arquivo da tela**:
```dart
// lib/presentation/screens/nome_tela/nome_tela_screen.dart
import 'package:flutter/material.dart';

class NomeTela Screen extends StatelessWidget {
  const NomeTelaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nome da Tela')),
      body: const Center(child: Text('Conteúdo')),
    );
  }
}
```

3. **Adicionar rota no main.dart**:
```dart
GoRoute(
  path: '/nome-tela',
  builder: (context, state) => const NomeTelaScreen(),
),
```

### Como Adicionar Novos Providers

1. **Criar o provider**:
```dart
// lib/presentation/providers/feature_provider.dart
import 'package:flutter/foundation.dart';

class FeatureProvider extends ChangeNotifier {
  // Estado
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Métodos
  Future<void> doSomething() async {
    _isLoading = true;
    notifyListeners();
    
    // Lógica aqui
    
    _isLoading = false;
    notifyListeners();
  }
}
```

2. **Registrar no main.dart**:
```dart
MultiProvider(
  providers: [
    Provider<AuthService>(create: (_) => FirebaseAuthService()),
    ChangeNotifierProvider(create: (_) => FeatureProvider()),
  ],
  child: const MyApp(),
)
```

## 🔧 Utilities Disponíveis

### Validators
```dart
import 'package:dunamys/core/utils/validators.dart';

// Email
Validators.email(emailController.text);

// Senha
Validators.password(passwordController.text, minLength: 8);

// CPF
Validators.cpf(cpfController.text);

// Telefone
Validators.phone(phoneController.text);
```

### Formatters
```dart
import 'package:dunamys/core/utils/formatters.dart';

// Moeda
Formatters.currency(150.50); // R$ 150,50

// Data
Formatters.date(DateTime.now()); // 14/12/2025

// Telefone
Formatters.phone('11987654321'); // (11) 98765-4321
```

### Helpers
```dart
import 'package:dunamys/core/utils/helpers.dart';

// Mostrar erro
Helpers.showError(context, 'Mensagem de erro');

// Mostrar sucesso
Helpers.showSuccess(context, 'Operação realizada!');

// Dialog de confirmação
final confirmed = await Helpers.showConfirmDialog(
  context,
  title: 'Confirmar',
  message: 'Deseja continuar?',
);
```

## 📚 Documentação

- **README.md**: Visão geral do projeto
- **ARCHITECTURE.md**: Detalhes da arquitetura e exemplos
- **MIGRATION_GUIDE.md**: Este arquivo

## 🎨 Componentes UI Reutilizáveis

### Botões
```dart
import 'package:dunamys/presentation/widgets/custom_button.dart';

PrimaryButton(
  text: 'Salvar',
  onPressed: () {},
  isLoading: false,
  icon: Icons.save,
)

SecondaryButton(
  text: 'Cancelar',
  onPressed: () {},
)
```

### Campos de Texto
```dart
import 'package:dunamys/presentation/widgets/custom_text_field.dart';

CustomTextField(
  label: 'Email',
  hint: 'Digite seu email',
  controller: emailController,
  validator: Validators.email,
  keyboardType: TextInputType.emailAddress,
  prefixIcon: Icons.email,
)
```

### Estados Comuns
```dart
import 'package:dunamys/presentation/widgets/common_widgets.dart';

// Loading
LoadingIndicator(message: 'Carregando...')

// Empty
EmptyState(
  icon: Icons.inbox,
  message: 'Nenhum item encontrado',
  actionText: 'Adicionar',
  onAction: () {},
)

// Error
ErrorState(
  message: 'Erro ao carregar dados',
  onRetry: () {},
)
```

## ✅ Checklist de Migração

### Setup Inicial
- [x] Estrutura de pastas criada
- [x] Core layer completo
- [x] Data layer completo
- [x] Domain layer completo
- [x] Presentation layer base
- [x] Documentação criada

### Screens
- [x] Splash Screen
- [x] Login Screen
- [x] Home Screen
- [ ] Rooms Screen
- [ ] Reservations Screen
- [ ] Profile Screen

### Features
- [x] Autenticação (Google & Apple)
- [x] Navegação (GoRouter)
- [x] State Management (Provider)
- [x] Theme customizado
- [ ] Listagem de quartos
- [ ] Sistema de reservas
- [ ] Perfil de usuário

## 🚀 Como Executar

```bash
# Instalar dependências
flutter pub get

# Executar em desenvolvimento
flutter run

# Build para produção
flutter build apk # Android
flutter build ios # iOS
flutter build web # Web
```

## 📞 Suporte

Para dúvidas sobre a arquitetura, consulte:
1. Este guia de migração
2. ARCHITECTURE.md para detalhes técnicos
3. README.md para visão geral do projeto
