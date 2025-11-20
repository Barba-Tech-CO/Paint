# Health Check

Endpoints de monitoramento e verificação de saúde da API.

## 🔗 Links Rápidos
- Guia de infraestrutura: `README.md`
- Coleção Postman (`/Health`): `docs/collections/api-postman.json`

## Endpoints

### `GET /api/health`

**Verificação de saúde da API**

Endpoint para verificar se a API está funcionando corretamente.

**Método & URL:** `GET /api/health`  
**Nome da rota:** N/A  
**Autenticação:** Livre  
**Permissões/Scopes:** N/A

#### Query params
Nenhum

#### Body (JSON)
Nenhum

#### Respostas

##### `200 OK` — API funcionando normalmente

```json
{
  "status": "ok",
  "timestamp": "2025-01-20T10:00:00Z",
  "service": "PaintPro API",
  "architecture": "Modular DDD"
}
```

**Campos da resposta:**
- `status` (string, obrigatório) — Status da API (`ok`)
- `timestamp` (string, obrigatório) — Timestamp ISO 8601 da verificação
- `service` (string, obrigatório) — Nome do serviço
- `architecture` (string, obrigatório) — Arquitetura utilizada

#### Paginação
N/A

#### Observações
- Endpoint público sem necessidade de autenticação
- Utilizado para health checks de load balancers e monitoramento
- Resposta sempre em formato JSON
- Tempo de resposta típico: < 50ms

#### Exemplo cURL

```bash
curl -X GET "https://paintpro.barbatech.company/api/health" \
  -H "Accept: application/json"
```

#### Rate Limiting
Este endpoint não possui rate limiting aplicado.
