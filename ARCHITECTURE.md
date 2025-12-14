# Clean Architecture - Dunamys Project

## Camadas da Arquitetura

```
┌─────────────────────────────────────────────────────────┐
│                   PRESENTATION LAYER                     │
│  ┌─────────────┐  ┌──────────────┐  ┌───────────────┐  │
│  │   Screens   │  │   Providers  │  │    Widgets    │  │
│  │  (UI Views) │  │(State Mgmt)  │  │ (Reusable UI) │  │
│  └─────────────┘  └──────────────┘  └───────────────┘  │
└─────────────────────────────────────────────────────────┘
                          ↓ ↑
┌─────────────────────────────────────────────────────────┐
│                     DOMAIN LAYER                        │
│  ┌─────────────────────┐  ┌────────────────────────┐   │
│  │     Entities        │  │  Repository Interfaces │   │
│  │ (Business Objects)  │  │   (Contracts)         │   │
│  └─────────────────────┘  └────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
                          ↓ ↑
┌─────────────────────────────────────────────────────────┐
│                      DATA LAYER                         │
│  ┌────────────┐  ┌──────────────────┐  ┌────────────┐  │
│  │   Models   │  │   Repositories   │  │  Services  │  │
│  │(Data DTOs) │  │(Implementations) │  │ (External) │  │
│  └────────────┘  └──────────────────┘  └────────────┘  │
└─────────────────────────────────────────────────────────┘
                          ↓ ↑
┌─────────────────────────────────────────────────────────┐
│                   EXTERNAL LAYER                        │
│        Firebase, APIs, Local Storage, etc.              │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│                       CORE LAYER                        │
│     Constants, Theme, Utils (Used by all layers)        │
└─────────────────────────────────────────────────────────┘
```

## Fluxo de Dados

### 1. User Interaction → UI Update
```
User taps button
    ↓
Screen calls Provider method
    ↓
Provider calls Repository
    ↓
Repository calls Service/Firebase
    ↓
Data returned to Repository
    ↓
Repository returns Model to Provider
    ↓
Provider updates state (notifyListeners)
    ↓
UI rebuilds with new data
```

## Responsabilidades de Cada Camada

### Presentation Layer
- **Screens**: Páginas completas da aplicação
- **Providers**: Gerenciamento de estado com ChangeNotifier
- **Widgets**: Componentes UI reutilizáveis

**Regra:** Nunca acessa diretamente Services ou Firebase. Sempre usa Providers.

### Domain Layer
- **Entities**: Objetos de negócio puros (sem dependências externas)
- **Repository Interfaces**: Contratos que definem operações de dados

**Regra:** Não depende de frameworks ou bibliotecas externas.

### Data Layer
- **Models**: Classes com serialização JSON (fromJson/toJson)
- **Repositories**: Implementações das interfaces do Domain
- **Services**: Integrações com serviços externos (Firebase, APIs)

**Regra:** Responsável por toda comunicação externa.

### Core Layer
- **Constants**: Strings, rotas, configurações
- **Theme**: Cores, fontes, estilos
- **Utils**: Validators, Formatters, Helpers

**Regra:** Usado por todas as camadas, mas não depende de nenhuma.

## Exemplos de Uso

### Criando uma nova Feature

1. **Criar Model** (Data Layer)
```dart
// lib/data/models/feature_model.dart
class FeatureModel {
  final String id;
  final String name;
  
  FeatureModel({required this.id, required this.name});
  
  factory FeatureModel.fromJson(Map<String, dynamic> json) {
    return FeatureModel(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
```

2. **Criar Repository Interface** (Domain Layer)
```dart
// lib/domain/repositories/feature_repository.dart
abstract class FeatureRepository {
  Future<List<FeatureModel>> getFeatures();
  Future<void> createFeature(FeatureModel feature);
}
```

3. **Implementar Repository** (Data Layer)
```dart
// lib/data/repositories/firebase_feature_repository.dart
class FirebaseFeatureRepository implements FeatureRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  @override
  Future<List<FeatureModel>> getFeatures() async {
    // Implementação...
  }
  
  @override
  Future<void> createFeature(FeatureModel feature) async {
    // Implementação...
  }
}
```

4. **Criar Provider** (Presentation Layer)
```dart
// lib/presentation/providers/feature_provider.dart
class FeatureProvider extends ChangeNotifier {
  final FeatureRepository _repository;
  List<FeatureModel> _features = [];
  
  List<FeatureModel> get features => _features;
  
  Future<void> loadFeatures() async {
    _features = await _repository.getFeatures();
    notifyListeners();
  }
}
```

5. **Usar na Screen** (Presentation Layer)
```dart
// lib/presentation/screens/feature/feature_screen.dart
class FeatureScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FeatureProvider>(context);
    
    return Scaffold(
      body: ListView.builder(
        itemCount: provider.features.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(provider.features[index].name),
          );
        },
      ),
    );
  }
}
```

## Vantagens desta Arquitetura

✅ **Testabilidade**: Cada camada pode ser testada isoladamente
✅ **Manutenibilidade**: Mudanças em uma camada não afetam as outras
✅ **Escalabilidade**: Fácil adicionar novas features
✅ **Independência**: Domain layer não depende de frameworks
✅ **Reusabilidade**: Widgets e utils podem ser reutilizados
✅ **Separação de Responsabilidades**: Cada classe tem uma única responsabilidade

## Regras de Dependência

- Presentation → Domain → Data
- Core pode ser usado por todas as camadas
- Data não conhece Presentation
- Domain não conhece Data nem Presentation
- Sempre depender de abstrações (interfaces) não de implementações

## Nomenclatura

- **Models**: `*_model.dart` (ex: `user_model.dart`)
- **Entities**: Sem sufixo (ex: `user.dart`)
- **Repositories (Interface)**: `*_repository.dart` (ex: `user_repository.dart`)
- **Repositories (Impl)**: `firebase_*_repository.dart` ou `api_*_repository.dart`
- **Providers**: `*_provider.dart` (ex: `user_provider.dart`)
- **Screens**: `*_screen.dart` (ex: `login_screen.dart`)
- **Widgets**: Descritivo (ex: `custom_button.dart`)
