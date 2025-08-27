# MÓDULO DE EXTRAÇÃO DE PDF - EXTRACAO_PDF_MODULE

Este módulo gerencia o upload e extração de dados de materiais a partir de arquivos PDF, permitindo processamento automático de orçamentos e listas de materiais.

## 1. Modelos de Dados e Estrutura da Tabela

### Modelo PdfUpload (Upload de PDF)

**Arquivo:** `app/PdfUpload.php`

**Atributos do Model:**
- `id` (integer, not null) - ID único do upload
- `user_id` (integer, nullable) - ID do usuário proprietário
- `original_name` (string, not null) - Nome original do arquivo
- `display_name` (string, nullable) - Nome de exibição personalizado
- `file_path` (string, not null) - Caminho do arquivo no storage
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
    file_path VARCHAR(255) NOT NULL,
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
- `name` (string, not null) - Nome do material
- `description` (text, nullable) - Descrição do material
- `quantity` (decimal, nullable) - Quantidade
- `unit` (string, nullable) - Unidade de medida
- `unit_price` (decimal, nullable) - Preço unitário
- `total_price` (decimal, nullable) - Preço total
- `category` (string, nullable) - Categoria do material
- `brand` (string, nullable) - Marca do material
- `code` (string, nullable) - Código do produto
- `metadata` (array, nullable) - Metadados adicionais
- `created_at` (timestamp, not null) - Data de criação
- `updated_at` (timestamp, not null) - Data de atualização

**Estrutura da Tabela `extracted_materials`:**
```sql
CREATE TABLE extracted_materials (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    pdf_upload_id BIGINT NOT NULL,
    user_id BIGINT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT NULL,
    quantity DECIMAL(10,3) NULL,
    unit VARCHAR(50) NULL,
    unit_price DECIMAL(10,2) NULL,
    total_price DECIMAL(10,2) NULL,
    category VARCHAR(100) NULL,
    brand VARCHAR(100) NULL,
    code VARCHAR(100) NULL,
    metadata JSON NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    FOREIGN KEY (pdf_upload_id) REFERENCES pdf_uploads(id) ON DELETE CASCADE,
    INDEX idx_pdf_upload (pdf_upload_id),
    INDEX idx_user_id (user_id),
    INDEX idx_category (category),
    INDEX idx_name (name)
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
pdf_file: [arquivo PDF] // Arquivo PDF (obrigatório, máximo 10MB)
display_name: "Orçamento Casa Maria Silva" // Nome de exibição (opcional)
```

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

## 4. Respostas Esperadas

### 4.1 Upload de PDF

**Status 201 (Created):**
```json
{
    "success": true,
    "upload": {
        "id": 15,
        "original_name": "orcamento_materiais.pdf",
        "display_name": "Orçamento Casa Maria Silva",
        "file_path": "pdfs/uploads/2025/01/20/abc123def456.pdf",
        "file_hash": "a1b2c3d4e5f6...",
        "status": "pending",
        "materials_extracted": 0,
        "created_at": "2025-01-20T16:30:00Z"
    },
    "message": "PDF enviado com sucesso. Processamento iniciado.",
    "job_queued": true
}
```

**Status 400 (Bad Request):**
```json
{
    "error": "validation_error",
    "message": "Dados inválidos para upload",
    "details": {
        "pdf_file": ["O arquivo PDF é obrigatório"],
        "pdf_file.size": ["O arquivo não pode exceder 10MB"]
    }
}
```

**Status 413 (Payload Too Large):**
```json
{
    "error": "file_too_large",
    "message": "Arquivo muito grande. Tamanho máximo permitido: 10MB"
}
```

**Status 415 (Unsupported Media Type):**
```json
{
    "error": "invalid_file_type",
    "message": "Tipo de arquivo não suportado. Apenas arquivos PDF são aceitos"
}
```

**Status 409 (Conflict):**
```json
{
    "error": "duplicate_file",
    "message": "Este arquivo já foi enviado anteriormente",
    "existing_upload_id": 12
}
```

### 4.2 Listar Uploads

**Status 200 (Success):**
```json
{
    "uploads": [
        {
            "id": 15,
            "original_name": "orcamento_materiais.pdf",
            "display_name": "Orçamento Casa Maria Silva",
            "status": "completed",
            "materials_extracted": 25,
            "created_at": "2025-01-20T16:30:00Z",
            "updated_at": "2025-01-20T16:45:00Z"
        },
        {
            "id": 14,
            "original_name": "lista_tintas.pdf",
            "display_name": "Lista de Tintas Premium",
            "status": "processing",
            "materials_extracted": 0,
            "created_at": "2025-01-20T15:15:00Z",
            "updated_at": "2025-01-20T15:20:00Z"
        }
    ],
    "pagination": {
        "total": 45,
        "per_page": 10,
        "current_page": 1,
        "last_page": 5
    }
}
```

### 4.3 Verificar Status

**Status 200 (Success) - Processamento Concluído:**
```json
{
    "upload": {
        "id": 15,
        "original_name": "orcamento_materiais.pdf",
        "display_name": "Orçamento Casa Maria Silva",
        "status": "completed",
        "materials_extracted": 25,
        "extraction_metadata": {
            "pages_processed": 3,
            "processing_time": "45.2s",
            "confidence_score": 0.92
        },
        "created_at": "2025-01-20T16:30:00Z",
        "updated_at": "2025-01-20T16:45:00Z"
    },
    "materials": [
        {
            "id": 101,
            "name": "Tinta Acrílica Premium Branca",
            "description": "Tinta acrílica lavável para paredes internas",
            "quantity": 5.0,
            "unit": "litros",
            "unit_price": 45.90,
            "total_price": 229.50,
            "category": "tinta",
            "brand": "Coral",
            "code": "ACR-001-BR"
        },
        {
            "id": 102,
            "name": "Primer Selador",
            "description": "Primer selador para preparação de superfície",
            "quantity": 2.0,
            "unit": "litros",
            "unit_price": 35.00,
            "total_price": 70.00,
            "category": "primer",
            "brand": "Suvinil",
            "code": "PRM-SEL-001"
        }
    ]
}
```

**Status 200 (Success) - Processamento em Andamento:**
```json
{
    "upload": {
        "id": 14,
        "original_name": "lista_tintas.pdf",
        "display_name": "Lista de Tintas Premium",
        "status": "processing",
        "materials_extracted": 0,
        "extraction_metadata": {
            "pages_processed": 1,
            "total_pages": 3,
            "estimated_completion": "2025-01-20T16:55:00Z"
        },
        "created_at": "2025-01-20T15:15:00Z",
        "updated_at": "2025-01-20T16:50:00Z"
    },
    "materials": []
}
```

**Status 200 (Success) - Processamento com Erro:**
```json
{
    "upload": {
        "id": 13,
        "original_name": "arquivo_corrompido.pdf",
        "display_name": "Arquivo com Problema",
        "status": "failed",
        "materials_extracted": 0,
        "error_message": "Arquivo PDF corrompido ou protegido por senha",
        "created_at": "2025-01-20T14:00:00Z",
        "updated_at": "2025-01-20T14:05:00Z"
    },
    "materials": []
}
```

**Status 404 (Not Found):**
```json
{
    "error": "upload_not_found",
    "message": "Upload de PDF não encontrado"
}
```

### 4.4 Atualizar Upload

**Status 200 (Success):**
```json
{
    "success": true,
    "upload": {
        "id": 15,
        "original_name": "orcamento_materiais.pdf",
        "display_name": "Orçamento Atualizado - Casa Maria Silva",
        "status": "completed",
        "updated_at": "2025-01-20T17:00:00Z"
    },
    "message": "Upload atualizado com sucesso"
}
```

**Status 400 (Bad Request):**
```json
{
    "error": "validation_error",
    "message": "Dados inválidos para atualização",
    "details": {
        "display_name": ["O campo nome de exibição é obrigatório"]
    }
}
```

**Status 404 (Not Found):**
```json
{
    "error": "upload_not_found",
    "message": "Upload não encontrado para atualização"
}
```

### 4.5 Excluir Upload

**Status 200 (Success):**
```json
{
    "success": true,
    "message": "Upload e materiais associados excluídos com sucesso",
    "materials_deleted": 25
}
```

**Status 404 (Not Found):**
```json
{
    "error": "upload_not_found",
    "message": "Upload não encontrado para exclusão"
}
```

**Status 409 (Conflict):**
```json
{
    "error": "upload_in_use",
    "message": "Upload não pode ser excluído pois os materiais estão sendo usados em orçamentos ativos"
}
```

**Status 500 (Internal Server Error):**
```json
{
    "error": "deletion_error",
    "message": "Erro interno ao excluir upload. Tente novamente."
}
```