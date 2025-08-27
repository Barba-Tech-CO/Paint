# 📚 Documentação dos Endpoints GHL de Usuários

## 🎯 Visão Geral

Esta documentação descreve os novos endpoints implementados para gerenciar dados de usuários autenticados via GoHighLevel (GHL). Os endpoints permitem salvar, recuperar e gerenciar informações de negócios dos usuários GHL na tabela `users`.

## 🔐 Autenticação

Todos os endpoints requerem autenticação via Laravel Sanctum. Inclua o token Bearer no header:

```http
Authorization: Bearer {seu_token_sanctum}
```

## 📋 Endpoints Disponíveis

### 1. **GET /api/user** - Dados Completos do Usuário

**Descrição:** Retorna os dados completos do usuário autenticado, incluindo informações GHL se aplicável.

**Método:** `GET`

**URL:** `/api/user`

**Headers:**

```http
Authorization: Bearer {token}
Accept: application/json
```

**Resposta de Sucesso (Usuário GHL):**

```json
{
  "id": 1,
  "name": "Microsoft",
  "email": "abc@microsoft.com",
  "email_verified_at": "2025-01-20T10:30:00Z",
  "created_at": "2025-01-20T10:30:00Z",
  "updated_at": "2025-01-20T10:30:00Z",
  "ghl_location_id": "5DP4iH6HLkQsiKESj6rh",
  "ghl_business_id": "63771dcac1116f0e21de8e12",
  "ghl_phone": "+1-555-123-4567",
  "ghl_website": "microsoft.com",
  "ghl_address": "123 Main St",
  "ghl_city": "New York",
  "ghl_state": "NY",
  "ghl_postal_code": "10001",
  "ghl_country": "United States",
  "ghl_description": "Professional painting services",
  "ghl_last_sync_at": "2025-01-20T10:30:00Z",
  "is_ghl_user": true,
  "business_info": {
    "name": "Microsoft",
    "email": "abc@microsoft.com",
    "phone": "+1-555-123-4567",
    "website": "microsoft.com",
    "address": "123 Main St",
    "city": "New York",
    "state": "NY",
    "postal_code": "10001",
    "country": "United States",
    "description": "Professional painting services"
  }
}
```

**Resposta de Sucesso (Usuário Regular):**

```json
{
  "id": 2,
  "name": "João Silva",
  "email": "joao@exemplo.com",
  "email_verified_at": "2025-01-20T10:30:00Z",
  "created_at": "2025-01-20T10:30:00Z",
  "updated_at": "2025-01-20T10:30:00Z",
  "is_ghl_user": false
}
```

**Resposta de Erro (Não Autenticado):**

```json
{
  "message": "Unauthenticated."
}
```

**Status HTTP:** `200 OK` | `401 Unauthorized`

---

### 2. **GET /api/user/ghl-profile** - Perfil GHL Específico

**Descrição:** Retorna apenas os dados específicos do perfil GHL do usuário autenticado.

**Método:** `GET`

**URL:** `/api/user/ghl-profile`

**Headers:**

```http
Authorization: Bearer {token}
Accept: application/json
```

**Resposta de Sucesso:**

```json
{
  "success": true,
  "data": {
    "user_id": 1,
    "ghl_location_id": "5DP4iH6HLkQsiKESj6rh",
    "business_info": {
      "name": "Microsoft",
      "email": "abc@microsoft.com",
      "phone": "+1-555-123-4567",
      "website": "microsoft.com",
      "address": "123 Main St",
      "city": "New York",
      "state": "NY",
      "postal_code": "10001",
      "country": "United States",
      "description": "Professional painting services"
    },
    "last_sync": "2025-01-20T10:30:00Z",
    "is_verified": true
  }
}
```

**Resposta de Erro (Usuário não GHL):**

```json
{
  "success": false,
  "message": "User is not authenticated via GHL"
}
```

**Resposta de Erro (Não Autenticado):**

```json
{
  "message": "Unauthenticated."
}
```

**Status HTTP:** `200 OK` | `401 Unauthorized` | `404 Not Found`

---

## 🔄 Fluxo de Integração GHL

### 1. **Processo de Login OAuth**

```
Frontend → GHL OAuth → Callback → API Laravel → Salva Dados do Usuário
```

### 2. **Fluxo Detalhado:**

1. **Redirecionamento:** Usuário é redirecionado para GHL via `/api/auth/redirect`
2. **Autorização:** Usuário autoriza o aplicativo no GHL
3. **Callback:** GHL retorna código de autorização para `/api/auth/callback`
4. **Troca de Tokens:** API troca código por tokens de acesso
5. **Busca de Dados:** `GhlUserService` busca dados do usuário via API GHL
6. **Salvamento:** Dados são salvos/atualizados na tabela `users`
7. **Sincronização:** Contatos são sincronizados em background

### 3. **API GHL Utilizada:**

```http
GET https://services.leadconnectorhq.com/businesses/{location_id}
Headers:
  Accept: application/json
  Authorization: Bearer {access_token}
  Version: 2021-07-28
```

## 🗄️ Estrutura da Tabela Users

### **Campos GHL Adicionados:**

| Campo              | Tipo      | Descrição                   | Exemplo                            |
| ------------------ | --------- | --------------------------- | ---------------------------------- |
| `ghl_location_id`  | string    | ID único da localização GHL | `"5DP4iH6HLkQsiKESj6rh"`           |
| `ghl_business_id`  | string    | ID do negócio GHL           | `"63771dcac1116f0e21de8e12"`       |
| `ghl_phone`        | string    | Telefone do negócio         | `"+1-555-123-4567"`                |
| `ghl_website`      | string    | Website do negócio          | `"microsoft.com"`                  |
| `ghl_address`      | text      | Endereço completo           | `"123 Main St"`                    |
| `ghl_city`         | string    | Cidade                      | `"New York"`                       |
| `ghl_state`        | string    | Estado/Província            | `"NY"`                             |
| `ghl_postal_code`  | string    | CEP/Código Postal           | `"10001"`                          |
| `ghl_country`      | string    | País                        | `"United States"`                  |
| `ghl_description`  | text      | Descrição do negócio        | `"Professional painting services"` |
| `ghl_last_sync_at` | timestamp | Última sincronização        | `"2025-01-20T10:30:00Z"`           |

## 🔧 Serviços e Modelos

### **GhlUserService**

- **Localização:** `app/Modules/GoHighLevel/Services/GhlUserService.php`
- **Responsabilidades:**
  - Buscar dados do usuário via API GHL
  - Salvar/atualizar dados na tabela `users`
  - Gerenciar sincronização de dados

### **Modelo User Estendido**

- **Localização:** `app/Modules/Shared/Models/User.php`
- **Novos Métodos:**
  - `isGhlUser()` - Verifica se é usuário GHL
  - `getBusinessInfo()` - Retorna informações do negócio
  - `getGhlLocationId()` - Retorna ID da localização GHL

## 📝 Exemplos de Uso

### **Frontend - React/JavaScript:**

```javascript
// Buscar dados do usuário
const fetchUserData = async () => {
  try {
    const response = await fetch("/api/user", {
      headers: {
        Authorization: `Bearer ${token}`,
        Accept: "application/json",
      },
    });

    if (response.ok) {
      const userData = await response.json();

      if (userData.is_ghl_user) {
        console.log("Usuário GHL:", userData.business_info);
        console.log("Localização ID:", userData.ghl_location_id);
      } else {
        console.log("Usuário regular:", userData.name);
      }
    }
  } catch (error) {
    console.error("Erro ao buscar dados do usuário:", error);
  }
};

// Buscar perfil GHL específico
const fetchGhlProfile = async () => {
  try {
    const response = await fetch("/api/user/ghl-profile", {
      headers: {
        Authorization: `Bearer ${token}`,
        Accept: "application/json",
      },
    });

    if (response.ok) {
      const profile = await response.json();
      console.log("Perfil GHL:", profile.data);
    }
  } catch (error) {
    console.error("Erro ao buscar perfil GHL:", error);
  }
};
```

### **cURL:**

```bash
# Buscar dados do usuário
curl -X GET "http://localhost:8080/api/user" \
  -H "Authorization: Bearer {seu_token}" \
  -H "Accept: application/json"

# Buscar perfil GHL
curl -X GET "http://localhost:8080/api/user/ghl-profile" \
  -H "Authorization: Bearer {seu_token}" \
  -H "Accept: application/json"
```

## 🚨 Tratamento de Erros

### **Códigos de Status HTTP:**

- `200 OK` - Sucesso
- `401 Unauthorized` - Token inválido ou expirado
- `404 Not Found` - Usuário não é usuário GHL (apenas para `/ghl-profile`)

### **Mensagens de Erro Comuns:**

- `"Unauthenticated."` - Usuário não autenticado
- `"User is not authenticated via GHL"` - Usuário não é usuário GHL

## 🔒 Segurança

### **Autenticação:**

- Todos os endpoints requerem autenticação via Laravel Sanctum
- Tokens devem ser incluídos no header `Authorization: Bearer {token}`

### **Validação:**

- Dados são validados antes de serem salvos no banco
- Sanitização automática de entrada via middleware Laravel

### **Rate Limiting:**

- Endpoints estão sujeitos ao rate limiting configurado no Laravel
- Middleware de throttling personalizado aplicado

## 📊 Monitoramento e Logs

### **Logs do Sistema:**

- Todas as operações são logadas via Laravel Log
- Logs incluem informações de usuário, operação e timestamp
- Logs de erro incluem stack trace completo

### **Métricas Disponíveis:**

- Timestamp da última sincronização GHL
- Status de verificação do email
- Contagem de usuários GHL vs. regulares

## 🔄 Atualizações e Manutenção

### **Sincronização Automática:**

- Dados são sincronizados automaticamente após login OAuth
- Sincronização manual pode ser implementada via comando artisan

### **Limpeza de Dados:**

- Dados antigos podem ser limpos via comandos artisan
- Logs de sincronização são mantidos para auditoria

---

## 📞 Suporte

Para dúvidas ou problemas com estes endpoints, consulte:

- **Logs do Laravel:** `storage/logs/laravel.log`
- **Documentação da API:** Swagger UI disponível em `/api/documentation`
- **Testes:** Execute `php artisan test` para validar funcionalidades

---

_Documentação gerada em: 20 de Janeiro de 2025_  
_Versão: 1.0_  
_Última atualização: Implementação inicial dos endpoints GHL_
