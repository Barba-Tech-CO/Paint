# Análise de Gap - Módulo de Autenticação (AUTH_MODULE)

## Resumo das Mudanças

Após análise detalhada da documentação da API do módulo de autenticação e comparação com a implementação atual da aplicação Flutter, foram identificadas as seguintes principais discrepâncias:

- **Endpoint `/api/user` não implementado**: A API documenta um endpoint completo para obter dados do usuário autenticado, mas a implementação atual no Flutter não possui integração com este endpoint.
- **Novos campos de resposta não mapeados**: Campos como `ghl_data_incomplete`, `ghl_error`, `sync_initiated` e `auth_token` presentes na documentação não estão implementados nos modelos Flutter.
- **Falta endpoint `/auth/success`**: A documentação menciona chamadas para este endpoint, mas não está documentado como endpoint da API principal.
- **Inconsistências nos modelos de resposta**: Alguns campos opcionais e estruturas de erro não estão completamente alinhados entre a API e os modelos Flutter.

## Análise Detalhada das Mudanças na API

### Endpoints Novos
- **`GET /api/user`**: Endpoint para obter dados completos do usuário autenticado, incluindo informações do GoHighLevel se disponíveis. Este endpoint retorna diferentes estruturas dependendo do tipo de usuário (GHL completo, GHL incompleto, regular, ou com erro).

### Endpoints Modificados
- **`GET /api/auth/callback`**: O endpoint existe na implementação atual, mas a documentação mostra campos de resposta adicionais:
  - `auth_token`: Token de autenticação Sanctum não mapeado
  - `sync_initiated`: Flag indicando se sincronização foi iniciada

### Campos Novos nos Modelos de Dados

#### AuthRefreshResponse (Callback Response)
- `auth_token` (string): Token de autenticação Sanctum
- `sync_initiated` (boolean): Flag de sincronização iniciada

#### UserModel (Resposta de /api/user)
- `ghl_data_incomplete` (boolean): Indica dados GHL incompletos
- `ghl_error` (boolean): Indica erro nos dados GHL
- `business_info` (objeto): Informações estruturadas do negócio

#### AuthStatusResponse
- `expires_in` (integer): Tempo de expiração em segundos
- `token_valid` (boolean): Validação do token

### Campos de Status Adicionais

#### AuthModel
- `expires_in_minutes` (integer): Já implementado
- `is_expiring_soon` (boolean): Já implementado
- Falta mapear `expires_in` em segundos
- Falta mapear `token_valid`

## Impacto no Código da Aplicação (Arquitetura MVVM)

### Models

#### Modificações Necessárias:

**AuthRefreshResponse** (`lib/model/auth_model/auth_refresh_response.dart:1`):
- Adicionar campo `authToken` (String?)
- Adicionar campo `syncInitiated` (bool?)

**AuthModel** (`lib/model/auth_model/auth_model.dart:1`):
- Adicionar campo `expiresIn` (int?) - tempo em segundos
- Adicionar campo `tokenValid` (bool?)

**UserModel** (`lib/model/user_model.dart:57`):
- Adicionar campo `ghlDataIncomplete` (bool?)
- Adicionar campo `ghlError` (bool?)
- Validar se `businessInfo` está completamente implementado

#### Novos Modelos:
- **AuthUserResponse**: Modelo para resposta do endpoint `/api/user` com diferentes estruturas de resposta

### Services/Repositories

#### AuthService (`lib/service/auth_service.dart:8`):
- **Método faltante**: Implementar `getUser()` para endpoint `/api/user`
- **Modificação**: Atualizar `processCallback()` para mapear novos campos (`auth_token`, `sync_initiated`)
- **Modificação**: Atualizar `getStatus()` para mapear campos adicionais (`expires_in`, `token_valid`)

#### UserService (`lib/service/user_service.dart:7`):
- **Verificação**: O método `getUser()` está implementado mas utiliza endpoint `api/user` sem a barra inicial - verificar se está correto
- **Modificação**: Tratar diferentes tipos de resposta do usuário (completo, incompleto, com erro)

#### AuthRepository (`lib/data/repository/auth_repository_impl.dart:6`):
- **Método faltante**: Adicionar `getUser()` para delegar ao AuthService
- Interface `IAuthRepository` (`lib/domain/repository/auth_repository.dart:4`) precisa incluir método `getUser()`

### ViewModels

#### AuthViewModel (`lib/viewmodel/auth/auth_viewmodel.dart:40`):
- **Modificação**: Atualizar `_processCallback()` para processar novos campos da resposta
- **Modificação**: Atualizar `_checkAuthStatus()` para lidar com campos adicionais
- **Método faltante**: Implementar método para obter dados do usuário autenticado
- **Modificação**: Atualizar persistência para incluir `auth_token` se necessário

#### UserViewModel (`lib/viewmodel/user/user_viewmodel.dart:1`):
- **Verificação necessária**: Confirmar se está tratando adequadamente os diferentes tipos de resposta do usuário
- **Modificação**: Adicionar lógica para lidar com `ghl_data_incomplete` e `ghl_error`

## Plano de Ação Recomendado

### Fase 1: Atualização dos Modelos (Prioridade Alta)
1. **Atualizar AuthRefreshResponse**
   - Adicionar campos `authToken` e `syncInitiated`
   - Atualizar método `fromJson()` e `toJson()`

2. **Atualizar AuthModel**
   - Adicionar campos `expiresIn` e `tokenValid`
   - Atualizar serialização JSON

3. **Atualizar UserModel**
   - Adicionar campos `ghlDataIncomplete` e `ghlError`
   - Validar implementação completa de `businessInfo`

### Fase 2: Atualização dos Services (Prioridade Alta)
1. **AuthService**
   - Implementar método `getUser()` para endpoint `/api/user`
   - Atualizar `processCallback()` e `getStatus()` para novos campos

2. **UserService**
   - Corrigir endpoint (adicionar barra inicial se necessário)
   - Implementar tratamento para diferentes tipos de resposta

### Fase 3: Atualização dos Repositories (Prioridade Média)
1. **IAuthRepository**
   - Adicionar método `getUser()` na interface

2. **AuthRepository**
   - Implementar método `getUser()` delegando para AuthService

### Fase 4: Atualização dos ViewModels (Prioridade Média)
1. **AuthViewModel**
   - Atualizar métodos existentes para novos campos
   - Implementar integração com `getUser()`
   - Atualizar lógica de persistência se necessário

2. **UserViewModel**
   - Implementar tratamento para estados especiais (`ghl_data_incomplete`, `ghl_error`)

### Fase 5: Testes e Validação (Prioridade Baixa)
1. **Testes de Integração**
   - Validar novos endpoints e campos
   - Testar diferentes cenários de resposta do usuário

2. **Testes de UI**
   - Verificar tratamento de estados especiais na interface
   - Validar fluxos de autenticação atualizados

### Considerações de Implementação

#### Compatibilidade Retroativa
- Todos os novos campos devem ser opcionais para manter compatibilidade
- Implementar valores padrão adequados para campos ausentes

#### Tratamento de Erro
- Implementar tratamento específico para `ghl_data_incomplete` e `ghl_error`
- Adicionar logs apropriados para novos campos

#### Performance
- Considerar cache para dados do usuário se `getUser()` for chamado frequentemente
- Avaliar impacto da sincronização iniciada (`sync_initiated`)

#### Segurança
- Validar se `auth_token` deve ser persistido localmente
- Implementar limpeza adequada de tokens em logout