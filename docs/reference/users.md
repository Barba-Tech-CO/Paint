# User Management

Gestão de usuários autenticados via Sanctum.

## 🔗 Links Rápidos
- Autenticação GHL: `docs/reference/ghl-auth.md`
- Modelo `User`: `docs/AUTH_MODULE.MD`
- Coleção Postman (`/Users`): `docs/collections/api-postman.json`

## Endpoints

### `GET /api/user`

**Retorna o usuário autenticado**

Retorna os dados do usuário autenticado via Sanctum.

**Método & URL:** `GET /api/user`  
**Nome da rota:** N/A  
**Autenticação:** `Bearer {token}`  
**Permissões/Scopes:** N/A

#### Query params
Nenhum

#### Body (JSON)
Nenhum

#### Respostas

##### `200 OK` — Usuário autenticado

```json
{
  "id": 1,
  "name": "Maria Silva",
  "email": "maria@paintpro.com",
  "ghl_location_id": "60d5ec49e1b2c50012345678",
  "ghl_business_id": "business_123",
  "ghl_phone": "+1234567890",
  "ghl_website": "https://paintpro.com",
  "ghl_address": "123 Business St",
  "ghl_city": "Business City",
  "ghl_state": "BC",
  "ghl_postal_code": "12345",
  "ghl_country": "USA",
  "ghl_description": "Professional painting services",
  "ghl_last_sync_at": "2025-01-20T10:00:00Z"
}
```

**Campos da resposta:**
- `id` (integer, obrigatório) — ID único do usuário
- `name` (string, obrigatório) — Nome completo do usuário
- `email` (string, obrigatório) — Email do usuário
- `ghl_location_id` (string, opcional) — ID da localização no GoHighLevel
- `ghl_business_id` (string, opcional) — ID do negócio no GoHighLevel  
- `ghl_phone` (string, opcional) — Telefone do negócio
- `ghl_website` (string, opcional) — Website do negócio
- `ghl_address` (string, opcional) — Endereço do negócio
- `ghl_city` (string, opcional) — Cidade do negócio
- `ghl_state` (string, opcional) — Estado do negócio
- `ghl_postal_code` (string, opcional) — CEP do negócio
- `ghl_country` (string, opcional) — País do negócio
- `ghl_description` (string, opcional) — Descrição do negócio
- `ghl_last_sync_at` (string, opcional) — Última sincronização com GHL (ISO 8601)

##### `401 Unauthorized` — Não autenticado

```json
{
  "success": false,
  "message": "Unauthenticated",
  "error_code": "TOKEN_INVALID"
}
```

#### Paginação
N/A

#### Observações
- Requer token de autenticação Sanctum válido
- O campo `password` é sempre oculto por questões de segurança  
- Campos GHL são populados quando o usuário se autentica via OAuth2 GoHighLevel
- Usuários podem verificar se `ghl_location_id` está presente para determinar se estão conectados ao GHL

#### Exemplo cURL

```bash
curl -X GET "https://paintpro.barbatech.company/api/user" \
  -H "Authorization: Bearer {your-token}" \
  -H "Accept: application/json"
```

#### Rate Limiting
Rate limiting: `read` (100 req/min)
