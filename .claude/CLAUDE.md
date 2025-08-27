# Prompt — Agente Flutter MVVM + Offline-First: Revisão do Módulo de Contatos

**Papel:** Você é um agente sênior em **Flutter** com **arquitetura MVVM** e **estratégias Offline-First** (cache local + sincronização).
**Objetivo:** Revisar e corrigir o **Módulo de Contatos** para aderir exatamente ao contrato descrito em `@docs/MODULO_CONTATOS_API.md`, ajustando as camadas necessárias (DataSource, Repository, ViewModel, mapeamentos e fluxo de sincronização), **sem alterar os modelos de dados existentes**.

## Entradas

* Documento de referência da API: `@docs/MODULO_CONTATOS_API.md` (fonte da verdade para rotas, métodos, headers, parâmetros, payloads e respostas).
* Código do módulo de contatos (pastas existentes do projeto).
* Configuração atual de rede (client HTTP, interceptors, autenticação).
* Camada de persistência local já utilizada (ex.: sqflite/isar/hive) e DAOs/Repos correspondentes.

## Restrições (críticas)

* **NÃO ALTERAR** modelos de dados/domínio/DTOs já existentes (nomes, campos, tipos, nullability, schema local).
* **NÃO ADICIONAR** novos campos de texto nem expandir entidades.
* **NÃO MIGRAR** banco local ou alterar o schema local.
* **NÃO REFAZER** UI. Ajuste somente o necessário para ligar corretamente ViewModel ⇄ UseCases/Repository.
* Se o doc exigir campos que não existem nos modelos atuais, **mapeie internamente** (adaptação na camada de dados) sem mudar o domínio.

## Escopo técnico (o que você deve fazer)

1. **Ler e entender o contrato da API** em `@docs/MODULO_CONTATOS_API.md`

   * Liste internamente: endpoints, métodos, URLs, headers, query params, body JSON (obrigatórios/opcionais), códigos de status e estrutura de respostas.

2. **Auditar o módulo de contatos (MVVM)**

   * **Camada Remota (Remote DataSource/Service):** conferir baseUrl, paths, métodos (GET/POST/PATCH/PUT/DELETE), headers (ex.: `Authorization`, `Content-Type`), paginação/filtro/ordenação conforme doc.
   * **Camada Local (DAO/Cache):** garantir que leitura/escrita funcionem de forma transacional e idempotente, sem tocar no schema.
   * **Repository:** validar orquestração entre remoto/local, mapeamentos, regras de merge, normalização de datas (ISO 8601), e conversões de boolean/inteiros/strings.
   * **ViewModel/UseCases:** garantir que ações (criar/editar/buscar/sincronizar) chamem corretamente o Repository, emitindo estados consistentes (loading/success/error) e atualizando o cache/apresentação.

3. **Corrigir chamadas de endpoints**

   * **Criar contato:** método/URL/headers/body exatos; tratar `201/200/422` e atualizar cache local, marcando como sincronizado (sem mudar entidades).
   * **Editar contato:** respeitar método (PUT/PATCH) exigido pelo doc; enviar apenas campos permitidos; tratar `200/204/422`.
   * **Buscar contatos (lista/detalhe):** aplicar paginação/filtros/ordenação conforme doc; mesclar com cache local sem duplicar; preservar ordenação.
   * **Deletar (se existir no doc):** soft/hard delete conforme especificado; atualizar estado local adequadamente.
   * **Sincronizar contatos:**

     * **Push**: enviar mutações pendentes (create/update/delete) em ordem determinística; política de retry exponencial c/ jitter para 5xx/timeout.
     * **Pull**: buscar alterações remotas (delta `since`/`updated_at`/ETag, conforme doc) e aplicar merge local.
     * **Conflitos:** seguir política definida no doc; se não houver, preservar a política **já existente** no repositório (não criar lógica nova).

4. **Offline-First e resiliência**

   * Fila de mutações offline (já existente): garantir marcação `dirty/pending` atual e escoamento na volta da conectividade/app-resume.
   * Tratar falhas comuns: `401` (renovar token se já implementado), `403/404`, `409` (conflito), `422` (validação), `429` (rate limit), `5xx`.
   * Garantir **idempotência** de reenvio (evitar duplicatas usando ids locais/temporários e reconciliação com o `id` servidor).

5. **Serialização e mapeamentos**

   * Ajustar os **mappers** remotos (JSON ⇄ modelos atuais) para obedecer ao contrato **sem mudar os modelos**.
   * Normalizar datas (ISO 8601), booleanos e enums conforme doc.
   * **Não** adicionar campos extras nos modelos; se a API retornar campos a mais, ignore-os no mapeamento.

6. **Eventos e estados (ViewModel)**

   * Assegurar que telas/listas sejam atualizadas após criar/editar/sincronizar (invalidate/refresh).
   * Estados claros: `idle/loading/success/error`, com mensagens reais de validação quando vier `422`.

7. **Telemetria & logs (mínimos)**

   * Manter logs **apenas** nos pontos críticos de diagnóstico (falha de rede, parse, conflito), sem verbosidade excessiva.

8. **Testes**

   * **Unitários** para Repository e DataSources (mocks de remoto/local) cobrindo: criar, editar, buscar, sync (push/pull), conflitos e erros de validação.
   * **Integração leve** para fluxo completo offline→online (modo avião → restabelecer conexão).
   * **Check manual** (roteiro abaixo).

## Checklist por endpoint (aplicar a cada rota do doc)

* Método & URL corretos
* Headers obrigatórios (Auth, Content-Type)
* Query params (pagina, per\_page, filtros)
* Body JSON (apenas campos permitidos; obrigatórios vs. opcionais)
* Códigos de status esperados e tratamento de erros (`422` com mensagens do backend)
* Atualização do cache local e reconciliação (id local ⇄ id remoto)
* Emissão de estado correto na ViewModel e atualização da UI

## Roteiro de validação manual

1. **Criar contato offline:** criar 2 contatos sem internet → verificar persistência local e status pendente → voltar internet → sync automático com sucesso → ids remotos conciliados.
2. **Editar contato com campo opcional ausente:** garantir envio mínimo válido conforme doc e retorno `200/204`.
3. **422 validação:** forçar erro (ex.: email inválido se previsto) → exibir mensagem vinda do backend.
4. **Listagem paginada:** navegar página 1→2→back, sem duplicar/omitir; filtros/ordem conforme doc.
5. **Conflito (409):** simular edição simultânea (local vs. remoto) e verificar política aplicada (doc ou política atual).
6. **Perda e retomada de conexão:** operações enfileiradas e reprocessadas sem duplicidade.

## Saída esperada do agente

* **Resumo de mudanças** (arquivos tocados e motivação por item).
* **Lista de endpoints checados** com status ✅/⚠️ e notas.
* **Casos de teste** criados/atualizados e como executá-los.
* **Pendências/TODOs** apenas se algo do doc estiver ambíguo/contraditório (referenciar trechos do código e do doc).
* **Sem alterar modelos de dados, UI ou schema local.**

## Parâmetros opcionais (preencha se quiser)

* `{{contacts_module_root}}` — diretório raiz do módulo de contatos
* `{{http_client}}` — ex.: Dio/http
* `{{storage_engine}}` — ex.: sqflite/isar/hive
* `{{auth_header}}` — ex.: `Authorization: Bearer {token}`

**Importante:** Execute as correções; **não** gere documentação extensa nem exemplos de código desnecessários. Foque em **ajustar o código** para obedecer ao `@docs/MODULO_CONTATOS_API.md`, mantendo **os modelos existentes inalterados**.
