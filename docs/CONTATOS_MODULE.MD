# MÓDULO DE CONTATOS - CONTATOS_MODULE

Este módulo gerencia a integração com contatos do GoHighLevel CRM, permitindo listar, criar, atualizar e sincronizar contatos entre o sistema local e o GoHighLevel.

## 1. Modelos de Dados e Estrutura da Tabela

### Modelo GhlContact (Contato GoHighLevel)

**Arquivo:** `app/Modules/GoHighLevel/Models/GhlContact.php`

**Atributos do Model:**
- `id` (integer, not null) - ID único local do contato
- `ghl_id` (string, not null, unique) - ID único do contato no GoHighLevel
- `location_id` (string, not null) - ID da localização no GoHighLevel
- `first_name` (string, nullable) - Primeiro nome
- `last_name` (string, nullable) - Último nome
- `email` (string, nullable) - Email principal
- `phone` (string, nullable) - Telefone principal
- `phone_label` (string, nullable) - Rótulo do telefone
- `company_name` (string, nullable) - Nome da empresa
- `business_name` (string, nullable) - Nome do negócio
- `address` (text, nullable) - Endereço completo
- `city` (string, nullable) - Cidade
- `state` (string, nullable) - Estado
- `postal_code` (string, nullable) - CEP
- `country` (string, nullable) - País
- `additional_emails` (array, nullable) - Emails adicionais
- `additional_phones` (array, nullable) - Telefones adicionais
- `custom_fields` (array, nullable) - Campos personalizados
- `tags` (array, nullable) - Tags do contato
- `type` (string, nullable) - Tipo do contato (lead, contact, etc)
- `source` (string, nullable) - Fonte do contato
- `dnd` (boolean, not null) - Do Not Disturb (não perturbar)
- `dnd_settings` (array, nullable) - Configurações de DND
- `sync_status` (enum, not null) - Status de sincronização (synced, pending, error)
- `last_synced_at` (timestamp, nullable) - Última sincronização
- `sync_error` (text, nullable) - Erro de sincronização
- `ghl_created_at` (timestamp, nullable) - Data de criação no GoHighLevel
- `ghl_updated_at` (timestamp, nullable) - Data de atualização no GoHighLevel
- `created_at` (timestamp, not null) - Data de criação local
- `updated_at` (timestamp, not null) - Data de atualização local

**Estrutura da Tabela `ghl_contacts`:**
```sql
CREATE TABLE ghl_contacts (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    ghl_id VARCHAR(255) NOT NULL UNIQUE,
    location_id VARCHAR(255) NOT NULL,
    first_name VARCHAR(255) NULL,
    last_name VARCHAR(255) NULL,
    email VARCHAR(255) NULL,
    phone VARCHAR(255) NULL,
    phone_label VARCHAR(255) NULL,
    company_name VARCHAR(255) NULL,
    business_name VARCHAR(255) NULL,
    address TEXT NULL,
    city VARCHAR(255) NULL,
    state VARCHAR(255) NULL,
    postal_code VARCHAR(255) NULL,
    country VARCHAR(255) NULL,
    additional_emails JSON NULL,
    additional_phones JSON NULL,
    custom_fields JSON NULL,
    tags JSON NULL,
    type VARCHAR(255) NULL,
    source VARCHAR(255) NULL,
    dnd BOOLEAN DEFAULT FALSE,
    dnd_settings JSON NULL,
    sync_status ENUM('synced', 'pending', 'error') DEFAULT 'synced',
    last_synced_at TIMESTAMP NULL,
    sync_error TEXT NULL,
    ghl_created_at TIMESTAMP NULL,
    ghl_updated_at TIMESTAMP NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    INDEX idx_location (location_id),
    INDEX idx_email (email),
    INDEX idx_phone (phone),
    INDEX idx_sync_status (sync_status),
    INDEX idx_location_sync (location_id, sync_status)
);
```

## 2. Endpoints da API

### 2.1 Listar Contatos

**Título:** Listar Todos os Contatos  
**Descrição:** Retorna lista paginada de contatos do CRM GoHighLevel com filtros opcionais

**URL e Método HTTP:** `GET /api/contacts`  
**Parâmetros da Rota:** Nenhum  
**Query Parameters:**
- `limit` (integer, opcional) - Número de contatos por página (min: 1, max: 100, padrão: 20)
- `query` (string, opcional) - Busca por nome, email ou telefone

### 2.2 Buscar Contatos

**Título:** Buscar Contatos  
**Descrição:** Realiza busca avançada de contatos com múltiplos critérios

**URL e Método HTTP:** `POST /api/contacts/search`  
**Parâmetros da Rota:** Nenhum

### 2.3 Criar Contato

**Título:** Criar Novo Contato  
**Descrição:** Cria um novo contato no GoHighLevel CRM

**URL e Método HTTP:** `POST /api/contacts`  
**Parâmetros da Rota:** Nenhum

### 2.4 Obter Contato

**Título:** Obter Contato por ID  
**Descrição:** Retorna dados detalhados de um contato específico

**URL e Método HTTP:** `GET /api/contacts/{contactId}`  
**Parâmetros da Rota:** 
- `contactId` (string, obrigatório) - ID do contato no GoHighLevel

### 2.5 Atualizar Contato

**Título:** Atualizar Dados do Contato  
**Descrição:** Atualiza informações de um contato existente no GoHighLevel

**URL e Método HTTP:** `PUT /api/contacts/{contactId}`  
**Parâmetros da Rota:**
- `contactId` (string, obrigatório) - ID do contato no GoHighLevel

### 2.6 Excluir Contato

**Título:** Excluir Contato  
**Descrição:** Remove um contato do GoHighLevel CRM

**URL e Método HTTP:** `DELETE /api/contacts/{contactId}`  
**Parâmetros da Rota:**
- `contactId` (string, obrigatório) - ID do contato no GoHighLevel

## 3. Requisição Esperada

### 3.1 Listar Contatos

**Headers:**
```
Accept: application/json
Authorization: Bearer {ghl_token}
```

**Corpo da Requisição:** Nenhum

### 3.2 Buscar Contatos

**Headers:**
```
Accept: application/json
Content-Type: application/json
Authorization: Bearer {ghl_token}
```

**Corpo da Requisição:**
```json
{
    "query": "string", // Termo de busca (opcional)
    "email": "string", // Filtrar por email (opcional)
    "phone": "string", // Filtrar por telefone (opcional)
    "tags": ["tag1", "tag2"], // Filtrar por tags (opcional)
    "type": "lead", // Filtrar por tipo (opcional)
    "limit": 20 // Limite de resultados (opcional)
}
```

### 3.3 Criar Contato

**Headers:**
```
Accept: application/json
Content-Type: application/json
Authorization: Bearer {ghl_token}
```

**Corpo da Requisição:**
```json
{
    "firstName": "string", // Primeiro nome (obrigatório)
    "lastName": "string", // Último nome (opcional)
    "email": "email@example.com", // Email (opcional, mas recomendado)
    "phone": "+5511999999999", // Telefone (opcional, mas recomendado)
    "companyName": "string", // Nome da empresa (opcional)
    "address": "string", // Endereço (opcional)
    "city": "string", // Cidade (opcional)
    "state": "string", // Estado (opcional)
    "postalCode": "string", // CEP (opcional)
    "country": "string", // País (opcional)
    "tags": ["tag1", "tag2"], // Tags (opcional)
    "customFields": { // Campos personalizados (opcional)
        "field1": "value1",
        "field2": "value2"
    },
    "source": "string" // Fonte do lead (opcional)
}
```

### 3.4 Obter Contato

**Headers:**
```
Accept: application/json
Authorization: Bearer {ghl_token}
```

**Corpo da Requisição:** Nenhum

### 3.5 Atualizar Contato

**Headers:**
```
Accept: application/json
Content-Type: application/json
Authorization: Bearer {ghl_token}
```

**Corpo da Requisição:**
```json
{
    "firstName": "string", // Primeiro nome (opcional)
    "lastName": "string", // Último nome (opcional)
    "email": "email@example.com", // Email (opcional)
    "phone": "+5511999999999", // Telefone (opcional)
    "companyName": "string", // Nome da empresa (opcional)
    "address": "string", // Endereço (opcional)
    "city": "string", // Cidade (opcional)
    "state": "string", // Estado (opcional)
    "postalCode": "string", // CEP (opcional)
    "country": "string", // País (opcional)
    "tags": ["tag1", "tag2"], // Tags (opcional)
    "customFields": { // Campos personalizados (opcional)
        "field1": "value1",
        "field2": "value2"
    }
}
```

### 3.6 Excluir Contato

**Headers:**
```
Accept: application/json
Authorization: Bearer {ghl_token}
```

**Corpo da Requisição:** Nenhum

## 4. Respostas Esperadas

### 4.1 Listar Contatos

**Status 200 (Success):**
```json
{
    "contacts": [
        {
            "id": "60d5ec49e1b2c50012345678",
            "name": "Maria Silva",
            "firstName": "Maria",
            "lastName": "Silva",
            "phoneNo": "+5511999999999",
            "phoneLabel": "primary",
            "email": "maria@example.com",
            "additionalEmails": [],
            "additionalPhones": [],
            "companyName": "Empresa ABC",
            "businessName": "Negócio XYZ",
            "address": "Rua das Flores, 123",
            "city": "São Paulo",
            "state": "SP",
            "postalCode": "01234-567",
            "country": "Brazil",
            "tags": ["cliente", "ativo"],
            "customFields": {},
            "type": "contact",
            "source": "website",
            "dnd": false
        }
    ],
    "count": 15
}
```

**Status 401 (Unauthorized):**
```json
{
    "error": "unauthorized",
    "message": "Token GHL inválido ou expirado"
}
```

**Status 429 (Too Many Requests):**
```json
{
    "error": "rate_limit_exceeded",
    "message": "Muitas requisições. Tente novamente em alguns segundos."
}
```

### 4.2 Buscar Contatos

**Status 200 (Success):**
```json
{
    "contacts": [
        {
            "id": "60d5ec49e1b2c50012345678",
            "name": "João Santos",
            "firstName": "João",
            "lastName": "Santos",
            "email": "joao@example.com",
            "phone": "+5511888888888"
        }
    ],
    "total": 1,
    "query": "joão"
}
```

**Status 400 (Bad Request):**
```json
{
    "error": "validation_error",
    "message": "Parâmetros de busca inválidos",
    "details": {
        "email": ["O campo email deve ser um endereço de email válido"]
    }
}
```

### 4.3 Criar Contato

**Status 201 (Created):**
```json
{
    "success": true,
    "contact": {
        "id": "60d5ec49e1b2c50012345678",
        "firstName": "Ana",
        "lastName": "Costa",
        "email": "ana@example.com",
        "phone": "+5511777777777",
        "companyName": "Tech Solutions",
        "dateAdded": "2025-01-20T10:00:00Z"
    },
    "message": "Contato criado com sucesso"
}
```

**Status 400 (Bad Request):**
```json
{
    "error": "validation_error",
    "message": "Dados inválidos para criação do contato",
    "details": {
        "firstName": ["O campo primeiro nome é obrigatório"],
        "email": ["O campo email deve ser um endereço válido"]
    }
}
```

**Status 409 (Conflict):**
```json
{
    "error": "contact_exists",
    "message": "Já existe um contato com este email",
    "existing_contact_id": "60d5ec49e1b2c50012345678"
}
```

### 4.4 Obter Contato

**Status 200 (Success):**
```json
{
    "contact": {
        "id": "60d5ec49e1b2c50012345678",
        "firstName": "Pedro",
        "lastName": "Oliveira",
        "email": "pedro@example.com",
        "phone": "+5511666666666",
        "companyName": "Consultoria ABC",
        "address": "Av. Paulista, 1000",
        "city": "São Paulo",
        "state": "SP",
        "postalCode": "01310-100",
        "country": "Brazil",
        "tags": ["prospecto", "interessado"],
        "customFields": {
            "orcamento_solicitado": "50000",
            "preferencia_contato": "email"
        },
        "type": "lead",
        "source": "google_ads",
        "dnd": false,
        "dateAdded": "2025-01-15T08:30:00Z",
        "dateUpdated": "2025-01-20T14:15:00Z"
    }
}
```

**Status 404 (Not Found):**
```json
{
    "error": "contact_not_found",
    "message": "Contato não encontrado"
}
```

### 4.5 Atualizar Contato

**Status 200 (Success):**
```json
{
    "success": true,
    "contact": {
        "id": "60d5ec49e1b2c50012345678",
        "firstName": "Pedro",
        "lastName": "Oliveira Santos",
        "email": "pedro.santos@example.com",
        "phone": "+5511666666666",
        "dateUpdated": "2025-01-20T15:30:00Z"
    },
    "message": "Contato atualizado com sucesso"
}
```

**Status 400 (Bad Request):**
```json
{
    "error": "validation_error",
    "message": "Dados inválidos para atualização",
    "details": {
        "email": ["O campo email deve ser um endereço válido"]
    }
}
```

**Status 404 (Not Found):**
```json
{
    "error": "contact_not_found",
    "message": "Contato não encontrado para atualização"
}
```

### 4.6 Excluir Contato

**Status 200 (Success):**
```json
{
    "success": true,
    "message": "Contato excluído com sucesso"
}
```

**Status 404 (Not Found):**
```json
{
    "error": "contact_not_found",
    "message": "Contato não encontrado para exclusão"
}
```

**Status 409 (Conflict):**
```json
{
    "error": "contact_in_use",
    "message": "Contato não pode ser excluído pois está sendo usado em orçamentos ativos"
}
```

**Status 500 (Internal Server Error):**
```json
{
    "error": "deletion_error",
    "message": "Erro interno ao excluir contato"
}
```