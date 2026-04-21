# Documento de Requisitos — Integração API & Autenticação

## Introdução

Este documento especifica os requisitos para duas mudanças estruturais no app Apex.OS (oi_coach):

1. **Remoção completa de dados mock** — todas as views devem consumir dados exclusivamente da API MongoDB (backend Node.js/Express já implantado em Railway). Quando não houver dados, exibir estados vazios em vez de dados falsos.
2. **Sistema de autenticação JWT** — login, registro, refresh de token, rotas protegidas no backend e gerenciamento de estado de autenticação no Flutter.

## Glossário

- **App**: Aplicativo Flutter Apex.OS (oi_coach) executado no dispositivo do usuário.
- **API_Backend**: Servidor Node.js/Express + Mongoose conectado ao MongoDB Atlas, implantado em Railway (https://oicoach-production.up.railway.app).
- **ApiClient**: Classe estática em `lib/data/services/api_client.dart` responsável por todas as requisições HTTP do App ao API_Backend.
- **Mock_Data**: Módulo `lib/data/mock_data.dart` contendo dados fictícios de treino, dieta, progresso e relatório.
- **JWT**: JSON Web Token utilizado para autenticação stateless entre App e API_Backend.
- **Access_Token**: JWT de curta duração (15 minutos) usado para autorizar requisições à API.
- **Refresh_Token**: JWT de longa duração (7 dias) usado para obter novos Access_Tokens sem re-login.
- **Auth_Middleware**: Middleware Express que valida o Access_Token em rotas protegidas do API_Backend.
- **Token_Storage**: Armazenamento seguro local no dispositivo (flutter_secure_storage) para persistir tokens JWT.
- **Auth_State**: Estado global no App que indica se o usuário está autenticado ou não.
- **Empty_State**: Widget exibido quando uma view não possui dados para mostrar, substituindo dados mock.
- **Ficha_de_Treino**: Plano de treino (WorkoutPlan) contendo dias de treino e exercícios com séries/reps/carga alvo.
- **Ficha_de_Dieta**: Plano alimentar (DietPlan) contendo refeições com horário, descrição e calorias.
- **ViewModel**: Classe ChangeNotifier que gerencia estado e lógica de uma feature no App.

## Requisitos

### Requisito 1: Remoção de Dados Mock das Views

**User Story:** Como atleta, eu quero que o app mostre apenas dados reais da API, para que eu confie que as informações exibidas refletem meu progresso real.

#### Critérios de Aceitação

1. WHEN a DashboardView é carregada, THE App SHALL buscar os dados de treino do dia e resumo semanal exclusivamente via API_Backend.
2. WHEN a API_Backend retorna uma lista vazia para treinos do dia, THE DashboardView SHALL exibir um Empty_State com a mensagem "Nenhum treino planejado para hoje".
3. WHEN a ProgressoView é carregada, THE App SHALL buscar as entradas de progresso exclusivamente via ApiProgressRepository.
4. WHEN a API_Backend retorna uma lista vazia para progresso, THE ProgressoView SHALL exibir um Empty_State com a mensagem "Nenhum dado de progresso disponível".
5. WHEN a RelatorioView é carregada, THE App SHALL buscar peso, atividades e dados do relatório exclusivamente via API_Backend.
6. WHEN a API_Backend retorna dados insuficientes para gerar o relatório, THE RelatorioView SHALL exibir um Empty_State informando quais dados estão faltando.
7. WHEN a FichasView é carregada, THE App SHALL buscar a Ficha_de_Treino e a Ficha_de_Dieta exclusivamente via API_Backend.
8. WHEN a API_Backend retorna fichas vazias, THE FichasView SHALL exibir um Empty_State com a mensagem "Nenhuma ficha anexada" e um botão para criar/anexar fichas.
9. WHEN a ConfiguracoesView é carregada, THE App SHALL buscar a lista de integrações exclusivamente via API_Backend.
10. WHEN a RotinaViewModel é inicializada, THE RotinaViewModel SHALL buscar a Ficha_de_Treino do dia, a Ficha_de_Dieta e os resultados da semana anterior exclusivamente via API_Backend.
11. WHEN a API_Backend retorna dados vazios para a rotina, THE RotinaViewModel SHALL sinalizar estado vazio e a view SHALL exibir um Empty_State com a mensagem "Configure sua ficha de treino e dieta para iniciar".
12. THE App SHALL remover todas as importações e referências ao módulo Mock_Data após a migração.

### Requisito 2: Modelos de Ficha de Treino e Dieta no Banco de Dados

**User Story:** Como atleta, eu quero que minha ficha de treino e plano alimentar sejam armazenados no banco de dados, para que eu possa atualizá-los sem precisar de uma nova versão do app.

#### Critérios de Aceitação

1. THE API_Backend SHALL expor um endpoint GET /api/workout-plans que retorna a Ficha_de_Treino do usuário autenticado.
2. THE API_Backend SHALL expor um endpoint POST /api/workout-plans que cria uma nova Ficha_de_Treino para o usuário autenticado.
3. THE API_Backend SHALL expor um endpoint PUT /api/workout-plans/:id que atualiza uma Ficha_de_Treino existente do usuário autenticado.
4. THE API_Backend SHALL expor um endpoint GET /api/diet-plans que retorna a Ficha_de_Dieta do usuário autenticado.
5. THE API_Backend SHALL expor um endpoint POST /api/diet-plans que cria uma nova Ficha_de_Dieta para o usuário autenticado.
6. THE API_Backend SHALL expor um endpoint PUT /api/diet-plans/:id que atualiza uma Ficha_de_Dieta existente do usuário autenticado.
7. THE API_Backend SHALL incluir um script de seed que popula o banco com os dados atuais de Mock_Data (workoutPlan e dietPlan) para o primeiro usuário cadastrado.
8. WHEN um usuário autenticado não possui Ficha_de_Treino cadastrada, THE API_Backend SHALL retornar uma lista vazia (status 200, corpo []).
9. WHEN um usuário autenticado não possui Ficha_de_Dieta cadastrada, THE API_Backend SHALL retornar uma lista vazia (status 200, corpo []).

### Requisito 3: Registro de Usuário

**User Story:** Como novo usuário, eu quero criar uma conta no app, para que meus dados de treino e dieta sejam associados ao meu perfil.

#### Critérios de Aceitação

1. THE API_Backend SHALL expor um endpoint POST /api/auth/register que aceita nome, email e senha.
2. WHEN um registro válido é recebido, THE API_Backend SHALL criar o usuário com a senha hasheada usando bcrypt (custo mínimo 10) e retornar um Access_Token e um Refresh_Token.
3. WHEN o email informado já está cadastrado, THE API_Backend SHALL retornar status 409 com a mensagem "Email já cadastrado".
4. WHEN o email informado possui formato inválido, THE API_Backend SHALL retornar status 400 com a mensagem "Email inválido".
5. WHEN a senha informada possui menos de 8 caracteres, THE API_Backend SHALL retornar status 400 com a mensagem "A senha deve ter no mínimo 8 caracteres".
6. WHEN o nome informado está vazio, THE API_Backend SHALL retornar status 400 com a mensagem "Nome é obrigatório".

### Requisito 4: Login de Usuário

**User Story:** Como usuário cadastrado, eu quero fazer login no app, para acessar meus dados de treino e dieta.

#### Critérios de Aceitação

1. THE API_Backend SHALL expor um endpoint POST /api/auth/login que aceita email e senha.
2. WHEN credenciais válidas são fornecidas, THE API_Backend SHALL retornar um Access_Token (expiração 15 minutos) e um Refresh_Token (expiração 7 dias).
3. WHEN o email não está cadastrado, THE API_Backend SHALL retornar status 401 com a mensagem "Credenciais inválidas".
4. WHEN a senha está incorreta, THE API_Backend SHALL retornar status 401 com a mensagem "Credenciais inválidas".
5. THE API_Backend SHALL usar a mesma mensagem de erro para email inexistente e senha incorreta para evitar enumeração de usuários.

### Requisito 5: Refresh de Token

**User Story:** Como usuário autenticado, eu quero que minha sessão seja renovada automaticamente, para que eu não precise fazer login repetidamente.

#### Critérios de Aceitação

1. THE API_Backend SHALL expor um endpoint POST /api/auth/refresh que aceita um Refresh_Token válido.
2. WHEN um Refresh_Token válido é fornecido, THE API_Backend SHALL retornar um novo Access_Token e um novo Refresh_Token.
3. WHEN um Refresh_Token expirado é fornecido, THE API_Backend SHALL retornar status 401 com a mensagem "Sessão expirada, faça login novamente".
4. WHEN um Refresh_Token inválido ou malformado é fornecido, THE API_Backend SHALL retornar status 401 com a mensagem "Token inválido".

### Requisito 6: Proteção de Rotas da API

**User Story:** Como operador do sistema, eu quero que as rotas da API sejam protegidas, para que apenas usuários autenticados acessem dados sensíveis.

#### Critérios de Aceitação

1. THE Auth_Middleware SHALL validar o Access_Token presente no header Authorization (formato "Bearer <token>") de cada requisição protegida.
2. WHEN uma requisição protegida não contém o header Authorization, THE Auth_Middleware SHALL retornar status 401 com a mensagem "Token não fornecido".
3. WHEN o Access_Token está expirado, THE Auth_Middleware SHALL retornar status 401 com a mensagem "Token expirado".
4. WHEN o Access_Token é válido, THE Auth_Middleware SHALL anexar o userId ao objeto da requisição e permitir o prosseguimento.
5. THE API_Backend SHALL aplicar o Auth_Middleware em todas as rotas sob /api/workouts, /api/diet, /api/progress, /api/activities, /api/weight, /api/workout-plans e /api/diet-plans.
6. THE API_Backend SHALL manter as rotas /api/auth/register, /api/auth/login, /api/auth/refresh e /health como rotas públicas (sem Auth_Middleware).
7. WHEN o Auth_Middleware está ativo, THE API_Backend SHALL filtrar os dados retornados para exibir apenas os dados pertencentes ao userId extraído do token.

### Requisito 7: Tela de Login e Registro no Flutter

**User Story:** Como usuário, eu quero uma tela de login e registro no app, para que eu possa me autenticar e acessar meus dados.

#### Critérios de Aceitação

1. THE App SHALL exibir uma tela de login com campos de email e senha e um botão "Entrar".
2. THE App SHALL exibir um link "Criar conta" na tela de login que navega para a tela de registro.
3. THE App SHALL exibir uma tela de registro com campos de nome, email e senha e um botão "Criar conta".
4. WHEN o usuário submete o formulário de login com campos válidos, THE App SHALL enviar as credenciais ao endpoint POST /api/auth/login.
5. WHEN o login é bem-sucedido, THE App SHALL armazenar o Access_Token e o Refresh_Token no Token_Storage e navegar para a DashboardView.
6. WHEN o login falha, THE App SHALL exibir a mensagem de erro retornada pela API abaixo do formulário.
7. WHEN o usuário submete o formulário de registro com campos válidos, THE App SHALL enviar os dados ao endpoint POST /api/auth/register.
8. WHEN o registro é bem-sucedido, THE App SHALL armazenar os tokens no Token_Storage e navegar para a DashboardView.
9. WHEN o registro falha, THE App SHALL exibir a mensagem de erro retornada pela API abaixo do formulário.
10. WHILE o formulário de login ou registro está sendo submetido, THE App SHALL exibir um indicador de carregamento e desabilitar o botão de submit.

### Requisito 8: Armazenamento e Envio Automático de Tokens

**User Story:** Como usuário autenticado, eu quero que o app envie meu token automaticamente em cada requisição, para que eu não precise me autenticar manualmente a cada ação.

#### Critérios de Aceitação

1. THE ApiClient SHALL armazenar o Access_Token e o Refresh_Token no Token_Storage (flutter_secure_storage) após login ou registro bem-sucedido.
2. THE ApiClient SHALL incluir o header "Authorization: Bearer <Access_Token>" em todas as requisições HTTP para rotas protegidas.
3. WHEN o API_Backend retorna status 401 com mensagem "Token expirado", THE ApiClient SHALL automaticamente enviar o Refresh_Token ao endpoint POST /api/auth/refresh para obter novos tokens.
4. WHEN o refresh é bem-sucedido, THE ApiClient SHALL atualizar os tokens no Token_Storage e repetir a requisição original com o novo Access_Token.
5. WHEN o refresh falha (Refresh_Token expirado ou inválido), THE ApiClient SHALL limpar os tokens do Token_Storage e redirecionar o usuário para a tela de login.
6. THE ApiClient SHALL carregar os tokens do Token_Storage ao ser inicializado para restaurar a sessão do usuário após reiniciar o app.

### Requisito 9: Gerenciamento de Estado de Autenticação

**User Story:** Como usuário, eu quero ser redirecionado para a tela de login quando não estou autenticado, para que o app proteja meus dados.

#### Critérios de Aceitação

1. THE App SHALL manter um Auth_State global (via ChangeNotifier) que indica se o usuário está autenticado.
2. WHEN o App é iniciado e não há tokens válidos no Token_Storage, THE App SHALL redirecionar o usuário para a tela de login.
3. WHEN o App é iniciado e há um Access_Token válido no Token_Storage, THE App SHALL navegar diretamente para a DashboardView.
4. WHEN o Auth_State muda para não-autenticado (logout ou token expirado sem refresh), THE App SHALL redirecionar o usuário para a tela de login e limpar a navegação anterior.
5. THE App SHALL expor uma ação de logout na ConfiguracoesView que limpa os tokens do Token_Storage e atualiza o Auth_State para não-autenticado.
6. THE GoRouter SHALL usar um redirect guard que verifica o Auth_State antes de permitir navegação para rotas protegidas.

### Requisito 10: Associação de Dados ao Usuário

**User Story:** Como atleta, eu quero que meus dados de treino, dieta e progresso sejam vinculados à minha conta, para que apenas eu tenha acesso a eles.

#### Critérios de Aceitação

1. THE API_Backend SHALL incluir o campo userId (referência ao modelo User) em todos os modelos de dados: WorkoutLog, DietLog, Weight, Activity, WorkoutPlan e DietPlan.
2. WHEN um novo registro é criado em qualquer rota protegida, THE API_Backend SHALL automaticamente associar o userId extraído do token ao registro.
3. WHEN dados são consultados em qualquer rota protegida, THE API_Backend SHALL filtrar os resultados para retornar apenas registros do userId autenticado.
4. WHEN um usuário tenta acessar ou modificar um registro que pertence a outro userId, THE API_Backend SHALL retornar status 403 com a mensagem "Acesso negado".
