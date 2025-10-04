# GoHighLevel Contacts

Gestão de contatos no CRM GoHighLevel com operações CRUD completas e suporte offline-first.

## 🔗 Links Rápidos
- Módulo de domínio: `docs/CONTATOS_MODULE.MD`
- Autenticação relacionada: `docs/reference/ghl-auth.md`
- Coleção Postman (`/Contacts`): `docs/collections/api-postman.json`

## 📊 Estrutura da Tabela (Offline-First)

A tabela `ghl_contacts` armazena cache local dos contatos do GoHighLevel com controle de sincronização.

### Schema da Tabela
```sql
CREATE TABLE ghl_contacts (
    id BIGINT UNSIGNED PRIMARY KEY,
    user_id BIGINT UNSIGNED, -- Isolamento por usuário
    
    -- Identificadores GHL
    ghl_id VARCHAR(255) UNIQUE, -- ID único no GoHighLevel
    location_id VARCHAR(255), -- ID da localização no GHL
    
    -- Informações Pessoais
    first_name VARCHAR(255) NULL,
    last_name VARCHAR(255) NULL,
    email VARCHAR(255) NULL,
    phone VARCHAR(255) NULL,
    
    -- Informações Empresa
    company_name VARCHAR(255) NULL,
    business_name VARCHAR(255) NULL,
    
    -- Endereço Completo
    address TEXT NULL,
    city VARCHAR(255) NULL,
    state VARCHAR(255) NULL,
    postal_code VARCHAR(255) NULL,
    country VARCHAR(255) NULL,
    
    -- Dados JSON para Offline
    additional_emails JSON NULL,
    additional_phones JSON NULL,
    custom_fields JSON NULL,
    tags JSON NULL,
    dnd_settings JSON NULL,
    
    -- Controle Offline-First
    sync_status ENUM('synced', 'pending', 'error') DEFAULT 'synced',
    last_synced_at TIMESTAMP NULL,
    sync_error TEXT NULL,
    
    -- Timestamps
    ghl_created_at TIMESTAMP NULL,
    ghl_updated_at TIMESTAMP NULL,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    
    -- Índices para Performance Offline
    KEY idx_user_id (user_id),
    KEY idx_sync_status (sync_status),
    KEY idx_user_sync (user_id, sync_status, updated_at)
);
```

### Campos para Sincronização Offline
- **`sync_status`** - `synced`, `pending`, `error`
- **`last_synced_at`** - Timestamp da última sincronização
- **`sync_error`** - Mensagem de erro para retry
- **`user_id`** - Isolamento por usuário para cache local

## Autenticação Requerida

Todos os endpoints requerem:
- `Authorization: Bearer {token}` (Sanctum)
- `X-GHL-Location-ID: {location-id}` ou parâmetro `location_id`

## Endpoints

### `GET /api/contacts`

**Lista todos os contatos do GoHighLevel**

Retorna lista paginada de contatos do CRM GoHighLevel com filtros opcionais.

**Método & URL:** `GET /api/contacts`  
**Nome da rota:** N/A  
**Autenticação:** `Bearer {token}` + GHL Token  
**Permissões/Scopes:** N/A

#### Query params
- `limit` (integer, opcional, min: 1, max: 100, default: 20) — Número de contatos por página
- `query` (string, opcional) — Busca por nome, email ou telefone
- `location_id` (string, obrigatório) — ID da localização no GoHighLevel

#### Respostas

##### `200 OK` — Lista de contatos retornada com sucesso

```json
{
  "contacts": [
    {
      "id": "60d5ec49e1b2c50012345678",
      "firstName": "Maria",
      "lastName": "Silva",
      "email": "maria@example.com",
      "phone": "+1234567890",
      "companyName": "Silva Construções",
      "address": "123 Main St, City, State 12345",
      "city": "São Paulo",
      "state": "SP",
      "postalCode": "01234-567",
      "country": "Brazil",
      "additionalEmails": ["maria.work@example.com"],
      "additionalPhones": ["+1234567891"],
      "customFields": [
        {
          "id": "field_123",
          "key": "project_type",
          "field_value": "exterior",
          "source": "custom"
        }
      ],
      "tags": ["prospect", "paint-service"],
      "dnd": false,
      "dndSettings": {}
    }
  ],
  "count": 15
}
```

##### `401 Unauthorized` — Token GHL inválido ou expirado

```json
{
  "error": "Token not found or expired",
  "message": "A new OAuth authentication is required",
  "auth_url": "https://paintpro.barbatech.company/api/auth/redirect?location_id=123"
}
```

---

### `POST /api/contacts`

**Cria novo contato no GoHighLevel**

Adiciona um novo contato ao CRM GoHighLevel.

**Método & URL:** `POST /api/contacts`  
**Nome da rota:** N/A  
**Autenticação:** `Bearer {token}` + GHL Token  
**Permissões/Scopes:** N/A

#### Query params
- `location_id` (string, obrigatório) — ID da localização no GoHighLevel

#### Body (JSON)

```json
{
  "name": "Maria Silva",
  "firstName": "Maria",
  "lastName": "Silva",
  "email": "maria@example.com",
  "phone": "+1234567890",
  "gender": "female",
  "address1": "123 Main Street",
  "city": "São Paulo",
  "state": "SP",
  "postalCode": "01234-567",
  "country": "Brazil",
  "companyName": "Silva Construções",
  "website": "https://silvacons.com",
  "timezone": "America/Sao_Paulo",
  "dnd": false,
  "tags": ["prospect", "referral"],
  "customFields": [
    {
      "id": "field_123",
      "key": "project_type",
      "field_value": "exterior",
      "source": "custom"
    }
  ],
  "assignedTo": "user_456"
}
```

**Campos do body:**
- `name` (string, condicional, max: 255) — Nome completo (obrigatório se firstName não fornecido)
- `firstName` (string, condicional, max: 255) — Primeiro nome (obrigatório se name não fornecido)
- `lastName` (string, opcional, max: 255) — Sobrenome
- `email` (string, opcional, email) — Email principal
- `phone` (string, opcional) — Telefone principal
- `gender` (string, opcional, enum: `male|female|other`) — Gênero
- `address1` (string, opcional, max: 255) — Endereço principal
- `city` (string, opcional, max: 255) — Cidade
- `state` (string, opcional, max: 255) — Estado/província
- `postalCode` (string, opcional, max: 20) — CEP/código postal
- `country` (string, opcional, max: 100) — País
- `companyName` (string, opcional, max: 255) — Nome da empresa
- `website` (string, opcional, url) — Website
- `timezone` (string, opcional, max: 100) — Timezone
- `dnd` (boolean, opcional) — Do not disturb
- `tags` (array<string>, opcional) — Tags do contato
- `customFields` (array, opcional) — Campos customizados
- `assignedTo` (string, opcional) — ID do usuário responsável

#### Respostas

##### `201 Created` — Contato criado com sucesso

```json
{
  "success": true,
  "message": "Contact created successfully",
  "contactDetails": {
    "id": "60d5ec49e1b2c50012345678",
    "firstName": "Maria",
    "lastName": "Silva",
    "email": "maria@example.com",
    "phone": "+1234567890",
    "companyName": "Silva Construções",
    "address": "123 Main St, City, State 12345",
    "customFields": [],
    "tags": ["prospect", "referral"]
  }
}
```

##### `422 Unprocessable Entity` — Erro de validação

```json
{
  "success": false,
  "message": "Validation failed",
  "errors": {
    "firstName": ["The first name field is required when name is not present."],
    "email": ["The email must be a valid email address."]
  }
}
```

---

### `POST /api/contacts/search`

**Busca contatos no GoHighLevel**

Realiza busca específica por contatos usando múltiplos critérios avançados.

**Método & URL:** `POST /api/contacts/search`  
**Nome da rota:** N/A  
**Autenticação:** `Bearer {token}` + GHL Token  
**Permissões/Scopes:** N/A

#### Body (JSON)

```json
{
  "locationId": "5DP41231LkQsiKESj6rh",
  "pageLimit": 20,
  "page": 1,
  "query": "joao",
  "filters": [
    {
      "field": "email",
      "operator": "contains",
      "value": "joao@example.com"
    }
  ],
  "sort": [
    {
      "field": "dateAdded",
      "direction": "desc"
    }
  ]
}
```

**Campos do body:**
- `locationId` (string, opcional) — ID da localização
- `pageLimit` (integer, opcional, min: 1, max: 100, default: 20) — Itens por página
- `page` (integer, opcional, min: 1, default: 1) — Página atual
- `query` (string, opcional) — Busca textual
- `filters` (array, opcional) — Filtros avançados
- `sort` (array, opcional) — Ordenação

#### Respostas

##### `200 OK` — Resultados da busca

```json
{
  "contacts": [
    {
      "id": "60d5ec49e1b2c50012345679",
      "firstName": "João",
      "lastName": "Santos",
      "email": "joao@example.com",
      "phone": "+1234567890",
      "companyName": null,
      "address": "456 Another St",
      "customFields": [],
      "tags": ["lead"]
    }
  ],
  "count": 3
}
```

---

### `GET /api/contacts/{contactId}`

**Busca contato específico no GoHighLevel**

Retorna detalhes completos de um contato específico pelo ID.

**Método & URL:** `GET /api/contacts/{contactId}`  
**Nome da rota:** N/A  
**Autenticação:** `Bearer {token}` + GHL Token  
**Permissões/Scopes:** N/A

#### Path params
- `contactId` (string, obrigatório) — ID do contato no GoHighLevel

#### Query params
- `location_id` (string, obrigatório) — ID da localização no GoHighLevel

#### Respostas

##### `200 OK` — Contato encontrado

```json
{
  "success": true,
  "contactDetails": {
    "id": "60d5ec49e1b2c50012345678",
    "firstName": "Maria",
    "lastName": "Silva",
    "email": "maria@example.com",
    "phone": "+1234567890",
    "companyName": "Silva Construções",
    "address": "123 Main St, City, State 12345",
    "city": "São Paulo",
    "state": "SP",
    "postalCode": "01234-567",
    "country": "Brazil",
    "additionalEmails": ["maria.work@example.com"],
    "additionalPhones": ["+1234567891"],
    "customFields": [
      {
        "id": "field_123",
        "key": "project_type",
        "field_value": "exterior",
        "source": "custom"
      }
    ],
    "tags": ["prospect", "paint-service"],
    "dnd": false,
    "dndSettings": {}
  }
}
```

##### `404 Not Found` — Contato não encontrado

```json
{
  "error": "Contact not found"
}
```

---

### `PUT /api/contacts/{contactId}`

**Atualiza contato no GoHighLevel**

Atualiza dados de um contato existente no CRM GoHighLevel.

**Método & URL:** `PUT /api/contacts/{contactId}`  
**Nome da rota:** N/A  
**Autenticação:** `Bearer {token}` + GHL Token  
**Permissões/Scopes:** N/A

#### Path params
- `contactId` (string, obrigatório) — ID do contato no GoHighLevel

#### Query params
- `location_id` (string, obrigatório) — ID da localização no GoHighLevel

#### Body (JSON)

```json
{
  "name": "Maria Silva Santos",
  "firstName": "Maria",
  "lastName": "Silva Santos",
  "email": "maria.santos@example.com",
  "phone": "+1234567891",
  "companyName": "Santos & Cia Ltda",
  "address1": "456 New Street",
  "city": "Rio de Janeiro",
  "state": "RJ",
  "postalCode": "20000-000",
  "country": "Brazil"
}
```

**Campos do body:** (todos opcionais para update)
- `name` (string, opcional, max: 255) — Nome completo
- `firstName` (string, opcional, max: 255) — Primeiro nome
- `lastName` (string, opcional, max: 255) — Sobrenome
- `email` (string, opcional, email) — Email principal
- `phone` (string, opcional) — Telefone principal
- `gender` (string, opcional, enum: `male|female|other`) — Gênero
- `address1` (string, opcional, max: 255) — Endereço principal
- `city` (string, opcional, max: 255) — Cidade
- `state` (string, opcional, max: 255) — Estado/província
- `postalCode` (string, opcional, max: 20) — CEP/código postal
- `country` (string, opcional, max: 100) — País
- `companyName` (string, opcional, max: 255) — Nome da empresa
- `website` (string, opcional, url) — Website
- `timezone` (string, opcional, max: 100) — Timezone
- `dnd` (boolean, opcional) — Do not disturb
- `tags` (array<string>, opcional) — Tags do contato
- `customFields` (array, opcional) — Campos customizados
- `assignedTo` (string, opcional) — ID do usuário responsável

#### Respostas

##### `200 OK` — Contato atualizado com sucesso

```json
{
  "success": true,
  "message": "Contact updated successfully",
  "contactDetails": {
    "id": "60d5ec49e1b2c50012345678",
    "firstName": "Maria",
    "lastName": "Silva Santos",
    "email": "maria.santos@example.com",
    "phone": "+1234567891",
    "companyName": "Santos & Cia Ltda",
    "address": "456 New Street, Rio de Janeiro, RJ",
    "customFields": [],
    "tags": []
  }
}
```

##### `404 Not Found` — Contato não encontrado

```json
{
  "error": "Contact not found"
}
```

---

### `DELETE /api/contacts/{contactId}`

**Remove contato do GoHighLevel**

Remove permanentemente um contato do CRM GoHighLevel.

**Método & URL:** `DELETE /api/contacts/{contactId}`  
**Nome da rota:** N/A  
**Autenticação:** `Bearer {token}` + GHL Token  
**Permissões/Scopes:** N/A

#### Path params
- `contactId` (string, obrigatório) — ID do contato no GoHighLevel

#### Query params
- `location_id` (string, obrigatório) — ID da localização no GoHighLevel

#### Respostas

##### `200 OK` — Contato removido com sucesso

```json
{
  "success": true,
  "message": "Contact deleted successfully",
  "verification": {
    "status": 404,
    "message": "Contact confirmed as deleted"
  }
}
```

##### `404 Not Found` — Contato não encontrado

```json
{
  "error": "Contact not found"
}
```

## Rate Limiting

- **Read operations:** 100 req/min
- **Write operations:** 30 req/min
- **GHL sync operations:** 10 req/5min

## Estrutura do Contato

### Campos Principais
- **Identificação:** `id`, `firstName`, `lastName`
- **Contato:** `email`, `phone`, `additionalEmails`, `additionalPhones`
- **Localização:** `address1`, `city`, `state`, `postalCode`, `country`
- **Empresa:** `companyName`, `website`
- **Configurações:** `timezone`, `dnd`, `dndSettings`
- **Tags e Campos:** `tags`, `customFields`
- **Atribuição:** `assignedTo`

### DND Settings Structure
```json
{
  "Call": {"status": "active"},
  "Email": {"status": "inactive"},
  "SMS": {"status": "permanent"},
  "WhatsApp": {"status": "active"},
  "GMB": {"status": "inactive"},
  "FB": {"status": "active"}
}
```

## Exemplos cURL

### Listar contatos
```bash
curl -X GET "https://paintpro.barbatech.company/api/contacts?location_id=60d5ec49e1b2c50012345678&limit=10" \
  -H "Authorization: Bearer {your-token}" \
  -H "Accept: application/json"
```

### Criar contato
```bash
curl -X POST "https://paintpro.barbatech.company/api/contacts?location_id=60d5ec49e1b2c50012345678" \
  -H "Authorization: Bearer {your-token}" \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Maria",
    "lastName": "Silva",
    "email": "maria@example.com",
    "phone": "+1234567890"
  }'
```

### Buscar contatos
```bash
curl -X POST "https://paintpro.barbatech.company/api/contacts/search" \
  -H "Authorization: Bearer {your-token}" \
  -H "Content-Type: application/json" \
  -d '{
    "locationId": "60d5ec49e1b2c50012345678",
    "query": "maria",
    "pageLimit": 20
  }'
```
