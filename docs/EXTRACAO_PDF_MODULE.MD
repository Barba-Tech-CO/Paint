# Módulo de Extração de PDF

## Visão Geral

O módulo de extração de PDF permite que usuários façam upload de arquivos PDF contendo catálogos de materiais de pintura, extraia informações dos materiais e as armazene no banco de dados para uso em estimativas de projetos.

## Arquitetura

### Componentes Principais

1. **QuoteStorageService** - Gerencia armazenamento de arquivos PDF (anteriormente PdfStorageService)
2. **PdfExtractionService** - Extrai dados dos PDFs
3. **QuoteExtractionController** - Endpoints da API para upload e gerenciamento
4. **ProcessPdfExtractionJob** - Job assíncrono para processamento
5. **ExtractedMaterial Model** - Modelo para materiais extraídos

## Armazenamento de Arquivos

### ⚠️ Configuração Atual: Armazenamento Local

**Nota Importante**: O serviço Cloudflare R2 foi desabilitado devido a problemas de conectividade. O sistema agora utiliza armazenamento local.

#### Configuração de Armazenamento

```php
// app/Services/QuoteStorageService.php
private const DISK = 'local'; // Alterado de 'r2' para 'local'
```

#### Estrutura de Arquivos

Os PDFs são armazenados em:

- **Localização**: `storage/app/public/quotes/YYYY/MM/DD/`
- **Nomenclatura**: `{uuid}-{nome-sanitizado}.pdf`
- **URLs de Acesso**: `https://paintpro.barbatech.company/storage/quotes/...`

### Funcionalidades do QuoteStorageService

```php
class QuoteStorageService
{
    // Armazenar PDF
    public function storeUploadedQuote(UploadedFile $file, ?array $context = []): array

    // Verificar existência
    public function exists(string $key): bool

    // Deletar arquivo
    public function delete(string $key): void

    // Gerar URL de acesso
    public function temporaryUrl(string $key, DateTimeInterface $expires): string
}
```

## Fluxo de Upload

### 1. Upload do Arquivo

```http
POST /api/materials/upload
Content-Type: multipart/form-data

{
    "quote": [arquivo PDF]
}
```

**Nota**: O parâmetro é `quote`, não `pdf` como documentado anteriormente.

### 2. Processamento

1. **Validação**: Verificação de tipo de arquivo, tamanho e formato
2. **Detecção de Duplicatas**: Check por hash MD5 do arquivo
3. **Armazenamento Local**: Salvamento em `storage/app/public/quotes/`
4. **Registro no Banco**: Criação de entrada na tabela `pdf_uploads`
5. **Job Assíncrono**: Dispatch do `ProcessPdfExtractionJob`

### 3. Resposta

```json
{
  "success": true,
  "data": {
    "upload": {
      "id": 123,
      "user_id": 1,
      "original_name": "catalogo.pdf",
      "display_name": null,
      "file_path": "quotes/2025/08/29/uuid-catalogo.pdf",
      "r2_url": "https://paintpro.barbatech.company/storage/quotes/2025/08/29/uuid-catalogo.pdf",
      "file_hash": "abc123...",
      "status": "pending",
      "materials_extracted": 0,
      "extraction_metadata": null,
      "error_message": null,
      "created_at": "2025-01-20T10:00:00.000000Z",
      "updated_at": "2025-01-20T10:00:00.000000Z"
    },
    "message": "Quote uploaded successfully. Processing started.",
    "url": "https://paintpro.barbatech.company/storage/quotes/2025/08/29/uuid-catalogo.pdf",
    "size": 1024000
  }
}
```

## Extração de Materiais

### PdfExtractionService

O serviço extrai informações estruturadas dos PDFs:

```php
class PdfExtractionService
{
    public function extractMaterials(string $filePath): array
    {
        // 1. Validação de moeda (apenas USD aceita)
        // 2. Extração de texto do PDF
        // 3. Parsing de materiais com regex
        // 4. Tradução de termos portugueses
        // 5. Estruturação dos dados
    }
}
```

### Campos Extraídos

- **Descrição**: Nome/descrição do material
- **Marca**: Fabricante do produto
- **Tipo**: Tipo do material (padrão: 'liquid')
- **Acabamento**: Tipo de acabamento (acetinado, fosco, etc.)
- **Categoria**: Ambiente de uso (interior, exterior)
- **Preço Unitário**: Valor em USD
- **Unidade**: Unidade de medida (gallon, quart)
- **Nota de Qualidade**: A-F baseada em características
- **Especificações**: Dados adicionais em formato JSON
- **Linha**: Número da linha no PDF original

## Validações

### Upload

- **Tipo**: Apenas PDFs (`application/pdf`)
- **Tamanho**: Máximo configurável (`UPLOAD_MAX_SIZE`)
- **Moeda**: Apenas catálogos em USD
- **Duplicatas**: Prevenção via hash MD5

### Extração

- **Moeda**: Rejeita PDFs com BRL, EUR, GBP
- **Formato**: Valida estrutura esperada do catálogo
- **Dados**: Garante campos obrigatórios

## Endpoints da API

### Upload

```http
POST /api/materials/upload
Authorization: Bearer {token}
Content-Type: multipart/form-data
```

### Listagem de Uploads

```http
GET /api/materials/uploads
Authorization: Bearer {token}
```

### Status do Upload

```http
GET /api/materials/status/{pdfUpload}
Authorization: Bearer {token}
```

### Atualizar Nome de Exibição

```http
PUT /api/materials/update/{pdfUpload}
Authorization: Bearer {token}
Content-Type: application/json

{
    "display_name": "Novo Nome"
}
```

### Deletar Upload

```http
DELETE /api/materials/delete/{pdfUpload}
Authorization: Bearer {token}
```

### Listar Materiais Extraídos

```http
GET /api/materials/extracted
Authorization: Bearer {token}
?brand=marca&ambient=categoria&finish=acabamento&quality[]=A&search=termo
```

### Obter Material Específico

```http
GET /api/materials/extracted/{material}
Authorization: Bearer {token}
```

### Filtros Disponíveis

```http
GET /api/materials/filters
Authorization: Bearer {token}
```

## Modelos de Dados

**Nota**: Todos os modelos possuem um campo `id` (chave primária auto-increment) e campos `created_at` e `updated_at` (timestamps) que são gerenciados automaticamente pelo Laravel. Estes campos não precisam estar no array `$fillable`.

### PdfUpload

```php
class PdfUpload extends Model
{
    protected $fillable = [
        'user_id',
        'original_name',
        'display_name',
        'file_path',        // Chave de armazenamento local
        'r2_url',          // URL de acesso (agora local)
        'file_hash',
        'status',          // pending, processing, completed, failed
        'materials_extracted',
        'extraction_metadata', // Metadados da extração em formato JSON
        'error_message',
        'created_at',          // Timestamp de criação
        'updated_at'           // Timestamp de atualização
    ];

    // Campos automáticos do Laravel (não fillable):
    // - id: Chave primária auto-increment
    // - timestamps: created_at, updated_at
}
```

### ExtractedMaterial

```php
class ExtractedMaterial extends Model
{
    protected $fillable = [
        'user_id',
        'pdf_upload_id',
        'brand',
        'description',
        'type',
        'unit',
        'unit_price',
        'finish',
        'quality_grade',
        'category',
        'specifications',
        'line_number',
        'created_at',          // Timestamp de criação
        'updated_at'           // Timestamp de atualização
    ];

    // Campos automáticos do Laravel (não fillable):
    // - id: Chave primária auto-increment
    // - timestamps: created_at, updated_at
}
```

## Configuração de Ambiente

### Variáveis de Ambiente (.env)

#### Produção

```bash
# Application Configuration
APP_URL=https://your-production-domain.com

# Upload Configuration
UPLOAD_MAX_SIZE=25M

# R2 Storage (DESABILITADO - mantido para compatibilidade)
# R2_ACCESS_KEY_ID=your_r2_access_key
# R2_SECRET_ACCESS_KEY=your_r2_secret_key
# R2_ACCOUNT_ID=your_r2_account_id
# R2_BUCKET=your-production-bucket
# R2_ENDPOINT=https://your_account_id.r2.cloudflarestorage.com
# R2_REGION=auto
# R2_PUBLIC_BASE_URL=https://your-production-cdn.com
```

#### Desenvolvimento Local

```bash
# Application Configuration
APP_URL=http://localhost:8000

# Upload Configuration
UPLOAD_MAX_SIZE=25M

# R2 Storage (DESABILITADO)
# Mantém configurações comentadas para desenvolvimento local
```

### Filesystem Configuration

```php
// config/filesystems.php
'local' => [
    'driver' => 'local',
    'root' => storage_path('app/public'),
    'url' => env('APP_URL').'/storage',
    'visibility' => 'public',
    'serve' => true,
    'throw' => false,
],

// R2 configuration (commented out - production ready)
'r2' => [
    'driver' => 's3',
    'key' => env('R2_ACCESS_KEY_ID', 'testing'),
    'secret' => env('R2_SECRET_ACCESS_KEY', 'testing'),
    'region' => env('AWS_DEFAULT_REGION', 'auto'),
    'bucket' => env('R2_BUCKET', 'test-bucket'),
    'endpoint' => env('R2_ENDPOINT', 'http://localhost'),
    'use_path_style_endpoint' => true,
    'throw' => true,
],
```

## Jobs e Queues

### ProcessPdfExtractionJob

```php
class ProcessPdfExtractionJob implements ShouldQueue
{
    public function handle(): void
    {
        // 1. Extrair materiais do PDF
        // 2. Salvar no banco de dados
        // 3. Atualizar status do upload
        // 4. Tratar erros e retry
    }
}
```

### Configuração

- **Queue**: `default`
- **Retry**: 3 tentativas
- **Timeout**: 300 segundos

## Segurança

### Autenticação

- Todos endpoints requerem autenticação Bearer token
- Middleware `auth:sanctum` aplicado

### Autorização

- Usuários só acessam seus próprios uploads
- Policies aplicadas para `PdfUpload` e `ExtractedMaterial`
- Validação manual de propriedade do usuário implementada

### Validação de Arquivos

- Tipo MIME verificado
- Tamanho limitado
- Conteúdo validado antes da extração

## Tratamento de Erros

### Códigos de Status

- **200**: Sucesso
- **201**: Upload criado com sucesso
- **400**: Dados inválidos
- **401**: Não autenticado
- **403**: Sem permissão
- **404**: Recurso não encontrado
- **422**: Falha na validação
- **500**: Erro interno

### Logs

Todos os eventos são logados em:

- Upload de arquivos
- Processamento de extração
- Erros de validação
- Falhas de armazenamento

## Testes

### Unit Tests

- `QuoteStorageServiceTest`: Testa funcionalidades de armazenamento local
- `PdfExtractionServiceTest`: Testa extração e validação

### Feature Tests

- `PdfUploadTest`: Testa endpoints de upload
- `MaterialsApiTest`: Testa API completa de materiais

### Executar Testes

```bash
php artisan test --filter="Pdf"
```

## Migração do R2 para Local Storage

### Alterações Realizadas

1. **QuoteStorageService**:

   - Disk alterado de 'r2' para 'local'
   - Métodos R2-específicos comentados
   - URLs simplificadas para storage local

2. **Controller**:

   - Lógica dual de armazenamento removida
   - Resposta atualizada para URLs locais

3. **Tests**:
   - Storage::fake('r2') alterado para 'local'
   - Assertivas atualizadas para URLs locais

### Reativação do R2 (Futuro)

Para reativar o R2:

1. Descomentar configurações em `config/filesystems.php`
2. Reverter `DISK = 'local'` para `DISK = 'r2'` em `QuoteStorageService`
3. Descomentar métodos R2-específicos
4. Atualizar testes para usar R2 novamente
5. Configurar variáveis de ambiente R2

## Performance

### Otimizações

- Upload assíncrono com jobs
- Prevenção de duplicatas por hash
- Caching de filtros de materiais
- Paginação em listagens

### Monitoramento

- Logs detalhados de operações
- Métricas de tempo de processamento
- Tracking de erros e falhas

## Considerações de Produção

### Requisitos de Infraestrutura

1. **Armazenamento**:

   - Espaço em disco suficiente para PDFs
   - Backup regular dos arquivos em `storage/app/public/quotes/`
   - Monitoramento de uso de disco

2. **Web Server**:

   - Configuração do symbolic link: `php artisan storage:link`
   - Permissions corretas para `storage/` e `public/storage/`
   - HTTPS obrigatório para segurança

3. **Performance**:
   - CDN recomendado para servir arquivos estáticos
   - Cache de headers apropriado
   - Compressão de arquivos

### Configuração de Segurança

```nginx
# Nginx - Servir arquivos PDF com headers de segurança
location /storage/quotes/ {
    add_header X-Content-Type-Options nosniff;
    add_header X-Frame-Options DENY;
    add_header X-XSS-Protection "1; mode=block";
    expires 1y;
    access_log off;
}
```

### Deploy Checklist

1. **Configuração Inicial**:

   ```bash
   # Criar symbolic link para storage
   php artisan storage:link

   # Definir permissões corretas
   chmod -R 775 storage/
   chmod -R 775 public/storage/

   # Verificar APP_URL no .env
   APP_URL=https://your-production-domain.com
   ```

2. **Monitoramento**:

   - Configurar alertas de espaço em disco
   - Monitorar logs de upload e processamento
   - Backup automatizado da pasta `storage/app/public/quotes/`

3. **Testes Pós-Deploy**:

   ```bash
   # Testar upload de PDF
   curl -X POST https://paintpro.barbatech.company/api/materials/upload \
     -H "Authorization: Bearer {token}" \
     -F "quote=@test.pdf"

   # Verificar acesso aos arquivos
   curl -I https://paintpro.barbatech.company/storage/quotes/2025/08/29/test-file.pdf
   ```

## Limitações Atuais

1. **Armazenamento**: Limitado ao servidor local (sem CDN nativo)
2. **Moeda**: Apenas USD suportado
3. **Formato**: Dependente de estrutura específica do PDF
4. **Idioma**: Otimizado para inglês/português
5. **Escalabilidade**: Arquivos armazenados no mesmo servidor da aplicação

## Roadmap

- [ ] Suporte para múltiplas moedas
- [ ] OCR para PDFs escaneados
- [ ] Upload via URL
- [ ] Batch processing
- [ ] Integração com CDN
- [ ] Reativação do Cloudflare R2

## Notas de Atualização

### Versão Atual: 2.2

- **Data**: Janeiro 2025
- **Principais Mudanças**:
  - Renomeado de `PdfStorageService` para `QuoteStorageService`
  - Endpoints atualizados para usar `{pdfUpload}` como parâmetro
  - Parâmetro de upload alterado de `pdf` para `quote`
  - Adicionados endpoints `/extracted` para materiais
  - Armazenamento local ativo, R2 desabilitado
  - Multi-tenancy implementada com `user_id` em todas as tabelas
