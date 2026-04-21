# Documento de Requisitos — Importação de Ficha de Treino (Anexar Ficha)

## Introdução

Este documento especifica os requisitos para a funcionalidade "Anexar Ficha" do app Apex.OS. A feature permite que o usuário importe fichas de treino a partir de PDFs (com extração de texto e parsing via IA), crie/edite fichas manualmente, revise os dados extraídos antes de salvar, e persista o plano de treino via API existente. O app opera em português brasileiro.

## Glossário

- **App**: Aplicativo Flutter Apex.OS (oi_coach) executado no dispositivo do usuário.
- **API_Backend**: Servidor Node.js/Express + Mongoose conectado ao MongoDB Atlas, implantado em Railway.
- **Ficha_de_Treino**: Plano de treino (WorkoutPlan) contendo dias de treino (WorkoutDay) e exercícios (Exercise) com séries, repetições e carga alvo.
- **PDF_Ficha**: Arquivo PDF contendo uma ficha de treino em formato tabular com colunas "Exercício" e "Metodologia", organizado por dias de treino (ex: "TREINO 1 - Push").
- **Texto_Extraído**: Texto bruto obtido a partir do processamento de um PDF_Ficha.
- **Metodologia**: String descritiva do volume de treino de um exercício (ex: "2 feeder sets + 2 sets de 6 a 10", "Aquecimento + 3 sets de 8 a 12").
- **Parser_IA**: Serviço no API_Backend que utiliza uma API de LLM para interpretar o Texto_Extraído e convertê-lo em uma estrutura WorkoutPlan válida.
- **Tela_Revisão**: Tela no App onde o usuário revisa, edita e confirma os dados extraídos do PDF antes de salvar.
- **Tela_Criação_Manual**: Tela no App onde o usuário cria ou edita uma Ficha_de_Treino manualmente, sem upload de PDF.
- **WorkoutPlan**: Modelo de dados existente no API_Backend contendo name, days (array de WorkoutDay com exercises).
- **Exercise**: Modelo de dados existente contendo id, order, name, targetSets, targetReps, targetWeight.
- **Dia_de_Treino**: Subdocumento de WorkoutPlan contendo id, name, focus, day e exercises.

## Requisitos

### Requisito 1: Upload de PDF no App

**User Story:** Como atleta, eu quero fazer upload de um PDF da minha ficha de treino no app, para que o sistema extraia os exercícios automaticamente.

#### Critérios de Aceitação

1. WHEN o usuário toca no botão "Anexar nova ficha" na FichasView, THE App SHALL exibir opções para "Importar PDF" e "Criar manualmente".
2. WHEN o usuário seleciona "Importar PDF", THE App SHALL abrir o seletor de arquivos do dispositivo filtrado para aceitar apenas arquivos com extensão .pdf.
3. WHEN o usuário seleciona um PDF_Ficha válido, THE App SHALL exibir um indicador de carregamento e enviar o arquivo ao endpoint de extração no API_Backend.
4. IF o arquivo selecionado excede 10 MB, THEN THE App SHALL exibir a mensagem "O arquivo excede o tamanho máximo de 10 MB" e cancelar o envio.
5. IF o usuário cancela a seleção de arquivo, THEN THE App SHALL retornar à tela anterior sem alterações.

### Requisito 2: Extração de Texto do PDF no Backend

**User Story:** Como atleta, eu quero que o sistema extraia o texto do meu PDF de ficha de treino, para que a IA consiga interpretar os exercícios e metodologias.

#### Critérios de Aceitação

1. THE API_Backend SHALL expor um endpoint POST /api/workout-plans/import que aceita um arquivo PDF via multipart/form-data.
2. WHEN um PDF válido é recebido, THE API_Backend SHALL extrair o texto completo do documento utilizando uma biblioteca de parsing de PDF (ex: pdf-parse).
3. WHEN o Texto_Extraído contém menos de 10 caracteres, THE API_Backend SHALL retornar status 422 com a mensagem "Não foi possível extrair texto do PDF. Verifique se o arquivo contém texto selecionável."
4. IF o arquivo enviado possui formato diferente de PDF, THEN THE API_Backend SHALL retornar status 400 com a mensagem "Formato de arquivo inválido. Envie um arquivo PDF."
5. IF ocorre um erro durante a extração de texto, THEN THE API_Backend SHALL retornar status 500 com a mensagem "Erro ao processar o PDF. Tente novamente."

### Requisito 3: Parsing via IA do Texto Extraído

**User Story:** Como atleta, eu quero que a IA interprete o texto do meu PDF e organize os exercícios por dia de treino com séries e repetições, para que eu não precise digitar tudo manualmente.

#### Critérios de Aceitação

1. WHEN o Texto_Extraído é obtido com sucesso, THE Parser_IA SHALL enviar o texto a uma API de LLM com um prompt estruturado solicitando a conversão para o formato WorkoutPlan.
2. THE Parser_IA SHALL mapear cada seção de dia de treino (ex: "TREINO 1 - Push") para um Dia_de_Treino com os campos name e focus extraídos do título.
3. THE Parser_IA SHALL mapear cada exercício listado para um Exercise com os campos name, targetSets, targetReps e order preenchidos.
4. WHEN a Metodologia contém padrões como "N sets de X a Y", THE Parser_IA SHALL extrair targetSets como N e targetReps como "X-Y".
5. WHEN a Metodologia contém "feeder sets" ou "aquecimento", THE Parser_IA SHALL contabilizar apenas os sets de trabalho efetivos no campo targetSets.
6. THE Parser_IA SHALL normalizar os nomes dos exercícios para formato legível (primeira letra maiúscula, sem abreviações ambíguas).
7. THE Parser_IA SHALL atribuir o campo order sequencialmente (1, 2, 3...) para cada exercício dentro de um Dia_de_Treino.
8. IF a API de LLM retorna uma resposta que não pode ser convertida em um WorkoutPlan válido, THEN THE API_Backend SHALL retornar status 422 com a mensagem "Não foi possível interpretar a ficha. Revise o PDF ou crie a ficha manualmente."
9. IF a API de LLM está indisponível ou retorna erro, THEN THE API_Backend SHALL retornar status 503 com a mensagem "Serviço de IA temporariamente indisponível. Tente novamente em alguns minutos."
10. WHEN o parsing é concluído com sucesso, THE API_Backend SHALL retornar status 200 com o WorkoutPlan estruturado no corpo da resposta, sem salvar no banco de dados.

### Requisito 4: Tela de Revisão e Edição dos Dados Extraídos

**User Story:** Como atleta, eu quero revisar e corrigir os dados extraídos do PDF antes de salvar, para garantir que minha ficha de treino esteja correta.

#### Critérios de Aceitação

1. WHEN o API_Backend retorna o WorkoutPlan extraído com sucesso, THE App SHALL navegar para a Tela_Revisão exibindo todos os dias de treino e exercícios organizados.
2. THE Tela_Revisão SHALL exibir cada Dia_de_Treino com seu nome e foco, e listar os exercícios com name, targetSets, targetReps e targetWeight.
3. WHEN o usuário toca em um exercício na Tela_Revisão, THE App SHALL permitir a edição dos campos name, targetSets, targetReps e targetWeight.
4. WHEN o usuário toca no botão "Adicionar exercício" em um Dia_de_Treino, THE App SHALL adicionar um novo exercício vazio ao final da lista com order incrementado.
5. WHEN o usuário toca no botão de remover em um exercício, THE App SHALL remover o exercício da lista e reordenar os exercícios restantes sequencialmente.
6. WHEN o usuário toca no botão "Adicionar dia de treino", THE App SHALL adicionar um novo Dia_de_Treino vazio ao plano.
7. WHEN o usuário toca no botão de remover em um Dia_de_Treino, THE App SHALL remover o dia e todos os exercícios associados.
8. THE Tela_Revisão SHALL permitir a edição do campo name do WorkoutPlan (nome da ficha).
9. WHEN o usuário toca no botão "Salvar ficha", THE App SHALL validar que o plano contém pelo menos um Dia_de_Treino com pelo menos um exercício antes de enviar ao API_Backend.
10. IF a validação falha (plano vazio), THEN THE App SHALL exibir a mensagem "A ficha deve conter pelo menos um dia de treino com um exercício."

### Requisito 5: Criação Manual de Ficha de Treino

**User Story:** Como atleta, eu quero criar uma ficha de treino manualmente no app, para que eu possa montar meu plano sem precisar de um PDF.

#### Critérios de Aceitação

1. WHEN o usuário seleciona "Criar manualmente" nas opções de anexar ficha, THE App SHALL navegar para a Tela_Criação_Manual com um WorkoutPlan vazio.
2. THE Tela_Criação_Manual SHALL reutilizar os mesmos componentes de edição da Tela_Revisão (edição de dias, exercícios, nome da ficha).
3. WHEN o usuário preenche os dados e toca em "Salvar ficha", THE App SHALL aplicar a mesma validação do Requisito 4.9 antes de enviar ao API_Backend.

### Requisito 6: Persistência da Ficha de Treino via API

**User Story:** Como atleta, eu quero que minha ficha de treino seja salva no servidor, para que eu possa acessá-la de qualquer dispositivo.

#### Critérios de Aceitação

1. WHEN o usuário confirma a ficha na Tela_Revisão ou Tela_Criação_Manual, THE App SHALL enviar o WorkoutPlan ao endpoint POST /api/workout-plans com os dados estruturados.
2. WHEN o API_Backend retorna status 201 (criação bem-sucedida), THE App SHALL navegar para a FichasView e exibir a ficha recém-criada.
3. IF o API_Backend retorna um erro (status 4xx ou 5xx), THEN THE App SHALL exibir a mensagem de erro retornada e manter o usuário na tela de edição sem perder os dados preenchidos.
4. WHILE a requisição de salvamento está em andamento, THE App SHALL exibir um indicador de carregamento e desabilitar o botão "Salvar ficha".

### Requisito 7: Endpoint de Importação com Autenticação

**User Story:** Como operador do sistema, eu quero que o endpoint de importação de PDF seja protegido por autenticação, para que apenas usuários autenticados possam importar fichas.

#### Critérios de Aceitação

1. THE API_Backend SHALL aplicar o Auth_Middleware no endpoint POST /api/workout-plans/import.
2. WHEN um usuário autenticado envia um PDF, THE API_Backend SHALL associar o userId extraído do token ao contexto do parsing.
3. WHEN uma requisição sem token válido é enviada ao endpoint de importação, THE API_Backend SHALL retornar status 401 com a mensagem "Token não fornecido" ou "Token expirado".

### Requisito 8: Formatação e Impressão do WorkoutPlan (Pretty Printer)

**User Story:** Como atleta, eu quero que o sistema consiga converter um WorkoutPlan estruturado de volta para um formato textual legível, para que eu possa verificar a integridade dos dados.

#### Critérios de Aceitação

1. THE API_Backend SHALL expor uma função formatWorkoutPlanToText que recebe um objeto WorkoutPlan e retorna uma representação textual legível organizada por dia de treino.
2. THE formatWorkoutPlanToText SHALL listar cada Dia_de_Treino com seu nome e foco, seguido dos exercícios com order, name, targetSets e targetReps.
3. FOR ALL objetos WorkoutPlan válidos, parsing o texto formatado por formatWorkoutPlanToText e comparando com o objeto original SHALL produzir um objeto equivalente (propriedade round-trip).
