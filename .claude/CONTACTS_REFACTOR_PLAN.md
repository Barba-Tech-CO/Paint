# PLANO DE REFATORAÇÃO - MÓDULO DE CONTATOS

## PROBLEMA IDENTIFICADO
O código atual está enviando `name` para a API, mas a documentação especifica que deve ser `firstName` (obrigatório) + `lastName` (opcional). Além disso, está tentando usar GET `/contacts` que está depreciado - deve usar apenas POST `/contacts/search`.

## A) ANTES → DEPOIS (Árvore do Módulo de Contatos)

**ANTES (Estado Atual):**
```
lib/
├── model/contacts/
│   ├── contact_model.dart
│   ├── contact_list_response.dart 
│   ├── contact_search_request.dart
│   ├── create_contact_request.dart
│   ├── update_contact_request.dart
│   └── ghl_contact_model.dart
├── service/
│   ├── contact_service.dart
│   └── contact_database_service.dart
├── data/repository/
│   └── contact_repository_impl.dart
├── domain/repository/
│   └── contact_repository.dart
├── viewmodel/contact/
│   ├── contact_detail_viewmodel.dart
│   └── contact_list_viewmodel.dart
├── viewmodel/contacts/
│   └── contacts_viewmodel.dart
├── view/
│   ├── contacts/contacts_view.dart
│   ├── contact_details/contact_details_view.dart
│   ├── new_contact/new_contact_view.dart
│   └── edit_contact/edit_contact_view.dart
├── widgets/contacts/
│   └── contact_item_widget.dart
└── use_case/contacts/
    ├── contact_operations_use_case.dart
    └── contact_sync_use_case.dart
```

**DEPOIS (Layout MVVM Proposto):**
```
features/contacts/
├── data/
│   ├── datasources/
│   │   ├── contact_remote_datasource.dart (reformulado de contact_service.dart)
│   │   └── contact_local_datasource.dart (reformulado de contact_database_service.dart)
│   ├── models/
│   │   ├── contact_dto.dart (DTOs para API)
│   │   ├── contact_list_dto.dart
│   │   └── contact_search_dto.dart
│   ├── mappers/
│   │   ├── contact_mapper.dart (DTO ↔ Entity)
│   │   └── contact_list_mapper.dart
│   └── repositories/
│       └── contacts_repository_remote.dart (implementação concreta ChangeNotifier)
├── domain/
│   ├── entities/
│   │   └── contact.dart (Entity pura)
│   ├── repositories/
│   │   └── contacts_repository.dart (contrato abstract)
│   └── usecases/
│       ├── get_contacts_usecase.dart (apenas se combinar múltiplos repos)
│       └── sync_contacts_usecase.dart
├── presentation/
│   ├── viewmodels/
│   │   ├── contacts_viewmodel.dart (ChangeNotifier + Commands)
│   │   ├── contact_detail_viewmodel.dart (ChangeNotifier + Commands)
│   │   └── states/
│   │       ├── contacts_state.dart (agrupador de estado)
│   │       └── contact_detail_state.dart
│   ├── views/
│   │   ├── contacts_page.dart
│   │   ├── contact_details_page.dart
│   │   ├── new_contact_page.dart
│   │   └── edit_contact_page.dart
│   └── widgets/
│       ├── contact_item_widget.dart
│       └── contact_form_widget.dart
└── di/
    └── contacts_injection.dart (registro específico do módulo)
```

## B) Tabela de Mapeamento

| **Arquivo/Classe Atual** | **Novo Caminho** | **Notas de Import** |
|---------------------------|------------------|-------------------|
| `lib/model/contacts/contact_model.dart` | `features/contacts/domain/entities/contact.dart` | Entity pura sem serialização |
| `lib/service/contact_service.dart` | `features/contacts/data/datasources/contact_remote_datasource.dart` | Consolidar no MedplusApi |
| `lib/service/contact_database_service.dart` | `features/contacts/data/datasources/contact_local_datasource.dart` | SQLite operations |
| `lib/data/repository/contact_repository_impl.dart` | `features/contacts/data/repositories/contacts_repository_remote.dart` | Extend ChangeNotifier |
| `lib/viewmodel/contact/contact_detail_viewmodel.dart` | `features/contacts/presentation/viewmodels/contact_detail_viewmodel.dart` | + Commands, - StateNotifier |
| `lib/view/contacts/contacts_view.dart` | `features/contacts/presentation/views/contacts_page.dart` | ListenableBuilder |
| **NOVO:** DTOs para API | `features/contacts/data/models/contact_dto.dart` | firstName/lastName split |
| **NOVO:** Mappers | `features/contacts/data/mappers/contact_mapper.dart` | DTO ↔ Entity conversion |

## C) Snippets de DI (GetIt)

```dart
// injector.dart (trechos)

void setupContactsModule() {
  _injectContactsServices();
  _injectContactsRepositories(); 
  _injectContactsUseCases();
  _injectContactsViewModels();
}

void _injectContactsServices() {
  // HTTP Service já registrado globalmente
  i.addLazySingleton<ContactRemoteDataSource>(() => 
    ContactRemoteDataSource(i<MedplusApi>(), i<LocationService>()));
    
  i.addLazySingleton<ContactLocalDataSource>(() => 
    ContactLocalDataSource(i<DatabaseService>()));
}

void _injectContactsRepositories() {
  i.addLazySingleton<ContactsRepository>(() => 
    ContactsRepositoryRemote(i<ContactRemoteDataSource>(), i<ContactLocalDataSource>()));
}

void _injectContactsUseCases() {
  // Criar apenas quando necessário
  i.addLazySingleton<SyncContactsUseCase>(() => 
    SyncContactsUseCase(i<ContactsRepository>()));
}

void _injectContactsViewModels() {
  i.addLazySingleton(() => 
    ContactsViewModel(i<ContactsRepository>()));
    
  i.addLazySingleton(() => 
    ContactDetailViewModel(i<ContactsRepository>()));
}

// Rotas (sem DI nas rotas)
// Em main/bootstrap:
final contactsPage = ContactsPage(viewModel: i<ContactsViewModel>());
final contactDetailPage = ContactDetailPage(viewModel: i<ContactDetailViewModel>());

// Na definição de rotas:
GoRoute(path: '/contacts', builder: (ctx, st) => contactsPage),
GoRoute(path: '/contacts/:id', builder: (ctx, st) => contactDetailPage),
```

## D) Classes Centrais Atualizadas

### 1. ContactsViewModel (esqueleto)
```dart
class ContactsViewModel extends ChangeNotifier {
  final ContactsRepository _repo;
  
  // Commands para operações assíncronas
  late final loadAll = Command0<List<Contact>>(_loadAll);
  late final search = Command1<List<Contact>, String>(_search);
  late final refresh = Command0<void>(_refresh);
  
  ContactsViewModel(this._repo) {
    _repo.addListener(() => notifyListeners());
  }
  
  // Fonte única de verdade
  List<Contact> get contacts => _repo.contacts;
  bool get isLoading => loadAll.isRunning || search.isRunning;
  String? get error => loadAll.error ?? search.error;
  
  Future<ResultApp<List<Contact>>> _loadAll() async => await _repo.fetchAll();
  Future<ResultApp<List<Contact>>> _search(String query) async => await _repo.search(query);
  Future<ResultApp<void>> _refresh() async => await _repo.sync();
}
```

### 2. ContactsRepository (esqueleto)
```dart
abstract class ContactsRepository extends ChangeNotifier {
  List<Contact> get contacts;
  Future<ResultApp<List<Contact>>> fetchAll();
  Future<ResultApp<Contact>> create(Contact contact);
  Future<ResultApp<Contact>> update(Contact contact);
  Future<ResultApp<void>> delete(String id);
  Future<ResultApp<void>> sync();
}

class ContactsRepositoryRemote extends ChangeNotifier implements ContactsRepository {
  final ContactRemoteDataSource _remote;
  final ContactLocalDataSource _local;
  
  ContactsRepositoryRemote(this._remote, this._local);
  
  List<Contact> _contacts = [];
  @override List<Contact> get contacts => _contacts;
  
  @override Future<ResultApp<List<Contact>>> fetchAll() async {
    // CORRIGIR: Usar POST /contacts/search (não GET depreciado)
    final res = await _remote.searchContacts(SearchContactsDto());
    switch (res) {
      case Ok(:final value): 
        _contacts = ContactMapper.fromDtoList(value.contacts); 
        await _local.saveContacts(_contacts);
        notifyListeners(); 
        return ResultApp.ok(_contacts);
      case Error(:final error): 
        _contacts = await _local.getContacts(); // Fallback offline
        return ResultApp.error(error);
    }
  }
  
  @override Future<ResultApp<Contact>> create(Contact contact) async {
    // CORRIGIR: Usar firstName/lastName
    final dto = ContactMapper.toCreateDto(contact);
    final res = await _remote.createContact(dto);
    switch (res) {
      case Ok(:final value):
        final newContact = ContactMapper.fromDto(value);
        _contacts.add(newContact);
        await _local.saveContact(newContact);
        notifyListeners();
        return ResultApp.ok(newContact);
      case Error(:final error): 
        return ResultApp.error(error);
    }
  }
}
```

### 3. ContactRemoteDataSource (corrigido)
```dart
class ContactRemoteDataSource {
  final MedplusApi _api;
  final LocationService _locationService;
  
  ContactRemoteDataSource(this._api, this._locationService);
  
  // CORRIGIR: Usar POST /contacts/search (não GET depreciado)
  Future<Result<ContactListDto>> searchContacts(SearchContactsDto request) async {
    final locationId = _locationService.currentLocationId;
    return await _api.post(
      '/contacts/search',
      data: request.copyWith(locationId: locationId).toJson(),
    );
  }
  
  // CORRIGIR: Usar firstName/lastName
  Future<Result<ContactDto>> createContact(CreateContactDto dto) async {
    final locationId = _locationService.currentLocationId;
    return await _api.post(
      '/contacts',
      data: dto.toJson(),
      queryParameters: {'location_id': locationId},
    );
  }
}
```

### 4. ContactMapper (DTO ↔ Entity)
```dart
class ContactMapper {
  // CORRIGIR: Split name em firstName/lastName  
  static CreateContactDto toCreateDto(Contact entity) {
    final nameParts = entity.name.trim().split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.skip(1).join(' ') : '';
    
    return CreateContactDto(
      firstName: firstName.isNotEmpty ? firstName : null,  // API REQUIRED
      lastName: lastName.isNotEmpty ? lastName : null,     // API OPTIONAL
      email: entity.email.isNotEmpty ? entity.email : null,
      phone: entity.phone.isNotEmpty ? entity.phone : null,
      companyName: entity.companyName?.isNotEmpty == true ? entity.companyName : null,
      address: entity.address?.isNotEmpty == true ? entity.address : null,
    );
  }
  
  static Contact fromDto(ContactDto dto) {
    // Combine firstName + lastName → name
    final fullName = [dto.firstName, dto.lastName]
        .where((part) => part?.isNotEmpty == true)
        .join(' ');
    
    return Contact(
      id: dto.id,
      ghlId: dto.id,
      name: fullName.isNotEmpty ? fullName : '',
      email: dto.email ?? '',
      phone: dto.phoneNo ?? '',
      companyName: dto.companyName,
      address: dto.address,
      syncStatus: SyncStatus.synced,
    );
  }
}
```

### 5. ContactDto (corrigido para API)
```dart
class ContactDto {
  final String id;
  final String? firstName;    // API REQUIRED para create
  final String? lastName;     // API OPTIONAL
  final String? email;
  final String? phoneNo;
  final String? companyName;
  final String? address;      // API retorna 'address', não 'address1'
  
  const ContactDto({
    required this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNo,
    this.companyName,
    this.address,
  });
  
  factory ContactDto.fromJson(Map<String, dynamic> json) {
    return ContactDto(
      id: json['id'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      email: json['email'] as String?,
      phoneNo: json['phoneNo'] as String?,
      companyName: json['companyName'] as String?,
      address: json['address'] as String?,
    );
  }
}

class CreateContactDto {
  final String firstName;     // REQUIRED pela API
  final String? lastName;     // OPTIONAL
  final String? email;
  final String? phone;
  final String? companyName;
  final String? address;
  
  const CreateContactDto({
    required this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.companyName,
    this.address,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,     // API expects firstName (REQUIRED)
      if (lastName != null) 'lastName': lastName,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (companyName != null) 'companyName': companyName,
      if (address != null) 'address': address,  // Note: address, não address1
    };
  }
}
```

## E) Testes/Smoke Tests

```dart
// test/contacts/viewmodel_test.dart
void main() {
  group('ContactsViewModel', () {
    test('should load contacts successfully', () async {
      // Arrange
      final mockRepo = MockContactsRepository();
      when(mockRepo.fetchAll()).thenAnswer((_) async => ResultApp.ok([mockContact]));
      final viewModel = ContactsViewModel(mockRepo);
      
      // Act
      await viewModel.loadAll.execute();
      
      // Assert
      expect(viewModel.loadAll.completed, true);
      expect(viewModel.contacts.length, 1);
      verify(mockRepo.fetchAll()).called(1);
    });
    
    test('should transition command states correctly', () async {
      // Test: idle → running → completed/error
      final mockRepo = MockContactsRepository();
      final viewModel = ContactsViewModel(mockRepo);
      
      expect(viewModel.loadAll.isIdle, true);
      
      final future = viewModel.loadAll.execute();
      expect(viewModel.loadAll.isRunning, true);
      
      await future;
      expect(viewModel.loadAll.completed, true);
    });
  });
  
  group('ContactsRepository', () {
    test('should create contact with firstName/lastName', () async {
      // Test caminho feliz: Contact não-nulo
      final contact = Contact(name: 'Maria Silva', email: 'maria@test.com');
      final result = await repository.create(contact);
      
      expect(result.isSuccess, true);
      expect(result.value?.name, 'Maria Silva');
      
      // Verify API call used firstName/lastName
      final captured = verify(mockRemote.createContact(captureAny)).captured.single;
      expect(captured.firstName, 'Maria'); 
      expect(captured.lastName, 'Silva');
    });
  });
}
```

## F) Guia de Migração

### Como Executar a Refatoração:

1. **Backup do código atual**
2. **Criar nova estrutura de pastas** conforme layout MVVM
3. **Migrar modelos primeiro**: Contact Entity + DTOs + Mappers
4. **Atualizar DataSources**: corrigir firstName/lastName nos requests
5. **Refatorar Repository**: ChangeNotifier + ResultApp pattern
6. **Migrar ViewModels**: Commands + estado reativo
7. **Atualizar DI**: centralizar em injector.dart
8. **Atualizar Views**: ListenableBuilder + reactive patterns

### Pontos de Atenção:
- ⚠️ **Crítico**: API espera `firstName` (obrigatório) + `lastName` (opcional), não `name`
- ⚠️ **Crítico**: Usar POST `/contacts/search`, não GET `/contacts` (depreciado)
- ⚠️ **Não adicionar** validação de nulo para Contact (domínio garante não-nulidade)
- ✅ Repository como fonte única de verdade (ChangeNotifier)
- ✅ Commands para operações assíncronas nos ViewModels

### Ordem de Execução:
1. DTOs e Mappers → 2. DataSources → 3. Repository → 4. ViewModels → 5. Views → 6. DI → 7. Testes

## G) Template de PR

```markdown
## 🎯 Objetivo
Refatorar módulo de Contatos para MVVM rigoroso + correção de contrato da API

## 🔧 Mudanças Principais
- ✅ **API Fix**: firstName/lastName em vez de name (conforme doc da API)
- ✅ **MVVM**: ChangeNotifier Repository + Commands nos ViewModels  
- ✅ **DI**: Centralizado no bootstrap, zero Service Locator em Widgets
- ✅ **Offline-First**: Repository como fonte única de verdade
- ✅ **Layout**: Estrutura features/contacts/ organizada

## 🧪 Como Testar
- [ ] Criar contato offline → online (sync automático)
- [ ] Editar contato (firstName/lastName correto na API)
- [ ] Buscar contatos (POST /contacts/search)
- [ ] Validação 422 com mensagens do backend
- [ ] UI responsiva (loading, success, error states)

## ⚠️ Riscos
- **Baixo**: Modelos existentes preservados
- **Baixo**: Fluxo offline-first mantido  
- **Médio**: Mudança de arquitetura (DI centralizada)

## 🔄 Rollback
```bash
git revert <commit-hash>
flutter clean && flutter pub get
```

## ✅ Checklist
- [ ] Compila sem warnings
- [ ] Tests/smoke tests verdes  
- [ ] UI/UX idêntica ao atual
- [ ] DI sem Service Locator em Widgets
- [ ] Commands funcionando nos ViewModels
- [ ] Repository isolado + ChangeNotifier
- [ ] firstName/lastName na API calls
- [ ] ResultApp em fluxos assíncronos

---
🤖 Generated with Claude Code
```

**RESULTADO**: Refatoração completa que corrige o contrato da API (firstName/lastName), implementa MVVM rigoroso com Commands, centraliza DI no bootstrap e mantém estratégia offline-first robusta.

## PRIORIDADE DE EXECUÇÃO

1. **CRÍTICO** - Corrigir contact_service.dart: firstName/lastName
2. **CRÍTICO** - Corrigir create_contact_request.dart: firstName/lastName  
3. **ALTO** - Refatorar Repository para ChangeNotifier
4. **ALTO** - Atualizar ViewModels com Commands
5. **MÉDIO** - Reorganizar estrutura de pastas
6. **MÉDIO** - Centralizar DI
7. **BAIXO** - Testes e documentação