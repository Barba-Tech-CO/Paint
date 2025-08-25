# 🔐 Módulo de Autenticação da API - Documentação Completa

## 📖 Visão Geral

O módulo de autenticação da API PaintPro gerencia a autenticação OAuth2 com o CRM GoHighLevel. Este módulo fornece endpoints para fluxo de autorização, gerenciamento de tokens e verificação de status de autenticação.

## 🏗️ Arquitetura

### Estrutura de Pastas

```
app/Modules/GoHighLevel/
├── Controllers/
│   └── GhlAuthController.php
├── Models/
│   └── GhlToken.php
├── Services/
│   └── OAuthService.php
└── Repositories/
    └── GhlTokenRepository.php
```

### Princípios da Arquitetura

- **OAuth2 Flow**: Implementação completa do fluxo de autorização OAuth2
- **Gerenciamento de Tokens**: Armazenamento seguro e renovação automática de tokens
- **Integração GHL**: Comunicação direta com GoHighLevel CRM
- **Segurança**: Criptografia de tokens sensíveis no banco de dados
- **Modular**: Estrutura DDD com separação clara de responsabilidades

## 🗄️ Modelo de Dados

### Model: GhlToken

```php
<?php
namespace App\Modules\GoHighLevel\Models;

class GhlToken extends Model
{
    protected $table = 'ghl_tokens';

    protected $fillable = [
        'location_id', 'access_token', 'refresh_token', 'expires_in',
        'token_type', 'scope', 'additional_data', 'token_expires_at'
    ];

    protected $casts = [
        'scope' => 'array',
        'additional_data' => 'array',
        'token_expires_at' => 'datetime'
    ];

    protected $hidden = [
        'access_token',
        'refresh_token'
    ];
}
```

### Tabela do Banco: ghl_tokens

```sql
CREATE TABLE ghl_tokens (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    -- Identificação da localização
    location_id VARCHAR(255) UNIQUE NOT NULL COMMENT 'ID da localização no GoHighLevel',

    -- Tokens OAuth2 (criptografados)
    access_token TEXT NOT NULL COMMENT 'Token de acesso criptografado',
    refresh_token TEXT NOT NULL COMMENT 'Token de renovação criptografado',

    -- Configuração do token
    expires_in INTEGER NOT NULL COMMENT 'Tempo de expiração em segundos',
    token_type VARCHAR(255) DEFAULT 'Bearer' COMMENT 'Tipo do token',

    -- Escopos e dados adicionais
    scope JSON NULL COMMENT 'Escopos de permissão OAuth2',
    additional_data JSON NULL COMMENT 'Dados extras da resposta OAuth2',

    -- Controle de expiração
    token_expires_at TIMESTAMP NOT NULL COMMENT 'Data/hora de expiração do token',

    -- Timestamps padrão
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    -- Índices
    INDEX idx_location_expires (location_id, token_expires_at)
);
```

## 🌐 Endpoints da API

### Base URL

```
https://paintpro.barbatech.company/api/auth
```

### Autenticação

Os endpoints de autenticação não requerem autenticação prévia, exceto os endpoints de debug que podem requerer validação adicional.

## 📋 Endpoints Disponíveis

### 1. Callback OAuth2

**GET** `/api/auth/callback`

Processa o callback OAuth2 do GoHighLevel após autorização bem-sucedida.

#### Parâmetros de Query

| Parâmetro           | Tipo   | Obrigatório | Descrição                                |
| ------------------- | ------ | ----------- | ---------------------------------------- |
| `code`              | string | Sim         | Código de autorização retornado pelo GHL |
| `error`             | string | Não         | Código de erro se a autorização falhar   |
| `error_description` | string | Não         | Descrição do erro de autorização         |

#### Exemplo de Request

```bash
GET /api/auth/callback?code=abc123def456
```

#### Exemplo de Response (200 OK - API Request)

```json
{
  "success": true,
  "expires_at": "2025-01-21T10:00:00Z",
  "location_id": "60d5ec49e1b2c50012345678",
  "sync_initiated": true
}
```

#### Exemplo de Response (302 Redirect - Browser Request)

```
Location: https://paintpro.barbatech.company/api/auth/success?location_id=60d5ec49e1b2c50012345678
```

#### Status Codes

- **200 OK**: Tokens obtidos com sucesso (requisições JSON)
- **302 Found**: Redirecionamento para app (requisições de browser)
- **400 Bad Request**: Erro de autorização ou código ausente
- **500 Internal Server Error**: Falha ao trocar código por tokens

---

### 2. Status de Autenticação

**GET** `/api/auth/status`

Verifica o status atual da autenticação OAuth2 com o GoHighLevel.

#### Descrição

Retorna informações sobre o status atual da autenticação, incluindo se está autenticado, ID da localização e status de expiração do token.

#### Exemplo de Request

```bash
GET /api/auth/status
```

#### Exemplo de Response (200 OK)

```json
{
  "success": true,
  "data": {
    "is_authenticated": true,
    "location_id": "60d5ec49e1b2c50012345678",
    "token_expires_at": "2025-01-21T10:00:00Z",
    "needs_refresh": false
  }
}
```

#### Status Codes

- **200 OK**: Status de autenticação retornado com sucesso
- **500 Internal Server Error**: Erro ao verificar status

---

### 3. Renovação de Token

**POST** `/api/auth/refresh`

Renova os tokens de acesso do GoHighLevel usando o refresh token.

#### Descrição

Utiliza o refresh token armazenado para obter novos tokens de acesso do GoHighLevel.

#### Exemplo de Request

```bash
POST /api/auth/refresh
```

#### Exemplo de Response (200 OK)

```json
{
  "success": true,
  "access_token": "ghl_new_token_abc123...",
  "refresh_token": "ghl_new_refresh_xyz789...",
  "expires_in": 3600,
  "location_id": "60d5ec49e1b2c50012345678"
}
```

#### Status Codes

- **200 OK**: Tokens renovados com sucesso
- **500 Internal Server Error**: Falha ao renovar token

---

## 🔄 Fluxo OAuth2

### 1. Início da Autenticação

```
Cliente → GET /api/auth/redirect → Redirecionamento para GHL
```

### 2. Autorização do Usuário

```
Usuário autoriza no GHL → GHL retorna código de autorização
```

### 3. Troca de Tokens

```
Cliente → GET /api/auth/callback?code=ABC123 → Troca por tokens
```

### 4. Armazenamento e Sincronização

```
Tokens armazenados → Sincronização automática iniciada → Resposta de sucesso
```

## 🔐 Segurança

### Criptografia de Tokens

- **Access Token**: Criptografado antes de salvar no banco
- **Refresh Token**: Criptografado antes de salvar no banco
- **Descriptografia**: Automática ao acessar os tokens

### Validação de Tokens

- **Expiração**: Verificação automática de validade
- **Renovação**: Renovação automática quando próximo da expiração
- **Middleware**: Validação em todas as requisições protegidas

### Escopos OAuth2

```
contacts.write associations.write associations.readonly oauth.readonly
oauth.write invoices.estimate.write invoices.estimate.readonly
invoices.readonly associations.relation.write associations.relation.readonly
contacts.readonly invoices.write
```

## 📊 Rate Limiting

### Configuração por Tipo de Operação

```php
'auth' => ['maxAttempts' => 10, 'decayMinutes' => 5]
```

- **Máximo**: 10 tentativas por 5 minutos
- **Aplicado**: Apenas em ambiente de produção
- **Desabilitado**: Em desenvolvimento e testes

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
- **401**: Autenticação falhou ou token expirado
- **500**: Erro interno do servidor

## 📝 Logs e Monitoramento

### Logs Automáticos

- **OAuth Flow**: Todas as etapas do fluxo de autenticação
- **Token Management**: Criação, renovação e expiração de tokens
- **Error Tracking**: Erros de autenticação e validação
- **Performance**: Tempo de resposta das operações OAuth2

### Informações Logadas

- **Location ID**: Identificação da localização
- **Token Status**: Status atual dos tokens
- **Sync Operations**: Operações de sincronização automática
- **Error Details**: Detalhes completos de erros

## 🔧 Configuração

### Variáveis de Ambiente

```env
GOHIGHLEVEL_CLIENT_ID=seu_client_id
GOHIGHLEVEL_CLIENT_SECRET=seu_client_secret
GOHIGHLEVEL_REDIRECT_URI=https://paintpro.barbatech.company/api/auth/callback
```

### Configuração de Serviços

```php
// config/services.php
'gohighlevel' => [
    'client_id' => env('GOHIGHLEVEL_CLIENT_ID'),
    'client_secret' => env('GOHIGHLEVEL_CLIENT_SECRET'),
    'redirect_uri' => env('GOHIGHLEVEL_REDIRECT_URI'),
],
```

## 🧪 Testes e Desenvolvimento

### Factory para Testes

```php
// database/factories/GhlTokenFactory.php
GhlToken::factory()->create([
    'location_id' => 'test_location_123',
    'access_token' => 'test_access_token',
    'refresh_token' => 'test_refresh_token',
    'expires_in' => 3600,
    'token_expires_at' => now()->addHour()
]);
```

### Comandos Artisan

```bash
# Verificar status de autenticação
php artisan ghl:auth:status

# Renovar tokens expirados
php artisan ghl:auth:refresh

# Limpar tokens expirados
php artisan ghl:auth:cleanup
```

## 📚 Recursos e Referências

### Documentação Oficial

- **GoHighLevel OAuth2**: [Documentação da API](https://developers.gohighlevel.com/docs/auth2)
- **Laravel Sanctum**: [Autenticação API](https://laravel.com/docs/sanctum)
- **OAuth2 RFC**: [RFC 6749](https://tools.ietf.org/html/rfc6749)

### Arquivos Relacionados

- **Controller**: `GhlAuthController.php`
- **Service**: `OAuthService.php`
- **Model**: `GhlToken.php`
- **Repository**: `GhlTokenRepository.php`
- **Middleware**: `ValidateGhlToken.php`
- **Routes**: `routes/api/v1/auth.php`

---

_Documentação gerada automaticamente baseada no código atual da API PaintPro_
