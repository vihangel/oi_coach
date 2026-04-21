# Requirements Document

## Introdução

Reestruturação do app Flutter "Apex.OS — Terminal de Desempenho" (oi_coach) para corrigir bugs de layout, simplificar a navegação (de 7 para 4 abas), unificar treino e dieta em uma única aba de rotina diária, adicionar registro manual de atividades extras, permitir input de peso na seção de relatório, corrigir o fluxo de sincronização Garmin→validação→confirmação, e expandir o progresso para rastrear carga E repetições.

## Glossário

- **App**: O aplicativo Flutter "Apex.OS — Terminal de Desempenho" (pacote oi_coach)
- **Bottom_Nav**: A barra de navegação inferior com abas do aplicativo
- **Safe_Area**: Região da tela que respeita notch, barra de status e home indicator do dispositivo
- **Rotina_Diária**: Aba unificada que combina treino e dieta do dia em uma única visualização
- **Atividade_Extra**: Atividade física complementar ao treino de musculação (yoga, corrida, crossfit, natação, tênis de mesa)
- **Garmin_Sync**: Processo de sincronização automática de atividades do dispositivo Garmin para o app
- **Ficha_Treino**: Plano de treino prescrito pelo coach contendo exercícios, séries, repetições e carga alvo
- **Confirmação_Usuário**: Ação do usuário validando que a atividade sincronizada corresponde à ficha de treino
- **Progresso_View**: Tela de comparação semanal de desempenho nos exercícios
- **Relatório_View**: Tela de resumo semanal com métricas consolidadas

## Requisitos

### Requisito 1: Correção de Safe Areas

**User Story:** Como usuário, eu quero que o conteúdo do app respeite as áreas seguras do dispositivo, para que nenhum texto ou componente fique cortado ou sobreposto por elementos do sistema.

#### Critérios de Aceitação

1. THE App SHALL wrap all page content within SafeArea boundaries on every screen
2. WHEN content exceeds the available horizontal space, THE App SHALL prevent text overflow by applying proper text wrapping or ellipsis truncation
3. WHEN the device has a notch or dynamic island, THE App SHALL ensure no interactive element is obscured by the hardware cutout
4. THE App SHALL maintain consistent padding of at least 16dp between content and screen edges on all pages

### Requisito 2: Simplificação da Navegação

**User Story:** Como usuário, eu quero uma navegação mais simples com menos abas, para que eu encontre o que preciso sem me perder em menus desnecessários.

#### Critérios de Aceitação

1. THE Bottom_Nav SHALL display exactly 4 tabs: Hoje, Rotina, Progresso, Config
2. WHEN the user taps the "Hoje" tab, THE App SHALL navigate to the dashboard with resumo do dia
3. WHEN the user taps the "Rotina" tab, THE App SHALL navigate to the unified daily routine view combining training and diet
4. WHEN the user taps the "Progresso" tab, THE App SHALL navigate to the weekly progress comparison view
5. WHEN the user taps the "Config" tab, THE App SHALL navigate to the settings and integrations view
6. THE Bottom_Nav SHALL render tab labels without text overflow on devices with screen width of 320dp or greater

### Requisito 3: Unificação de Treino e Dieta na Rotina Diária

**User Story:** Como usuário, eu quero ver treino e dieta na mesma tela, pois ambos fazem parte da minha rotina diária e estão relacionados.

#### Critérios de Aceitação

1. THE Rotina_Diária SHALL display the training session and diet log in a single scrollable view
2. THE Rotina_Diária SHALL show the training section first, followed by the diet section
3. WHEN the user completes all exercise confirmations and all meal check-ins, THE Rotina_Diária SHALL display a visual indicator that the daily routine is complete
4. THE Rotina_Diária SHALL preserve all existing training functionality: exercise sets, weight input, reps input, and mapping confirmation
5. THE Rotina_Diária SHALL preserve all existing diet functionality: meal status selection (Seguiu/Ajustou/Não), notes for adjustments, free meal entry, and fasting weight display

### Requisito 4: Registro Manual de Atividades Extras

**User Story:** Como usuário, eu quero registrar atividades extras (yoga, corrida, crossfit, natação, tênis de mesa) com duração, para que meu coach tenha visibilidade completa do meu volume de treino.

#### Critérios de Aceitação

1. THE Rotina_Diária SHALL provide a section for logging extra activities below the training and diet sections
2. WHEN the user adds a manual activity, THE App SHALL require selection of activity type from the list: yoga, corrida, crossfit, natação, tênis de mesa
3. WHEN the user adds a manual activity, THE App SHALL require input of duration in minutes
4. WHEN a Garmin-synced activity matches a supported activity type, THE App SHALL display the activity as pre-filled with a "Garmin" source badge
5. WHEN the user manually logs an activity, THE App SHALL display the activity with a "Manual" source badge
6. THE App SHALL allow the user to log multiple extra activities for the same day
7. THE Relatório_View SHALL include logged extra activities in the weekly summary

### Requisito 5: Input de Peso no Relatório

**User Story:** Como usuário, eu quero inserir meu peso diretamente na seção de relatório, para que eu possa atualizar essa informação sem navegar para outra tela.

#### Critérios de Aceitação

1. THE Relatório_View SHALL display an editable weight input field showing the current fasting weight in kg
2. WHEN the user submits a new weight value, THE App SHALL update the stored fasting weight
3. WHEN the user submits a new weight value, THE App SHALL recalculate and display the weight delta compared to the previous entry
4. THE App SHALL persist the weight value using local storage (SharedPreferences)
5. IF the user enters a weight value outside the range of 30kg to 300kg, THEN THE App SHALL display a validation error message

### Requisito 6: Fluxo de Sincronização Garmin

**User Story:** Como usuário, eu quero que atividades do Garmin sincronizem automaticamente e sejam validadas contra minha ficha de treino, para que eu confirme e salve minha rotina diária com confiança.

#### Critérios de Aceitação

1. WHEN a new activity is synced from Garmin, THE App SHALL display the synced activity data in the training section of Rotina_Diária
2. WHEN a synced activity contains exercises, THE App SHALL compare each exercise against the Ficha_Treino and display match status (mapeado/não mapeado)
3. WHEN all exercises are validated against the Ficha_Treino, THE App SHALL enable the confirmation button for the user
4. WHEN the user confirms the synced session, THE App SHALL save the daily activity record including training data and diet data together
5. IF a synced activity does not match any exercise in the Ficha_Treino, THEN THE App SHALL highlight the unmatched exercise and prompt the user to resolve the discrepancy
6. WHILE the Garmin integration is disconnected, THE App SHALL allow full manual entry of training data as fallback

### Requisito 7: Progresso com Carga e Repetições

**User Story:** Como usuário, eu quero que o progresso rastreie tanto carga quanto repetições, para que eu tenha uma visão completa da minha evolução e não apenas de um aspecto.

#### Critérios de Aceitação

1. THE Progresso_View SHALL display both weight (carga) and repetitions (reps) columns for each exercise in the comparison table
2. THE Progresso_View SHALL calculate and display the delta for weight (kg) between current and previous week
3. THE Progresso_View SHALL calculate and display the delta for repetitions between current and previous week
4. WHEN an exercise shows progression in weight OR repetitions, THE Progresso_View SHALL mark the exercise with a positive progression indicator (green)
5. WHEN an exercise shows regression in both weight AND repetitions, THE Progresso_View SHALL mark the exercise with a negative regression indicator (red)
6. THE Progresso_View SHALL display a summary stat showing the count of exercises with progression in weight and a separate count for progression in repetitions

### Requisito 8: Incorporação de Relatório e Fichas no Dashboard

**User Story:** Como usuário, eu quero acessar relatório e fichas a partir do dashboard, já que a navegação foi simplificada e essas funcionalidades não têm mais aba própria.

#### Critérios de Aceitação

1. THE Dashboard SHALL provide a navigation card to access the weekly report (Relatório) view
2. THE Dashboard SHALL provide a navigation card to access the training sheets (Fichas) view
3. WHEN the user taps the report card, THE App SHALL navigate to the Relatório_View as a sub-page within the Hoje tab
4. WHEN the user taps the sheets card, THE App SHALL navigate to the Fichas view as a sub-page within the Hoje tab
5. THE App SHALL provide a back navigation from Relatório_View and Fichas to the Dashboard
