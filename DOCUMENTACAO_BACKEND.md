# Documentação Completa do Backend - PaintPro API

Este documento detalha a arquitetura, endpoints, e funcionamento do backend do sistema PaintPro. O backend é composto por uma aplicação monolítica em Laravel que orquestra a lógica de negócio.

## 1. Arquitetura Geral

O sistema é baseado em uma arquitetura de serviços:

- **API Principal (Backend Laravel)**: Construído com [Laravel 11](https://laravel.com/), serve como o núcleo da aplicação. É responsável pela gestão de orçamentos, lógica de negócio, persistência de dados e atua como um proxy seguro para serviços externos como GoHighLevel (GHL).

## 2. Como Executar o Ambiente Local

```bash
docker compose up -d --build
```

- **API Laravel**: `http://localhost:8080`

## 3. Estrutura dos Endpoints

Os endpoints são agrupados por domínio de negócio:

| Prefixo              | Módulo       | Descrição                                       |
| -------------------- | ------------ | ----------------------------------------------- |
| `/api/auth`          | GoHighLevel  | Autenticação e autorização OAuth2 com o GHL.    |
| `/api/contacts`      | GoHighLevel  | CRUD de contatos diretamente na API do GHL.     |
| `/api/paint-pro`     | PaintPro     | Fluxo principal de criação de orçamentos.       |
| `/api/paint-catalog` | PaintCatalog | Gerenciamento e consulta do catálogo de tintas. |

---

## 4. Autenticação com GoHighLevel (`/api/auth`)

A integração com o GoHighLevel utiliza OAuth2 para autenticação segura. O backend gerencia tokens de acesso, refresh tokens e renovação automática, garantindo que o app cliente nunca precise lidar diretamente com credenciais sensíveis.

### 🔗 **Tabela de Endpoints do Fluxo OAuth2**

| Método | Endpoint                                        | Descrição                           | Tipo    | Cliente |
| ------ | ----------------------------------------------- | ----------------------------------- | ------- | ------- |
| GET    | /api/auth/authorize-url                         | Retorna URL de autorização OAuth2   | JSON    | App     |
| GET    | /api/auth/redirect                              | Redireciona para autorização GHL    | 302     | Browser |
| GET    | /api/oauth/callback                             | Troca code por tokens               | Misto   | Ambos   |
| GET    | /api/auth/status                                | Verifica status da autenticação     | JSON    | App     |
| POST   | /api/auth/refresh                               | Renova token manual                 | JSON    | App     |
| GET    | /api/auth/debug                                 | Estatísticas e debug dos tokens     | JSON    | App     |
| DELETE | /api/auth/debug-logout                          | Remove token (logout debug)         | JSON    | Dev     |
| POST   | https://services.leadconnectorhq.com/auth/token | Troca code/refresh_token por tokens | Interno | -       |

---

#### 🐞 **Rota de Debug: Logout/Invalidar Token**

- **Endpoint:** `DELETE /api/auth/debug-logout`
- **Descrição:** Remove o token OAuth do usuário referente ao `location_id` informado. Útil para testes de fluxo de login/logout.
- **Como usar:**
  - Envie o `location_id` no corpo da requisição como JSON:
    ```json
    {
      "location_id": "SEU_LOCATION_ID"
    }
    ```
  - Ou envie como query param: `/api/auth/debug-logout?location_id=SEU_LOCATION_ID`
- **Resposta de sucesso:**
  ```json
  { "success": true, "message": "Token removido com sucesso" }
  ```
- **Se não encontrar token:**
  ```json
  {
    "success": true,
    "message": "Nenhum token encontrado para este location_id"
  }
  ```
- **Atenção:** Rota apenas para desenvolvimento/debug. Não usar em produção sem proteção!

---

### 🔐 **Fluxo OAuth2 Completo — Passo a Passo**

1. **Solicitação da URL de Autorização**

   - **Para Apps (Flutter/React Native):**

     - App chama: `GET /api/auth/authorize-url`
     - Backend retorna JSON com a URL de autorização
     - **Resposta:**
       ```json
       {
         "success": true,
         "url": "https://marketplace.gohighlevel.com/auth/chooselocation?...",
         "message": "Authorization URL generated successfully"
       }
       ```

   - **Para Browsers (Web):**
     - Browser chama: `GET /api/auth/redirect`
     - Backend redireciona diretamente para o GHL (HTTP 302)

2. **Redirecionamento do Usuário**

   - Frontend abre a URL recebida.
   - Usuário faz login e autoriza.

3. **Callback: Envio do Code para o Backend**

   - **Para Apps (Flutter/React Native):**

     - App chama: `GET /api/oauth/callback?code=...`
     - Backend processa e retorna JSON com resultado
     - **Resposta de sucesso:**
       ```json
       {
         "success": true,
         "expires_at": "2024-08-20T12:00:00.000000Z",
         "location_id": "LOCATION_ID_FROM_GHL"
       }
       ```

   - **Para Browsers (Web):**
     - Browser é redirecionado para: `GET /api/oauth/callback?code=...`
     - Backend processa e redireciona para o app via deep link
     - **Redirecionamento de sucesso:** `paintproapp://auth/success?location_id=...`
     - **Redirecionamento de erro:** `paintproapp://auth/failure?error=...`

3.1 **Chamada Interna: Troca do Code por Tokens**

- Backend faz `POST https://services.leadconnectorhq.com/oauth/token` com:
  ```http
  grant_type=authorization_code&client_id=...&client_secret=...&code=...&redirect_uri=...&user_type=Location
  ```
- Exemplo de response:
  ```json
  {
    "access_token": "...",
    "refresh_token": "...",
    "expires_in": 86400,
    "token_type": "Bearer",
    "scope": "contacts",
    "locationId": "..."
  }
  ```
- Backend armazena tokens criptografados na tabela `ghl_tokens`.

4. **Verificação de Status da Autenticação**

   - Frontend chama: `GET /api/auth/status`
   - Backend verifica validade do token no banco.
   - **Resposta autenticado:**
     ```json
     {
       "success": true,
       "data": {
         "authenticated": true,
         "expires_at": "2024-08-20T12:00:00.000000Z",
         "expires_in_minutes": 1380,
         "needs_login": false,
         "location_id": "LOCATION_ID_FROM_GHL",
         "is_expiring_soon": false
       }
     }
     ```
   - **Resposta não autenticado:**
     ```json
     {
       "success": true,
       "data": {
         "authenticated": false,
         "needs_login": true
       }
     }
     ```

5. **Renovação Manual do Token**
   - Frontend chama: `POST /api/auth/refresh`

5.1 **Chamada Interna: Refresh do Token**

- Backend faz `POST https://services.leadconnectorhq.com/oauth/token` com:
  ```http
  grant_type=refresh_token&client_id=...&client_secret=...&refresh_token=...&user_type=Location
  ```
- Exemplo de response:
  ```json
  {
    "access_token": "...",
    "refresh_token": "...",
    "expires_in": 86400,
    "token_type": "Bearer",
    "scope": "contacts",
    "locationId": "..."
  }
  ```
- Backend atualiza o token no banco.
- **Resposta de sucesso:**
  ```json
  {
    "success": true,
    "expires_at": "2024-08-21T12:00:00.000000Z",
    "location_id": "LOCATION_ID_FROM_GHL"
  }
  ```
- **Resposta de erro:**
  ```json
  {
    "success": false,
    "location_id": "LOCATION_ID_FROM_GHL"
  }
  ```

6. **Debug e Monitoramento**
   - Frontend chama: `GET /api/auth/debug`
   - Backend retorna estatísticas dos tokens.
   - **Resposta:**
     ```json
     {
       "success": true,
       "data": {
         "total_tokens": 5,
         "valid": 3,
         "expired": 2,
         "needs_refresh": 1,
         "health_percentage": 60.0
       }
     }
     ```

### 🛡️ **Segurança, Middleware e Observações Técnicas**

- **Middlewares:**
  - `ValidateGhlToken`: Garante que a requisição tem um token válido para a location. Retorna 401 e URL de reautenticação se inválido.
  - `Authenticate` (Laravel): Usado para rotas protegidas por autenticação padrão.
- **Tokens criptografados:** Nunca são expostos ao frontend, nem mesmo parcialmente.
- **O backend suporta múltiplas locations** (um token por location_id).
- O middleware pode exigir o header `X-GHL-Location-ID` para identificar a location.
- O backend faz toda a criptografia/descriptografia dos tokens.
- O fluxo é seguro e preparado para produção, mas recomenda-se proteger os endpoints do backend com autenticação adicional em produção.

### 🗄️ **Models e Migrations**

- **Model:** `App\Modules\GoHighLevel\Models\GhlToken`
  - Campos: location_id, access_token (criptografado), refresh_token (criptografado), expires_in, token_type, scope, additional_data, token_expires_at, timestamps
- **Migration:** `2025_06_18_145644_create_ghl_tokens_table.php`

### ⚙️ **Variáveis de Ambiente**

- `GHL_CLIENT_ID`
- `GHL_CLIENT_SECRET`
- `GHL_REDIRECT_URI`
- `APP_KEY` (criptografia dos tokens)

### 🛠️ **Comando Artisan Relacionado**

- `php artisan ghl:refresh-tokens` — Renova tokens que estão para expirar (cron job recomendado a cada 23h)

### 📝 **Logs e Tratamento de Erros**

- Todos os erros de integração com o GHL são logados (`Log::error` e `Log::warning`)
- Respostas de erro padronizadas:
  - Falha de autorização: `{ "success": false, "message": "Authorization failed on GoHighLevel side.", "error": "..." }`
  - Token expirado ou inválido: `{ "success": false, "needs_login": true }`
  - Falha de rede/integridade: Mensagem clara e log detalhado

### 📋 **Resumo de Integração Frontend**

#### **Para Apps Mobile (Flutter/React Native):**

```javascript
// 1. Obter URL de autorização
const response = await fetch("/api/auth/authorize-url");
const { url } = await response.json();

// 2. Abrir WebView/navegador
openWebView(url);

// 3. Capturar code do callback
const code = await captureCallbackCode();

// 4. Trocar code por tokens
const result = await fetch(`/api/oauth/callback?code=${code}`).then((r) =>
  r.json()
);

// 5. Verificar status
const status = await fetch("/api/auth/status").then((r) => r.json());
```

#### **Para Web (Browser):**

```javascript
// 1. Redirecionar para autorização
window.location.href = "/api/auth/redirect";

// 2. O callback será processado automaticamente
// 3. O usuário será redirecionado para o app via deep link
// 4. O app captura o deep link e processa o resultado
```

---

## 5. CRUD de Contatos GHL (`/api/contacts`)

Endpoints que atuam como proxy para o CRUD de Contatos do GoHighLevel. **Todos os endpoints requerem autenticação OAuth2 válida.**

#### `GET /`

- **Descrição**: Lista contatos com paginação e filtros
- **Requisição**: `GET /api/contacts` com query params opcionais
- **Query Params**: `limit=10`, `offset=0`, `locationId` (automático via token)
- **Headers**: `Accept: application/json`
- **Resposta de Sucesso (200)**: Retorna a resposta da API do GHL com lista de contatos
- **Resposta de Erro (401)**: Token inválido ou expirado

#### `POST /`

- **Descrição**: Cria um novo contato no GoHighLevel
- **Requisição**: `POST /api/contacts` com `Content-Type: application/json`
- **Body**:
  ```json
  {
    "firstName": "João",
    "lastName": "Silva",
    "email": "joao.silva@exemplo.com",
    "phone": "+5511999999999",
    "locationId": "auto_from_token"
  }
  ```
- **Resposta de Sucesso (201)**: Retorna o contato criado da API do GHL
- **Resposta de Erro (400)**: Dados inválidos ou (401) Token inválido

#### `GET /{contactId}`

- **Descrição**: Obtém detalhes de um contato específico
- **Requisição**: `GET /api/contacts/{contactId}`
- **Resposta de Sucesso (200)**: Retorna o contato completo
- **Resposta de Erro (404)**: Contato não encontrado

#### `PUT /{contactId}`

- **Descrição**: Atualiza um contato existente
- **Requisição**: `PUT /api/contacts/{contactId}` com `Content-Type: application/json`
- **Body**: JSON com campos a serem atualizados
- **Resposta de Sucesso (200)**: Retorna o contato atualizado
- **Resposta de Erro (404)**: Contato não encontrado

#### `DELETE /{contactId}`

- **Descrição**: Remove um contato do GoHighLevel
- **Requisição**: `DELETE /api/contacts/{contactId}`
- **Resposta de Sucesso (200)**: Confirmação de exclusão
- **Resposta de Erro (404)**: Contato não encontrado

---

## 6. Fluxo de Orçamento (`/api/paint-pro`)

Endpoints do fluxo principal da aplicação. **Prefixo**: `/api/paint-pro`.

#### `GET /estimates/dashboard`

- **Descrição**: Retorna dados para o dashboard de orçamentos
- **Requisição**: `GET /api/paint-pro/estimates/dashboard`
- **Headers**: `Accept: application/json`
- **Resposta de Sucesso (200)**:
  ```json
  {
    "success": true,
    "data": {
      "total_estimates": 25,
      "pending": 8,
      "completed": 12,
      "sent": 5,
      "recent_activity": [...]
    }
  }
  ```

#### `GET /estimates`

- **Descrição**: Lista orçamentos com filtros e paginação
- **Requisição**: `GET /api/paint-pro/estimates` com query params opcionais
- **Query Params**: `limit=10`, `offset=0`, `status=pending`, `client_name=João`
- **Headers**: `Accept: application/json`
- **Resposta de Sucesso (200)**:
  ```json
  {
    "success": true,
    "data": {
      "estimates": [
        {
          "id": 1,
          "project_name": "Pintura de Apartamento",
          "client_name": "João da Silva",
          "status": "pending",
          "total_area": 450,
          "created_at": "2024-01-15T10:30:00Z"
        }
      ],
      "pagination": {
        "total": 25,
        "per_page": 10,
        "current_page": 1
      }
    }
  }
  ```

#### `POST /estimates`

- **Descrição**: Cria um novo orçamento
- **Requisição**: `POST /api/paint-pro/estimates` com `Content-Type: application/json`
- **Body**:
  ```json
  {
    "project_name": "Pintura de Apartamento",
    "client_name": "João da Silva",
    "project_type": "residential",
    "client_email": "joao@exemplo.com",
    "client_phone": "+5511999999999"
  }
  ```
- **Resposta de Sucesso (201)**:
  ```json
  {
    "success": true,
    "message": "Estimate created successfully",
    "data": {
      "id": 1,
      "project_name": "Pintura de Apartamento",
      "status": "draft",
      "created_at": "2024-01-15T10:30:00Z"
    }
  }
  ```

#### `GET /estimates/{id}`

- **Descrição**: Obtém detalhes completos de um orçamento
- **Requisição**: `GET /api/paint-pro/estimates/{id}`
- **Headers**: `Accept: application/json`
- **Resposta de Sucesso (200)**:
  ```json
  {
    "success": true,
    "data": {
      "id": 1,
      "project_name": "Pintura de Apartamento",
      "client_name": "João da Silva",
      "status": "photos_uploaded",
      "total_area": 450,
      "paintable_area": 380,
      "photos": [...],
      "materials": [...],
      "total_cost": 1250.00,
      "created_at": "2024-01-15T10:30:00Z"
    }
  }
  ```

#### `PUT /estimates/{id}`

- **Descrição**: Atualiza dados básicos de um orçamento
- **Requisição**: `PUT /api/paint-pro/estimates/{id}` com `Content-Type: application/json`
- **Body**: JSON com campos a serem atualizados
- **Resposta de Sucesso (200)**:
  ```json
  {
    "success": true,
    "message": "Estimate updated successfully",
    "data": {
      /* orçamento atualizado */
    }
  }
  ```

#### `DELETE /estimates/{id}`

- **Descrição**: Exclui um orçamento (apenas se ainda não foi enviado)
- **Requisição**: `DELETE /api/paint-pro/estimates/{id}`
- **Resposta de Sucesso (200)**:
  ```json
  {
    "success": true,
    "message": "Estimate deleted successfully"
  }
  ```

#### `PATCH /estimates/{id}/status`

- **Descrição**: Atualiza o status de um orçamento
- **Requisição**: `PATCH /api/paint-pro/estimates/{id}/status` com `Content-Type: application/json`
- **Body**:
  ```json
  {
    "status": "completed"
  }
  ```
- **Status Possíveis**: `draft`, `photos_uploaded`, `elements_selected`, `completed`, `sent`
- **Resposta de Sucesso (200)**:
  ```json
  {
    "success": true,
    "message": "Estimate status updated successfully",
    "data": {
      /* orçamento atualizado */
    }
  }
  ```

#### `POST /estimates/{id}/photos`

- **Descrição**: **Upload de Fotos para o Orçamento.** Este endpoint permite o upload das fotos do ambiente para serem anexadas ao orçamento.

- **Requisição**: `POST /api/paint-pro/estimates/{id}/photos` com `Content-Type: multipart/form-data`
- **Body**: Campo `photos[]` com array de arquivos de imagem (ex: `photos[0]`, `photos[1]`)
- **Resposta de Sucesso (200)**:
  ```json
  {
    "success": true,
    "message": "Photos uploaded successfully",
    "data": {
      "id": 1,
      "photos_uploaded": 3,
      "status": "photos_uploaded"
    }
  }
  ```

#### `POST /estimates/{id}/select-elements`

- **Descrição**: Seleciona tintas e calcula custos baseado na área pintável
- **Requisição**: `POST /api/paint-pro/estimates/{id}/select-elements` com `Content-Type: application/json`
- **Body**:
  ```json
  {
    "use_catalog": true,
    "brand_key": "sherwin_williams",
    "color_key": "pure_white",
    "usage": "interior",
    "size_key": "gallon",
    "coats": 2
  }
  ```
- **Resposta de Sucesso (200)**:
  ```json
  {
    "success": true,
    "message": "Elements selected and costs calculated successfully",
    "data": {
      "materials": [
        {
          "brand": "Sherwin Williams",
          "color": "Pure White",
          "quantity": 2,
          "unit_cost": 45.0,
          "total_cost": 90.0
        }
      ],
      "total_cost": 90.0,
      "labor_cost": 200.0,
      "grand_total": 290.0,
      "status": "elements_selected"
    }
  }
  ```

#### `POST /estimates/{id}/complete`

- **Descrição**: Finaliza o orçamento com cálculos finais
- **Requisição**: `POST /api/paint-pro/estimates/{id}/complete`
- **Resposta de Sucesso (200)**:
  ```json
  {
    "success": true,
    "message": "Estimate completed successfully",
    "data": {
      "id": 1,
      "status": "completed",
      "total_cost": 290.0,
      "valid_until": "2024-02-15T10:30:00Z"
    }
  }
  ```

#### `POST /estimates/{id}/send-to-ghl`

- **Descrição**: Envia o orçamento para o GoHighLevel CRM
- **Requisição**: `POST /api/paint-pro/estimates/{id}/send-to-ghl` com `Content-Type: application/json`
- **Body** (opcional):
  ```json
  {
    "include_photos": true,
    "create_opportunity": true,
    "opportunity_value": 290.0,
    "pipeline_stage": "estimate_sent"
  }
  ```
- **Resposta de Sucesso (200)**:
  ```json
  {
    "success": true,
    "message": "Estimate sent to GHL successfully",
    "data": {
      "ghl_contact_id": "contact_123",
      "ghl_opportunity_id": "opp_456",
      "photos_uploaded": 3,
      "status": "sent"
    }
  }
  ```

---

## 7. Catálogo de Tintas (`/api/paint-catalog`)

Endpoints para interagir com o catálogo de tintas.

#### `GET /brands`

- **Descrição**: Lista todas as marcas disponíveis
- **Requisição**: `GET /api/paint-catalog/brands`
- **Headers**: `Accept: application/json`
- **Resposta de Sucesso (200)**:
  ```json
  {
    "success": true,
    "data": [
      {
        "key": "sherwin_williams",
        "name": "Sherwin Williams"
      },
      {
        "key": "benjamin_moore",
        "name": "Benjamin Moore"
      },
      {
        "key": "ppg",
        "name": "PPG"
      }
    ]
  }
  ```

#### `GET /brands/popular`

- **Descrição**: Lista marcas mais populares
- **Requisição**: `GET /api/paint-catalog/brands/popular`
- **Resposta de Sucesso (200)**: Lista das marcas mais utilizadas

#### `GET /brands/{brandKey}/colors`

- **Descrição**: Lista cores de uma marca específica
- **Requisição**: `GET /api/paint-catalog/brands/{brandKey}/colors?usage=interior`
- **Query Params**: `usage` (opcional: `interior`, `exterior`)
- **Resposta de Sucesso (200)**:
  ```json
  {
    "success": true,
    "data": [
      {
        "key": "pure_white",
        "name": "Pure White",
        "hex_code": "#FFFFFF",
        "usage": ["interior", "exterior"],
        "price_per_gallon": 45.0
      }
    ]
  }
  ```

#### `GET /brands/{brandKey}/colors/{colorKey}`

- **Descrição**: Detalhes completos de uma cor específica
- **Requisição**: `GET /api/paint-catalog/brands/{brandKey}/colors/{colorKey}?usage=interior`
- **Resposta de Sucesso (200)**:
  ```json
  {
    "success": true,
    "data": {
      "key": "pure_white",
      "name": "Pure White",
      "hex_code": "#FFFFFF",
      "rgb": [255, 255, 255],
      "usage": ["interior", "exterior"],
      "coverage": 350,
      "drying_time": "2-4 hours",
      "price_per_gallon": 45.0,
      "available_sizes": ["gallon", "5_gallon"]
    }
  }
  ```

#### `GET /search`

- **Descrição**: Busca em todas as cores e marcas
- **Requisição**: `GET /api/paint-catalog/search?q=pure_white&brand=sherwin_williams`
- **Query Params**: `q` (termo de busca), `brand` (opcional)
- **Resposta de Sucesso (200)**: Lista de cores que correspondem à busca

#### `POST /calculate`

- **Descrição**: Calcula a necessidade de tinta para uma área específica
- **Requisição**: `POST /api/paint-catalog/calculate` com `Content-Type: application/json`
- **Body**:
  ```json
  {
    "brand_key": "sherwin_williams",
    "color_key": "pure_white",
    "usage": "interior",
    "area": 450,
    "coats": 2
  }
  ```
- **Resposta de Sucesso (200)**:
  ```json
  {
    "success": true,
    "data": {
      "gallons_needed": 2.57,
      "gallons_rounded": 3,
      "total_cost": 135.0,
      "coverage_per_gallon": 350,
      "coats": 2
    }
  }
  ```

#### `GET /overview`

- **Descrição**: Retorna uma visão geral do catálogo
- **Requisição**: `GET /api/paint-catalog/overview`
- **Resposta de Sucesso (200)**:
  ```json
  {
    "success": true,
    "data": {
      "total_brands": 15,
      "total_colors": 2500,
      "popular_brands": [...],
      "recent_additions": [...]
    }
  }
  ```
