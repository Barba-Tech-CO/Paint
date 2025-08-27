# MÓDULO DE CONTATOS - CRM Integration

Este módulo gerencia a integração completa com contatos do CRM, permitindo operações CRUD, busca avançada e sincronização offline-first no aplicativo Flutter.

## 1. Visão Geral

### 1.1 Funcionalidades Principais
- ✅ **CRUD Completo** - Criar, ler, atualizar e deletar contatos
- ✅ **Busca Avançada** - Filtros múltiplos e ordenação
- ✅ **Sincronização Offline-First** - Cache local com sincronização automática
- ✅ **Autenticação CRM** - OAuth2 integrado
- ✅ **Rate Limiting** - Controle automático de requisições

### 1.2 Limitações e Controles
- **Rate Limiting de Leitura:** 100 requisições/minuto
- **Rate Limiting de Escrita:** 30 requisições/minuto
- **Cache Recomendado:** 1000 contatos por usuário
- **Sincronização:** Automática com controle de conflitos

## 2. Modelo de Dados (Flutter/SQLite)

### 2.1 Estrutura para Cache Local (SQLite)

```sql
CREATE TABLE ghl_contacts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER, -- Isolamento por usuário
    
    -- Identificadores GoHighLevel
    ghl_id TEXT UNIQUE NOT NULL, -- ID único no GoHighLevel
    location_id TEXT NOT NULL, -- ID da localização no GHL
    
    -- Informações Pessoais
    first_name TEXT,
    last_name TEXT,
    email TEXT,
    phone TEXT,
    phone_label TEXT,
    
    -- Informações Empresa
    company_name TEXT,
    business_name TEXT,
    
    -- Endereço Completo
    address TEXT,
    city TEXT,
    state TEXT,
    postal_code TEXT,
    country TEXT,
    
    -- Dados Complexos (JSON como TEXT no SQLite)
    additional_emails TEXT, -- JSON: ["email1@example.com", "email2@example.com"]
    additional_phones TEXT, -- JSON: ["+1234567890", "+0987654321"]
    custom_fields TEXT, -- JSON: [{"id":"field1", "key":"project_type", "field_value":"exterior"}]
    tags TEXT, -- JSON: ["prospect", "paint-service"]
    
    -- Configurações
    type TEXT, -- lead, contact, etc
    source TEXT, -- Fonte do contato
    dnd INTEGER DEFAULT 0, -- Do Not Disturb (0=false, 1=true)
    dnd_settings TEXT, -- JSON: {"Call": {"status": "active"}, "Email": {"status": "inactive"}}
    
    -- Controle de Sincronização Offline-First
    sync_status TEXT DEFAULT 'synced', -- synced, pending, error
    last_synced_at TEXT, -- ISO 8601 timestamp
    sync_error TEXT,
    
    -- Timestamps GoHighLevel
    ghl_created_at TEXT, -- ISO 8601 timestamp
    ghl_updated_at TEXT, -- ISO 8601 timestamp
    created_at TEXT, -- ISO 8601 timestamp
    updated_at TEXT -- ISO 8601 timestamp
);

-- Índices para Performance
CREATE INDEX idx_ghl_contacts_user_id ON ghl_contacts(user_id);
CREATE INDEX idx_ghl_contacts_ghl_id ON ghl_contacts(ghl_id);
CREATE INDEX idx_ghl_contacts_location_id ON ghl_contacts(location_id);
CREATE INDEX idx_ghl_contacts_email ON ghl_contacts(email);
CREATE INDEX idx_ghl_contacts_phone ON ghl_contacts(phone);
CREATE INDEX idx_ghl_contacts_sync_status ON ghl_contacts(sync_status);
CREATE INDEX idx_ghl_contacts_location_sync ON ghl_contacts(location_id, sync_status);
CREATE INDEX idx_ghl_contacts_user_sync ON ghl_contacts(user_id, sync_status, updated_at);
```

### 2.2 Estados de Sincronização

- **synced** - Contato sincronizado com sucesso
- **pending** - Aguardando sincronização  
- **error** - Erro na sincronização

## 3. Endpoints da API

### 3.1 Autenticação Requerida

**Headers obrigatórios em todas as requisições:**
- `Authorization: Bearer {sanctum_token}`
- `X-GHL-Location-ID: {location_id}` ou query param `location_id`
- `Accept: application/json`
- `Content-Type: application/json` (para POST/PUT)

### 3.2 Lista de Endpoints

| Método | Endpoint | Descrição | Rate Limit |
|--------|----------|-----------|------------|
| `GET` | `/api/contacts` | Lista contatos com filtros | 100 req/min |
| `POST` | `/api/contacts` | Cria novo contato | 30 req/min |
| `POST` | `/api/contacts/search` | Busca avançada | 100 req/min |
| `GET` | `/api/contacts/{contactId}` | Busca contato específico | 100 req/min |
| `PUT` | `/api/contacts/{contactId}` | Atualiza contato | 30 req/min |
| `DELETE` | `/api/contacts/{contactId}` | Remove contato | 30 req/min |

## 4. Validação de Dados

### 4.1 Campos para Criar Contato

**Obrigatórios:**
- `firstName` OU `name` - String, máx 255 caracteres

**Opcionais:**
- `lastName` - String, máx 255 caracteres
- `email` - Email válido, máx 255 caracteres
- `phone` - String, máx 20 caracteres
- `gender` - Enum: "male", "female", "other"
- `address1` - String, máx 255 caracteres
- `city` - String, máx 255 caracteres
- `state` - String, máx 255 caracteres
- `postalCode` - String, máx 20 caracteres
- `country` - String, máx 100 caracteres
- `companyName` - String, máx 255 caracteres
- `website` - URL válida, máx 255 caracteres
- `timezone` - String, máx 100 caracteres
- `dnd` - Boolean
- `tags` - Array de strings, cada tag máx 50 caracteres
- `customFields` - Array de objetos CustomField
- `assignedTo` - String (ID do usuário responsável)

### 4.2 Campos para Atualizar Contato

**Todos os campos são opcionais** para operação de atualização, seguindo as mesmas regras de validação da criação.

## 5. Exemplos de Uso

### 5.1 Listar Contatos

**Request:**
```http
GET /api/contacts?location_id=60d5ec49e1b2c50012345678&limit=20&query=maria
Authorization: Bearer {sanctum_token}
X-GHL-Location-ID: 60d5ec49e1b2c50012345678
Accept: application/json
```

**Response (200 OK):**
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

**Response (401 Unauthorized):**
```json
{
  "error": "Token not found or expired",
  "message": "A new OAuth authentication is required",
  "auth_url": "https://paintpro.barbatech.company/api/auth/redirect?location_id=123"
}
```

**Response (429 Too Many Requests):**
```json
{
  "success": false,
  "message": "Too many requests. Please slow down.",
  "error_code": "RATE_LIMIT_EXCEEDED",
  "details": {
    "max_attempts": 100,
    "decay_minutes": 1,
    "retry_after_seconds": 45
  }
}
```

### 5.2 Criar Contato

**Request:**
```http
POST /api/contacts?location_id=60d5ec49e1b2c50012345678
Authorization: Bearer {sanctum_token}
Content-Type: application/json
Accept: application/json
```

**Request Body:**
```json
{
  "firstName": "Maria",
  "lastName": "Silva",
  "email": "maria@example.com",
  "phone": "+1234567890",
  "companyName": "Silva Construções",
  "address1": "123 Main Street",
  "city": "São Paulo",
  "state": "SP",
  "postalCode": "01234-567",
  "country": "Brazil",
  "tags": ["prospect", "referral"],
  "customFields": [
    {
      "id": "field_123",
      "key": "project_type",
      "field_value": "exterior"
    }
  ]
}
```

**Response (201 Created):**
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

**Response (422 Unprocessable Entity):**
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

**Response (401 Unauthorized):**
```json
{
  "error": "Token not found or expired",
  "message": "A new OAuth authentication is required",
  "auth_url": "https://paintpro.barbatech.company/api/auth/redirect?location_id=123"
}
```

**Response (429 Too Many Requests):**
```json
{
  "success": false,
  "message": "Too many requests. Please slow down.",
  "error_code": "RATE_LIMIT_EXCEEDED",
  "details": {
    "max_attempts": 30,
    "decay_minutes": 1,
    "retry_after_seconds": 45
  }
}
```

### 5.3 Busca Avançada de Contatos

**Request:**
```http
POST /api/contacts/search
Authorization: Bearer {sanctum_token}
Content-Type: application/json
Accept: application/json
```

**Request Body:**
```json
{
  "locationId": "60d5ec49e1b2c50012345678",
  "query": "maria",
  "pageLimit": 20,
  "page": 1,
  "filters": [
    {
      "field": "email",
      "operator": "contains",
      "value": "maria"
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

**Response (200 OK):**
```json
{
  "contacts": [
    {
      "id": "60d5ec49e1b2c50012345679",
      "firstName": "Maria",
      "lastName": "Santos",
      "email": "maria@example.com",
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

**Response (422 Unprocessable Entity):**
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": {
    "locationId": ["The location id field is required."],
    "page": ["The page field must be at least 1."]
  }
}
```

**Response (401 Unauthorized):**
```json
{
  "error": "Token not found or expired",
  "message": "A new OAuth authentication is required",
  "auth_url": "https://paintpro.barbatech.company/api/auth/redirect?location_id=123"
}
```

**Response (429 Too Many Requests):**
```json
{
  "success": false,
  "message": "Too many requests. Please slow down.",
  "error_code": "RATE_LIMIT_EXCEEDED",
  "details": {
    "max_attempts": 100,
    "decay_minutes": 1,
    "retry_after_seconds": 45
  }
}
```

### 5.4 Buscar Contato Específico

**Request:**
```http
GET /api/contacts/60d5ec49e1b2c50012345678?location_id=60d5ec49e1b2c50012345678
Authorization: Bearer {sanctum_token}
X-GHL-Location-ID: 60d5ec49e1b2c50012345678
Accept: application/json
```

**Response (200 OK):**
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
    "dndSettings": {
      "Call": {"status": "active"},
      "Email": {"status": "inactive"}
    }
  }
}
```

**Response (404 Not Found):**
```json
{
  "error": "Contact not found"
}
```

**Response (401 Unauthorized):**
```json
{
  "error": "Token not found or expired",
  "message": "A new OAuth authentication is required",
  "auth_url": "https://paintpro.barbatech.company/api/auth/redirect?location_id=123"
}
```

**Response (429 Too Many Requests):**
```json
{
  "success": false,
  "message": "Too many requests. Please slow down.",
  "error_code": "RATE_LIMIT_EXCEEDED",
  "details": {
    "max_attempts": 100,
    "decay_minutes": 1,
    "retry_after_seconds": 45
  }
}
```

### 5.5 Atualizar Contato

**Request:**
```http
PUT /api/contacts/60d5ec49e1b2c50012345678?location_id=60d5ec49e1b2c50012345678
Authorization: Bearer {sanctum_token}
X-GHL-Location-ID: 60d5ec49e1b2c50012345678
Content-Type: application/json
Accept: application/json
```

**Request Body:**
```json
{
  "firstName": "Maria",
  "lastName": "Silva Santos",
  "email": "maria.santos@example.com",
  "companyName": "Silva & Santos Construções",
  "tags": ["prospect", "paint-service", "premium"]
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Contact updated successfully",
  "contactDetails": {
    "id": "60d5ec49e1b2c50012345678",
    "firstName": "Maria",
    "lastName": "Silva Santos",
    "email": "maria.santos@example.com",
    "phone": "+1234567890",
    "companyName": "Silva & Santos Construções",
    "address": "123 Main St, City, State 12345",
    "customFields": [
      {
        "id": "field_123",
        "key": "project_type",
        "field_value": "exterior",
        "source": "custom"
      }
    ],
    "tags": ["prospect", "paint-service", "premium"]
  }
}
```

**Response (404 Not Found):**
```json
{
  "error": "Contact not found"
}
```

**Response (422 Unprocessable Entity):**
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": {
    "email": ["The email must be a valid email address."],
    "tags": ["Each tag must not exceed 50 characters."]
  }
}
```

**Response (401 Unauthorized):**
```json
{
  "error": "Token not found or expired",
  "message": "A new OAuth authentication is required",
  "auth_url": "https://paintpro.barbatech.company/api/auth/redirect?location_id=123"
}
```

**Response (429 Too Many Requests):**
```json
{
  "success": false,
  "message": "Too many requests. Please slow down.",
  "error_code": "RATE_LIMIT_EXCEEDED",
  "details": {
    "max_attempts": 30,
    "decay_minutes": 1,
    "retry_after_seconds": 45
  }
}
```

### 5.6 Deletar Contato

**Request:**
```http
DELETE /api/contacts/60d5ec49e1b2c50012345678?location_id=60d5ec49e1b2c50012345678
Authorization: Bearer {sanctum_token}
X-GHL-Location-ID: 60d5ec49e1b2c50012345678
Accept: application/json
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Contact deleted successfully"
}
```

**Response (404 Not Found):**
```json
{
  "error": "Contact not found"
}
```

**Response (401 Unauthorized):**
```json
{
  "error": "Token not found or expired",
  "message": "A new OAuth authentication is required",
  "auth_url": "https://paintpro.barbatech.company/api/auth/redirect?location_id=123"
}
```

**Response (429 Too Many Requests):**
```json
{
  "success": false,
  "message": "Too many requests. Please slow down.",
  "error_code": "RATE_LIMIT_EXCEEDED",
  "details": {
    "max_attempts": 30,
    "decay_minutes": 1,
    "retry_after_seconds": 45
  }
}
```

## 6. Tratamento de Erros

### 6.1 Todos os Códigos de Status HTTP

**2xx - Sucesso:**
- `200 OK` - Operação bem-sucedida (listar, buscar, atualizar)
- `201 Created` - Contato criado com sucesso

**4xx - Erros do Cliente:**
- `400 Bad Request` - Requisição malformada
- `401 Unauthorized` - Token de autenticação inválido ou expirado
- `403 Forbidden` - Acesso negado ao recurso
- `404 Not Found` - Contato não encontrado
- `422 Unprocessable Entity` - Erro de validação de dados
- `429 Too Many Requests` - Rate limit excedido

**5xx - Erros do Servidor:**
- `500 Internal Server Error` - Erro interno do servidor
- `502 Bad Gateway` - Erro de comunicação com GoHighLevel
- `503 Service Unavailable` - Serviço temporariamente indisponível

### 6.2 Exemplos de Respostas de Erro

**401 Unauthorized:**
```json
{
  "error": "Token not found or expired",
  "message": "A new OAuth authentication is required",
  "auth_url": "https://paintpro.barbatech.company/api/auth/redirect?location_id=123"
}
```

**403 Forbidden:**
```json
{
  "success": false,
  "message": "Access denied to this resource",
  "error_code": "FORBIDDEN"
}
```

**422 Unprocessable Entity:**
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

**429 Too Many Requests:**
```json
{
  "success": false,
  "message": "Too many requests. Please slow down.",
  "error_code": "RATE_LIMIT_EXCEEDED",
  "details": {
    "max_attempts": 100,
    "decay_minutes": 1,
    "retry_after_seconds": 45
  }
}
```

**500 Internal Server Error:**
```json
{
  "success": false,
  "message": "Internal server error occurred",
  "error_code": "INTERNAL_ERROR"
}
```

**502 Bad Gateway:**
```json
{
  "success": false,
  "message": "Unable to communicate with GoHighLevel service",
  "error_code": "UPSTREAM_ERROR"
}
```

**503 Service Unavailable:**
```json
{
  "success": false,
  "message": "Service temporarily unavailable. Please try again later.",
  "error_code": "SERVICE_UNAVAILABLE"
}
```

## 7. Sincronização Offline-First

### 7.1 Controle de Estado

**Estados de sync_status:**
- **synced** - Contato sincronizado com sucesso
- **pending** - Aguardando sincronização
- **error** - Erro na sincronização

### 7.2 Queries SQLite Essenciais

**Buscar contatos para sincronização:**
```sql
SELECT * FROM ghl_contacts 
WHERE user_id = ? 
AND (sync_status = 'pending' OR sync_status = 'error')
ORDER BY 
  CASE sync_status 
    WHEN 'error' THEN 1 
    WHEN 'pending' THEN 2 
    ELSE 3 
  END, 
  updated_at DESC;
```

**Buscar mudanças incrementais:**
```sql
SELECT * FROM ghl_contacts 
WHERE user_id = ? 
AND updated_at > ?
ORDER BY updated_at ASC;
```

### 7.3 Estratégias de Cache

**Limite recomendado:** 1000 contatos por usuário

**Limpeza de cache:**
```sql
DELETE FROM ghl_contacts 
WHERE user_id = ? 
AND id NOT IN (
  SELECT id FROM ghl_contacts 
  WHERE user_id = ? 
  ORDER BY last_synced_at DESC, updated_at DESC 
  LIMIT ?
);
```

## 8. Integração GoHighLevel

### 8.1 Configuração de Headers

A API detecta automaticamente o `location_id` de múltiplas fontes:
1. **Query parameter:** `?location_id=123`
2. **Header HTTP:** `X-GHL-Location-ID: 123`
3. **Parâmetro de rota:** `/{location_id}`

**Recomendado:** Usar sempre o header HTTP `X-GHL-Location-ID` para consistência.

### 8.2 Estrutura DND Settings

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

### 8.3 Campos Personalizados do GHL

```json
{
  "customFields": [
    {
      "id": "field_unique_id",
      "key": "project_type",
      "field_value": "exterior_painting",
      "source": "custom"
    }
  ]
}
```

### Health Check de Tokens

**GET /api/auth/status** - Verifica status dos tokens GoHighLevel.

---

**Módulo:** GoHighLevel Contacts  
**Versão:** 1.0.1  
**Última Atualização:** 2025-01-20  
**Plataforma:** Flutter + SQLite  
**Suporte Offline:** ✅ Completo  
**Sincronização:** ✅ Automática