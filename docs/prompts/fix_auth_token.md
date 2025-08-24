Perfeito — vou te entregar um **prompt novo para o agente Flutter** já levando em conta o seu log (connection refused ao chamar `http://localhost:8080/api/auth/callback?...`) e o contrato do backend (callback retorna `auth_token`).

---

# Prompt — Agente de IA (Flutter + MVVM, WebView OAuth GHL, correção do callback)

**Perfil do agente:** Engenheiro sênior Flutter (MVVM), especialista em WebView OAuth, rede/ATS no iOS, interceptors HTTP (Dio), parsing robusto e logging.

**Contexto do projeto (fatos):**

* Login no GHL é feito em **WebView**.
* Ao detectar o redirect, o app chama **GET** `BASE_URL/api/auth/callback?code=...` e espera receber `{"auth_token": "1|..."}`.
* Log do app mostra:

  * WebView capturando a URL: `http://localhost:8080/api/auth/callback?code=...`
  * `HttpService` montando `Full URL` corretamente: `http://localhost:8080/api/auth/callback?code=...`
  * **Falha**: `DioException [connection error]: Connection refused (OS Error: errno = 61), address = localhost`
* Em **browser** tudo funciona. No app iOS, o **callback falha** (erro de conexão).
* Ambiente **local/prod** já é alternado por flag/env (não precisa reinventar isso).

**Sua missão:** Eliminar o erro ao processar o callback no iOS, garantindo que o app consiga **chamar o endpoint de callback** e **persistir o `auth_token`** retornado pelo backend.

---

## Tarefas (em ordem de execução)

### 1) Diagnosticar e corrigir **acesso de rede local no iOS**

* Verifique se está rodando em **simulador** ou **device físico**.

  * **Simulador iOS**: `http://localhost:8080` deve alcançar o host da máquina.
  * **Device físico**: `localhost` aponta para o **próprio device** → conexão recusada.
* Adapte a **BASE\_URL** do ambiente local:

  * `LOCAL_SIM`: `http://localhost:8080`
  * `LOCAL_LAN`: `http://<SEU_IP_LAN>:8080` (para device físico na mesma rede)
* **ATS (App Transport Security)** em `Info.plist`:

  * Se usar **HTTP** em dev, crie exceções:

    ```
    <key>NSAppTransportSecurity</key>
    <dict>
      <key>NSAllowsArbitraryLoads</key><false/>
      <key>NSExceptionDomains</key>
      <dict>
        <key>localhost</key>
        <dict>
          <key>NSExceptionAllowsInsecureHTTPLoads</key><true/>
          <key>NSIncludesSubdomains</key><true/>
        </dict>
        <key>127.0.0.1</key>
        <dict>
          <key>NSExceptionAllowsInsecureHTTPLoads</key><true/>
          <key>NSIncludesSubdomains</key><true/>
        </dict>
        <!-- opcional: seu IP/LAN hostname em dev se usar http -->
        <key>192.168.x.x</key>
        <dict>
          <key>NSExceptionAllowsInsecureHTTPLoads</key><true/>
          <key>NSIncludesSubdomains</key><true/>
        </dict>
      </dict>
    </dict>
    ```
  * Se for **HTTPS** com certificado dev, adicione exceções de domínio ou use um túnel (ngrok) para evitar ATS.
* **Critério:** o app iOS deve conseguir abrir `GET BASE_URL/api/ping` (crie um ping simples) sem “connection refused”.

### 2) Garantir **redirect\_uri** idêntico ao cadastrado no GHL

* Gere e logue a **AUTH URL** aberta no WebView e o **redirect\_uri** efetivo.
* O valor do `redirect_uri` deve ser **idêntico** ao cadastrado no cliente GHL (mesmo domínio, porta, path e barra) para que o `code` seja válido.
* Isso evita “Invalid client: `redirect_uri` does not match …”.

### 3) Blindar o **processamento do callback** (WebView → UseCase)

* **Interceptação:** no `navigationDelegate/onLoadStart`, detecte a URL de callback.
* **Cancelamento:** cancele a navegação quando a URL for o callback, para não carregar a página no WebView.
* **Single-flight:** previna múltiplas chamadas (flag `_inFlight`).
* **Parse do code:**

  ```dart
  final uri = Uri.parse(url);
  final code = uri.queryParameters['code'];
  if (code == null || code.isEmpty) { /* log + erro claro */ }
  ```
* **Chamada ao backend:** use `Dio.get('/auth/callback', queryParameters: {'code': code})` com **BASE\_URL** correta (local/prod).
* **Parse da resposta:** leia **explicitamente** `json['auth_token']` (não confundir com tokens do GHL).
* **Persistência:** salve `auth_token` em `flutter_secure_storage`.
* **Estado MVVM:** `loading → success(token)`; em erro, propague mensagem amigável + log técnico.

### 4) Resiliência e logs úteis

* **Timeouts/Retry**: timeout de conexão (ex. 10s) e retry 1x apenas para `SocketException`/`Connection refused` (útil quando o dev acabou de subir o servidor).
* **Erros mapeados:**

  * `connection refused` → “Servidor local não acessível. Verifique BASE\_URL/ATS/servidor ativo.”
  * `4xx/5xx` → mostre `status` + `body` em log (mas não em UI).
* **Logs de depuração**:

  * AUTH URL aberta no WebView (com `redirect_uri`).
  * URL de callback interceptada (completo).
  * `Full URL` que o Dio chamou (BASE\_URL + path).
  * Corpo bruto da resposta do backend **quando** `auth_token == null`.

### 5) Interceptor HTTP e teste de rota protegida

* Configure o **interceptor** do `Dio` para injetar `Authorization: Bearer <auth_token>` nas próximas requisições.
* Faça um GET a **`/api/user`** após salvar o token e valide 200 com o payload esperado.

---

## Diffs/entregáveis esperados

1. **Atualização de configuração de rede iOS (Info.plist)** com exceções ATS para localhost/127.0.0.1 (e IP LAN se necessário).
2. **Ajustes no WebView**:

   * Interceptação/cancelamento do callback.
   * `single-flight` para evitar chamadas duplicadas.
3. **AuthService/AuthRepository**:

   * Chamada ao **`GET /api/auth/callback?code=...`** usando a **BASE\_URL** correta (flag/env).
   * Parse explícito de `auth_token` e persistência segura.
4. **Melhoria de logs**: AUTH URL, callback URL, Full URL Dio, corpo de erro.
5. **Teste manual**: login → callback → `auth_token` ≠ null → `/api/user` ok.

---

## Critérios de aceite

* **Sem** `connection refused` no iOS após ajustes de BASE\_URL/ATS.
* `auth_token` **não é null**; salvo em storage; **interceptor** injeta o Bearer nas rotas.
* Fluxo consistente com o contrato do backend (`/api/auth/callback` retorna `auth_token`).
* Logs permitem isolar rapidamente problemas de rede (ATS/host), de `redirect_uri` e de parse JSON.

---

> Observação: se for necessário testar em device físico mantendo `localhost`, use **ngrok** para um domínio público HTTPS e configure esse domínio como `redirect_uri` e `BASE_URL` de dev; assim você elimina ATS e LAN de uma vez.

Pronto — é só colar esse prompt no teu agente que ele sabe exatamente **onde mexer e como validar** até eliminar o erro no callback.
