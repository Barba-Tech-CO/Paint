# Database Schema - Offline First Support

Estrutura completa do banco de dados para suporte offline-first no frontend da aplicação PaintPro.

## 📊 Visão Geral

O banco de dados foi projetado com isolamento por usuário (`user_id`) em todas as tabelas principais, permitindo sincronização offline eficiente e segura.

### Tabelas Principais

- **Sistema:** `users`, `password_reset_tokens`, `sessions`
- **GoHighLevel:** `ghl_tokens`, `ghl_contacts`
- **Estimativas:** `estimates`
- **Materiais:** `pdf_uploads`, `extracted_materials`
- **Sistema:** `environments`, `zones`, `materials` (tabelas auxiliares)

## 🔐 Isolamento de Dados

Todas as tabelas principais possuem `user_id` (foreign key para `users.id`) garantindo:
- **Isolamento por usuário** - cada usuário só acessa seus dados
- **Cascade delete** - remoção automática ao deletar usuário
- **Índices otimizados** - performance em consultas por usuário

---

## 📋 Esquemas de Tabelas

### `users` - Usuários do Sistema

**Descrição:** Tabela principal de usuários com integração GoHighLevel.

```sql
CREATE TABLE users (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    email_verified_at TIMESTAMP NULL,
    password VARCHAR(255) NOT NULL,
    remember_token VARCHAR(100) NULL,
    
    -- Campos GHL (adicionados via migration)
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
    
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    
    -- Índices
    KEY idx_ghl_location_id (ghl_location_id),
    KEY idx_ghl_business_id (ghl_business_id)
);
```

**Campos Offline-First:**
- `ghl_location_id` - Chave única para sincronização GHL
- `ghl_last_sync_at` - Controle de sincronização
- Todos os campos GHL podem ser sincronizados offline

---

### `ghl_tokens` - Tokens OAuth2 GoHighLevel

**Descrição:** Armazena tokens de autenticação OAuth2 do GoHighLevel por usuário.

```sql
CREATE TABLE ghl_tokens (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NULL,
    location_id VARCHAR(255) NOT NULL UNIQUE,
    access_token TEXT NOT NULL,
    refresh_token TEXT NOT NULL,
    expires_in INT NOT NULL,
    token_type VARCHAR(255) NOT NULL DEFAULT 'Bearer',
    scope JSON NULL,
    additional_data JSON NULL,
    token_expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    
    -- Foreign Keys
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    
    -- Índices
    KEY idx_user_id (user_id),
    KEY idx_location_expires (location_id, token_expires_at)
);
```

**Campos Offline-First:**
- `location_id` - Identificador único para cache offline
- `token_expires_at` - Controle de expiração offline
- `scope` - Permissões em JSON para validação local

---

### `ghl_contacts` - Contatos GoHighLevel

**Descrição:** Cache local dos contatos do GoHighLevel com status de sincronização.

```sql
CREATE TABLE ghl_contacts (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NULL,
    
    -- Identificadores GHL
    ghl_id VARCHAR(255) NULL UNIQUE COMMENT 'ID único no GoHighLevel (nullable para contatos locais)',
    location_id VARCHAR(255) NOT NULL COMMENT 'ID da localização no GHL',
    
    -- Informações Pessoais
    first_name VARCHAR(255) NULL,
    last_name VARCHAR(255) NULL,
    email VARCHAR(255) NULL,
    phone VARCHAR(255) NULL,
    phone_label VARCHAR(255) NULL,
    
    -- Informações Empresa
    company_name VARCHAR(255) NULL,
    business_name VARCHAR(255) NULL,
    
    -- Endereço
    address TEXT NULL,
    city VARCHAR(255) NULL,
    state VARCHAR(255) NULL,
    postal_code VARCHAR(255) NULL,
    country VARCHAR(255) NULL,
    
    -- Campos JSON para dados complexos
    additional_emails JSON NULL,
    additional_phones JSON NULL,
    custom_fields JSON NULL,
    tags JSON NULL,
    
    -- Metadados
    type VARCHAR(255) NULL COMMENT 'lead, contact, etc',
    source VARCHAR(255) NULL,
    dnd BOOLEAN NOT NULL DEFAULT FALSE COMMENT 'Do Not Disturb',
    dnd_settings JSON NULL,
    
    -- Sincronização Offline
    sync_status ENUM('synced', 'pending', 'error') NOT NULL DEFAULT 'synced',
    last_synced_at TIMESTAMP NULL,
    sync_error TEXT NULL,
    
    -- Timestamps GHL
    ghl_created_at TIMESTAMP NULL COMMENT 'Data criação no GHL',
    ghl_updated_at TIMESTAMP NULL COMMENT 'Data atualização no GHL',
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    
    -- Foreign Keys
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    
    -- Índices para Performance Offline
    KEY idx_user_id (user_id),
    KEY idx_location_id (location_id),
    KEY idx_email (email),
    KEY idx_phone (phone),
    KEY idx_sync_status (sync_status),
    KEY idx_location_sync (location_id, sync_status),
    UNIQUE KEY idx_ghl_id (ghl_id)
);
```

**Campos Offline-First:**
- `sync_status` - Estado da sincronização (`synced`, `pending`, `error`)
- `last_synced_at` - Timestamp da última sincronização
- `sync_error` - Mensagem de erro para retry offline
- Todos os campos JSON permitem dados complexos offline

---

### `estimates` - Orçamentos de Pintura

**Descrição:** Orçamentos completos com fotos, medições e cálculos de materiais.

```sql
CREATE TABLE estimates (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NULL,
    
    -- Integração GHL
    ghl_estimate_id VARCHAR(255) NULL,
    ghl_contact_id VARCHAR(255) NULL,
    contact VARCHAR(255) NOT NULL COMMENT 'ID do contato (obrigatório)',
    
    -- Dados Básicos do Projeto
    project_name VARCHAR(255) NULL,
    client_name VARCHAR(255) NULL,
    project_type ENUM('interior', 'exterior', 'both') NULL,
    additional_notes TEXT NULL,
    
    -- Status do Processamento (Workflow)
    status ENUM('draft', 'photos_uploaded', 'photos_processed', 'elements_selected', 'materials_calculated', 'completed', 'sent') NOT NULL DEFAULT 'draft',
    
    -- Dados das Fotos (JSON para offline)
    photos_data JSON NULL COMMENT 'URLs das fotos + metadados',
    zones JSON NULL COMMENT 'Dados das zonas (cômodos) do projeto',
    measurements JSON NULL COMMENT 'Medidas dos cômodos',

    -- Elementos de Pintura
    paint_elements JSON NULL COMMENT 'Elementos selecionados',
    wall_condition ENUM('very_good', 'good', 'poor', 'very_poor') NOT NULL,
    has_accent_wall BOOLEAN NOT NULL DEFAULT FALSE,
    extra_notes TEXT NULL,
    
    -- Cálculos (JSON para flexibilidade offline)
    materials_calculation JSON NULL COMMENT 'Tintas, primer, suprimentos',
    materials JSON NULL COMMENT 'Lista de materiais do projeto',
    totals JSON NULL COMMENT 'Totais consolidados (custos, quantidades)',
    labor_calculation JSON NULL COMMENT 'Prep work, painting, cleanup',
    total_cost DECIMAL(10,2) NOT NULL,
    complete BOOLEAN NOT NULL DEFAULT FALSE,
    estimated_timeline_days INT NULL,
    
    -- Metadados GHL
    ghl_folder_name VARCHAR(255) NULL,
    photos_uploaded_at TIMESTAMP NULL,
    measurements_completed_at TIMESTAMP NULL,
    sent_to_client_at TIMESTAMP NULL,
    
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    
    -- Foreign Keys
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    
    -- Índices para Offline
    KEY idx_user_id (user_id),
    KEY idx_ghl_estimate_id (ghl_estimate_id),
    KEY idx_ghl_contact_id (ghl_contact_id),
    KEY idx_client_project (client_name, project_name),
    KEY idx_status (status),
    KEY idx_created_at (created_at)
);
```

**Campos Offline-First:**
- `status` - Workflow de estados para controle offline
- `photos_data` - JSON com URLs e metadados das fotos
- `measurements` - JSON com medições para cálculos offline
- `materials_calculation`, `labor_calculation` - Cálculos em JSON
- Timestamps para controle de sincronização

---

### `pdf_uploads` - Uploads de PDF para Extração

**Descrição:** Controle de uploads de PDF e status de processamento IA.

```sql
CREATE TABLE pdf_uploads (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NULL,
    original_name VARCHAR(255) NOT NULL,
    display_name VARCHAR(255) NULL COMMENT 'Nome amigável gerado',
    file_path VARCHAR(255) NOT NULL,
    file_hash VARCHAR(255) NOT NULL UNIQUE COMMENT 'Hash para deduplicação',
    status VARCHAR(255) NOT NULL DEFAULT 'pending' COMMENT 'pending, processing, completed, failed',
    materials_extracted INT NOT NULL DEFAULT 0 COMMENT 'Contador de materiais extraídos',
    extraction_metadata JSON NULL COMMENT 'Metadados do processamento IA',
    error_message TEXT NULL,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    
    -- Foreign Keys
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    
    -- Índices para Offline
    KEY idx_user_id (user_id),
    KEY idx_status (status),
    KEY idx_file_hash (file_hash),
    KEY idx_user_status (user_id, status)
);
```

**Campos Offline-First:**
- `status` - Estados de processamento para UI offline
- `extraction_metadata` - JSON com dados da IA para cache
- `file_hash` - Evita uploads duplicados offline
- `display_name` - Nome amigável para interface

---

### `extracted_materials` - Materiais Extraídos de PDFs

**Descrição:** Materiais extraídos via IA dos PDFs carregados.

```sql
CREATE TABLE extracted_materials (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NULL,
    pdf_upload_id BIGINT UNSIGNED NOT NULL,
    brand VARCHAR(255) NOT NULL,
    description VARCHAR(255) NOT NULL,
    type VARCHAR(255) NOT NULL DEFAULT 'liquid',
    unit VARCHAR(255) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    finish VARCHAR(255) NULL,
    quality_grade VARCHAR(255) NULL,
    category VARCHAR(255) NULL,
    specifications JSON NULL COMMENT 'Especificações técnicas',
    line_number INT NOT NULL COMMENT 'Linha no PDF original',
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    
    -- Foreign Keys
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (pdf_upload_id) REFERENCES pdf_uploads(id) ON DELETE CASCADE,
    
    -- Índices para Busca Offline
    KEY idx_user_id (user_id),
    KEY idx_pdf_upload_id (pdf_upload_id),
    KEY idx_brand (brand),
    KEY idx_type (type),
    KEY idx_category (category)
);
```

**Campos Offline-First:**
- `specifications` - JSON com dados técnicos para busca offline
- `type`, `category` - Campos para filtros offline
- `line_number` - Referência ao documento original

---

### Tabelas Auxiliares do Sistema

#### `password_reset_tokens` - Reset de Senhas
```sql
CREATE TABLE password_reset_tokens (
    email VARCHAR(255) NOT NULL PRIMARY KEY,
    token VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NULL
);
```

#### `sessions` - Sessões de Usuário
```sql
CREATE TABLE sessions (
    id VARCHAR(255) NOT NULL PRIMARY KEY,
    user_id BIGINT UNSIGNED NULL,
    ip_address VARCHAR(45) NULL,
    user_agent TEXT NULL,
    payload LONGTEXT NOT NULL,
    last_activity INT NOT NULL,
    
    KEY idx_user_id (user_id),
    KEY idx_last_activity (last_activity)
);
```

## 🔄 Estratégias de Sincronização Offline

### 1. **Sincronização Incremental**
```sql
-- Buscar dados modificados desde última sync
SELECT * FROM ghl_contacts 
WHERE user_id = ? 
AND (updated_at > ? OR sync_status = 'pending')
ORDER BY updated_at ASC;
```

### 2. **Controle de Conflitos**
```sql
-- Identificar conflitos de sincronização
SELECT * FROM estimates 
WHERE user_id = ? 
AND ghl_estimate_id IS NOT NULL 
AND updated_at > sent_to_client_at;
```

### 3. **Queue de Sincronização**
```sql
-- Priorizar itens para sincronização
SELECT * FROM ghl_contacts 
WHERE user_id = ? 
AND sync_status = 'pending' 
ORDER BY 
  CASE sync_status 
    WHEN 'error' THEN 1 
    WHEN 'pending' THEN 2 
    ELSE 3 
  END, 
  updated_at DESC;
```

## 📱 Suporte Offline-First Frontend

### IndexedDB Schema Sugerido
```javascript
// Estrutura recomendada para IndexedDB no frontend
const dbSchema = {
  version: 1,
  stores: [
    {
      name: 'users',
      keyPath: 'id',
      indexes: ['email', 'ghl_location_id']
    },
    {
      name: 'ghl_contacts', 
      keyPath: 'id',
      indexes: ['ghl_id', 'email', 'sync_status', 'user_id']
    },
    {
      name: 'paint_pro_estimates',
      keyPath: 'id', 
      indexes: ['status', 'client_name', 'user_id', 'created_at']
    },
    {
      name: 'sync_queue',
      keyPath: 'id',
      indexes: ['table_name', 'action', 'priority']
    }
  ]
};
```

### Campos Críticos para Offline

**Sempre incluir no cache local:**
- `user_id` - Isolamento de dados
- `created_at`, `updated_at` - Controle temporal
- `sync_status` - Estado de sincronização  
- IDs de relacionamentos (`ghl_id`, `ghl_contact_id`)

**Campos JSON para flexibilidade:**
- `photos_data` - Permite cache de metadados de fotos
- `materials_calculation` - Cálculos complexos offline
- `custom_fields` - Dados dinâmicos do GHL
- `specifications` - Dados técnicos de materiais

## 🚀 Performance e Otimizações

### Índices Essenciais para Offline
```sql
-- Consultas por usuário (mais comum)
KEY idx_user_id (user_id)

-- Sincronização
KEY idx_user_sync (user_id, sync_status, updated_at)

-- Busca de contatos  
KEY idx_user_email (user_id, email)
KEY idx_user_phone (user_id, phone)

-- Orçamentos por status
KEY idx_user_status (user_id, status, created_at)
```

### Tamanhos de Cache Recomendados
- **Contatos:** 1000 registros por usuário
- **Orçamentos:** 500 registros por usuário  
- **Materiais:** 10000 registros (compartilhados)
- **Fotos:** Apenas metadados (URLs e thumbnails)

---

**Última atualização:** 2025-01-20  
**Versão do Schema:** 1.0.0  
**Suporte Offline:** ✅ Completo
