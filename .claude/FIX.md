### Prompt Encadeado para Agente Especialista Flutter MVVM + Laravel API

Você é um agente de desenvolvimento especialista em Flutter utilizando arquitetura MVVM e backend Laravel com APIs REST autênticadas. Seu objetivo é fazer uma análise minuciosa da estrutura dos projetos frontend e backend, arquivos, pastas, práticas de autenticação e fluxo completo para identificar e corrigir o erro apresentado abaixo.

***

#### Contexto do problema

- Ao acessar a tela "New project" do app Flutter, um dropdown deveria listar contatos obtidos via API.
- Ocorre um erro de autenticação (DioException) que impede o carregamento dos contatos, com mensagem:

  ```
  Exception: Authentication required. Please log in again.
  ```
- Este erro ocorre apenas nesta tela, especificamente no dropdown; a listagem completa de contatos em outra tela funciona normalmente.
- Stack trace indica que o erro ocorre na camada do serviço que chama a API, e na camada do repositório que sincroniza contatos com a API.

***

#### Detalhamento do que analisar no projeto Flutter (MVVM)

1. **Estrutura e organização MVVM**
   - Rever a organização clara das camadas:  
     - `models/` para entidades simples Dart (ex: Contato)  
     - `repositories/` para abstração das fontes de dados e orquestração (ex: `ContactRepository`)  
     - `services/` para chamadas HTTP e lógica externa (ex: `ContactService` usando Dio)  
     - `view_models/` para lógica de UI e estado reativo (ChangeNotifier ou streams)  
     - `views/` para widgets responsivos que observam ViewModel.
   - Validar uso correto do estado reativo entre ViewModel e Views para atualização do dropdown.

2. **Gerenciamento do token e autenticação**
   - Confirmação de como o token JWT (ou outro) é armazenado (ex: SecureStorage, SharedPreferences) e injetado nas requisições Dio.  
   - Verificar a configuração dos interceptadores Dio para adicionar cabeçalhos de autenticação em todas as requisições relevantes.  
   - Analisar se existe tratamento para refresh de token automático em caso de erro 401, para evitar solicitar re-login logo que o token expira.  

3. **Chamada específica que falha**
   - Investigar a função `getContacts()` em `ContactService`, seu uso dentro do repositório e no ViewModel.  
   - Comparar fluxo da chamada que funciona (tela específica de listagem) com a chamada no dropdown (tela "New project") para identificar diferenças no envio do token, uso do ViewModel ou estado.  
   - Debugar para checar se o token válido está presente e corretamente aplicado na chamada do dropdown.

4. **Tratamento de erros e logging**
   - Revisar implementação do `_handleDioException()` para respostas de erro, especialmente 401 (não autorizado).  
   - Verificar se o app loga essa falha e qual o fluxo após o erro (ex: mostrar diálogo, forçar logout).  

***

#### Detalhamento do backend Laravel (API)

1. **Configuração de autenticação da API**
   - Confirmar o uso e configuração correta do middleware de autenticação (`auth:sanctum`, `auth:api`, `jwt.auth`).  
   - Analisar se o endpoint que retorna contatos exige autenticação e se retorna respostar padronizadas de erro 401 para tokens inválidos ou expirados.  

2. **Fluxo de autenticação e tokens**
   - Verificar existência e funcionamento do endpoint de refresh de token.  
   - Validar se o backend está configurado para não expirar tokens prematuramente ou se requer revalidação frequente.  
   - Conferir formatos e cabeçalhos esperados para autenticação, e se há alguma particularidade para chamadas via dropdown.

3. **Consistência do contrato API**
   - Garantir que as respostas da API para dados e para erros sigam um padrão previsível.  
   - Confirmar se o cliente Flutter está interpretando corretamente as respostas JSON de erro.

***

#### Diagnóstico e sugestões práticas

- Comparar e unificar o fluxo de obtenção e uso do token no app entre as duas telas para assegurar consistência.  
- Implementar interceptadores Dio que:  
  - Automaticamente injetem tokens atualizados nos headers.  
  - Detectem erro 401 e tentem refresh de token antes de falhar.  
  - Forcem logout e redirecionem para login com mensagens claras se refresh falhar.  
- Garantir que ViewModels sejam corretamente reinicializados e que o estado das credenciais seja sempre válido ao acessar o dropdown.  
- Adicionar logs detalhados no frontend para capturar estado do token no momento da requisição e erros detalhados.  
- Revisar testes unitários e de integração para simularem cenários de token expirado, refresh e autenticação.

***

#### Boas práticas MVVM e integração com API

- Separação clara de responsabilidades entre camadas para facilitar manutenção e testes.  
- Uso de repositories para encapsular lógica de fonte de dados (remote/local).  
- ViewModels usados para propagação reativa da UI com notificações de estado.  
- Serviços dedicados para chamadas HTTP desacopladas da lógica de aplicação.  
- Gerenciamento seguro e centralizado do token com suporte a refresh automático.  
- Tratamento uniforme e amigável de erros de rede, autenticação e autorização na UI.  