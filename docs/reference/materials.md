# Materials Extraction

Upload e processamento de PDFs para extração automática de materiais com IA.

## 🔗 Links Rápidos
- Módulo de domínio: `docs/EXTRACAO_PDF_MODULE.MD`
- Orçamentos consumidores: `docs/reference/estimates.md`
- Coleção Postman (`/Materials`): `docs/collections/api-postman.json`

## 📊 Estruturas das Tabelas (Offline-First)

### Schema da Tabela `pdf_uploads`
```sql
CREATE TABLE pdf_uploads (
    id BIGINT UNSIGNED PRIMARY KEY,
    user_id BIGINT UNSIGNED, -- Isolamento por usuário
    original_name VARCHAR(255) NOT NULL,
    display_name VARCHAR(255) NULL, -- Nome amigável
    file_path VARCHAR(255) NOT NULL,
    file_hash VARCHAR(255) UNIQUE, -- Evita duplicatas
    status VARCHAR(255) DEFAULT 'pending', -- pending, processing, completed, failed
    materials_extracted INT DEFAULT 0, -- Contador
    extraction_metadata JSON NULL, -- Metadados da IA
    error_message TEXT NULL,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    
    -- Índices para Performance Offline
    KEY idx_user_id (user_id),
    KEY idx_status (status),
    KEY idx_user_status (user_id, status)
);
```

### Schema da Tabela `extracted_materials`
```sql
CREATE TABLE extracted_materials (
    id BIGINT UNSIGNED PRIMARY KEY,
    user_id BIGINT UNSIGNED, -- Isolamento por usuário
    pdf_upload_id BIGINT UNSIGNED,
    brand VARCHAR(255) NOT NULL,
    description VARCHAR(255) NOT NULL,
    type VARCHAR(255) DEFAULT 'liquid',
    unit VARCHAR(255) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    finish VARCHAR(255) NULL,
    quality_grade VARCHAR(255) NULL,
    category VARCHAR(255) NULL,
    specifications JSON NULL, -- Dados técnicos
    line_number INT NOT NULL, -- Referência ao PDF
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    
    FOREIGN KEY (pdf_upload_id) REFERENCES pdf_uploads(id) ON DELETE CASCADE,
    
    -- Índices para Busca Offline
    KEY idx_user_id (user_id),
    KEY idx_pdf_upload_id (pdf_upload_id),
    KEY idx_brand (brand),
    KEY idx_type (type)
);
```

### Campos para Cache Offline
- **`extraction_metadata`** - JSON com dados da IA para cache
- **`specifications`** - JSON com especificações técnicas
- **`file_hash`** - Evita uploads duplicados offline
- **`status`** - Estados para controle de UI offline

## Fluxo de Processamento

1. **Upload** → `POST /api/materials/upload`
2. **Processamento** → Processamento automático em background
3. **Monitoramento** → `GET /api/materials/status/{id}`
4. **Resultado** → Materiais extraídos disponíveis

## Estados do Processamento

- `pending` — Aguardando processamento
- `processing` — Sendo processado pela IA
- `completed` — Processamento concluído com sucesso
- `failed` — Falha no processamento

## Endpoints

### `POST /api/materials/upload`

**Faz upload de PDF para extração de materiais**

Faz upload de um arquivo PDF e inicia o processo de extração de materiais com IA.

**Método & URL:** `POST /api/materials/upload`  
**Nome da rota:** `materials.upload`  
**Autenticação:** `Bearer {token}`  
**Permissões/Scopes:** `user.ownership`

#### Body (multipart/form-data)

**Campos obrigatórios:**
- `pdf` (file, obrigatório) — Arquivo PDF (máximo 10MB)

#### Validações de PDF
- **Formato aceito:** PDF
- **Tamanho máximo:** 10MB (10240 KB)
- **Tipos MIME:** `application/pdf`

#### Respostas

##### `201 Created` — Upload realizado com sucesso e processamento iniciado

```json
{
  "success": true,
  "message": "PDF uploaded successfully, processing started",
  "data": {
    "id": 1,
    "original_name": "quote.pdf",
    "display_name": "Paint Quote - Project ABC",
    "status": "pending",
    "file_path": "storage/app/private/pdfs/1755692773_quote.pdf",
    "created_at": "2025-01-20T10:00:00Z",
    "updated_at": "2025-01-20T10:00:00Z"
  }
}
```

**Campos da resposta:**
- `id` (integer, obrigatório) — ID único do upload
- `original_name` (string, obrigatório) — Nome original do arquivo
- `display_name` (string, obrigatório) — Nome de exibição gerado
- `status` (string, obrigatório) — Status atual do processamento
- `file_path` (string, obrigatório) — Caminho do arquivo armazenado
- `created_at` (string, obrigatório) — Data de criação (ISO 8601)
- `updated_at` (string, obrigatório) — Data de atualização (ISO 8601)

##### `422 Unprocessable Entity` — Erro de validação

```json
{
  "success": false,
  "message": "Validation failed",
  "errors": {
    "pdf": ["The pdf field is required."],
    "pdf": ["The file must be a PDF."],
    "pdf": ["The PDF file must not exceed 10MB."]
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
    "max_attempts": 5,
    "decay_minutes": 1,
    "retry_after_seconds": 45
  }
}
```

#### Observações
- O processamento é iniciado automaticamente em background via Job Queue
- Um `display_name` é gerado automaticamente baseado no conteúdo do PDF
- O arquivo é armazenado de forma segura em `storage/app/private/pdfs/`

---

### `GET /api/materials/uploads`

**Lista todos os uploads de PDF**

Retorna lista paginada de todos os uploads de PDF do usuário.

**Método & URL:** `GET /api/materials/uploads`  
**Nome da rota:** `materials.uploads`  
**Autenticação:** `Bearer {token}`  
**Permissões/Scopes:** `user.ownership`

#### Query params
- `status` (string, opcional, enum: `pending|processing|completed|failed`) — Filtrar por status
- `limit` (integer, opcional, min: 1, max: 100, default: 15) — Número de itens por página
- `page` (integer, opcional, min: 1, default: 1) — Página atual

#### Respostas

##### `200 OK` — Lista de uploads retornada com sucesso

```json
{
  "success": true,
  "uploads": [
    {
      "id": 1,
      "original_name": "quote.pdf",
      "display_name": "Paint Quote - Project ABC",
      "status": "completed",
      "progress": 100,
      "file_size_kb": 2048,
      "created_at": "2025-01-20T10:00:00Z",
      "updated_at": "2025-01-20T10:05:00Z",
      "completed_at": "2025-01-20T10:05:00Z"
    },
    {
      "id": 2,
      "original_name": "materials_list.pdf",
      "display_name": "Materials List - House Project",
      "status": "processing",
      "progress": 65,
      "file_size_kb": 1536,
      "created_at": "2025-01-20T11:00:00Z",
      "updated_at": "2025-01-20T11:02:00Z",
      "completed_at": null
    }
  ],
  "pagination": {
    "total": 25,
    "per_page": 15,
    "current_page": 1,
    "last_page": 2
  }
}
```

---

### `GET /api/materials/status/{pdfUpload}`

**Verifica status de processamento de PDF**

Retorna o status atual do processamento de um PDF específico.

**Método & URL:** `GET /api/materials/status/{pdfUpload}`  
**Nome da rota:** `materials.status`  
**Autenticação:** `Bearer {token}`  
**Permissões/Scopes:** `user.ownership`

#### Path params
- `pdfUpload` (integer, obrigatório) — ID do upload de PDF

#### Respostas

##### `200 OK` — Status retornado com sucesso

```json
{
  "success": true,
  "data": {
    "id": 1,
    "original_name": "quote.pdf",
    "display_name": "Paint Quote - Project ABC",
    "status": "completed",
    "progress": 100,
    "processing_started_at": "2025-01-20T10:00:30Z",
    "processing_completed_at": "2025-01-20T10:05:15Z",
    "extracted_materials": [
      {
        "material_type": "paint",
        "brand": "Sherwin Williams",
        "product_name": "ProClassic Interior Acrylic Latex Enamel",
        "color": "Pure White",
        "color_code": "7005-1",
        "quantity": 2.5,
        "unit": "gallon",
        "estimated_cost": 125.50,
        "coverage_sqft": 400,
        "finish": "satin",
        "location": "interior walls"
      },
      {
        "material_type": "primer",
        "brand": "Sherwin Williams",
        "product_name": "ProBlock Oil Based Primer",
        "color": "White",
        "quantity": 1.0,
        "unit": "gallon",
        "estimated_cost": 45.99,
        "coverage_sqft": 200,
        "location": "interior walls"
      },
      {
        "material_type": "supplies",
        "product_name": "Roller Covers 9\"",
        "quantity": 4,
        "unit": "piece",
        "estimated_cost": 12.00
      }
    ],
    "total_estimated_cost": 183.49,
    "extraction_confidence": 0.92,
    "pages_processed": 3,
    "created_at": "2025-01-20T10:00:00Z",
    "updated_at": "2025-01-20T10:05:15Z"
  }
}
```

**Campos específicos da extração:**
- `extracted_materials` (array, condicional) — Lista de materiais extraídos (só presente quando `status=completed`)
- `total_estimated_cost` (number, condicional) — Custo total estimado
- `extraction_confidence` (number, condicional) — Confiança da extração (0.0 a 1.0)
- `pages_processed` (integer, condicional) — Número de páginas processadas
- `progress` (integer, obrigatório) — Progresso em percentual (0-100)

##### `404 Not Found` — Upload não encontrado

```json
{
  "success": false,
  "message": "Resource not found",
  "error_code": "RESOURCE_NOT_FOUND"
}
```

#### Estados de Processamento

**Pending (`status: "pending"`):**
```json
{
  "status": "pending",
  "progress": 0,
  "processing_started_at": null,
  "extracted_materials": null
}
```

**Processing (`status: "processing"`):**
```json
{
  "status": "processing",
  "progress": 65,
  "processing_started_at": "2025-01-20T10:00:30Z",
  "estimated_completion": "2025-01-20T10:06:00Z",
  "extracted_materials": null
}
```

**Failed (`status: "failed"`):**
```json
{
  "status": "failed",
  "progress": 0,
  "error_message": "Could not extract text from PDF. File may be corrupted or contain only images.",
  "error_code": "EXTRACTION_FAILED",
  "retry_available": true,
  "extracted_materials": null
}
```

---

### `PUT /api/materials/update/{pdfUpload}`

**Atualiza informações de um upload de PDF**

Permite atualizar o nome de exibição e outras informações de um upload.

**Método & URL:** `PUT /api/materials/update/{pdfUpload}`  
**Nome da rota:** `materials.update`  
**Autenticação:** `Bearer {token}`  
**Permissões/Scopes:** `user.ownership`

#### Path params
- `pdfUpload` (integer, obrigatório) — ID do upload de PDF

#### Body (JSON)

```json
{
  "display_name": "Paint Quote - Updated Name"
}
```

**Campos do body:**
- `display_name` (string, obrigatório, max: 255) — Novo nome de exibição

#### Respostas

##### `200 OK` — Upload atualizado com sucesso

```json
{
  "success": true,
  "message": "PDF upload updated successfully",
  "data": {
    "id": 1,
    "original_name": "quote.pdf",
    "display_name": "Paint Quote - Updated Name",
    "status": "completed",
    "updated_at": "2025-01-20T15:30:00Z"
  }
}
```

---

### `DELETE /api/materials/delete/{pdfUpload}`

**Remove um upload de PDF**

Remove permanentemente um upload de PDF e seus dados extraídos.

**Método & URL:** `DELETE /api/materials/delete/{pdfUpload}`  
**Nome da rota:** `materials.delete`  
**Autenticação:** `Bearer {token}`  
**Permissões/Scopes:** `user.ownership`

#### Path params
- `pdfUpload` (integer, obrigatório) — ID do upload de PDF

#### Respostas

##### `200 OK` — Upload removido com sucesso

```json
{
  "success": true,
  "message": "PDF upload deleted successfully"
}
```

##### `404 Not Found` — Upload não encontrado

```json
{
  "success": false,
  "message": "Resource not found",
  "error_code": "RESOURCE_NOT_FOUND"
}
```

#### Observações
- Remove o arquivo físico do storage
- Remove todos os dados extraídos associados
- Operação irreversível

## Estrutura dos Materiais Extraídos

### Tipos de Material
- `paint` — Tintas
- `primer` — Primers/seladores
- `stain` — Vernizes/stains
- `supplies` — Suprimentos (rolos, pincéis, etc.)
- `tools` — Ferramentas
- `preparation` — Materiais de preparação

### Campos Comuns
- `material_type` — Tipo do material
- `brand` — Marca do produto
- `product_name` — Nome do produto
- `quantity` — Quantidade
- `unit` — Unidade de medida
- `estimated_cost` — Custo estimado

### Campos Específicos para Tintas
- `color` — Cor
- `color_code` — Código da cor
- `coverage_sqft` — Cobertura em pés quadrados
- `finish` — Acabamento (flat, satin, semi-gloss, gloss)
- `location` — Localização de uso

### Unidades de Medida
- `gallon`, `quart`, `pint` — Volume
- `piece`, `set` — Quantidade
- `sqft`, `sqm` — Área
- `lbs`, `kg` — Peso

## Rate Limiting

- **Upload operations:** 5 req/min (muito restritivo devido ao processamento)
- **Read operations:** 100 req/min
- **Write operations:** 30 req/min

## Background Processing

O processamento é feito via Laravel Jobs Queue com as seguintes características:

- **Job:** `ProcessPdfExtractionJob`
- **Queue:** `pdf-processing`
- **Timeout:** 10 minutos
- **Tries:** 3 tentativas
- **Backoff:** 30, 60, 120 segundos

## Exemplos cURL

### Upload de PDF
```bash
curl -X POST "https://paintpro.barbatech.company/api/materials/upload" \
  -H "Authorization: Bearer {your-token}" \
  -F "pdf=@/path/to/quote.pdf"
```

### Listar uploads
```bash
curl -X GET "https://paintpro.barbatech.company/api/materials/uploads?status=completed&limit=10" \
  -H "Authorization: Bearer {your-token}" \
  -H "Accept: application/json"
```

### Verificar status
```bash
curl -X GET "https://paintpro.barbatech.company/api/materials/status/1" \
  -H "Authorization: Bearer {your-token}" \
  -H "Accept: application/json"
```

### Atualizar nome
```bash
curl -X PUT "https://paintpro.barbatech.company/api/materials/update/1" \
  -H "Authorization: Bearer {your-token}" \
  -H "Content-Type: application/json" \
  -d '{"display_name": "New Display Name"}'
```

### Deletar upload
```bash
curl -X DELETE "https://paintpro.barbatech.company/api/materials/delete/1" \
  -H "Authorization: Bearer {your-token}" \
  -H "Accept: application/json"
```
