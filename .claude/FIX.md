### **Prompt para o Agente de IA Flutter MVVM**

**Persona:** Você é um desenvolvedor sênior de Flutter AI, com profunda especialização na implementação da arquitetura MVVM (Model-View-ViewModel), sem o uso de Clean Architecture. Sua principal habilidade é analisar bases de código existentes, identificar bugs de lógica e estado, e corrigi-los de forma cirúrgica e eficiente.

**Contexto do Problema:**
Estou desenvolvendo um aplicativo que usa o RoomPlan para escanear ambientes (zonas). Estou enfrentando um problema crítico com a listagem dessas zonas. O fluxo é o seguinte:

1.  O usuário cria um projeto e escaneia a primeira zona (ex: "Room 1").
2.  Após o escaneamento, os dados são processados e a zona é adicionada com sucesso a uma lista e exibida na tela de zonas.
3.  O usuário então escaneia uma segunda zona (ex: "Room 2").
4.  **O problema:** Embora os logs mostrem que todos os dados da segunda zona (medidas, fotos, objetos) são capturados e processados corretamente, a zona **NÃO** aparece na lista da interface do usuário. A lista continua mostrando apenas a primeira zona.

O problema parece estar na lógica de atualização de estado ou na comunicação entre os ViewModels após o segundo escaneamento, e não no processo de captura de dados em si.

**Logs Relevantes:**
A seguir estão os logs do console que ilustram o fluxo de sucesso para a primeira zona e o ponto de falha para a segunda. Observe como após a navegação com os dados de "Room 2", os logs de `ZonesListViewModel` e `ZonesService` não são acionados como foram para "Room 1".

```log
// --- Início do fluxo de SUCESSO com a primeira zona ("Room 1") ---
[log] CreateProjectView: Project data being sent: {projectName: Test 1, zoneName: Room 1, ...}
[log] === ROOMPLAN DATA PROCESSING ===
... (processamento completo dos dados de "Room 1") ...
[log] === END ROOMPLAN DATA PROCESSING ===
[log] RoomPlanViewModel: Navigating to zones with zone "Room 1"
[log] ZonesResultsWidget: Adding initial zone data: Room 1
[log] ZonesListViewModel: addZone() called for "Room 1"
[log] ZonesService: Adding zone "Room 1" - Current count: 0
[log] ZonesService: Successfully added zone "Room 1" - New count: 1
[log] ZoneInitializerViewModel: Zone "Room 1" already exists, skipping
[log] ZonesListViewModel: Zone "Room 1" already exists in local list, skipping
// --- Fim do fluxo de SUCESSO ---

// --- Início do fluxo de FALHA com a segunda zona ("Room 2") ---
[log] === ROOMPLAN DATA PROCESSING ===
... (processamento completo dos dados de "Room 2") ...
[log] === END ROOMPLAN DATA PROCESSING ===
[log] RoomPlanViewModel: Navigating to zones with zone "Room 2"
[log] RoomPlanViewModel: Project data: {zoneName: Room 2, ...}
// --- FIM DOS LOGS. NENHUMA CHAMADA PARA ZonesListViewModel OU ZonesService ACONTECE ---
```

**Sua Tarefa:**
Sua missão é analisar o código-fonte do meu aplicativo, identificar a causa raiz desse bug e corrigi-lo.

**Instruções e Requisitos:**

1.  **Análise Completa:** Comece lendo TODA a estrutura de pastas e arquivos do projeto (`/lib`) para entender completamente a arquitetura MVVM implementada, o fluxo de dados, o gerenciamento de estado (provavelmente com `ChangeNotifier` ou similar) e a interação entre Views, ViewModels e Services.

2.  **Diagnóstico Preciso:** Com base na sua análise e nos logs, identifique por que o `ZonesListViewModel` (ou o serviço correspondente) não é acionado ou não atualiza seu estado corretamente ao receber a segunda zona. A hipótese principal é que a View não está reconstruindo ou o ViewModel não está recebendo os novos dados após a navegação da tela do RoomPlan.

3.  **Correção Cirúrgica:** Modifique **APENAS** os pontos necessários no código. Evite refatorações em larga escala. O foco é corrigir o bug de forma limpa, respeitando a arquitetura existente. As áreas prováveis para modificação são:

      * A lógica de navegação e passagem de dados da `RoomPlanView` para a `ZonesListView`.
      * O ciclo de vida da `ZonesListView` e seu `ViewModel` para garantir que ele possa receber e processar novas zonas após sua inicialização.
      * O mecanismo de notificação de mudanças no `ZonesListViewModel` para garantir que a UI seja atualizada.

4.  **Melhoria de Logs:** Você está autorizado a adicionar novos logs (`log('message', name: 'ClassName')` de `dart:developer`) em pontos estratégicos para rastrear o fluxo de dados e o ciclo de vida dos widgets/viewmodels. Você também pode remover ou ajustar logs existentes para maior clareza.

**Restrições Críticas (NÃO FAÇA):**

  * **NÃO** crie novas classes, arquivos ou widgets, a menos que seja absolutamente impossível corrigir o bug sem eles. Priorize a reutilização e o ajuste do que já existe.
  * **NÃO** remova componentes existentes, a menos que se tornem redundantes após a sua correção.
  * **NÃO** altere as unidades de medida. As medições em `sq ft` e `sq m` devem ser preservadas em seus formatos originais. A correção deve ser na lógica do aplicativo, não nos dados.

**Plano de Execução (Obrigatório):**
**Antes de escrever qualquer código**, você deve me apresentar um **Plano de Execução** detalhado. Este plano deve ser uma lista de tarefas, passo a passo, que você seguirá para resolver o problema. O plano deve ser baseado na sua análise inicial da estrutura do projeto e deve incluir, no mínimo:

  * **Fase 1: Análise e Mapeamento**
      * Arquivos que serão analisados prioritariamente (ex: `room_plan_viewmodel.dart`, `zones_list_view.dart`, `zones_list_viewmodel.dart`, `zones_service.dart`, `navigation_service.dart`).
      * Como os dados da zona escaneada são passados da `RoomPlanView` para a `ZonesListView`.
  * **Fase 2: Hipótese do Bug**
      * Sua principal teoria sobre a causa do problema (ex: "O `ChangeNotifier` do `ZonesListViewModel` está sendo instanciado de forma que não persiste entre as navegações", ou "A `ZonesListView` é um `StatelessWidget` e não reage a novos dados passados por argumentos de rota após a primeira construção").
  * **Fase 3: Implementação da Correção**
      * Descrição da mudança planejada (ex: "Vou garantir que o `ZonesListViewModel` seja provido por um `Provider` que não seja recriado a cada navegação" ou "Vou ajustar o método `didUpdateWidget` ou `initState` da `ZonesListView` para processar novos dados de zona").
  * **Fase 4: Verificação**
      * Como você vai confirmar que o bug foi corrigido e que não foram introduzidos efeitos colaterais.

Inicie a análise agora e crie um arquivo seu Plano de Execução.