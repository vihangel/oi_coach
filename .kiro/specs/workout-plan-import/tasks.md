# Implementation Plan: Workout Plan Import (Anexar Ficha)

## Overview

Implement PDF import and manual creation of workout plans. The backend receives a PDF, extracts text with `pdf-parse`, parses it via OpenAI GPT-4o-mini, and returns a structured WorkoutPlan for review. The Flutter app provides file picking, a review/edit screen, and saves via the existing API. Implementation proceeds backend-first, then Flutter services, then UI, then integration.

## Tasks

- [ ] 1. Backend foundation — install dependencies and create services
  - [ ] 1.1 Install backend dependencies (`pdf-parse`, `multer`, `openai`) and add `OPENAI_API_KEY` to `.env.example`
    - Run `npm install pdf-parse multer openai` in `backend/`
    - Add `OPENAI_API_KEY=` to `backend/.env.example`
    - _Requirements: 2.2, 3.1_

  - [ ] 1.2 Create multer upload middleware (`backend/src/middleware/upload.js`)
    - Configure `multer.memoryStorage()` with 10 MB file size limit
    - Add `fileFilter` that accepts only `application/pdf` MIME type
    - Export the configured `upload` middleware
    - _Requirements: 2.1, 2.4_

  - [ ] 1.3 Create PDF extractor service (`backend/src/services/pdfExtractor.js`)
    - Implement `async extractTextFromPdf(buffer)` that uses `pdf-parse` to extract text
    - Return the extracted text string
    - Throw descriptive error if extraction fails
    - _Requirements: 2.2, 2.3, 2.5_

  - [ ] 1.4 Create AI parser service (`backend/src/services/aiParser.js`)
    - Implement `async parseWorkoutText(text)` using the OpenAI SDK with `gpt-4o-mini`
    - Include the structured prompt from the design (JSON schema, methodology rules, normalization rules)
    - Use JSON mode (`response_format: { type: "json_object" }`) for reliable parsing
    - Validate the LLM response structure before returning
    - Handle OpenAI API errors (unavailable → throw with 503 context, invalid response → throw with 422 context)
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8, 3.9_

  - [ ] 1.5 Create workout plan validator (`backend/src/services/workoutPlanValidator.js`)
    - Implement `validateWorkoutPlan(plan)` returning `{ valid, errors }`
    - Validate: `name` is non-empty string, `days` is non-empty array, each day has `id`, `name`, `focus`, `day` (non-empty strings), each day has at least 1 exercise, each exercise has `id`, `name` (non-empty), `order` > 0, `targetSets` > 0, `targetReps` (non-empty string)
    - _Requirements: 4.9, 4.10, 3.10_

  - [ ] 1.6 Create workout plan formatter service (`backend/src/services/workoutPlanFormatter.js`)
    - Implement `formatWorkoutPlanToText(workoutPlan)` — converts WorkoutPlan to readable text organized by training day, listing name, focus, and each exercise with order, name, targetSets, targetReps
    - Implement `parseFormattedText(text)` — parses the formatted text back into a WorkoutPlan object
    - _Requirements: 8.1, 8.2, 8.3_

  - [ ]* 1.7 Write property tests for formatter round-trip (backend, fast-check)
    - **Property 1: Round-trip de formatação do WorkoutPlan** — for any valid WorkoutPlan, `parseFormattedText(formatWorkoutPlanToText(plan))` produces an equivalent object
    - **Validates: Requirements 8.1, 8.2, 8.3**

  - [ ]* 1.8 Write property test for formatted text completeness (backend, fast-check)
    - **Property 2: Texto formatado contém todos os campos obrigatórios** — for any valid WorkoutPlan, the text from `formatWorkoutPlanToText` contains every day's name/focus and every exercise's order, name, targetSets, targetReps
    - **Validates: Requirements 8.2**

  - [ ]* 1.9 Write property test for workout plan validation (backend, fast-check)
    - **Property 4: Validação do WorkoutPlan aceita apenas planos com conteúdo** — `validateWorkoutPlan` returns true iff the plan has at least one day with at least one exercise with non-empty name, targetSets > 0, and non-empty targetReps
    - **Validates: Requirements 4.9, 4.10, 5.3**

- [ ] 2. Backend — import route and server wiring
  - [ ] 2.1 Create import route (`backend/src/routes/workoutPlanImport.js`)
    - `POST /` handler: use multer upload middleware for single file field `'file'`
    - Check `req.file` exists → 400 "Nenhum arquivo enviado."
    - Call `extractTextFromPdf(req.file.buffer)` → catch → 500
    - Validate extracted text length ≥ 10 → 422
    - Call `parseWorkoutText(text)` → catch OpenAI errors (503/422)
    - Validate parsed plan with `validateWorkoutPlan` → 422 if invalid
    - Return 200 with the parsed WorkoutPlan (do NOT save to database)
    - Handle multer errors (file too large → 400, invalid format → 400)
    - _Requirements: 2.1, 2.3, 2.4, 3.8, 3.9, 3.10, 7.1_

  - [ ] 2.2 Register import route in `backend/src/index.js`
    - Import `workoutPlanImportRoutes` from `./routes/workoutPlanImport`
    - Register `app.use('/api/workout-plans/import', authMiddleware, workoutPlanImportRoutes)` BEFORE the existing `/api/workout-plans` route to avoid path conflicts
    - _Requirements: 7.1, 7.2, 7.3_

  - [ ]* 2.3 Write unit tests for import endpoint and services
    - Test pdfExtractor: extracts text from a valid PDF buffer
    - Test pdfExtractor: throws for invalid buffer
    - Test aiParser: returns valid WorkoutPlan for sample text (mock OpenAI)
    - Test aiParser: throws on invalid JSON response (mock)
    - Test aiParser: throws on OpenAI unavailable (mock)
    - Test validateWorkoutPlan: accepts valid plan, rejects plan without days, rejects day without exercises
    - Test import endpoint: returns 400 for non-PDF, 422 for insufficient text, 200 for valid PDF (mocked services), 401 without auth token
    - _Requirements: 2.2, 2.3, 2.4, 2.5, 3.1, 3.8, 3.9, 7.3_

- [ ] 3. Checkpoint — Backend complete
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 4. Flutter foundation — dependencies and data layer
  - [ ] 4.1 Add `file_picker` dependency to `pubspec.yaml`
    - Run `flutter pub add file_picker`
    - _Requirements: 1.2_

  - [ ] 4.2 Add `uploadFile` method to `ApiClient` (`lib/data/services/api_client.dart`)
    - Implement `Future<dynamic> uploadFile(String path, Uint8List bytes, String fileName)` using `http.MultipartRequest`
    - Attach auth headers, send file as `'file'` field
    - Reuse `_handleResponse` for 401 refresh logic
    - _Requirements: 1.3, 2.1_

  - [ ] 4.3 Add `importFromPdf` method to `ApiWorkoutPlanRepository` (`lib/data/repositories/api_workout_plan_repository.dart`)
    - Implement `Future<Map<String, dynamic>> importFromPdf(Uint8List bytes, String fileName)` calling `_apiClient.uploadFile('/workout-plans/import', bytes, fileName)`
    - _Requirements: 1.3, 3.10_

  - [ ] 4.4 Create `ImportViewModel` (`lib/features/fichas/view_model/import_view_model.dart`)
    - Extend `ChangeNotifier` with `isUploading`, `isSaving`, `error`, `parsedPlan` state
    - Implement `uploadPdf(Uint8List bytes, String fileName)` — calls repository `importFromPdf`, updates state
    - Implement `savePlan(Map<String, dynamic> plan)` — calls repository `createWorkoutPlan`, updates state
    - Implement `clearError()`
    - Handle all error scenarios from the design (400, 422, 503, network errors) with user-friendly messages
    - _Requirements: 1.3, 1.4, 6.1, 6.3, 6.4_

- [ ] 5. Flutter UI — ReviewView and FichasView updates
  - [ ] 5.1 Create `ReviewView` (`lib/features/fichas/view/review_view.dart`)
    - Accept optional `initialPlan` parameter (null = manual creation, non-null = imported data)
    - Display editable plan name field
    - Display each training day with name, focus, and list of exercises (name, targetSets, targetReps, targetWeight)
    - Allow inline editing of all exercise fields
    - "Adicionar exercício" button per day — appends exercise with incremented order
    - Remove exercise button — removes and reorders remaining exercises sequentially (1, 2, 3...)
    - "Adicionar dia de treino" button — appends empty day
    - Remove day button — removes day and all its exercises
    - "Salvar ficha" button — validates plan (at least 1 day with 1 exercise), shows error "A ficha deve conter pelo menos um dia de treino com um exercício." if invalid
    - On successful save, navigate to FichasView
    - On save error, show error message and keep data on screen
    - Show loading indicator while saving, disable save button
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.7, 4.8, 4.9, 4.10, 5.1, 5.2, 5.3, 6.1, 6.2, 6.3, 6.4_

  - [ ]* 5.2 Write property test for exercise order invariant (Flutter, glados)
    - **Property 3: Invariante de ordem sequencial após mutações** — after adding or removing an exercise at any valid position, the resulting exercise list has sequential `order` values starting at 1
    - **Validates: Requirements 3.7, 4.4, 4.5**

  - [ ]* 5.3 Write property test for plan validation (Flutter, glados)
    - **Property 4: Validação do WorkoutPlan aceita apenas planos com conteúdo** — validation returns true iff plan has at least one day with at least one exercise with non-empty name, targetSets > 0, non-empty targetReps
    - **Validates: Requirements 4.9, 4.10, 5.3**

  - [ ] 5.4 Update `FichasView` (`lib/features/fichas/view/fichas_view.dart`)
    - Change "Anexar nova ficha" button to show a bottom sheet with two options: "Importar PDF" and "Criar manualmente"
    - "Importar PDF": open `file_picker` filtered to `.pdf`, validate file ≤ 10 MB, show loading indicator, call `ImportViewModel.uploadPdf`, navigate to ReviewView with parsed data
    - "Criar manualmente": navigate to ReviewView with null initialPlan
    - Show error messages for file size exceeded, upload errors, and parsing errors
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 5.1_

  - [ ] 5.5 Add ReviewView route to GoRouter (`lib/app/router.dart`)
    - Add `GoRoute(path: 'review', builder: (_, state) => ReviewView(initialPlan: state.extra as Map<String, dynamic>?))` as a child of the `/fichas` route
    - _Requirements: 4.1, 5.1_

- [ ] 6. Checkpoint — Flutter UI complete
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 7. Integration and environment wiring
  - [ ] 7.1 Update `backend/.env.example` and document Railway environment variable
    - Ensure `OPENAI_API_KEY` is listed in `.env.example` with a comment
    - Add a note in the file about setting this variable on Railway
    - _Requirements: 3.1_

  - [ ]* 7.2 Write integration tests
    - Test full import flow: upload PDF → parse → review → save → verify in FichasView (mocked backend)
    - Test manual creation flow: create → fill → save → verify (mocked backend)
    - Test that import endpoint returns data without saving to database
    - _Requirements: 1.1, 1.2, 1.3, 3.10, 4.1, 5.1, 6.1, 6.2_

- [ ] 8. Final checkpoint — All features integrated
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Backend uses JavaScript (Node.js/Express), Flutter uses Dart
- Property tests use `fast-check` (backend) and `glados` (Flutter, already in dev_dependencies)
- The import endpoint does NOT save to the database — saving uses the existing `POST /api/workout-plans` endpoint
- The import route must be registered BEFORE `/api/workout-plans` in `index.js` to avoid Express path conflicts
- `OPENAI_API_KEY` must be set on Railway for production
