# 📋 Módulo de Contatos da API - Documentação Completa

## 📖 Visão Geral

O módulo de contatos da API PaintPro integra com o CRM GoHighLevel para gerenciar contatos, leads e sincronização de dados. Este módulo fornece endpoints RESTful para operações CRUD completas e sincronização bidirecional com o sistema externo.

## 🏗️ Arquitetura

### Estrutura de Pastas

```
app/Modules/GoHighLevel/
├── Controllers/
│   └── GhlContactController.php
├── Models/
│   └── GhlContact.php
├── Services/
│   ├── GhlContactService.php
│   └── GhlContactSyncService.php
├── Requests/
│   ├── CreateGhlContactRequest.php
│   └── UpdateGhlContactRequest.php
└── Repositories/
    └── GhlContactRepository.php
```

### Princípios da Arquitetura

- **Integração GHL**: Comunicação direta com GoHighLevel CRM
- **Sincronização Bidirecional**: Dados sincronizados entre sistemas
- **Validação Robusta**: Validação de dados antes do envio
- **Tratamento de Erros**: Gestão completa de erros e exceções
- **Modular**: Estrutura DDD com separação clara de responsabilidades

## 🗄️ Modelo de Dados

### Model: GhlContact

```php
<?php
namespace App\Modules\GoHighLevel\Models;

class GhlContact extends Model
{
    protected $table = 'ghl_contacts';

    protected $fillable = [
        'ghl_id', 'location_id', 'first_name', 'last_name', 'email', 'phone',
        'phone_label', 'company_name', 'business_name', 'address', 'city',
        'state', 'postal_code', 'country', 'additional_emails',
        'additional_phones', 'custom_fields', 'tags', 'type', 'source',
        'dnd', 'dnd_settings', 'sync_status', 'last_synced_at',
        'sync_error', 'ghl_created_at', 'ghl_updated_at'
    ];

    protected $casts = [
        'additional_emails' => 'array',
        'additional_phones' => 'array',
        'custom_fields' => 'array',
        'tags' => 'array',
        'dnd_settings' => 'array',
        'dnd' => 'boolean',
        'last_synced_at' => 'datetime',
        'ghl_created_at' => 'datetime',
        'ghl_updated_at' => 'datetime'
    ];
}
```

### Tabela do Banco: ghl_contacts

```sql
CREATE TABLE ghl_contacts (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    -- Campos principais do GoHighLevel
    ghl_id VARCHAR(255) UNIQUE NOT NULL COMMENT 'ID único do contato no GoHighLevel',
    location_id VARCHAR(255) NOT NULL COMMENT 'ID da localização no GoHighLevel',

    -- Informações pessoais
    first_name VARCHAR(255) NULL,
    last_name VARCHAR(255) NULL,
    email VARCHAR(255) NULL,
    phone VARCHAR(255) NULL,
    phone_label VARCHAR(255) NULL,

    -- Informações de empresa
    company_name VARCHAR(255) NULL,
    business_name VARCHAR(255) NULL,

    -- Endereço
    address TEXT NULL,
    city VARCHAR(255) NULL,
    state VARCHAR(255) NULL,
    postal_code VARCHAR(255) NULL,
    country VARCHAR(255) NULL,

    -- Campos adicionais
    additional_emails JSON NULL,
    additional_phones JSON NULL,
    custom_fields JSON NULL,
    tags JSON NULL,

    -- Metadados
    type VARCHAR(255) NULL COMMENT 'lead, contact, etc',
    source VARCHAR(255) NULL,
    dnd BOOLEAN DEFAULT FALSE COMMENT 'Do Not Disturb',
    dnd_settings JSON NULL,

    -- Status de sincronização
    sync_status ENUM('synced', 'pending', 'error') DEFAULT 'synced',
    last_synced_at TIMESTAMP NULL,
    sync_error TEXT NULL,
    ghl_created_at TIMESTAMP NULL,
    ghl_updated_at TIMESTAMP NULL,

    -- Timestamps padrão
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    -- Índices
    INDEX idx_ghl_id (ghl_id),
    INDEX idx_location_id (location_id),
    INDEX idx_email (email),
    INDEX idx_phone (phone),
    INDEX idx_sync_status (sync_status)
);
```

## 🌐 Endpoints da API

### Base URL

```
https://paintpro.barbatech.company/api/v1/contacts
```

### Autenticação

Todos os endpoints requerem autenticação via token GoHighLevel:

```
Authorization: Bearer {ghl_token}
```

## 📋 Endpoints Disponíveis

### 1. Listar Contatos

**GET** `/api/v1/contacts`

Lista todos os contatos do GoHighLevel com paginação e filtros.

#### Parâmetros de Query

| Parâmetro | Tipo    | Obrigatório | Descrição                                         |
| --------- | ------- | ----------- | ------------------------------------------------- |
| `limit`   | integer | Não         | Número de contatos por página (1-100, padrão: 20) |
| `query`   | string  | Não         | Busca por nome, email ou telefone                 |

#### Exemplo de Request

```bash
GET /api/v1/contacts?limit=10&query=maria
```

#### Exemplo de Response (200 OK)

```json
{
  "contacts": [
    {
      "id": "60d5ec49e1b2c50012345678",
      "name": "Maria Silva",
      "firstName": "Maria",
      "lastName": "Silva",
      "phoneNo": "+5511999999999",
      "phoneLabel": "mobile",
      "email": "maria@example.com",
      "additionalEmails": ["maria.silva@company.com"],
      "additionalPhones": ["+5511888888888"],
      "companyName": "Silva Construções",
      "businessName": "Silva Construções Ltda",
      "address": "Rua das Flores, 123",
      "city": "São Paulo",
      "state": "SP",
      "postalCode": "01234-567",
      "country": "BR",
      "customFields": [
        {
          "field": "project_type",
          "value": "exterior"
        }
      ]
    }
  ],
  "count": 1
}
```

#### Status Codes

- **200 OK**: Contatos retornados com sucesso
- **401 Unauthorized**: Token GHL inválido ou expirado
- **500 Internal Server Error**: Erro interno do servidor

---

### 2. Buscar Contatos

**POST** `/api/v1/contacts/search`

Realiza busca avançada por contatos usando múltiplos critérios.

#### Request Body

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

#### Exemplo de Response (200 OK)

```json
{
  "contacts": [
    {
      "id": "60d5ec49e1b2c50012345679",
      "name": "João Santos",
      "firstName": "João",
      "lastName": "Santos",
      "phoneNo": "+5511777777777",
      "phoneLabel": "work",
      "email": "joao@example.com",
      "additionalEmails": [],
      "additionalPhones": [],
      "companyName": "Santos Arquitetura",
      "businessName": "Santos Arquitetura Ltda",
      "address": "Av. Paulista, 1000",
      "city": "São Paulo",
      "state": "SP",
      "postalCode": "01310-100",
      "country": "BR",
      "customFields": [],
      "tags": ["arquiteto", "premium"],
      "type": "contact",
      "source": "website",
      "dnd": false,
      "dndSettings": [],
      "dateAdded": "2024-01-15T10:30:00Z",
      "dateUpdated": "2024-01-20T14:45:00Z",
      "assignedTo": "user123",
      "locationId": "5DP41231LkQsiKESj6rh",
      "validEmail": true,
      "opportunities": []
    }
  ],
  "count": 1
}
```

---

### 3. Buscar Contato Específico

**GET** `/api/v1/contacts/{contactId}`

Retorna detalhes completos de um contato específico.

#### Parâmetros de Path

| Parâmetro   | Tipo   | Obrigatório | Descrição                    |
| ----------- | ------ | ----------- | ---------------------------- |
| `contactId` | string | Sim         | ID do contato no GoHighLevel |

#### Exemplo de Request

```bash
GET /api/v1/contacts/60d5ec49e1b2c50012345678
```

#### Exemplo de Response (200 OK)

```json
{
  "success": true,
  "contactDetails": {
    "id": "60d5ec49e1b2c50012345678",
    "name": "Maria Silva",
    "phoneNo": "+5511999999999",
    "email": "maria@example.com",
    "additionalEmails": ["maria.silva@company.com"],
    "companyName": "Silva Construções",
    "address": "Rua das Flores, 123",
    "customFields": [
      {
        "field": "project_type",
        "value": "exterior"
      }
    ]
  }
}
```

---

### 4. Criar Contato

**POST** `/api/v1/contacts`

Cria um novo contato no GoHighLevel.

#### Request Body

```json
{
  "name": "Maria Silva",
  "email": "maria@example.com",
  "phone": "+5511999999999",
  "companyName": "Silva Construções",
  "address": "Rua das Flores, 123, São Paulo, SP, 01234-567",
  "customFields": [
    {
      "field": "project_type",
      "value": "exterior"
    }
  ]
}
```

#### Exemplo de Response (201 Created)

```json
{
  "success": true,
  "message": "Contact created successfully",
  "contactDetails": {
    "id": "60d5ec49e1b2c50012345678",
    "name": "Maria Silva",
    "firstName": "Maria",
    "lastName": "Silva",
    "phoneNo": "+5511999999999",
    "phoneLabel": null,
    "email": "maria@example.com",
    "additionalEmails": [],
    "additionalPhones": [],
    "companyName": "Silva Construções",
    "businessName": null,
    "address": "Rua das Flores, 123",
    "city": "São Paulo",
    "state": "SP",
    "postalCode": "01234-567",
    "country": "BR",
    "customFields": [
      {
        "field": "project_type",
        "value": "exterior"
      }
    ],
    "tags": [],
    "type": null,
    "source": null,
    "dnd": false,
    "dndSettings": [],
    "dateAdded": "2024-01-25T15:30:00Z",
    "dateUpdated": "2024-01-25T15:30:00Z",
    "assignedTo": null,
    "locationId": "5DP41231LkQsiKESj6rh",
    "validEmail": true,
    "opportunities": []
  },
  "isExisting": false
}
```

#### Exemplo de Response (200 OK - Contato Existente)

```json
{
  "success": true,
  "message": "Contact already exists",
  "contactDetails": {
    "id": "60d5ec49e1b2c50012345678",
    "name": "Maria Silva",
    "firstName": "Maria",
    "lastName": "Silva",
    "phoneNo": "+5511999999999",
    "email": "maria@example.com",
    "companyName": "Silva Construções",
    "address": "Rua das Flores, 123",
    "customFields": [
      {
        "field": "project_type",
        "value": "exterior"
      }
    ]
  },
  "isExisting": true
}
```

---

### 5. Atualizar Contato

**PUT** `/api/v1/contacts/{contactId}`

Atualiza dados de um contato existente.

#### Parâmetros de Path

| Parâmetro   | Tipo   | Obrigatório | Descrição                    |
| ----------- | ------ | ----------- | ---------------------------- |
| `contactId` | string | Sim         | ID do contato no GoHighLevel |

#### Request Body

```json
{
  "name": "Maria Silva Santos",
  "email": "maria.santos@example.com",
  "phone": "+5511999999998",
  "companyName": "Silva & Santos Ltda",
  "address": "456 Nova Rua, São Paulo, SP, 01234-789"
}
```

#### Exemplo de Response (200 OK)

```json
{
  "success": true,
  "message": "Contact updated successfully",
  "contactDetails": {
    "id": "60d5ec49e1b2c50012345678",
    "name": "Maria Silva Santos",
    "phoneNo": "+5511999999998",
    "email": "maria.santos@example.com",
    "additionalEmails": [],
    "companyName": "Silva & Santos Ltda",
    "address": "456 Nova Rua, São Paulo, SP, 01234-789",
    "customFields": []
  }
}
```

---

### 6. Deletar Contato

**DELETE** `/api/v1/contacts/{contactId}`

Remove permanentemente um contato do GoHighLevel.

#### Parâmetros de Path

| Parâmetro   | Tipo   | Obrigatório | Descrição                    |
| ----------- | ------ | ----------- | ---------------------------- |
| `contactId` | string | Sim         | ID do contato no GoHighLevel |

#### Exemplo de Request

```bash
DELETE /api/v1/contacts/60d5ec49e1b2c50012345678
```

#### Exemplo de Response (200 OK)

```json
{
  "success": true,
  "message": "Contact deleted successfully",
  "verification": {
    "status": 404,
    "message": "Contact confirmed as deleted from GoHighLevel",
    "local_deleted": true
  }
}
```

## 🔄 Sincronização

### Serviço de Sincronização

O módulo inclui um serviço dedicado para sincronização com o GoHighLevel:

```php
class GhlContactSyncService
{
    public function syncContact(string $ghlId, string $locationId): bool
    public function markAsDeleted(string $ghlId): bool
}
```

### Status de Sincronização

- **`synced`**: Contato sincronizado com sucesso
- **`pending`**: Aguardando sincronização
- **`error`**: Erro na sincronização

## 📊 Validações

### CreateGhlContactRequest

- `name` ou `firstName`: obrigatório (pelo menos um)
- `email`: formato válido de email
- `phone`: string opcional
- `companyName`: string opcional
- `address`: string opcional

### UpdateGhlContactRequest

- Todos os campos são opcionais
- Validações aplicadas apenas aos campos fornecidos

### Estrutura de Custom Fields

```json
{
  "custom_fields": [
    {
      "key": "string_required",
      "value": "any_type",
      "type": "string|number|boolean|date",
      "required": false
    }
  ]
}
```

### Estrutura de Tags

```json
{
  "tags": ["string1", "string2", "string3"]
}
```

## 🚨 Tratamento de Erros

### Estrutura de Erro Padrão

```json
{
  "success": false,
  "message": "Descrição do erro",
  "error": "Detalhes técnicos do erro"
}
```

### Códigos de Erro Comuns

- **400**: Parâmetros inválidos ou dados incorretos
- **401**: Autenticação falhou
- **404**: Recurso não encontrado
- **422**: Erro de validação
- **500**: Erro interno do servidor

## 🔐 Segurança

### Autenticação

- Token GoHighLevel obrigatório em todos os endpoints
- Validação automática de expiração de token
- Middleware `ValidateGhlToken`
