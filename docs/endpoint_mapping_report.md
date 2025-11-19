# Mapeamento de Endpoints do App Paint

## Visao Geral
- Foram mapeadas 27 chamadas HTTP no app (`lib/`), distribuidas entre autenticacao, contatos, orcamentos, materiais e catalogo de tintas.
- A documentacao oficial cobre a maioria dos endpoints nucleares, porem ha divergencias importantes em payloads (especialmente em autenticacao e criacao de orcamentos) e lacunas de documentacao para rotas auxiliares.
- Principais ajustes necessarios: alinhar o fluxo de autenticacao com os contratos de `docs/AUTH_MODULE.MD`, validar campos obrigatorios do POST `/api/estimates`, revisar limites/tipos de arquivos em uploads e documentar rotas adicionais (`/paint-catalog` e acoes derivadas de orcamentos/materials`).

## Autenticacao & Usuario

| Endpoint | Uso no app | Referencia da doc | Alinhamento / Ajuste necessario |
| --- | --- | --- | --- |
| `POST /api/auth/login` | `lib/viewmodel/auth/login_viewmodel.dart:48` | `docs/AUTH_MODULE.MD` sec.2.2 | Backend responde com `auth_token` na raiz (`paint_pro_api/app/Modules/Auth/Controllers/CredentialsAuthController.php:65-76`). Doc/front precisam alinhar (doc ainda mostra `data.token`). |
| `POST /api/auth/register` | `lib/viewmodel/auth/signup_viewmodel.dart:52` | `docs/AUTH_MODULE.MD` sec.2.1 | Backend exige `password_confirmation` (`paint_pro_api/app/Modules/Auth/Requests/RegisterRequest.php:23-28`) e retorna `auth_token` na raiz. Front nao envia confirmacao, logo request falha. |
| `POST /api/auth/verify-otp` | `lib/viewmodel/auth/verify_otp_viewmodel.dart:43` | Doc usa `POST /api/auth/password/reset` com campos `email`, `token`, `password`, `password_confirmation` | Rota `/auth/verify-otp` nao existe (`paint_pro_api/routes/api/v1/auth.php:8-12`). Usar `/password/reset` documentado ou atualizar backend caso novo fluxo seja adotado. |
| `POST /api/auth/password/forgot` | `lib/viewmodel/auth/verify_otp_viewmodel.dart:101` | `docs/AUTH_MODULE.MD` sec.2.3 | Alinhado (envia `email`). Garantir tratamento de resposta `200` sem `success`. |
| `GET /api/user` | `lib/service/auth_service.dart:104`, `lib/service/user_service.dart:16` | `docs/reference/users.md` | Estrutura esperada compativel. Sem ajustes. |

## Contatos GoHighLevel

| Endpoint | Uso no app | Referencia da doc | Alinhamento / Ajuste necessario |
| --- | --- | --- | --- |
| `POST /api/contacts/sync` | `lib/service/contact_service.dart:36` | `docs/CONTATOS_MODULE.MD` sec.5.3 | Backend so processa se houver credenciais GHL (`paint_pro_api/app/Modules/Contacts/Controllers/ContactController.php:24-64`). Doc ok, mas front deve tratar `400` quando integracao ausente. |
| `GET /api/contacts` | `lib/service/contact_service.dart:93` | `docs/reference/ghl-contacts.md` sec.GET | Backend injeta `locationId` das credenciais (`paint_pro_api/app/Modules/Contacts/Services/IntegrationService.php:90-119`), portanto query `location_id` e opcional. Doc deve refletir isso; header `X-GHL-Location-ID` nao e lido. |
| `POST /api/contacts/search` | `lib/service/contact_service.dart:224` (e `advancedSearch`) | `docs/reference/ghl-contacts.md` sec.POST /search | Campos (`locationId`, `pageLimit`, filtros) aderentes. Considerar reutilizar unico metodo para evitar duplicidade. |
| `GET /api/contacts/{id}` | `lib/service/contact_service.dart:275` | `docs/reference/ghl-contacts.md` sec.GET /{contactId} | Envia `location_id` como query + header. Alinhado. |
| `POST /api/contacts` | `lib/service/contact_service.dart:400` | `docs/reference/ghl-contacts.md` sec.POST | Backend preenche `locationId` antes da chamada (`paint_pro_api/app/Modules/Contacts/Services/IntegrationService.php:134-154`). Estrutura de nomes do app esta aderente. |
| `PUT /api/contacts/{id}` | `lib/service/contact_service.dart:532` | `docs/reference/ghl-contacts.md` sec.PUT | Backend reaproveita `IntegrationService::updateContact` (`paint_pro_api/app/Modules/Contacts/Services/IntegrationService.php:156-182`); payload mapeado corretamente. |
| `DELETE /api/contacts/{id}` | `lib/service/contact_service.dart:595` | `docs/reference/ghl-contacts.md` sec.DELETE | Backend delega para `IntegrationService::deleteContact` (`paint_pro_api/app/Modules/Contacts/Services/IntegrationService.php:184-201`); rota confirmada. |

## Orcamentos (Estimates)

| Endpoint | Uso no app | Referencia da doc | Alinhamento / Ajuste necessario |
| --- | --- | --- | --- |
| `GET /api/estimates/dashboard` | `lib/service/estimate_service.dart:16`, `lib/service/dashboard_service.dart:23` | `docs/reference/estimates.md` sec.Dashboard | Consumo ok; consolidar chamadas para evitar duplicidade se desejado. |
| `GET /api/estimates` | `lib/service/estimate_service.dart:39` | `docs/reference/estimates.md` sec.GET | Espera `estimates` direto no payload (doc idem). Sem ajustes. |
| `POST /api/estimates` (JSON) | `lib/service/estimate_service.dart:65` | `docs/reference/estimates.md` sec.POST | Backend exige `contact`, `project_name`, `client_name`, `project_type`, `wall_condition`, `has_accent_wall` (`paint_pro_api/app/Modules/PaintPro/DTOs/EstimateCreateDTO.php:71-88`). App nao monta esses campos hoje, entao fluxo JSON quebraria; doc deve refletir campos realmente requeridos (sem `materials_calculation`, `complete`). |
| `POST /api/estimates` (multipart one-shot) | `lib/model/estimates/estimate_model.dart:370` (`toFormData`) + `lib/use_case/estimates/estimate_upload_use_case.dart:151` | `docs/reference/estimates.md` (sec.one-shot + requisitos de fotos) | Backend cria padroes para `wall_condition`/`has_accent_wall`/`total_cost` quando recebe `zones` (`paint_pro_api/app/Modules/PaintPro/Services/EstimateService.php:132-143`) e exige apenas `contact_id`, `project_name`, `zones`, `materials`, `totals`. Doc precisa alinhar; app esta coerente. |
| Upload de fotos (validacoes) | `lib/use_case/estimates/estimate_upload_use_case.dart:151` | Doc exige 3-9 fotos de ate 5 MB | Backend aceita ate 200 MB por foto (`paint_pro_api/app/Modules/PaintPro/Requests/UpdateEstimateRequest.php:51-66`). Atualizar doc/UX para refletir limites reais ou reduzir validacao no app/backend. |
| `PATCH /api/estimates/{id}/status` | `lib/service/estimate_service.dart:132` | Nao documentado | Rota nao existe (ver `paint_pro_api/routes/api/v1/estimates.php:9-18`). Front deve remover chamada ou backend criar endpoint/documentacao. |
| `POST /api/estimates/{id}/photos` | `lib/service/estimate_service.dart:160` | Nao documentado | Nao ha rota exposta; apenas metodo interno (`paint_pro_api/routes/api/v1/estimates.php`) suporta CRUD basico. Ajustar app/documentacao. |
| `POST /api/estimates/{id}/elements` | `lib/service/estimate_service.dart:180` | Nao documentado | Mesma situacao: so existe metodo interno na service. Criar rota ou remover uso no app. |
| `POST /api/estimates/{id}/finalize` | `lib/service/estimate_service.dart:196` | Nao documentado | Sem rota. Necessario alinhar estrategia (finalizacao acontece via payload `complete`/`createFinalEstimate`). |
| `POST /api/estimates/{id}/send-to-ghl` | `lib/service/estimate_service.dart:212` | Nao documentado | Nao ha endpoint publico; envio ao GHL ocorre durante `createEstimate`/`createFinalEstimate`. Front deve parar de chamar rota inexistente. |

## Materiais / Extracao de PDFs

| Endpoint | Uso no app | Referencia da doc | Alinhamento / Ajuste necessario |
| --- | --- | --- | --- |
| `POST /api/materials/upload` | `lib/service/quote_service.dart:60` | `docs/reference/materials.md` sec.POST upload | Backend exige campo `quote` e limite 25 MB (`paint_pro_api/app/Http/Requests/UploadQuoteRequest.php:24-33`). Doc/front devem ajustar nomenclatura/limite (doc ainda cita `pdf` de 10 MB). |
| `GET /api/materials/uploads` | `lib/service/quote_service.dart:187` | `docs/reference/materials.md` sec.GET uploads | Mapeamento ok. |
| `GET /api/materials/status/{id}` | `lib/service/quote_service.dart:218` | `docs/reference/materials.md` sec.GET status | Ok. |
| `PUT /api/materials/update/{id}` | `lib/service/quote_service.dart:248` | `docs/reference/materials.md` sec.PUT update | Ok. |
| `DELETE /api/materials/delete/{id}` | `lib/service/quote_service.dart:273` | `docs/reference/materials.md` sec.DELETE | Ok. |
| `GET /api/materials/extracted` | `lib/service/quote_service.dart:307` | `paint_pro_api/docs/EXTRACAO_PDF_MODULE.MD` sec. "Lista de materiais" | Backend e doc ja cobrem filtros/paginacao (ver controller em `paint_pro_api/app/Http/Controllers/QuoteExtractionController.php:901-944`). App apenas precisa alinhar com params oficiais. |
| `GET /api/materials/extracted/{id}` | `lib/service/quote_service.dart:359` | `paint_pro_api/docs/EXTRACAO_PDF_MODULE.MD` sec. "Detalhe do material" | Rota implementada (`paint_pro_api/app/Http/Controllers/QuoteExtractionController.php:946-988`). Atualizar doc do app para apontar para referencia existente. |
| `GET /api/materials/filters` | `lib/service/quote_service.dart:386` | Nao documentado | Endpoint nao existe nas rotas (`paint_pro_api/routes/api/v1/quote-extraction.php`). Remover chamada ou criar rota/documentacao. |

## Catalogo de Tintas

| Endpoint | Uso no app | Referencia da doc | Alinhamento / Ajuste necessario |
| --- | --- | --- | --- |
| `GET /api/paint-catalog/brands` | `lib/service/paint_catalog_service.dart:14` | **Sem documentacao** | Acrescentar secao dedicada (lista de marcas). |
| `GET /api/paint-catalog/brands/popular` | `lib/service/paint_catalog_service.dart:25` | **Sem documentacao** | Documentar. |
| `GET /api/paint-catalog/brands/{brand}/colors` | `lib/service/paint_catalog_service.dart:36` | **Sem documentacao** | Documentar parametros e resposta. |
| `GET /api/paint-catalog/colors/{id}` | `lib/service/paint_catalog_service.dart:50` | **Sem documentacao** | Documentar. |
| `GET /api/paint-catalog/colors/search` | `lib/service/paint_catalog_service.dart:62` | **Sem documentacao** | Documentar query `q`. |
| `POST /api/paint-catalog/calculate` | `lib/service/paint_catalog_service.dart:82` | **Sem documentacao** | Documentar body (`area`, `colorId`, `coats`) e retorno. |
| `GET /api/paint-catalog/overview` | `lib/service/paint_catalog_service.dart:104` | **Sem documentacao** | Documentar metricas. |
| `GET /api/paint-catalog/colors/find` | `lib/service/paint_catalog_service.dart:116` | **Sem documentacao** | Documentar. |
| `GET /api/paint-catalog/colors/usage/{usage}` | `lib/service/paint_catalog_service.dart:132` | **Sem documentacao** | Documentar valores aceitos de `usage`. |

## Recomendacoes Prioritarias
1. **Autenticacao** - Ajustar payload/resposta de registro/login e substituir `/auth/verify-otp` pelo fluxo documentado (ou atualizar documentacao conforme implementacao vigente).
2. **Criacao de orcamentos** - Revisar `EstimateModel.toFormData` e `EstimateUploadUseCase` para enviar campos obrigatorios e respeitar limites de fotos. Alinhar doc se o backend aceitar variacao.
3. **Materiais** - Atualizar doc para refletir upload em `quote` com limite real de 25 MB e adicionar cobranca para o endpoint inexistente `/materials/filters`.
4. **Rotas nao documentadas** - Adicionar secoes para `/paint-catalog/*`, `/estimates/{id}/photos|elements|finalize|send-to-ghl`, `/materials/filters` (ou remover chamadas no app).
5. **Clientes GHL** - Ajustar doc para deixar `location_id` como opcional e destacar que o backend usa as credenciais armazenadas; remover dependencia do header customizado.

## Proximos Passos Sugeridos
- Validar contratos reais da API (Postman/insomnia) para confirmar divergencias antes de alterar codigo.
- Atualizar o backlog tecnico com as correcoes acima, priorizando autenticacao e criacao de orcamentos que podem bloquear usuarios.
- Revisar colecoes Postman (`docs/collections/api-postman.json`) para garantir que refletem as rotas adicionais do app.
- Apos ajustes, sincronizar documentacao (`docs/reference/*`) e comunicar a equipe para manter o padrao AI-ready.
