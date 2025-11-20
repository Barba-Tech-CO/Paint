# Estimates

Operações relacionadas a orçamentos de pintura com zonas, fotos por zona e materiais. Este documento reflete o contrato final (one-shot POST) descrito em `paint_pro_api/response.json`. Consulte também `docs/ORCAMENTOS_MODULE.MD` para visão de domínio e `docs/reference/jamie-ai.md` para o fluxo assistido pela Jamie AI.

## 🔗 Links Rápidos
- Módulo de negócio: `docs/ORCAMENTOS_MODULE.MD`
- Materiais vinculados: `docs/reference/materials.md`
- Assistente Jamie AI: `docs/reference/jamie-ai.md`
- Coleção Postman (`/Estimates`): `docs/collections/api-postman.json`

## 📊 Estrutura da Tabela (Offline-First)

### Schema da Tabela `estimates`

```sql
CREATE TABLE estimates (
    id BIGINT UNSIGNED PRIMARY KEY,
    user_id BIGINT UNSIGNED, -- Isolamento por usuário

    -- Integração GHL
    ghl_estimate_id VARCHAR(255) NULL,
    ghl_contact_id VARCHAR(255) NULL,
    contact VARCHAR(255) NOT NULL, -- ID do contato

    -- Dados do Projeto
    project_name VARCHAR(255) NULL,
    client_name VARCHAR(255) NULL,
    project_type ENUM('interior', 'exterior', 'both') NULL,
    additional_notes TEXT NULL,

    -- Workflow Status
    status ENUM('draft', 'photos_uploaded', 'photos_processed',
                'elements_selected', 'materials_calculated',
                'completed', 'sent') DEFAULT 'draft',

    -- Dados JSON para Offline
    photos_data JSON NULL, -- URLs das fotos + metadados
    zones JSON NULL, -- Dados das zonas (cômodos) do projeto
    measurements JSON NULL, -- Medidas dos cômodos
    paint_elements JSON NULL, -- Elementos selecionados
    materials_calculation JSON NULL, -- Cálculos de materiais
    materials JSON NULL, -- Lista de materiais do projeto
    totals JSON NULL, -- Totais consolidados (custos, quantidades)
    labor_calculation JSON NULL, -- Cálculos de mão-de-obra

    -- Condições e Custos
    wall_condition ENUM('very_good', 'good', 'poor', 'very_poor') NOT NULL,
    has_accent_wall BOOLEAN NOT NULL DEFAULT FALSE,
    total_cost DECIMAL(10,2) NOT NULL,
    complete BOOLEAN DEFAULT FALSE,

    -- Timestamps para Sincronização
    photos_uploaded_at TIMESTAMP NULL,
    measurements_completed_at TIMESTAMP NULL,
    sent_to_client_at TIMESTAMP NULL,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,

    -- Índices para Performance Offline
    KEY idx_user_id (user_id),
    KEY idx_status (status),
    KEY idx_client_project (client_name, project_name),
    KEY idx_created_at (created_at)
);
```

### Campos JSON para Flexibilidade Offline

- **`photos_data`** - URLs e metadados das fotos
- **`zones`** - Dados das zonas (cômodos) do projeto
- **`measurements`** - Medições dos cômodos
- **`paint_elements`** - Elementos selecionados para pintura
- **`materials_calculation`** - Cálculos de tintas e materiais
- **`materials`** - Lista de materiais do projeto
- **`totals`** - Totais consolidados (custos, quantidades)
- **`labor_calculation`** - Cálculos de mão-de-obra

## Estados do Orçamento

Os orçamentos seguem um fluxo de estados bem definido:

- `draft` → Rascunho inicial
- `photos_uploaded` → Fotos enviadas
- `photos_processed` → Fotos processadas pela IA
- `elements_selected` → Elementos de pintura selecionados
- `materials_calculated` → Materiais calculados
- `completed` → Orçamento finalizado
- `sent` → Enviado para o CRM

## Endpoints

### `GET /api/estimates`

**Lista todos os orçamentos com paginação e filtros**

Retorna uma lista paginada de orçamentos com opções de filtro por cliente, tipo de projeto, status e busca geral.

**Método & URL:** `GET /api/estimates`  
**Nome da rota:** N/A  
**Autenticação:** `Bearer {token}`  
**Permissões/Scopes:** `user.ownership`

#### Query params

- `client_name` (string, opcional) — Filtrar por nome do cliente
- `project_type` (string, opcional, enum: `interior|exterior|both`) — Filtrar por tipo de projeto
- `status` (string, opcional) — Filtrar por status do orçamento
- `search` (string, opcional) — Busca geral em nome do cliente, projeto e tipo
- `limit` (integer, opcional, min: 1, max: 100, default: 15) — Número de itens por página
- `page` (integer, opcional, min: 1, default: 1) — Página atual

#### Respostas

##### `200 OK` — Lista de orçamentos retornada com sucesso

```json
{
  "success": true,
  "estimates": [
    {
      "id": 1,
      "user_id": 1,
      "ghl_estimate_id": "est_60d5ec49e1b2c50012345678",
      "ghl_contact_id": "60d5ec49e1b2c50012345678",
      "contact": "60d5ec49e1b2c50012345678",
      "project_name": "Casa da Maria - Pintura Externa",
      "client_name": "Maria Silva",
      "project_type": "exterior",
      "additional_notes": "Cliente prefere tintas ecológicas",
      "status": "completed",
      "photos_data": [
        "storage/estimates/1/photos/photo1.jpg",
        "storage/estimates/1/photos/photo2.jpg"
      ],
      "measurements": [
        {
          "room": "living_room",
          "area": 25.5
        }
      ],
      "paint_elements": [
        {
          "type": "wall",
          "description": "Parede externa frontal",
          "area": 25.5
        }
      ],
      "wall_condition": "good",
      "has_accent_wall": false,
      "extra_notes": "Acesso difícil na parede dos fundos",
      "materials_calculation": {
        "gallons_needed": 2.5,
        "cans_needed": 3,
        "unit": "gallon"
      },
      "labor_calculation": {
        "hours_needed": 8,
        "hourly_rate": 35.0,
        "total_cost": 280.0
      },
      "total_cost": 405.5,
      "complete": false,
      "estimated_timeline_days": 3,
      "ghl_folder_name": "casa_maria_silva",
      "photos_uploaded_at": "2025-01-20T14:30:00Z",
      "measurements_completed_at": "2025-01-20T15:45:00Z",
      "sent_to_client_at": "2025-01-20T16:00:00Z",
      "created_at": "2025-01-20T10:00:00Z",
      "updated_at": "2025-01-20T16:00:00Z"
    }
  ],
  "pagination": {
    "total": 50,
    "per_page": 15,
    "current_page": 1,
    "last_page": 4
  }
}
```

##### `429 Too Many Requests` — Rate limit excedido

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

---

### `POST /api/estimates`

**Cria um novo orçamento completo**

Cria um novo orçamento de pintura com todas as funcionalidades: upload de fotos, seleção de elementos e finalização em um único endpoint.

**Método & URL:** `POST /api/estimates`  
**Nome da rota:** N/A  
**Autenticação:** `Bearer {token}`  
**Permissões/Scopes:** `user.ownership`

#### Body (multipart/form-data)

**Campos obrigatórios:**

- `contact` (string, max: 255) — ID ou nome do contato
- `wall_condition` (string, max: 255) — Condição da parede
- `has_accent_wall` (boolean) — Possui parede de destaque (em multipart, envie como `0` ou `1`)
- `materials_calculation` (object) — Cálculo de materiais
- `total_cost` (number, min: 0, max: 999999.99) — Valor total dos materiais
- `complete` (boolean) — Marcar projeto como completo (em multipart, envie como `0` ou `1`)
- `photos` (array<file>, min: 3, max: 9) — Fotos do projeto

**Campos opcionais:**

- `project_name` (string, max: 255) — Nome do projeto
- `client_name` (string, max: 255) — Nome do cliente
- `project_type` (string, enum: `interior|exterior|both`) — Tipo de projeto
- `ghl_contact_id` (string, max: 255) — ID do contato no GoHighLevel
- `additional_notes` (string, max: 1000) — Notas adicionais
- `paint_elements` (array) — Elementos de pintura
- `extra_notes` (string, max: 1000) — Notas extras

#### Validações de Fotos

- **Formatos aceitos:** JPEG, PNG, JPG, WEBP
- **Tamanho máximo:** 5MB por foto
- **Dimensões mínimas:** 800x600 pixels
- **Dimensões máximas:** 4096x4096 pixels
- **Quantidade:** 3-9 fotos obrigatórias

#### Exemplo de Body

```json
{
  "project_name": "Casa da Maria - Pintura Externa",
  "client_name": "Maria Silva",
  "project_type": "exterior",
  "contact": "Maria Silva",
  "ghl_contact_id": "60d5ec49e1b2c50012345678",
  "additional_notes": "Cliente prefere tintas ecológicas",
  "paint_elements": [
    {
      "type": "wall",
      "description": "Parede externa frontal",
      "area": 25.5
    }
  ],
  "wall_condition": "good",
  "has_accent_wall": false,
  "extra_notes": "Acesso difícil na parede dos fundos",
  "materials_calculation": {
    "gallons_needed": 2.5,
    "cans_needed": 3,
    "unit": "gallon"
  },
  "total_cost": 350.75,
  "complete": false,
  "photos": ["(binary file 1)", "(binary file 2)", "(binary file 3)"]
}
```

#### Respostas

##### `201 Created` — Orçamento criado com sucesso

```json
{
  "success": true,
  "message": "Estimate created successfully",
  "data": {
    "id": 1,
    "ghl_estimate_id": "est_60d5ec49e1b2c50012345678",
    "project_name": "Casa da Maria - Pintura Externa",
    "client_name": "Maria Silva",
    "status": "photos_uploaded",
    "total_cost": 350.75,
    "created_at": "2025-01-20T10:00:00Z"
  }
}
```

##### `422 Unprocessable Entity` — Erro de validação

```json
{
  "success": false,
  "message": "Validation failed",
  "errors": {
    "contact": ["The contact field is required."],
    "photos": ["The photos field must contain at least 3 items."],
    "photos.0": ["Each photo must be at least 800x600 pixels."],
    "total_cost": ["The total cost field is required."]
  }
}
```

---

### `GET /api/estimates/dashboard`

**Dashboard com estatísticas e orçamentos pendentes**

Retorna estatísticas gerais e lista de orçamentos que requerem atenção. Cache de 15 minutos.

**Método & URL:** `GET /api/estimates/dashboard`  
**Nome da rota:** N/A  
**Autenticação:** `Bearer {token}`  
**Permissões/Scopes:** `user.ownership`

#### Respostas

##### `200 OK` — Dados do dashboard retornados com sucesso

```json
{
  "success": true,
  "data": {
    "statistics": {
      "total_estimates": 150,
      "completed": 120,
      "sent": 100,
      "pending": 30
    },
    "requiring_attention": [
      {
        "id": 1,
        "client_name": "Maria Silva",
        "project_name": "Casa da Maria",
        "status": "photos_uploaded",
        "created_at": "2025-01-20T10:00:00Z"
      }
    ],
    "requiring_attention_count": 5
  }
}
```

---

### `GET /api/estimates/{id}`

**Busca um orçamento específico**

Retorna todos os detalhes de um orçamento específico pelo ID.

**Método & URL:** `GET /api/estimates/{id}`  
**Nome da rota:** N/A  
**Autenticação:** `Bearer {token}`  
**Permissões/Scopes:** `user.ownership`

#### Path params

- `id` (integer, obrigatório) — ID do orçamento

#### Respostas

##### `200 OK` — Orçamento encontrado

```json
{
  "success": true,
  "estimate": {
    "id": 1,
    "user_id": 1,
    "ghl_estimate_id": "est_60d5ec49e1b2c50012345678",
    "ghl_contact_id": "60d5ec49e1b2c50012345678",
    "contact": "Maria Silva",
    "project_name": "Casa da Maria - Pintura Externa",
    "client_name": "Maria Silva",
    "project_type": "exterior",
    "additional_notes": "Cliente prefere tintas ecológicas",
    "status": "completed",
    "photos_data": [
      "storage/estimates/1/photos/photo1.jpg",
      "storage/estimates/1/photos/photo2.jpg",
      "storage/estimates/1/photos/photo3.jpg"
    ],
    "measurements": [
      {
        "room": "living_room",
        "area": 25.5
      },
      {
        "room": "kitchen",
        "area": 15.2
      }
    ],
    "paint_elements": [
      {
        "type": "wall",
        "description": "Parede externa frontal",
        "area": 25.5
      },
      {
        "type": "ceiling",
        "description": "Teto da sala",
        "area": 20.0
      }
    ],
    "wall_condition": "good",
    "has_accent_wall": false,
    "extra_notes": "Acesso difícil na parede dos fundos",
    "materials_calculation": {
      "gallons_needed": 2.5,
      "cans_needed": 3,
      "unit": "gallon"
    },
    "labor_calculation": {
      "hours_needed": 8,
      "hourly_rate": 35.0,
      "total_cost": 280.0
    },
    "total_cost": 405.5,
    "complete": false,
    "estimated_timeline_days": 3,
    "ghl_folder_name": "casa_maria_silva",
    "photos_uploaded_at": "2025-01-20T14:30:00Z",
    "measurements_completed_at": "2025-01-20T15:45:00Z",
    "sent_to_client_at": null,
    "created_at": "2025-01-20T10:00:00Z",
    "updated_at": "2025-01-20T16:00:00Z"
  }
}
```

##### `404 Not Found` — Orçamento não encontrado

```json
{
  "success": false,
  "message": "Estimate not found or access denied"
}
```

---

### `PUT /api/estimates/{id}`

**Atualiza um orçamento existente**

Atualiza dados de um orçamento incluindo fotos adicionais se fornecidas.

**Método & URL:** `PUT /api/estimates/{id}`  
**Nome da rota:** N/A  
**Autenticação:** `Bearer {token}`  
**Permissões/Scopes:** `user.ownership`

#### Path params

- `id` (integer, obrigatório) — ID do orçamento

#### Body (multipart/form-data)

**Todos os campos são opcionais para update:**

```json
{
  "project_name": "Casa da Maria - Pintura Externa Atualizada",
  "client_name": "Maria Silva",
  "project_type": "exterior",
  "ghl_contact_id": "60d5ec49e1b2c50012345678",
  "additional_notes": "Cliente prefere tons neutros",
  "wall_condition": "excellent",
  "has_accent_wall": true,
  "extra_notes": "Parede de destaque será azul",
  "total_cost": 2500.0,
  "photos": ["(binary file - optional)"],
  "paint_elements": [
    {
      "type": "wall",
      "description": "Parede da sala",
      "area": 25.5
    }
  ],
  "materials_calculation": {
    "gallons_needed": 3.2,
    "cans_needed": 4,
    "unit": "gallon"
  }
}
```

#### Respostas

##### `200 OK` — Orçamento atualizado com sucesso

```json
{
  "success": true,
  "message": "Estimate updated successfully",
  "data": {
    "id": 1,
    "project_name": "Casa da Maria - Pintura Externa Atualizada",
    "client_name": "Maria Silva",
    "status": "completed",
    "total_cost": 2500.0,
    "updated_at": "2025-01-20T17:00:00Z"
  }
}
```

---

### `POST /api/estimates` (one-shot com zonas e fotos)

Fluxo atual: enviar todo o conteúdo do orçamento em um único POST (offline-first) — `contact_id`, `project_name`, `additional_notes` (opcional), `zones[]` (com `data[0]` e `photos[]` por zona), `materials[]` e `totals`.

Para exemplos detalhados de multipart aninhado por zona, veja a seção "Exemplo de submissão" em `docs/reference/jamie-ai.md` e o cURL em “Criar orçamento (one-shot, formulário)”.

```json
{
  "success": true,
  "message": "Estimate updated successfully",
  "data": {
    "id": 123,
    "status": "photos_uploaded",
    "photos_data": [
      "/storage/estimates/123/photos/p1.jpg",
      "/storage/estimates/123/photos/p2.jpg",
      "/storage/estimates/123/photos/p3.jpg"
    ],
    "photos_uploaded_at": "2025-09-11 18:22:00"
  }
}
```

---

### `DELETE /api/estimates/{id}`

**Remove um orçamento**

Remove permanentemente um orçamento do sistema.

**Método & URL:** `DELETE /api/estimates/{id}`  
**Nome da rota:** N/A  
**Autenticação:** `Bearer {token}`  
**Permissões/Scopes:** `user.ownership`

#### Path params

- `id` (integer, obrigatório) — ID do orçamento

#### Respostas

##### `200 OK` — Orçamento removido com sucesso

```json
{
  "success": true,
  "message": "Estimate deleted successfully"
}
```

##### `400 Bad Request` — Falha ao remover o orçamento

```json
{
  "success": false,
  "message": "Failed to delete estimate"
}
```

## Regras de Negócio

### Transições de Estado

- `draft` → `photos_uploaded` (automaticamente ao criar com fotos)
- `photos_uploaded` → `photos_processed` (após processamento IA)
- `photos_processed` → `elements_selected` (após seleção de elementos)
- `elements_selected` → `materials_calculated` (após cálculo)
- `materials_calculated` → `completed` (após finalização)
- `completed` → `sent` (após envio para CRM)

### Editabilidade

Orçamentos podem ser editados nos estados:

- `draft`, `photos_uploaded`, `photos_processed`, `elements_selected`, `materials_calculated`, `completed`

Orçamentos **não podem** ser editados no estado `sent`.

### Sincronização GHL

- Orçamentos são automaticamente sincronizados com GoHighLevel após criação.
- Quando sincronizado com sucesso, `ghl_estimate_id` é definido no recurso criado.
- Se a sincronização falhar, o orçamento ainda é criado localmente; uma retentativa pode ser acionada por job/serviço.

## Rate Limiting

- **Read operations:** 100 req/min
- **Write operations:** 30 req/min
- **Upload operations:** 5 req/min
- **Dashboard/stats:** 20 req/min

## Exemplos cURL

### Listar orçamentos

```bash
curl -X GET "https://paintpro.barbatech.company/api/estimates?limit=10&status=completed" \
  -H "Authorization: Bearer {your-token}" \
  -H "Accept: application/json"
```

### Criar orçamento (one-shot, formulário)

```bash
curl -X POST "https://paintpro.barbatech.company/api/estimates" \
  -H "Authorization: Bearer {your-token}" -H "Accept: application/json" \
  -F "contact_id=60d5ec49e1b2c50012345678" \
  -F "project_name=Casa da Maria" \
  -F "additional_notes=" \
  -F "zones[0][id]=zone-1" \
  -F "zones[0][name]=Living Room" \
  -F "zones[0][zone_type]=interior" \
  -F "zones[0][data][0][floor_dimensions][length]=16.4" \
  -F "zones[0][data][0][floor_dimensions][width]=13.1" \
  -F "zones[0][data][0][floor_dimensions][height]=8.9" \
  -F "zones[0][data][0][floor_dimensions][unit]=ft" \
  -F "zones[0][data][0][surface_areas][walls][0][id]=wall-1" \
  -F "zones[0][data][0][surface_areas][walls][0][width]=4.0" \
  -F "zones[0][data][0][surface_areas][walls][0][height]=2.7" \
  -F "zones[0][data][0][surface_areas][walls][0][openings_area]=2.0" \
  -F "zones[0][data][0][surface_areas][walls][0][net_area]=8.8" \
  -F "zones[0][data][0][surface_areas][walls][0][unit]=sqft" \
  -F "zones[0][data][0][photos][]=@/path/to/photo1.jpg" \
  -F "zones[0][data][0][photos][]=@/path/to/photo2.jpg" \
  -F "materials[0][id]=mat-001" \
  -F "materials[0][quantity]=3" \
  -F "materials[0][unit_price]=45.99" \
  -F "totals[materials_cost]=150.97" \
  -F "totals[grand_total]=150.97"
```

### Buscar orçamento específico

```bash
curl -X GET "https://paintpro.barbatech.company/api/estimates/1" \
  -H "Authorization: Bearer {your-token}" \
  -H "Accept: application/json"
```

### Dashboard

```bash
curl -X GET "https://paintpro.barbatech.company/api/estimates/dashboard" \
  -H "Authorization: Bearer {your-token}" \
  -H "Accept: application/json"
```

### Anexar fotos (multipart PUT)

```bash
curl -X POST "https://paintpro.barbatech.company/api/estimates/123" \
  -H "Authorization: Bearer {your-token}" \
  -H "Accept: application/json" \
  -F "_method=PUT" \
  -F "photos[]=@/path/to/photo4.jpg" \
  -F "photos[]=@/path/to/photo5.jpg"
```
## Exemplo cURL — One‑shot

```bash
curl -X POST "https://paintpro.barbatech.company/api/estimates" \
  -H "Authorization: Bearer {your-token}" -H "Accept: application/json" \
  -F "contact_id=60d5ec49e1b2c50012345678" \
  -F "project_name=Casa da Maria" \
  -F "additional_notes=" \
  -F "zones[0][id]=zone-1" \
  -F "zones[0][name]=Living Room" \
  -F "zones[0][zone_type]=interior" \
  -F "zones[0][data][0][floor_dimensions][length]=16.4" \
  -F "zones[0][data][0][floor_dimensions][width]=13.1" \
  -F "zones[0][data][0][floor_dimensions][height]=8.9" \
  -F "zones[0][data][0][floor_dimensions][unit]=ft" \
  -F "zones[0][data][0][surface_areas][walls][0][id]=wall-1" \
  -F "zones[0][data][0][surface_areas][walls][0][unit]=sqft" \
  -F "zones[0][data][0][photos][]=@/path/to/photo1.jpg" \
  -F "zones[0][data][0][photos][]=@/path/to/photo2.jpg" \
  -F "materials[0][id]=mat-001" \
  -F "materials[0][quantity]=3" \
  -F "materials[0][unit_price]=45.99" \
  -F "totals[materials_cost]=150.97" \
  -F "totals[grand_total]=150.97"
```

## Resposta — Fonte de Verdade

Veja `paint_pro_api/response.json` para o exemplo completo e atualizado do payload de resposta.
