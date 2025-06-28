# Estrutura do Projeto PaintPro

Este documento descreve a estrutura de Models, Services e ViewModels criados para o projeto PaintPro, baseados na documentação do backend.

## 📁 Estrutura de Pastas

```
lib/
├── config/
│   ├── app_colors.dart
│   ├── app_config.dart
│   ├── routes.dart
│   ├── theme.dart
│   └── dependency_injection.dart
├── model/
│   ├── auth_model.dart
│   ├── contact_model.dart
│   ├── estimate_model.dart
│   ├── paint_catalog_model.dart
│   ├── navigation_item_model.dart
│   └── models.dart (barrel file)
├── service/
│   ├── auth_service.dart
│   ├── contact_service.dart
│   ├── estimate_service.dart
│   ├── paint_catalog_service.dart
│   ├── http_service.dart
│   ├── i_http_service.dart
│   └── services.dart (barrel file)
├── viewmodel/
│   ├── auth_viewmodel.dart
│   ├── contact_viewmodel.dart
│   ├── estimate_viewmodel.dart
│   ├── paint_catalog_viewmodel.dart
│   ├── navigation_viewmodel.dart
│   └── viewmodels.dart (barrel file)
└── main.dart
```

## 🏗️ Arquitetura

### Models

Responsáveis por representar os dados da aplicação:

- **AuthModel**: Modelos para autenticação com GoHighLevel
- **ContactModel**: Modelos para contatos do GHL
- **EstimateModel**: Modelos para orçamentos (estimates)
- **PaintCatalogModel**: Modelos para o catálogo de tintas

### Services

Responsáveis pela comunicação com a API:

- **AuthService**: Gerencia autenticação OAuth2 com GoHighLevel
- **ContactService**: CRUD de contatos do GHL
- **EstimateService**: Gerenciamento completo de orçamentos
- **PaintCatalogService**: Consultas ao catálogo de tintas
- **HttpService**: Cliente HTTP baseado em Dio

### ViewModels

Responsáveis pela lógica de negócio e estado da UI:

- **AuthViewModel**: Gerencia estado de autenticação
- **ContactViewModel**: Gerencia lista e operações de contatos
- **EstimateViewModel**: Gerencia orçamentos e dashboard
- **PaintCatalogViewModel**: Gerencia catálogo de tintas
- **NavigationViewModel**: Gerencia navegação da aplicação

## 🔧 Configuração

### Injeção de Dependências

Utilizamos `get_it` para injeção de dependências:

```dart
// Em config/dependency_injection.dart
void setupDependencies() {
  // Services
  getIt.registerLazySingleton<IHttpService>(() => HttpService());
  getIt.registerLazySingleton<AuthService>(() => AuthService(getIt<IHttpService>()));
  // ... outros services e viewmodels
}
```

### Provider

Utilizamos `provider` para gerenciamento de estado:

```dart
// Em main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider<AuthViewModel>(create: (_) => getIt<AuthViewModel>()),
    ChangeNotifierProvider<ContactViewModel>(create: (_) => getIt<ContactViewModel>()),
    // ... outros providers
  ],
  child: MaterialApp.router(...),
)
```

## 📋 Endpoints Implementados

### Autenticação (`/api/auth`)

- ✅ `GET /authorize-url` - URL de autorização
- ✅ `GET /callback` - Callback de autorização
- ✅ `GET /status` - Status da autenticação
- ✅ `POST /refresh` - Renovação de token
- ✅ `GET /debug` - Informações de debug

### Contatos (`/api/contacts`)

- ✅ `GET /` - Lista contatos
- ✅ `POST /` - Cria contato
- ✅ `GET /{id}` - Obtém contato
- ✅ `PUT /{id}` - Atualiza contato
- ✅ `DELETE /{id}` - Remove contato

### Orçamentos (`/api/paint-pro`)

- ✅ `GET /estimates/dashboard` - Dashboard
- ✅ `GET /estimates` - Lista orçamentos
- ✅ `POST /estimates` - Cria orçamento
- ✅ `GET /estimates/{id}` - Detalhes do orçamento
- ✅ `PUT /estimates/{id}` - Atualiza orçamento
- ✅ `DELETE /estimates/{id}` - Remove orçamento
- ✅ `PATCH /estimates/{id}/status` - Atualiza status
- ✅ `POST /estimates/{id}/photos` - Upload de fotos
- ✅ `POST /estimates/{id}/select-elements` - Seleciona tintas
- ✅ `POST /estimates/{id}/complete` - Finaliza orçamento
- ✅ `POST /estimates/{id}/send-to-ghl` - Envia para GHL

### Catálogo de Tintas (`/api/paint-catalog`)

- ✅ `GET /brands` - Lista marcas
- ✅ `GET /brands/popular` - Marcas populares
- ✅ `GET /brands/{brandKey}/colors` - Cores da marca
- ✅ `GET /brands/{brandKey}/colors/{colorKey}/{usage}` - Detalhes da cor
- ✅ `GET /search` - Busca cores
- ✅ `POST /calculate` - Calcula necessidade de tinta
- ✅ `GET /overview` - Visão geral do catálogo

## 🚀 Como Usar

### 1. Acessar ViewModels

```dart
// Em qualquer widget
final authViewModel = context.read<AuthViewModel>();
final contactViewModel = context.read<ContactViewModel>();
final estimateViewModel = context.read<EstimateViewModel>();
final paintCatalogViewModel = context.read<PaintCatalogViewModel>();
```

### 2. Escutar Mudanças

```dart
// Em um widget
Consumer<AuthViewModel>(
  builder: (context, authViewModel, child) {
    if (authViewModel.isLoading) {
      return CircularProgressIndicator();
    }
    return Text('Status: ${authViewModel.isAuthenticated}');
  },
)
```

### 3. Executar Ações

```dart
// Exemplo: Carregar contatos
await context.read<ContactViewModel>().loadContacts();

// Exemplo: Criar orçamento
await context.read<EstimateViewModel>().createEstimate(
  projectName: 'Pintura Residencial',
  clientName: 'João Silva',
  projectType: ProjectType.residential,
);
```

## 📝 Observações

1. **Tratamento de Erros**: Todos os ViewModels incluem tratamento de erros e estados de loading
2. **Paginação**: Implementada nos ViewModels de lista (ContactViewModel, EstimateViewModel)
3. **Cache**: Os ViewModels mantêm estado local para melhor performance
4. **Tipagem**: Todos os modelos são fortemente tipados
5. **Documentação**: Código documentado em português conforme solicitado

## 🔄 Próximos Passos

1. Implementar as Views correspondentes
2. Adicionar testes unitários
3. Implementar cache local (se necessário)
4. Adicionar interceptors para refresh automático de token
5. Implementar upload de imagens com progresso
