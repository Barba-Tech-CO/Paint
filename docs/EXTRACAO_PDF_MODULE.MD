# MÓDULO DE EXTRAÇÃO DE PDF - EXTRACAO_PDF_MODULE

Este módulo gerencia o upload e extração de dados de materiais a partir de arquivos PDF, com armazenamento em **Cloudflare R2** e processamento automático de orçamentos e listas de materiais. O sistema suporta apenas arquivos com preços em **USD ($)** e todas as mensagens são em **inglês**.

## 1. Modelos de Dados e Estrutura da Tabela

### Modelo PdfUpload (Upload de PDF)

**Arquivo:** `app/PdfUpload.php`

**Atributos do Model:**
- `id` (integer, not null) - ID único do upload
- `user_id` (integer, nullable) - ID do usuário proprietário
- `original_name` (string, not null) - Nome original do arquivo
- `display_name` (string, nullable) - Nome de exibição personalizado
- `file_path` (string, not null) - **Chave R2 do arquivo** (formato: `pdfs/{Y}/{m}/{d}/{uuid}-{nome}.pdf`)
- `r2_url` (string, nullable) - **URL de acesso R2** (temporária ou pública via CDN)
- `file_hash` (string, not null, unique) - Hash único do arquivo
- `status` (string, not null) - Status do processamento (pending, processing, completed, failed)
- `materials_extracted` (integer, not null) - Número de materiais extraídos
- `extraction_metadata` (array, nullable) - Metadados da extração
- `error_message` (text, nullable) - Mensagem de erro se houver
- `created_at` (timestamp, not null) - Data de upload
- `updated_at` (timestamp, not null) - Data de atualização

**Estrutura da Tabela `pdf_uploads`:**
```sql
CREATE TABLE pdf_uploads (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NULL,
    original_name VARCHAR(255) NOT NULL,
    display_name VARCHAR(255) NULL,
    file_path VARCHAR(255) NOT NULL, -- Chave R2 do arquivo
    r2_url VARCHAR(512) NULL, -- URL de acesso R2
    file_hash VARCHAR(255) NOT NULL UNIQUE,
    status VARCHAR(255) DEFAULT 'pending',
    materials_extracted INT DEFAULT 0,
    extraction_metadata JSON NULL,
    error_message TEXT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    INDEX idx_user_id (user_id),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
);
```

### Modelo ExtractedMaterial (Material Extraído)

**Arquivo:** `app/ExtractedMaterial.php`

**Atributos do Model:**
- `id` (integer, not null) - ID único do material
- `pdf_upload_id` (integer, not null) - ID do upload de PDF
- `user_id` (integer, nullable) - ID do usuário proprietário
- `brand` (string, not null) - Marca do material
- `description` (string, not null) - Descrição do material
- `type` (string, not null) - Tipo do material (padrão: 'liquid')
- `unit` (string, not null) - Unidade de medida
- `unit_price` (decimal, not null) - Preço unitário
- `finish` (string, nullable) - Acabamento do material
- `quality_grade` (string, nullable) - Grau de qualidade
- `category` (string, nullable) - Categoria do material
- `specifications` (array, nullable) - Especificações técnicas
- `line_number` (integer, not null) - Número da linha no documento
- `created_at` (timestamp, not null) - Data de criação
- `updated_at` (timestamp, not null) - Data de atualização

**Estrutura da Tabela `extracted_materials`:**
```sql
CREATE TABLE extracted_materials (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    pdf_upload_id BIGINT NOT NULL,
    user_id BIGINT NULL,
    brand VARCHAR(255) NOT NULL,
    description VARCHAR(255) NOT NULL,
    type VARCHAR(255) DEFAULT 'liquid',
    unit VARCHAR(255) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    finish VARCHAR(255) NULL,
    quality_grade VARCHAR(255) NULL,
    category VARCHAR(255) NULL,
    specifications JSON NULL,
    line_number INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    FOREIGN KEY (pdf_upload_id) REFERENCES pdf_uploads(id) ON DELETE CASCADE,
    INDEX idx_pdf_upload (pdf_upload_id),
    INDEX idx_user_id (user_id),
    INDEX idx_brand (brand),
    INDEX idx_category (category)
);
```

## 2. Endpoints da API

### 2.1 Upload de PDF

**Título:** Fazer Upload de Arquivo PDF  
**Descrição:** Faz upload de um arquivo PDF para extração de materiais

**URL e Método HTTP:** `POST /api/materials/upload`  
**Parâmetros da Rota:** Nenhum

### 2.2 Listar Uploads

**Título:** Listar Uploads de PDF  
**Descrição:** Retorna lista paginada de uploads de PDF com status de processamento

**URL e Método HTTP:** `GET /api/materials/uploads`  
**Parâmetros da Rota:** Nenhum  
**Query Parameters:**
- `status` (string, opcional) - Filtrar por status (pending, processing, completed, failed)
- `limit` (integer, opcional) - Número de itens por página (padrão: 10)
- `page` (integer, opcional) - Número da página (padrão: 1)

### 2.3 Verificar Status

**Título:** Verificar Status do Processamento  
**Descrição:** Retorna o status e resultados do processamento de um PDF específico

**URL e Método HTTP:** `GET /api/materials/status/{pdfUpload}`  
**Parâmetros da Rota:**
- `pdfUpload` (integer, obrigatório) - ID do upload de PDF

### 2.4 Atualizar Upload

**Título:** Atualizar Dados do Upload  
**Descrição:** Atualiza informações de um upload de PDF (como nome de exibição)

**URL e Método HTTP:** `PUT /api/materials/update/{pdfUpload}`  
**Parâmetros da Rota:**
- `pdfUpload` (integer, obrigatório) - ID do upload de PDF

### 2.5 Excluir Upload

**Título:** Excluir Upload de PDF  
**Descrição:** Remove um upload de PDF e todos os materiais extraídos

**URL e Método HTTP:** `DELETE /api/materials/delete/{pdfUpload}`  
**Parâmetros da Rota:**
- `pdfUpload` (integer, obrigatório) - ID do upload de PDF

### 2.6 Listar Materiais Extraídos

**Título:** Listar Materiais Extraídos  
**Descrição:** Retorna lista paginada e filtrada de todos os materiais extraídos dos PDFs

**URL e Método HTTP:** `GET /api/materials/extracted`  
**Parâmetros da Rota:** Nenhum  
**Query Parameters:**
- `brand` (string, opcional) - Filtrar por marca específica (dropdown)
- `ambient` (string, opcional) - Filtrar por ambiente/categoria (dropdown: Interior, Exterior, etc.)
- `finish` (string, opcional) - Filtrar por acabamento (dropdown: Flat, Satin, Semi-Gloss, Gloss)
- `quality` (string|array, opcional) - Filtrar por qualidade (chips selecionáveis: Economic, Standard, High, Premium)
- `search` (string, opcional) - Busca textual em descrição e marca (campo de busca no topo)
- `sort_by` (string, opcional) - Campo para ordenação (created_at, brand, finish, unit_price, description, line_number)
- `sort_order` (string, opcional) - Ordem (asc, desc) - padrão: desc
- `page` (integer, opcional) - Número da página (padrão: 1, fixo 20 itens por página)

### 2.7 Obter Material Específico

**Título:** Obter Detalhes de Material Extraído  
**Descrição:** Retorna detalhes completos de um material extraído específico

**URL e Método HTTP:** `GET /api/materials/extracted/{material}`  
**Parâmetros da Rota:**
- `material` (integer, obrigatório) - ID do material extraído

### 2.8 Obter Filtros Disponíveis

**Título:** Obter Opções de Filtros  
**Descrição:** Retorna todos os valores únicos disponíveis para filtros (marcas, tipos, acabamentos, etc.)

**URL e Método HTTP:** `GET /api/materials/filters`  
**Parâmetros da Rota:** Nenhum

## 3. Requisição Esperada

### 3.1 Upload de PDF

**Headers:**
```
Accept: application/json
Content-Type: multipart/form-data
Authorization: Bearer {auth_token}
```

**Corpo da Requisição:**
```
pdf: [arquivo PDF] // Arquivo PDF (obrigatório, máximo 25MB, apenas .pdf)
```

**Validações:**
- Arquivo obrigatório
- Apenas tipo MIME `application/pdf`
- Tamanho máximo: 25MB (25.600 KB)
- Apenas preços em USD ($) são aceitos
- Rejeita documentos com moedas não-USD (R$, €, £, etc.)

### 3.2 Listar Uploads

**Headers:**
```
Accept: application/json
Authorization: Bearer {auth_token}
```

**Corpo da Requisição:** Nenhum

### 3.3 Verificar Status

**Headers:**
```
Accept: application/json
Authorization: Bearer {auth_token}
```

**Corpo da Requisição:** Nenhum

### 3.4 Atualizar Upload

**Headers:**
```
Accept: application/json
Content-Type: application/json
Authorization: Bearer {auth_token}
```

**Corpo da Requisição:**
```json
{
    "display_name": "Orçamento Atualizado - Casa Maria Silva" // Nome de exibição (obrigatório)
}
```

### 3.5 Excluir Upload

**Headers:**
```
Accept: application/json
Authorization: Bearer {auth_token}
```

**Corpo da Requisição:** Nenhum

### 3.6 Listar Materiais Extraídos

**Headers:**
```
Accept: application/json
Authorization: Bearer {auth_token}
```

**Corpo da Requisição:** Nenhum

**Exemplos de Uso dos Filtros:**

**1. Filtrar por marca específica (dropdown):**
```
GET /api/materials/extracted?brand=Benjamin Moore
# Encontra apenas materiais da marca "Benjamin Moore"
```

**2. Filtrar por ambiente/categoria (dropdown):**
```
GET /api/materials/extracted?ambient=Exterior
# Encontra apenas materiais para uso exterior
```

**3. Filtrar por acabamento (dropdown):**
```
GET /api/materials/extracted?finish=Flat
# Encontra apenas materiais com acabamento "Flat"
```

**4. Filtrar por qualidade única (chip selecionado):**
```
GET /api/materials/extracted?quality=Premium
# Encontra apenas materiais de qualidade "Premium"
```

**5. Filtrar por múltiplas qualidades (múltiplos chips):**
```
GET /api/materials/extracted?quality[]=Premium&quality[]=High
# Encontra materiais de qualidade "Premium" OU "High"
```

**6. Busca textual (campo search no topo):**
```
GET /api/materials/extracted?search=interior paint
# Busca "interior paint" na descrição e marca
```

**7. Múltiplos filtros combinados:**
```
GET /api/materials/extracted?brand=Benjamin Moore&ambient=Interior&finish=Satin&quality[]=Premium&quality[]=High&search=paint&sort_by=unit_price&sort_order=asc&page=1
```

**9. Navegação entre páginas:**
```
# Primeira página (padrão)
GET /api/materials/extracted?page=1

# Segunda página  
GET /api/materials/extracted?page=2

# Terceira página com filtros
GET /api/materials/extracted?brand=Benjamin Moore&finish=Satin&page=3
```

**8. Ordenação personalizada:**
```
# Ordenar por preço (menor para maior)
GET /api/materials/extracted?sort_by=unit_price&sort_order=asc

# Ordenar por marca (A-Z)
GET /api/materials/extracted?sort_by=brand&sort_order=asc

# Ordenar por acabamento (A-Z)
GET /api/materials/extracted?sort_by=finish&sort_order=asc
```

### 3.7 Obter Material Específico

**Headers:**
```
Accept: application/json
Authorization: Bearer {auth_token}
```

**Corpo da Requisição:** Nenhum

### 3.8 Obter Filtros Disponíveis

**Headers:**
```
Accept: application/json
Authorization: Bearer {auth_token}
```

**Corpo da Requisição:** Nenhum

## 4. Respostas Esperadas

### 4.1 Upload de PDF

**Status 201 (Created):**
```json
{
    "success": true,
    "data": {
        "upload": {
            "id": 15,
            "user_id": 1,
            "original_name": "quote-materials.pdf",
            "file_path": "pdfs/2025/08/27/uuid-quote-materials.pdf",
            "r2_url": "https://cdn.example.com/pdfs/2025/08/27/uuid-quote-materials.pdf",
            "file_hash": "a1b2c3d4e5f6...",
            "status": "pending",
            "materials_extracted": 0,
            "created_at": "2025-08-27T16:30:00Z",
            "updated_at": "2025-08-27T16:30:00Z"
        },
        "message": "PDF uploaded successfully. Processing started.",
        "r2_url": "https://cdn.example.com/pdfs/2025/08/27/uuid-quote-materials.pdf",
        "size": 1048576
    }
}
```

**Status 422 (Validation Error):**
```json
{
    "message": "The PDF field is required.",
    "errors": {
        "pdf": ["The PDF field is required."]
    }
}
```

**Status 422 (File Size Error):**
```json
{
    "message": "The PDF must not exceed 25MB.",
    "errors": {
        "pdf": ["The PDF must not exceed 25MB."]
    }
}
```

**Status 422 (Invalid File Type):**
```json
{
    "message": "The PDF must be a valid PDF file.",
    "errors": {
        "pdf": ["The PDF must be a valid PDF file."]
    }
}
```

**Status 422 (Invalid Currency):**
```json
{
    "success": false,
    "message": "Upload failed: Invalid currency detected: Brazilian Real (R$). Only USD ($) is supported for material pricing."
}
```

**Status 200 (Duplicate File - Already Processed):**
```json
{
    "success": true,
    "data": {
        "upload": {
            "id": 12,
            "original_name": "quote-materials.pdf",
            "file_path": "pdfs/2025/08/27/uuid-quote-materials.pdf",
            "r2_url": "https://cdn.example.com/pdfs/2025/08/27/uuid-quote-materials.pdf",
            "status": "completed",
            "materials_extracted": 25
        },
        "message": "File already uploaded and processed"
    }
}
```

### 4.2 Listar Uploads

**Status 200 (Success):**
```json
{
    "success": true,
    "data": {
        "uploads": [
            {
                "id": 15,
                "original_name": "quote-materials.pdf",
                "display_name": "Quote Materials - Project Alpha",
                "file_path": "pdfs/2025/08/27/uuid-quote-materials.pdf",
                "r2_url": "https://cdn.example.com/pdfs/2025/08/27/uuid-quote-materials.pdf",
                "status": "completed",
                "materials_extracted": 25,
                "created_at": "2025-08-27T16:30:00Z",
                "updated_at": "2025-08-27T16:45:00Z"
            },
            {
                "id": 14,
                "original_name": "paint-list.pdf",
                "display_name": "Premium Paint List",
                "file_path": "pdfs/2025/08/27/uuid-paint-list.pdf",
                "r2_url": "https://cdn.example.com/pdfs/2025/08/27/uuid-paint-list.pdf",
                "status": "processing",
                "materials_extracted": 0,
                "created_at": "2025-08-27T15:15:00Z",
                "updated_at": "2025-08-27T15:20:00Z"
            }
        ],
        "pagination": {
            "total": 45,
            "per_page": 15,
            "current_page": 1,
            "last_page": 3
        }
    }
}
```

### 4.3 Verificar Status

**Status 200 (Success) - Processamento Concluído:**
```json
{
    "success": true,
    "data": {
        "upload": {
            "id": 15,
            "original_name": "quote-materials.pdf",
            "display_name": "Quote Materials - Project Alpha",
            "file_path": "pdfs/2025/08/27/uuid-quote-materials.pdf",
            "r2_url": "https://cdn.example.com/pdfs/2025/08/27/uuid-quote-materials.pdf",
            "status": "completed",
            "materials_extracted": 25,
            "error_message": null,
            "r2_key": "pdfs/2025/08/27/uuid-quote-materials.pdf",
            "extraction_metadata": {
                "brand": "Sherwin-Williams", 
                "total_materials": 25,
                "extraction_timestamp": "2025-08-27T16:45:00Z"
            },
            "created_at": "2025-08-27T16:30:00Z",
            "updated_at": "2025-08-27T16:45:00Z"
        }
    }
}
```

**Status 200 (Success) - Processamento em Andamento:**
```json
{
    "success": true,
    "data": {
        "upload": {
            "id": 14,
            "original_name": "paint-list.pdf",
            "display_name": "Premium Paint List",
            "file_path": "pdfs/2025/08/27/uuid-paint-list.pdf", 
            "r2_url": "https://cdn.example.com/pdfs/2025/08/27/uuid-paint-list.pdf",
            "status": "processing",
            "materials_extracted": 0,
            "error_message": null,
            "r2_key": "pdfs/2025/08/27/uuid-paint-list.pdf",
            "created_at": "2025-08-27T15:15:00Z",
            "updated_at": "2025-08-27T16:50:00Z"
        }
    }
}
```

**Status 200 (Success) - Processamento com Erro:**
```json
{
    "success": true,
    "data": {
        "upload": {
            "id": 13,
            "original_name": "corrupted-file.pdf",
            "display_name": "Problematic File",
            "file_path": "pdfs/2025/08/27/uuid-corrupted-file.pdf",
            "r2_url": "https://cdn.example.com/pdfs/2025/08/27/uuid-corrupted-file.pdf",
            "status": "error",
            "materials_extracted": 0,
            "error_message": "Invalid currency detected: Brazilian Real (R$). Only USD ($) is supported for material pricing.",
            "r2_key": "pdfs/2025/08/27/uuid-corrupted-file.pdf",
            "created_at": "2025-08-27T14:00:00Z",
            "updated_at": "2025-08-27T14:05:00Z"
        }
    }
}
```

**Status 404 (Not Found):**
```json
{
    "success": false,
    "message": "Failed to retrieve status: No query results for model [App\\PdfUpload]."
}
```

### 4.4 Atualizar Upload

**Status 200 (Success):**
```json
{
    "success": true,
    "data": {
        "upload": {
            "id": 15,
            "original_name": "quote-materials.pdf",
            "display_name": "Updated Quote - Project Alpha",
            "file_path": "pdfs/2025/08/27/uuid-quote-materials.pdf",
            "r2_url": "https://cdn.example.com/pdfs/2025/08/27/uuid-quote-materials.pdf",
            "status": "completed",
            "updated_at": "2025-08-27T17:00:00Z"
        },
        "message": "PDF display name updated successfully"
    }
}
```

**Status 422 (Validation Error):**
```json
{
    "message": "The display name field is required.",
    "errors": {
        "display_name": ["The display name field is required."]
    }
}
```

**Status 404 (Not Found):**
```json
{
    "success": false,
    "message": "Failed to update PDF: No query results for model [App\\PdfUpload]."
}
```

### 4.5 Excluir Upload

**Status 200 (Success):**
```json
{
    "success": true,
    "data": {
        "message": "PDF and all related materials deleted successfully"
    }
}
```

**Status 404 (Not Found):**
```json
{
    "success": false,
    "message": "Failed to delete PDF: No query results for model [App\\PdfUpload]."
}
```

**Status 422 (Server Error):**
```json
{
    "success": false,
    "message": "Failed to delete PDF: [error details]"
}
```

### 4.6 Listar Materiais Extraídos

**Status 200 (Success):**
```json
{
    "success": true,
    "data": {
        "materials": [
            {
                "id": 15,
                "pdf_upload_id": 3,
                "user_id": 1,
                "brand": "Sherwin-Williams",
                "description": "ProClassic Interior Acrylic Latex Enamel",
                "type": "liquid",
                "unit": "gallon",
                "unit_price": 52.99,
                "finish": "satin",
                "quality_grade": "premium",
                "category": "interior-paint",
                "specifications": {
                    "coverage": "350-400 sq ft per gallon",
                    "dry_time": "2-4 hours",
                    "voc_content": "<50 g/L"
                },
                "line_number": 3,
                "created_at": "2025-08-27T16:45:00Z",
                "updated_at": "2025-08-27T16:45:00Z",
                "pdf_upload": {
                    "id": 3,
                    "original_name": "sherwin-quote.pdf",
                    "display_name": "Sherwin Williams Quote - Living Room",
                    "created_at": "2025-08-27T16:30:00Z"
                }
            },
            {
                "id": 16,
                "pdf_upload_id": 3,
                "user_id": 1,
                "brand": "Benjamin Moore",
                "description": "Advance Waterborne Interior Alkyd Paint",
                "type": "liquid",
                "unit": "quart",
                "unit_price": 28.99,
                "finish": "semi-gloss",
                "quality_grade": "professional",
                "category": "trim-paint",
                "specifications": {
                    "coverage": "75-100 sq ft per quart",
                    "dry_time": "1-2 hours",
                    "durability": "high"
                },
                "line_number": 7,
                "created_at": "2025-08-27T16:45:00Z",
                "updated_at": "2025-08-27T16:45:00Z",
                "pdf_upload": {
                    "id": 3,
                    "original_name": "sherwin-quote.pdf",
                    "display_name": "Sherwin Williams Quote - Living Room",
                    "created_at": "2025-08-27T16:30:00Z"
                }
            }
        ],
        "pagination": {
            "total": 125,
            "per_page": 20,
            "current_page": 1,
            "last_page": 7,
            "from": 1,
            "to": 20
        },
        "filters_applied": {
            "brand": "Benjamin Moore",
            "ambient": "Interior",
            "finish": "Satin",
            "quality": ["Premium"]
        }
    }
}
```

**Status 422 (Error):**
```json
{
    "success": false,
    "message": "Failed to retrieve materials: [error details]"
}
```

### 4.7 Obter Material Específico

**Status 200 (Success):**
```json
{
    "success": true,
    "data": {
        "material": {
            "id": 15,
            "pdf_upload_id": 3,
            "user_id": 1,
            "brand": "Sherwin-Williams",
            "description": "ProClassic Interior Acrylic Latex Enamel",
            "type": "liquid",
            "unit": "gallon",
            "unit_price": 52.99,
            "finish": "satin",
            "quality_grade": "premium",
            "category": "interior-paint",
            "specifications": {
                "coverage": "350-400 sq ft per gallon",
                "dry_time": "2-4 hours",
                "voc_content": "<50 g/L",
                "color_family": "white",
                "sheen_level": "25-35%"
            },
            "line_number": 3,
            "created_at": "2025-08-27T16:45:00Z",
            "updated_at": "2025-08-27T16:45:00Z",
            "pdf_upload": {
                "id": 3,
                "original_name": "sherwin-quote.pdf",
                "display_name": "Sherwin Williams Quote - Living Room",
                "created_at": "2025-08-27T16:30:00Z"
            }
        }
    }
}
```

**Status 404 (Not Found):**
```json
{
    "success": false,
    "message": "Failed to retrieve material: No query results for model [App\\ExtractedMaterial]."
}
```

### 4.8 Obter Filtros Disponíveis

**Status 200 (Success):**
```json
{
    "success": true,
    "data": {
        "filters": {
            "brands": [
                "Benjamin Moore",
                "Sherwin-Williams"
            ],
            "ambients": [
                "Interior",
                "Exterior"
            ],
            "finishes": [
                "Flat",
                "Satin",
                "Semi-Gloss",
                "Gloss"
            ],
            "qualities": [
                "Economic",
                "Standard",
                "High",
                "Premium"
            ]
        }
    }
}
```

**Status 422 (Error):**
```json
{
    "success": false,
    "message": "Failed to retrieve filters: [error details]"
}
```

## 5. Configuração do Cloudflare R2

### 5.1 Variáveis de Ambiente

Adicione ao `.env`:

```env
# Cloudflare R2 Storage Configuration
R2_ACCESS_KEY_ID=your_r2_access_key_id
R2_SECRET_ACCESS_KEY=your_r2_secret_access_key
R2_ACCOUNT_ID=your_cloudflare_account_id
R2_BUCKET=your_r2_bucket_name
R2_ENDPOINT=https://${R2_ACCOUNT_ID}.r2.cloudflarestorage.com
R2_REGION=auto
R2_PUBLIC_BASE_URL=https://your-custom-domain.com
```

### 5.2 Estrutura de Armazenamento

**Formato da Chave R2:**
```
pdfs/{year}/{month}/{day}/{uuid}-{sanitized-filename}.pdf
```

**Exemplo:**
```
pdfs/2025/08/27/03aa1e55-fcc2-47e4-be98-5346dc76ba05-quote-materials.pdf
```

### 5.3 URLs de Acesso

- **URL Temporária (Privada)**: Válida por 15 minutos para buckets privados
- **URL Pública (CDN)**: Via domínio personalizado quando `R2_PUBLIC_BASE_URL` configurado

### 5.4 Funcionalidades do Sistema

- ✅ **Armazenamento Duplo**: R2 (permanente) + Local (temporário para processamento)
- ✅ **Detecção de Duplicatas**: Baseada em hash MD5 do arquivo
- ✅ **Validação de Moeda**: Apenas USD aceito, rejeita R$, €, £, etc.
- ✅ **Mensagens em Inglês**: Logs, validações, e respostas API
- ✅ **Sanitização de Nomes**: Remove caracteres especiais
- ✅ **Organização Temporal**: Estrutura de pastas por data
- ✅ **Cleanup Automático**: Remove arquivos locais após processamento
- ✅ **Marca Suportadas**: Sherwin-Williams e Benjamin Moore

## 6. Exemplos de Implementação Flutter

### 6.1 Classe Dart para Requisições

```dart
class MaterialFilters {
  String? brand;        // Dropdown: marca específica
  String? ambient;      // Dropdown: Interior, Exterior, etc.
  String? finish;       // Dropdown: Flat, Satin, Semi-Gloss, Gloss
  List<String>? quality; // Chips: Economic, Standard, High, Premium (múltiplo)
  String? search;       // Campo de busca textual
  String sortBy;        // Ordenação
  String sortOrder;     // Direção da ordenação
  int page;             // Página atual (fixo 20 itens por página)

  MaterialFilters({
    this.brand,
    this.ambient,
    this.finish,
    this.quality,
    this.search,
    this.sortBy = 'created_at',
    this.sortOrder = 'desc',
    this.page = 1,
  });

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    
    if (brand != null && brand!.isNotEmpty) params['brand'] = brand;
    if (ambient != null && ambient!.isNotEmpty) params['ambient'] = ambient;
    if (finish != null && finish!.isNotEmpty) params['finish'] = finish;
    if (search != null && search!.isNotEmpty) params['search'] = search;
    
    // Qualidade pode ser múltipla (array)
    if (quality != null && quality!.isNotEmpty) {
      if (quality!.length == 1) {
        params['quality'] = quality!.first;
      } else {
        for (int i = 0; i < quality!.length; i++) {
          params['quality[]'] = quality![i];
        }
      }
    }
    
    params['sort_by'] = sortBy;
    params['sort_order'] = sortOrder;
    params['page'] = page.toString();
    
    return params;
  }
}
```

### 6.2 Exemplos de Uso no Flutter

```dart
// 1. Buscar tintas Benjamin Moore com acabamento Satin
final filters = MaterialFilters(
  brand: 'Benjamin Moore',
  finish: 'Satin',
  ambient: 'Interior'
);

final materials = await apiClient.getMaterials(filters);

// 2. Buscar materiais Premium ou High qualidade
final qualityFilters = MaterialFilters(
  quality: ['Premium', 'High'],
  sortBy: 'unit_price',
  sortOrder: 'asc'
);

// 3. Busca textual por "interior paint" - página 2
final searchFilters = MaterialFilters(
  search: 'interior paint',
  page: 2
);

// 4. Filtros combinados da interface
final combinedFilters = MaterialFilters(
  brand: 'Benjamin Moore',
  ambient: 'Exterior', 
  finish: 'Flat',
  quality: ['Premium'],
  search: 'EG-SHEL',
  sortBy: 'brand',
  sortOrder: 'asc'
);
```

### 6.3 Construção de URLs

```dart
String buildMaterialsUrl(MaterialFilters filters) {
  final baseUrl = 'https://paintpro.barbatech.company/api/materials/extracted';
  final params = filters.toQueryParams();
  
  if (params.isEmpty) return baseUrl;
  
  final queryString = params.entries
      .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
      .join('&');
      
  return '$baseUrl?$queryString';
}

// Exemplo de URL gerada:
// https://paintpro.barbatech.company/api/materials/extracted?brand=Benjamin Moore&ambient=Interior&finish=Satin&quality[]=Premium&quality[]=High&sort_by=unit_price&sort_order=asc&page=2
```

### 6.4 Filtros Dinâmicos com Dropdown

```dart
// 1. Primeiro, buscar opções disponíveis para filtros
final filterOptions = await apiClient.getFilterOptions();

// 2. Popular dropdowns conforme a interface
Widget buildBrandDropdown() {
  return DropdownButton<String>(
    value: selectedBrand,
    hint: Text('Brand'),
    items: filterOptions.brands.map((brand) {
      return DropdownMenuItem(value: brand, child: Text(brand));
    }).toList(),
    onChanged: (value) {
      setState(() => selectedBrand = value);
      applyFilters();
    },
  );
}

Widget buildAmbientDropdown() {
  return DropdownButton<String>(
    value: selectedAmbient,
    hint: Text('Ambient'),
    items: filterOptions.ambients.map((ambient) {
      return DropdownMenuItem(value: ambient, child: Text(ambient));
    }).toList(),
    onChanged: (value) {
      setState(() => selectedAmbient = value);
      applyFilters();
    },
  );
}

Widget buildFinishDropdown() {
  return DropdownButton<String>(
    value: selectedFinish,
    hint: Text('Finish'),
    items: filterOptions.finishes.map((finish) {
      return DropdownMenuItem(value: finish, child: Text(finish));
    }).toList(),
    onChanged: (value) {
      setState(() => selectedFinish = value);
      applyFilters();
    },
  );
}

// 3. Chips de qualidade (seleção múltipla)
Widget buildQualityChips() {
  return Wrap(
    spacing: 8.0,
    children: filterOptions.qualities.map((quality) {
      final isSelected = selectedQualities.contains(quality);
      return FilterChip(
        label: Text(quality),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            if (selected) {
              selectedQualities.add(quality);
            } else {
              selectedQualities.remove(quality);
            }
          });
          applyFilters();
        },
      );
    }).toList(),
  );
}

// 4. Aplicar filtros quando mudarem
void applyFilters() {
  final filters = MaterialFilters(
    brand: selectedBrand,
    ambient: selectedAmbient,
    finish: selectedFinish,
    quality: selectedQualities.isEmpty ? null : selectedQualities,
    search: searchController.text.isEmpty ? null : searchController.text,
  );
  
  // Recarregar lista
  loadMaterials(filters);
}

// 5. Implementação de paginação
class MaterialsPagination {
  int currentPage = 1;
  int? totalPages;
  bool isLoading = false;
  
  // Carregar próxima página
  void loadNextPage() {
    if (totalPages != null && currentPage < totalPages! && !isLoading) {
      currentPage++;
      final filters = getCurrentFilters();
      filters.page = currentPage;
      loadMaterials(filters);
    }
  }
  
  // Carregar página anterior
  void loadPreviousPage() {
    if (currentPage > 1 && !isLoading) {
      currentPage--;
      final filters = getCurrentFilters();
      filters.page = currentPage;
      loadMaterials(filters);
    }
  }
  
  // Ir para página específica
  void goToPage(int page) {
    if (page >= 1 && (totalPages == null || page <= totalPages!) && !isLoading) {
      currentPage = page;
      final filters = getCurrentFilters();
      filters.page = page;
      loadMaterials(filters);
    }
  }
  
  // Widget de paginação
  Widget buildPagination() {
    if (totalPages == null || totalPages! <= 1) return SizedBox.shrink();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: currentPage > 1 ? loadPreviousPage : null,
          icon: Icon(Icons.chevron_left),
        ),
        Text('Página $currentPage de $totalPages'),
        IconButton(
          onPressed: currentPage < totalPages! ? loadNextPage : null,
          icon: Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}
```

## 7. Observações Técnicas

### 7.1 Processamento
- Arquivo armazenado em R2 imediatamente após upload
- Arquivo temporário local usado apenas para extração de texto
- Job de processamento desabilitado em ambiente de teste
- Suporte a PDF com preços apenas em USD

### 7.2 Segurança
- Autenticação obrigatória (Laravel Sanctum)  
- Rate limiting aplicado
- Validação rigorosa de tipo MIME
- Limite de tamanho: 25MB

### 7.3 Performance
- Armazenamento distribuído via Cloudflare R2
- URLs de acesso otimizadas (temporárias ou CDN)
- Processamento assíncrono via jobs
- Cache de metadados no banco de dados