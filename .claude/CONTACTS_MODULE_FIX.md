Você é um(a) engenheiro(a) Flutter sênior, especialista em MVVM e grandes refatorações.

OBJETIVO
Refatorar TODO o módulo de Contatos para obedecer estritamente ao MVVM, corrigindo DI (GetIt), ViewModels (ChangeNotifier + Commands), Repositories, Services, Mappers e layout de pastas — SEM alterar lógica de negócio nem o visual/UX. Preserve rotas, textos, chaves e fluxos.

REGRAS OBRIGATÓRIAS
1) DI com GetIt somente no bootstrap (main/injector). NÃO resolver dependências em rotas nem dentro de Widgets. Widgets recebem ViewModels por construtor.  
2) NUNCA adicionar checagens de nulo para `Contact`. O domínio garante não-nulidade. Não torne `Contact` ou seus campos opcionais se hoje não são.  
3) MVVM rigoroso:
   - View: sem regra de negócio e sem Service Locator; apenas renderiza e reage a Commands.
   - ViewModel: `ChangeNotifier` + `Command0/1/...` para operações assíncronas; SEM `BuildContext` e sem lógica de UI.
   - Repository: fonte única de verdade (estado, cache, notifyListeners).
   - UseCase: crie **apenas** quando combinar múltiplos repositórios, quando a lógica for complexa ou reutilizada por diversos ViewModels.
4) Services: **um** serviço HTTP central (ex.: `MedplusApi`) com interceptors/refresh; NUNCA criar vários services por feature.
5) Result: toda comunicação assíncrona retorna `ResultApp<T>` (ou `Result<T>` conforme utilitário do projeto); nada de exceptions “vazando”.
6) Sem acoplamento entre repositórios (repo não depende de outro repo).

TAREFAS
- Inventariar o módulo de Contatos (views, viewmodels, repositories, datasources/services, models/dtos, mappers, rotas e pontos de DI).
- Reorganizar pastas para o layout abaixo (adapte à convenção atual do repo sem quebrar imports públicos):

features/contacts/
  data/
    datasources/           # ex.: api client / storage
    models/                # DTOs
    mappers/               # DTO <-> Entity
    repositories/          # implementações concretas (ChangeNotifier)
  domain/
    entities/
    repositories/          # contratos
    usecases/              # criar só quando necessário (ver regras)
  presentation/
    viewmodels/            # ChangeNotifier + Commands
      states/              # (opcional) agrupadores de estado
    views/                 # páginas e widgets de tela
    widgets/               # componentes
  di/                      # registro específico do módulo (se houver módulo-scoped)
  
- Atualizar ViewModels:
  - Expor Commands (ex.: `Command0`, `Command1<Out, In>`).
  - Assinar repositórios via `addListener` e propagar mudanças com `notifyListeners()`.
  - Remover qualquer `StateNotifier`/estados antigos; migrar para Commands.
- Atualizar Repository:
  - Estender `ChangeNotifier`, manter estado interno (listas, itens selecionados etc.).
  - Retornar `ResultApp<T>` em todos os métodos.
  - Chamar **apenas** serviços externos (API/storage). NÃO depender de outros repositórios.
- Atualizar Service (API):
  - Consolidar chamadas HTTP no client central (ex.: `MedplusApi`).
  - Interceptors e refresh token automáticos (sem lógica de refresh no ViewModel).
- DI (GetIt):
  - Centralizar em `injector.dart` (ou equivalente) com funções: `_injectServices`, `_injectRepositories`, `_injectUseCases`, `_injectViewModels`.
  - **Não** resolver dependências em rotas. Se necessário, crie as páginas já com o ViewModel resolvido no bootstrap e apenas retorne-as na configuração de rotas.
- UI:
  - Usar `ListenableBuilder`/`ReactiveBuilder` para reagir aos `Commands` e ao `ChangeNotifier`.
  - Nada de `GetIt.instance` dentro dos Widgets.

ENTREGÁVEIS
A) Árvore “Antes → Depois” somente do módulo de Contatos  
B) Tabela de mapeamento (arquivo/classe antiga → novo caminho/nome) com notas de import  
C) Snippet(s) de DI (GetIt) do módulo de Contatos:
   - `setupInjector()` e `_injectServices/_injectRepositories/_injectUseCases/_injectViewModels()`
   - exemplo de criação de página **sem** resolver dependências na rota  
D) Classes centrais atualizadas (ViewModels, Repository, Datasource/API, Mapper) — apenas do módulo de Contatos  
E) Testes/smoke tests:
   - transições de `Command` no ViewModel
   - caminhos felizes do Repository (Contact não-nulo)  
F) Guia de migração (como rodar, pontos de atenção)  
G) Template de PR (objetivo, como testar, riscos, rollback, checklist)

EXEMPLOS QUE VOCÊ DEVE GERAR (ADAPTAR AO PROJETO)
1) injector.dart (trechos)
   - Services:
     i.addLazySingleton<MedplusApi>(() => MedplusApi(dio: _buildDio(apiConfig)));
   - Repositories:
     i.addLazySingleton<ContactsRepository>(() => ContactsRepositoryRemote(i()));
   - UseCases (se necessários):
     i.addLazySingleton<GetContactsUseCase>(() => GetContactsUseCase(i(), /* ... */));
   - ViewModels:
     i.addLazySingleton(() => ContactsViewModel(i() /* repo */, /* usecases… */));

2) Rotas (sem DI nas rotas):
   // Em main/bootstrap:
   final contactsPage = ContactsPage(viewModel: i<ContactsViewModel>());
   // Na definição de rotas:
   GoRoute(path: '/contacts', builder: (ctx, st) => contactsPage);

3) ViewModel (esqueleto):
   class ContactsViewModel extends ChangeNotifier {
     final ContactsRepository _repo;
     // Commands
     late final loadAll = Command0<List<Contact>>(_loadAll);
     late final select   = Command1<void, Contact>(_select);
     ContactsViewModel(this._repo /*, usecases se houver */) {
       _repo.addListener(() => notifyListeners());
     }
     List<Contact> get contacts => _repo.contacts; // fonte única de verdade
     Future<ResultApp<List<Contact>>> _loadAll() async => await _repo.fetchAll();
     Future<ResultApp<void>> _select(Contact c) async => await _repo.select(c);
   }

4) Repository (esqueleto):
   abstract class ContactsRepository extends ChangeNotifier {
     List<Contact> get contacts;
     Future<ResultApp<List<Contact>>> fetchAll();
     Future<ResultApp<void>> select(Contact c);
   }

   class ContactsRepositoryRemote extends ChangeNotifier implements ContactsRepository {
     final MedplusApi _api;
     ContactsRepositoryRemote(this._api);
     List<Contact> _contacts = [];
     @override List<Contact> get contacts => _contacts;
     @override Future<ResultApp<List<Contact>>> fetchAll() async {
       final res = await _api.getContacts();
       switch (res) {
         case Ok(:final value): _contacts = value; notifyListeners(); return ResultApp.ok(value);
         case Error(:final error): return ResultApp.error(error);
       }
     }
     @override Future<ResultApp<void>> select(Contact c) async { /* atualiza estado, notifica */ }
   }

CHECKLIST DE ACEITAÇÃO
- Compila sem novos warnings; testes/smoke verdes.
- UI/UX e regras de negócio **idênticas** ao que já funcionava.
- DI centralizada (GetIt) no bootstrap; **nenhum** uso de Service Locator em Widgets/rotas.
- Commands nos ViewModels; Repository isolado; Service HTTP único; `ResultApp<T>` em fluxos assíncronos.
- Nenhuma nova validação de nulo em `Contact`.

SAÍDA
Responda com:
A) Before→After (árvore)  
B) Tabela de mapeamento  
C) Snippets de DI  
D) Classes núcleo (Contacts)  
E) Testes/smoke  
F) Descrição de PR pronta para colar
