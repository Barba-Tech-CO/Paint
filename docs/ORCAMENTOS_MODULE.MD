# MÓDULO DE ORÇAMENTOS - ORCAMENTOS_MODULE

Este módulo gerencia orçamentos de pintura (estimates), permitindo criar, listar, atualizar e acompanhar o progresso de projetos de pintura com cálculo automático de materiais e custos.

## 1. Modelos de Dados e Estrutura da Tabela

### Modelo Estimate (Orçamento)

**Arquivo:** `app/Modules/PaintPro/Models/Estimate.php`

**Atributos do Model:**
- `id` (integer, not null) - ID único do orçamento
- `user_id` (integer, nullable) - ID do usuário proprietário
- `ghl_estimate_id` (string, nullable) - ID do orçamento no GoHighLevel
- `ghl_contact_id` (string, nullable) - ID do contato no GoHighLevel
- `contact` (string, not null) - ID do contato (obrigatório)
- `project_name` (string, nullable) - Nome do projeto
- `client_name` (string, nullable) - Nome do cliente
- `project_type` (enum, nullable) - Tipo do projeto (interior, exterior, both)
- `additional_notes` (text, nullable) - Notas adicionais
- `status` (enum, not null) - Status do orçamento (draft, photos_uploaded, elements_selected, materials_calculated, completed, sent)
- `photos_data` (array, nullable) - Dados das fotos
- `measurements` (array, nullable) - Medidas dos cômodos
- `paint_elements` (array, nullable) - Elementos selecionados para pintura
- `wall_condition` (enum, not null) - Condição da parede (very_good, good, poor, very_poor)
- `has_accent_wall` (boolean, not null) - Possui parede de destaque
- `extra_notes` (text, nullable) - Notas extras
- `materials_calculation` (array, nullable) - Cálculo de materiais
- `labor_calculation` (array, nullable) - Cálculo de mão de obra
- `total_cost` (decimal, not null) - Custo total
- `complete` (boolean, not null) - Projeto marcado como completo
- `estimated_timeline_days` (integer, nullable) - Prazo estimado em dias
- `ghl_folder_name` (string, nullable) - Nome da pasta no GHL
- `photos_uploaded_at` (timestamp, nullable) - Data do upload das fotos
- `measurements_completed_at` (timestamp, nullable) - Data da conclusão das medidas
- `sent_to_client_at` (timestamp, nullable) - Data de envio ao cliente
- `created_at` (timestamp, not null) - Data de criação
- `updated_at` (timestamp, not null) - Data de atualização

**Estrutura da Tabela `paint_pro_estimates`:**
```sql
CREATE TABLE paint_pro_estimates (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NULL,
    ghl_estimate_id VARCHAR(255) NULL,
    ghl_contact_id VARCHAR(255) NULL,
    contact VARCHAR(255) NOT NULL,
    project_name VARCHAR(255) NULL,
    client_name VARCHAR(255) NULL,
    project_type ENUM('interior', 'exterior', 'both') NULL,
    additional_notes TEXT NULL,
    status ENUM('draft', 'photos_uploaded', 'photos_processed', 'elements_selected', 'materials_calculated', 'completed', 'sent') DEFAULT 'draft',
    photos_data JSON NULL,
    measurements JSON NULL,
    paint_elements JSON NULL,
    wall_condition ENUM('very_good', 'good', 'poor', 'very_poor') NOT NULL,
    has_accent_wall BOOLEAN DEFAULT FALSE,
    extra_notes TEXT NULL,
    materials_calculation JSON NULL,
    labor_calculation JSON NULL,
    total_cost DECIMAL(10,2) NOT NULL,
    complete BOOLEAN DEFAULT FALSE,
    estimated_timeline_days INT NULL,
    ghl_folder_name VARCHAR(255) NULL,
    photos_uploaded_at TIMESTAMP NULL,
    measurements_completed_at TIMESTAMP NULL,
    sent_to_client_at TIMESTAMP NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    INDEX idx_ghl_estimate (ghl_estimate_id),
    INDEX idx_ghl_contact (ghl_contact_id),
    INDEX idx_client_project (client_name, project_name),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
);
```

### Enum EstimateStatus (Status do Orçamento)

**Arquivo:** `app/Modules/Shared/Enums/EstimateStatus.php`

**Valores Possíveis:**
- `DRAFT` - Rascunho
- `PHOTOS_UPLOADED` - Fotos carregadas
- `PHOTOS_PROCESSED` - Fotos processadas
- `ELEMENTS_SELECTED` - Elementos selecionados
- `MATERIALS_CALCULATED` - Materiais calculados
- `COMPLETED` - Concluído
- `SENT` - Enviado ao cliente

## 2. Endpoints da API

### 2.1 Listar Orçamentos

**Título:** Listar Todos os Orçamentos  
**Descrição:** Retorna uma lista paginada de orçamentos com opções de filtro

**URL e Método HTTP:** `GET /api/estimates`  
**Parâmetros da Rota:** Nenhum  
**Query Parameters:**
- `client_name` (string, opcional) - Filtrar por nome do cliente
- `project_type` (string, opcional) - Filtrar por tipo de projeto (interior, exterior, both)
- `status` (string, opcional) - Filtrar por status do orçamento
- `search` (string, opcional) - Busca geral em nome do cliente, projeto e tipo
- `limit` (integer, opcional) - Número de itens por página (min: 1, max: 100, padrão: 15)

### 2.2 Obter Dashboard

**Título:** Dashboard de Estatísticas  
**Descrição:** Retorna estatísticas e métricas dos orçamentos

**URL e Método HTTP:** `GET /api/estimates/dashboard`  
**Parâmetros da Rota:** Nenhum

### 2.3 Obter Orçamento

**Título:** Obter Orçamento por ID  
**Descrição:** Retorna dados detalhados de um orçamento específico

**URL e Método HTTP:** `GET /api/estimates/{id}`  
**Parâmetros da Rota:**
- `id` (integer, obrigatório) - ID do orçamento

### 2.4 Criar Orçamento

**Título:** Criar Novo Orçamento  
**Descrição:** Cria um novo orçamento de pintura

**URL e Método HTTP:** `POST /api/estimates`  
**Parâmetros da Rota:** Nenhum

### 2.5 Atualizar Orçamento

**Título:** Atualizar Orçamento  
**Descrição:** Atualiza dados de um orçamento existente

**URL e Método HTTP:** `PUT /api/estimates/{id}`  
**Parâmetros da Rota:**
- `id` (integer, obrigatório) - ID do orçamento

### 2.6 Excluir Orçamento

**Título:** Excluir Orçamento  
**Descrição:** Remove um orçamento do sistema

**URL e Método HTTP:** `DELETE /api/estimates/{id}`  
**Parâmetros da Rota:**
- `id` (integer, obrigatório) - ID do orçamento

## 3. Requisição Esperada

### 3.1 Listar Orçamentos

**Headers:**
```
Accept: application/json
Authorization: Bearer {auth_token}
```

**Corpo da Requisição:** Nenhum

### 3.2 Obter Dashboard

**Headers:**
```
Accept: application/json
Authorization: Bearer {auth_token}
```

**Corpo da Requisição:** Nenhum

### 3.3 Obter Orçamento

**Headers:**
```
Accept: application/json
Authorization: Bearer {auth_token}
```

**Corpo da Requisição:** Nenhum

### 3.4 Criar Orçamento

**Headers:**
```
Accept: application/json
Content-Type: application/json
Authorization: Bearer {auth_token}
```

**Corpo da Requisição:**
```json
{
    "contact": "60d5ec49e1b2c50012345678", // ID do contato (obrigatório)
    "project_name": "Casa da Maria - Pintura Externa", // Nome do projeto (opcional)
    "client_name": "Maria Silva", // Nome do cliente (opcional)
    "project_type": "exterior", // Tipo do projeto (opcional: interior, exterior, both)
    "additional_notes": "Cliente prefere tintas ecológicas", // Notas adicionais (opcional)
    "wall_condition": "good", // Condição da parede (obrigatório: very_good, good, poor, very_poor)
    "has_accent_wall": false, // Possui parede de destaque (opcional, padrão: false)
    "extra_notes": "Acesso difícil na parede dos fundos", // Notas extras (opcional)
    "measurements": [ // Medidas dos cômodos (opcional)
        {
            "room": "living_room",
            "area": 25.5
        },
        {
            "room": "bedroom",
            "area": 15.0
        }
    ],
    "paint_elements": [ // Elementos para pintura (opcional)
        {
            "type": "wall",
            "description": "Parede externa frontal",
            "area": 25.5
        }
    ],
    "total_cost": 405.50 // Custo total (obrigatório)
}
```

### 3.5 Atualizar Orçamento

**Headers:**
```
Accept: application/json
Content-Type: application/json
Authorization: Bearer {auth_token}
```

**Corpo da Requisição:**
```json
{
    "project_name": "Casa da Maria - Pintura Completa", // Nome do projeto (opcional)
    "client_name": "Maria Silva Santos", // Nome do cliente (opcional)
    "project_type": "both", // Tipo do projeto (opcional)
    "additional_notes": "Cliente quer cores neutras", // Notas adicionais (opcional)
    "status": "materials_calculated", // Status (opcional)
    "wall_condition": "good", // Condição da parede (opcional)
    "has_accent_wall": true, // Possui parede de destaque (opcional)
    "extra_notes": "Parede de destaque na sala", // Notas extras (opcional)
    "measurements": [ // Medidas atualizadas (opcional)
        {
            "room": "living_room",
            "area": 30.0
        }
    ],
    "materials_calculation": { // Cálculo de materiais (opcional)
        "gallons_needed": 3.5,
        "cans_needed": 4,
        "unit": "gallon",
        "total_cost": 175.00
    },
    "labor_calculation": { // Cálculo de mão de obra (opcional)
        "hours_needed": 12,
        "hourly_rate": 35.00,
        "total_cost": 420.00
    },
    "total_cost": 595.00, // Custo total atualizado (opcional)
    "estimated_timeline_days": 4 // Prazo estimado (opcional)
}
```

### 3.6 Excluir Orçamento

**Headers:**
```
Accept: application/json
Authorization: Bearer {auth_token}
```

**Corpo da Requisição:** Nenhum

## 4. Respostas Esperadas

### 4.1 Listar Orçamentos

**Status 200 (Success):**
```json
{
    "data": [
        {
            "id": 1,
            "contact": "60d5ec49e1b2c50012345678",
            "project_name": "Casa da Maria - Pintura Externa",
            "client_name": "Maria Silva",
            "project_type": "exterior",
            "status": "completed",
            "total_cost": "405.50",
            "estimated_timeline_days": 3,
            "created_at": "2025-01-20T10:00:00Z",
            "updated_at": "2025-01-20T16:00:00Z"
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

**Status 429 (Too Many Requests):**
```json
{
    "error": "rate_limit_exceeded",
    "message": "Limite de requisições excedido"
}
```

### 4.2 Obter Dashboard

**Status 200 (Success):**
```json
{
    "statistics": {
        "total_estimates": 125,
        "completed_estimates": 85,
        "pending_estimates": 25,
        "sent_estimates": 60,
        "total_revenue": "125450.00",
        "average_project_value": "1254.50"
    },
    "recent_estimates": [
        {
            "id": 15,
            "client_name": "João Santos",
            "project_name": "Apartamento Copacabana",
            "status": "materials_calculated",
            "total_cost": "850.00",
            "created_at": "2025-01-20T14:30:00Z"
        }
    ],
    "status_breakdown": {
        "draft": 15,
        "photos_uploaded": 8,
        "elements_selected": 12,
        "materials_calculated": 25,
        "completed": 45,
        "sent": 20
    }
}
```

### 4.3 Obter Orçamento

**Status 200 (Success):**
```json
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
        "unit": "gallon",
        "total_cost": 125.50
    },
    "labor_calculation": {
        "hours_needed": 8,
        "hourly_rate": 35.00,
        "total_cost": 280.00
    },
    "total_cost": "405.50",
    "complete": true,
    "estimated_timeline_days": 3,
    "ghl_folder_name": "casa_maria_silva",
    "photos_uploaded_at": "2025-01-20T14:30:00Z",
    "measurements_completed_at": "2025-01-20T15:45:00Z",
    "sent_to_client_at": "2025-01-20T16:00:00Z",
    "created_at": "2025-01-20T10:00:00Z",
    "updated_at": "2025-01-20T16:00:00Z"
}
```

**Status 404 (Not Found):**
```json
{
    "error": "estimate_not_found",
    "message": "Orçamento não encontrado"
}
```

### 4.4 Criar Orçamento

**Status 201 (Created):**
```json
{
    "id": 26,
    "contact": "60d5ec49e1b2c50012345678",
    "project_name": "Casa da Maria - Pintura Externa",
    "client_name": "Maria Silva",
    "project_type": "exterior",
    "status": "draft",
    "wall_condition": "good",
    "has_accent_wall": false,
    "total_cost": "405.50",
    "complete": false,
    "created_at": "2025-01-20T17:00:00Z",
    "updated_at": "2025-01-20T17:00:00Z"
}
```

**Status 400 (Bad Request):**
```json
{
    "error": "validation_error",
    "message": "Dados inválidos para criação do orçamento",
    "details": {
        "contact": ["O campo contato é obrigatório"],
        "wall_condition": ["O campo condição da parede é obrigatório"],
        "total_cost": ["O campo custo total é obrigatório"]
    }
}
```

**Status 422 (Unprocessable Entity):**
```json
{
    "error": "business_rule_error",
    "message": "Contato especificado não existe ou não está ativo"
}
```

### 4.5 Atualizar Orçamento

**Status 200 (Success):**
```json
{
    "id": 1,
    "project_name": "Casa da Maria - Pintura Completa",
    "client_name": "Maria Silva Santos",
    "project_type": "both",
    "status": "materials_calculated",
    "total_cost": "595.00",
    "estimated_timeline_days": 4,
    "updated_at": "2025-01-20T17:30:00Z"
}
```

**Status 400 (Bad Request):**
```json
{
    "error": "validation_error",
    "message": "Dados inválidos para atualização",
    "details": {
        "total_cost": ["O campo custo total deve ser um número válido"]
    }
}
```

**Status 404 (Not Found):**
```json
{
    "error": "estimate_not_found",
    "message": "Orçamento não encontrado para atualização"
}
```

**Status 422 (Unprocessable Entity):**
```json
{
    "error": "estimate_not_editable",
    "message": "Orçamento não pode ser editado no status atual"
}
```

### 4.6 Excluir Orçamento

**Status 200 (Success):**
```json
{
    "success": true,
    "message": "Orçamento excluído com sucesso"
}
```

**Status 404 (Not Found):**
```json
{
    "error": "estimate_not_found",
    "message": "Orçamento não encontrado para exclusão"
}
```

**Status 409 (Conflict):**
```json
{
    "error": "estimate_in_use",
    "message": "Orçamento não pode ser excluído pois já foi enviado ao cliente"
}
```

**Status 500 (Internal Server Error):**
```json
{
    "error": "deletion_error",
    "message": "Erro interno ao excluir orçamento"
}
```