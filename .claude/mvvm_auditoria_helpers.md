# Auditoria MVVM — Helpers & Migração (Fase 1)

**Resumo Executivo**
O projeto Paint está estruturado com arquitetura MVVM, mas possui vários helpers contendo lógica de negócio que deveria estar nas ViewModels apropriadas. A análise identificou 19 arquivos de helpers, dos quais 8 contêm regras de negócio que precisam ser migradas, 6 são utilitários de apresentação que podem permanecer como helpers, e 5 são infraestrutura genérica. A migração melhorará a coesão das ViewModels, reduzirá acoplamento e facilitará testes unitários das regras de negócio.

O projeto já possui uma estrutura MVVM bem definida com ViewModels utilizando Commands, repositórios e use cases. Algumas ViewModels já migraram funcionalidades de helpers (ContactsViewModel e ContactDetailViewModel), demonstrando o padrão a ser seguido.

## Mapa do Projeto

```
lib/
├── viewmodel/                 # ViewModels (MVVM)
│   ├── contacts/             # Módulo de contatos
│   ├── contact/              # Detalhes de contato
│   ├── zones/                # Módulo de zonas
│   ├── estimate/             # Módulo de orçamentos
│   ├── auth/                 # Autenticação
│   └── material/             # Materiais
├── helpers/                  # Helpers (para migração)
│   ├── contacts/             # Regras de contatos
│   ├── zones/                # Regras de zonas
│   ├── processing/           # Regras de processamento
│   └── *.dart               # Diversos helpers
├── view/                     # Views (UI)
├── model/                    # Modelos de dados
├── service/                  # Serviços
├── data/repository/          # Repositórios
├── domain/repository/        # Interfaces de repositórios
└── use_case/                 # Use cases
```

## Inventário de Helpers

| Arquivo/Símbolo | Categoria (negócio/UI/infra) | Quem consome | Problema | Destino Proposto (ViewModel / use case leve) | Impacto | Risco | Estimativa |
|---|---|---|---|---|---|---|---|
| estimate_builder.dart | negócio | OverviewZonesViewModel | Lógica de construção de estimates | EstimateCalculationViewModel | alto | baixo | 2h |
| processing/processing_helper.dart | negócio | ZonesListViewModel | Cálculos de área e processamento RoomPlan | ZonesListViewModel (já migrado parcialmente) | alto | baixo | 3h |
| contacts/contact_details_helper.dart | negócio | ContactDetailViewModel | Formatação e validação de contatos | ContactDetailViewModel (já migrado) | baixo | baixo | 1h |
| contacts/contacts_helper.dart | negócio | ContactsViewModel | Operações de contatos e formatação | ContactsViewModel (já migrado) | baixo | baixo | 1h |
| contacts/new_contact_helper.dart | negócio | NewContactViewModel, Views | Validações e criação de contatos | NewContactViewModel | alto | baixo | 2h |
| contacts/edit_contact_helper.dart | negócio | EditContactView | Validações e edição de contatos | ContactDetailViewModel | alto | baixo | 2h |
| auth_helper.dart | negócio | App initialization | Lógica de inicialização de auth | AuthViewModel | médio | baixo | 2h |
| contact_helper.dart | negócio | Repository | Carregamento offline-first | ContactsViewModel | médio | baixo | 1h |
| loading_helper.dart | UI | Views | Navegação para telas de loading | Manter como utilitário | baixo | baixo | 0h |
| snackbar_helper.dart | UI | Views, ViewModels | Exibição de mensagens | Manter como utilitário | baixo | baixo | 0h |
| status_helper.dart | UI | Widgets | Formatação de status | Manter como utilitário | baixo | baixo | 0h |
| date_helper.dart | UI | Widgets | Formatação de datas | Manter como utilitário | baixo | baixo | 0h |
| zone_photos_helper.dart | UI | Widgets | UI de fotos de zonas | Manter como utilitário | baixo | baixo | 0h |
| error_message_helper.dart | infra | ViewModels, Repository | Tratamento de erros | Manter como utilitário | baixo | baixo | 0h |
| zones/zone_data_classes.dart | infra | ViewModels | DTOs de zona | Manter como utilitário | baixo | baixo | 0h |
| zones/zone_add_data.dart | infra | ViewModels | DTOs de zona | Manter como utilitário | baixo | baixo | 0h |
| zones/zone__rename_data.dart | infra | ViewModels | DTOs de zona | Manter como utilitário | baixo | baixo | 0h |
| zones/zone_initializer.dart | negócio | Views | Inicialização de zonas | ZonesListViewModel | médio | baixo | 1h |
| contacts/split_full_name.dart | UI | Views | Utilitário simples de nome | Manter como utilitário | baixo | baixo | 0h |

## Decisões de Design (MVVM)

- Critérios para **ViewModel** vs **use case leve**:
  - Se a lógica pertence claramente a uma ViewModel específica (contatos, zonas, estimates) → migrar para ViewModel
  - Se a mesma regra é usada por 2+ ViewModels diferentes → considerar use case leve
  - Validações de formulário → manter na ViewModel responsável pelos dados

- Convenções (nomes, empacotamento, padrões de estado):
  - ViewModels continuam usando Commands para operações assíncronas
  - Estados usando enums (ContactsState, ZonesListState, etc.)
  - Métodos privados para lógica de negócio migrada (prefixo _ )
  - Métodos estáticos para utilitários de formatação/validação
  - Preservar Result<T> pattern para tratamento de erros

## Plano de Refatoração (ordem de execução, sem aplicar ainda)

1. **Migrar validações de contatos** — NewContactHelper e EditContactHelper para NewContactViewModel e ContactDetailViewModel (2h cada)
2. **Migrar EstimateBuilder** — Mover lógica de construção para EstimateCalculationViewModel (2h)
3. **Finalizar migração ProcessingHelper** — Completar migração para ZonesListViewModel (3h)
4. **Migrar AuthHelper** — Mover inicialização para AuthViewModel (2h)
5. **Migrar ZoneInitializer** — Mover para ZonesListViewModel (1h)
6. **Migrar ContactHelper** — Mover para ContactsViewModel (1h)
7. **Limpeza** — Remover helpers vazios e atualizar imports (1h)

**Rollback**: Cada migração será feita por commit individual para facilitar rollback. Manter helpers originais até confirmar que ViewModels funcionam corretamente.

## Checklist de Aceitação

- [ ] Lint/format ok
- [ ] Sem regressão de UI/fluxo
- [ ] Logs/erros revisados
- [ ] Imports atualizados após remoção de helpers
- [ ] ViewModels mantêm mesmo comportamento público
- [ ] Commands continuam funcionando corretamente

## Riscos & Mitigações

- **Risco**: Quebrar funcionalidade existente ao migrar lógica complexa | **Mitigação**: Migração incremental com testes após cada step
- **Risco**: ViewModels ficarem muito grandes | **Mitigação**: Quebrar em métodos privados bem nomeados, considerar use cases se necessário
- **Risco**: Dependências circulares ao mover código | **Mitigação**: Revisar imports e dependências antes de cada migração
- **Risco**: Perder validações importantes | **Mitigação**: Manter lista de validações antes/depois de cada helper migrado
- **Risco**: UI não funcionar após mudanças | **Mitigação**: Testar fluxos principais após cada migração (criar/editar/listar contatos, zonas)