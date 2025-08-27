# MÓDULO DE AUTENTICAÇÃO - AUTH_MODULE

Este módulo gerencia a autenticação OAuth2 com o GoHighLevel CRM, permitindo que usuários autentiquem suas contas e acessem recursos protegidos da API.

## 1. Modelos de Dados e Estrutura da Tabela

### Modelo User (Usuário)

**Arquivo:** `app/Modules/Shared/Models/User.php`

**Atributos do Model:**
- `id` (integer, not null) - ID único do usuário
- `name` (string, not null) - Nome do usuário
- `email` (string, not null, unique) - Email do usuário
- `email_verified_at` (timestamp, nullable) - Data de verificação do email
- `password` (string, not null) - Senha criptografada
- `remember_token` (string, nullable) - Token para "lembrar-me"
- `ghl_location_id` (string, nullable, unique) - ID da localização no GoHighLevel
- `ghl_business_id` (string, nullable) - ID do negócio no GoHighLevel
- `ghl_phone` (string, nullable) - Telefone do usuário no GHL
- `ghl_website` (string, nullable) - Website do usuário
- `ghl_address` (text, nullable) - Endereço completo
- `ghl_city` (string, nullable) - Cidade
- `ghl_state` (string, nullable) - Estado
- `ghl_postal_code` (string, nullable) - CEP
- `ghl_country` (string, nullable) - País
- `ghl_description` (text, nullable) - Descrição do negócio
- `ghl_last_sync_at` (timestamp, nullable) - Última sincronização com GHL
- `created_at` (timestamp, not null) - Data de criação
- `updated_at` (timestamp, not null) - Data de atualização

**Estrutura da Tabela `users`:**
```sql
CREATE TABLE users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    email_verified_at TIMESTAMP NULL,
    password VARCHAR(255) NOT NULL,
    remember_token VARCHAR(100) NULL,
    ghl_location_id VARCHAR(255) NULL UNIQUE,
    ghl_business_id VARCHAR(255) NULL,
    ghl_phone VARCHAR(255) NULL,
    ghl_website VARCHAR(255) NULL,
    ghl_address TEXT NULL,
    ghl_city VARCHAR(255) NULL,
    ghl_state VARCHAR(255) NULL,
    ghl_postal_code VARCHAR(255) NULL,
    ghl_country VARCHAR(255) NULL,
    ghl_description TEXT NULL,
    ghl_last_sync_at TIMESTAMP NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);
```

### Modelo GhlToken (Token GoHighLevel)

**Arquivo:** `app/Modules/GoHighLevel/Models/GhlToken.php`

**Atributos do Model:**
- `id` (integer, not null) - ID único do token
- `user_id` (integer, nullable) - ID do usuário proprietário
- `location_id` (string, not null, unique) - ID da localização no GHL
- `access_token` (text, not null) - Token de acesso (criptografado)
- `refresh_token` (text, not null) - Token de renovação (criptografado)
- `expires_in` (integer, not null) - Tempo de expiração em segundos
- `token_type` (string, not null) - Tipo do token (Bearer)
- `scope` (array, nullable) - Escopo das permissões
- `additional_data` (array, nullable) - Dados adicionais da resposta OAuth
- `token_expires_at` (timestamp, not null) - Data de expiração do token
- `created_at` (timestamp, not null) - Data de criação
- `updated_at` (timestamp, not null) - Data de atualização

**Estrutura da Tabela `ghl_tokens`:**
```sql
CREATE TABLE ghl_tokens (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NULL,
    location_id VARCHAR(255) NOT NULL UNIQUE,
    access_token TEXT NOT NULL,
    refresh_token TEXT NOT NULL,
    expires_in INT NOT NULL,
    token_type VARCHAR(255) DEFAULT 'Bearer',
    scope JSON NULL,
    additional_data JSON NULL,
    token_expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    INDEX idx_location_expires (location_id, token_expires_at)
);
```

## 2. Endpoints da API

### 2.1 Processar Callback OAuth2

**Título:** Processar Callback de Autenticação  
**Descrição:** Recebe o código de autorização do GoHighLevel e troca por tokens de acesso

**URL e Método HTTP:** `GET /api/auth/callback`  
**Parâmetros da Rota:** Nenhum  
**Query Parameters:**
- `code` (string, obrigatório) - Código de autorização retornado pelo GoHighLevel
- `error` (string, opcional) - Código de erro se a autorização falhar
- `error_description` (string, opcional) - Descrição do erro

### 2.2 Verificar Status de Autenticação

**Título:** Status da Autenticação  
**Descrição:** Verifica se o usuário está autenticado e retorna informações do token

**URL e Método HTTP:** `GET /api/auth/status`  
**Parâmetros da Rota:** Nenhum

### 2.3 Obter Dados do Usuário Autenticado

**Título:** Dados do Usuário Autenticado  
**Descrição:** Retorna os dados completos do usuário autenticado, incluindo informações do GoHighLevel se disponíveis

**URL e Método HTTP:** `GET /api/user`  
**Parâmetros da Rota:** Nenhum


## 3. Requisição Esperada

### 3.1 Processar Callback OAuth2

**Headers:**
```
Accept: application/json
```

**Corpo da Requisição:** Nenhum (parâmetros via query string)

### 3.2 Verificar Status de Autenticação

**Headers:**
```
Accept: application/json
Authorization: Bearer {ghl_token} (opcional)
```

**Corpo da Requisição:** Nenhum

### 3.3 Obter Dados do Usuário Autenticado

**Headers:**
```
Accept: application/json
Authorization: Bearer {auth_token}
```

**Corpo da Requisição:** Nenhum


## 4. Respostas Esperadas

### 4.1 Processar Callback OAuth2

**Status 200 (Success) - Autenticação bem-sucedida:**
```json
{
    "success": true,
    "expires_at": "2025-01-21T10:00:00Z",
    "location_id": "60d5ec49e1b2c50012345678",
    "auth_token": "1|abc123def456...",
    "sync_initiated": true
}
```

**Status 400 (Bad Request) - Código inválido:**
```json
{
    "success": false,
    "error": "invalid_code",
    "message": "Código de autorização inválido ou expirado"
}
```

**Status 401 (Unauthorized) - Acesso negado:**
```json
{
    "success": false,
    "error": "access_denied",
    "message": "Usuário negou o acesso"
}
```

**Status 500 (Internal Server Error) - Erro interno:**
```json
{
    "success": false,
    "error": "oauth_error",
    "message": "Erro interno durante a autenticação OAuth"
}
```

### 4.2 Verificar Status de Autenticação

**Status 200 (Success) - Usuário autenticado:**
```json
{
    "authenticated": true,
    "location_id": "60d5ec49e1b2c50012345678",
    "expires_at": "2025-01-21T10:00:00Z",
    "expires_in": 3600,
    "token_valid": true
}
```

**Status 200 (Success) - Usuário não autenticado:**
```json
{
    "authenticated": false,
    "location_id": null,
    "expires_at": null,
    "expires_in": null,
    "token_valid": false
}
```

**Status 401 (Unauthorized) - Token inválido:**
```json
{
    "authenticated": false,
    "error": "invalid_token",
    "message": "Token inválido ou expirado"
}
```

### 4.3 Obter Dados do Usuário Autenticado

**Status 200 (Success) - Usuário GHL com dados completos:**
```json
{
    "id": 1,
    "name": "Maria Silva",
    "email": "maria@paintpro.com",
    "email_verified_at": "2025-01-15T10:30:00Z",
    "created_at": "2025-01-10T08:00:00Z",
    "updated_at": "2025-01-20T14:30:00Z",
    "ghl_location_id": "5DP4iH6HLkQsiKESj6rh",
    "ghl_business_id": "63771dcac1116f0e21de8e12",
    "ghl_phone": "+1-555-123-4567",
    "ghl_website": "paintpro.com",
    "ghl_address": "123 Main St",
    "ghl_city": "New York",
    "ghl_state": "NY",
    "ghl_postal_code": "10001",
    "ghl_country": "United States",
    "ghl_description": "Professional painting services",
    "ghl_last_sync_at": "2025-01-20T10:30:00Z",
    "is_ghl_user": true,
    "business_info": {
        "name": "Maria Silva",
        "email": "maria@paintpro.com",
        "phone": "+1-555-123-4567",
        "website": "paintpro.com",
        "address": "123 Main St",
        "city": "New York",
        "state": "NY",
        "postal_code": "10001",
        "country": "United States",
        "description": "Professional painting services"
    }
}
```

**Status 200 (Success) - Usuário GHL com dados incompletos:**
```json
{
    "id": 2,
    "name": "João Santos",
    "email": "joao@email.com",
    "email_verified_at": "2025-01-18T12:00:00Z",
    "created_at": "2025-01-18T10:00:00Z",
    "updated_at": "2025-01-20T16:00:00Z",
    "ghl_location_id": "5DP4iH6HLkQsiKESj6rh",
    "is_ghl_user": false,
    "ghl_data_incomplete": true
}
```

**Status 200 (Success) - Usuário regular (não GHL):**
```json
{
    "id": 3,
    "name": "Ana Costa",
    "email": "ana@email.com",
    "email_verified_at": "2025-01-12T15:45:00Z",
    "created_at": "2025-01-12T14:00:00Z",
    "updated_at": "2025-01-19T11:20:00Z",
    "is_ghl_user": false
}
```

**Status 200 (Success) - Usuário GHL com erro:**
```json
{
    "id": 4,
    "name": "Carlos Pereira",
    "email": "carlos@email.com",
    "email_verified_at": "2025-01-16T09:30:00Z",
    "created_at": "2025-01-16T08:00:00Z",
    "updated_at": "2025-01-20T17:00:00Z",
    "ghl_location_id": "5DP4iH6HLkQsiKESj6rh",
    "is_ghl_user": false,
    "ghl_error": true
}
```

**Status 401 (Unauthorized) - Não autenticado:**
```json
{
    "message": "Unauthenticated."
}
```

**Status 500 (Internal Server Error) - Erro interno:**
```json
{
    "error": "Internal server error",
    "message": "Failed to retrieve user data"
}
```

