# Fluxo de Autenticação - PaintPro

Este documento descreve o fluxo completo de autenticação OAuth2 com GoHighLevel implementado no PaintPro.

## 🔄 **Fluxo Completo**

### 1. **Inicialização do App (Splash Screen)**

```dart
// SplashView inicia automaticamente
await authViewModel.initializeAuth();

// Verifica se já está autenticado
if (authViewModel.isAuthenticated) {
  // Vai direto para o dashboard
  Navigator.pushReplacementNamed('/dashboard');
} else {
  // Vai para a tela de autenticação
  Navigator.pushReplacementNamed('/auth');
}
```

### 2. **Tela de Autenticação (WebView)**

```dart
// AuthView carrega a URL de autorização
final authUrl = await authViewModel.getAuthorizeUrl();

// Abre WebView com a URL do GoHighLevel
WebViewWidget(controller: _createWebViewController())
```

### 3. **Processamento do Callback**

```dart
// Intercepta URLs que contêm o código de autorização
onNavigationRequest: (NavigationRequest request) {
  if (request.url.contains('code=')) {
    _handleCallback(request.url);
    return NavigationDecision.prevent;
  }
  return NavigationDecision.navigate;
}
```

## 📱 **Telas Implementadas**

### **SplashView** (`/splash`)

- **Propósito**: Tela inicial que verifica autenticação
- **Funcionalidades**:
  - Animação de loading com logo
  - Verificação automática de autenticação
  - Redirecionamento inteligente
  - Tratamento de erros

### **AuthView** (`/auth`)

- **Propósito**: WebView para autenticação OAuth2
- **Funcionalidades**:
  - WebView integrado
  - Interceptação de callback
  - Loading overlay
  - Tratamento de erros
  - Redirecionamento automático

## 🔧 **Configuração**

### **Dependências**

```yaml
dependencies:
  webview_flutter: ^4.7.0
  provider: ^6.1.2
  get_it: ^8.0.3
```

### **Rotas**

```dart
final GoRouter router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => SplashView()),
    GoRoute(path: '/auth', builder: (context, state) => AuthView()),
    // ... outras rotas
  ],
);
```

## 🚀 **Como Funciona**

### **Primeira Inicialização**

1. App inicia em `/splash`
2. `SplashView` chama `authViewModel.initializeAuth()`
3. Verifica status de autenticação
4. Como não está autenticado, navega para `/auth`
5. `AuthView` obtém URL de autorização
6. Abre WebView com URL do GoHighLevel
7. Usuário faz login no GHL
8. GHL redireciona com código de autorização
9. App intercepta callback e processa código
10. Autenticação bem-sucedida → navega para `/dashboard`

### **Inicializações Seguintes**

1. App inicia em `/splash`
2. `SplashView` chama `authViewModel.initializeAuth()`
3. Verifica status de autenticação
4. Como já está autenticado, navega direto para `/dashboard`

## 🛡️ **Segurança**

### **Renovação Automática de Token**

```dart
// No AuthViewModel.initializeAuth()
if (isAuthenticated) {
  final isExpiringSoon = await checkTokenExpiration();
  if (isExpiringSoon) {
    await refreshToken();
  }
}
```

### **Tratamento de Erros**

- Tokens expirados
- Erros de rede
- URLs inválidas
- Callbacks malformados

## 📋 **Endpoints Utilizados**

### **Backend Laravel**

- `GET /api/auth/authorize-url` - URL de autorização
- `GET /api/auth/callback` - Processa callback
- `GET /api/auth/status` - Verifica status
- `POST /api/auth/refresh` - Renova token

### **GoHighLevel**

- `https://marketplace.gohighlevel.com/oauth/chooselocation` - Login
- `https://services.leadconnectorhq.com/oauth/token` - Troca de tokens

## 🎨 **UI/UX**

### **Splash Screen**

- Logo animado
- Loading indicator
- Tratamento de erros
- Botão "Tentar Novamente"

### **Auth Screen**

- Header com branding
- WebView integrado
- Loading overlay
- Mensagens de erro
- Design consistente

## 🔄 **Estados da Aplicação**

### **Não Autenticado**

- Usuário precisa fazer login
- Redirecionamento para WebView
- Sem acesso às funcionalidades

### **Autenticado**

- Acesso completo ao app
- Tokens válidos
- Renovação automática

### **Token Expirado**

- Renovação automática
- Fallback para nova autenticação
- Transparente para o usuário

## 📝 **Logs e Debug**

### **Informações de Debug**

```dart
// Obtém estatísticas de tokens
final debugInfo = await authViewModel.getDebugInfo();
// Retorna: total_tokens, valid, expired, needs_refresh
```

### **Monitoramento**

- Status de autenticação
- Expiração de tokens
- Erros de rede
- Performance do WebView

## 🚨 **Tratamento de Erros**

### **Erros Comuns**

1. **Rede indisponível**

   - Mensagem: "Erro de conexão"
   - Ação: Botão "Tentar Novamente"

2. **Token expirado**

   - Ação: Renovação automática
   - Fallback: Nova autenticação

3. **URL inválida**

   - Mensagem: "URL de autenticação não disponível"
   - Ação: Reinicialização

4. **Callback malformado**
   - Mensagem: "Código de autorização não encontrado"
   - Ação: Nova tentativa

## 🔄 **Próximos Passos**

1. **Melhorias de UX**

   - Animações mais suaves
   - Feedback visual melhorado
   - Mensagens mais claras

2. **Segurança**

   - Validação adicional de URLs
   - Sanitização de parâmetros
   - Logs de auditoria

3. **Performance**
   - Cache de tokens
   - Pré-carregamento
   - Otimização do WebView
