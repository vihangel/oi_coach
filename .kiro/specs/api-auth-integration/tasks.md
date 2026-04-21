# Implementation Plan: API Auth Integration

## Overview

This plan implements JWT authentication and removes mock data from the Apex.OS app. The backend (Node.js/Express) gets auth routes, protected middleware, new models (User, WorkoutPlan, DietPlan), and userId on existing models. The Flutter app gets token storage, auth views, ApiClient interceptor, and router guards. All views migrate from mock data to real API calls with empty states.

## Tasks

- [x] 1. Backend authentication foundation
  - [x] 1.1 Install backend auth dependencies and create User model
    - Add `bcryptjs` and `jsonwebtoken` to backend/package.json
    - Create `backend/src/models/User.js` with name, email (unique, lowercase, trim), password (bcrypt hash), timestamps
    - Add JWT_SECRET and JWT_REFRESH_SECRET to `.env` and `.env.example`
    - _Requirements: 3.1, 3.2_

  - [x] 1.2 Create auth middleware
    - Create `backend/src/middleware/auth.js`
    - Extract Bearer token from Authorization header
    - Verify with jwt.verify using JWT_SECRET
    - Attach `req.userId` on success
    - Return 401 with appropriate messages: "Token não fornecido", "Token expirado", "Token inválido"
    - _Requirements: 6.1, 6.2, 6.3, 6.4_

  - [x] 1.3 Create auth routes (register, login, refresh)
    - Create `backend/src/routes/auth.js`
    - POST /api/auth/register: validate name/email/password, hash password (cost 10), create user, return access+refresh tokens
    - POST /api/auth/login: find user by email, compare password with bcrypt, return tokens or 401 "Credenciais inválidas"
    - POST /api/auth/refresh: verify refresh token, issue new token pair
    - Register validation: 400 for invalid email, password < 8 chars, empty name; 409 for duplicate email
    - _Requirements: 3.1–3.6, 4.1–4.5, 5.1–5.4_

  - [x] 1.4 Register auth routes in index.js
    - Import authRoutes and mount at `/api/auth` (public, no middleware)
    - _Requirements: 6.6_

  - [ ]* 1.5 Write property tests for auth routes (backend)
    - **Property 1: Registration produces hashed password and valid tokens**
    - **Property 2: Registration input validation rejects invalid inputs**
    - **Property 3: Login returns tokens with correct expiration**
    - **Property 4: Login error messages prevent user enumeration**
    - **Property 5: Token refresh produces new valid tokens**
    - **Property 6: Invalid tokens are rejected**
    - **Property 7: Auth middleware validates token and extracts userId**
    - **Validates: Requirements 3.1, 3.2, 3.4, 3.5, 4.2, 4.3, 4.4, 4.5, 5.2, 5.4, 6.1, 6.4**

- [x] 2. Checkpoint — Backend auth
  - Ensure all tests pass, ask the user if questions arise.

- [x] 3. Backend data models and route protection
  - [x] 3.1 Create WorkoutPlan model
    - Create `backend/src/models/WorkoutPlan.js` with userId (ObjectId, ref User, required), name, days array (subdocuments with id, name, focus, day, exercises array)
    - _Requirements: 2.1, 2.2, 2.3_

  - [x] 3.2 Create DietPlan model
    - Create `backend/src/models/DietPlan.js` with userId (ObjectId, ref User, required), name, meals array (subdocuments with id, name, time, description, kcal)
    - _Requirements: 2.4, 2.5, 2.6_

  - [x] 3.3 Add userId field to existing models
    - Add `userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true }` to WorkoutLog, DietLog, Weight, Activity models
    - Add index on userId for each model
    - _Requirements: 10.1_

  - [x] 3.4 Create WorkoutPlan routes
    - Create `backend/src/routes/workoutPlans.js`
    - GET /api/workout-plans — list plans filtered by req.userId
    - POST /api/workout-plans — create plan with req.userId
    - PUT /api/workout-plans/:id — update plan owned by req.userId, return 403 if not owner
    - _Requirements: 2.1, 2.2, 2.3, 2.8, 10.4_

  - [x] 3.5 Create DietPlan routes
    - Create `backend/src/routes/dietPlans.js`
    - GET /api/diet-plans — list plans filtered by req.userId
    - POST /api/diet-plans — create plan with req.userId
    - PUT /api/diet-plans/:id — update plan owned by req.userId, return 403 if not owner
    - _Requirements: 2.4, 2.5, 2.6, 2.9, 10.4_

  - [x] 3.6 Apply auth middleware and userId filtering to existing routes
    - Update `backend/src/routes/workouts.js`: add authMiddleware, filter by req.userId on GET, set req.userId on POST
    - Update `backend/src/routes/diet.js`: add authMiddleware, filter by req.userId on GET, set req.userId on POST
    - Update `backend/src/routes/activities.js`: add authMiddleware, filter by req.userId on GET, set req.userId on POST/DELETE
    - Update `backend/src/routes/weight.js`: add authMiddleware, filter by req.userId on GET, set req.userId on POST
    - Update `backend/src/routes/progress.js`: add authMiddleware, filter by req.userId
    - _Requirements: 6.5, 6.7, 10.2, 10.3_

  - [x] 3.7 Register new routes in index.js with auth middleware
    - Mount workoutPlanRoutes at `/api/workout-plans` with authMiddleware
    - Mount dietPlanRoutes at `/api/diet-plans` with authMiddleware
    - _Requirements: 6.5_

  - [ ]* 3.8 Write property tests for data isolation and ownership (backend)
    - **Property 8: Data isolation — queries return only authenticated user's data**
    - **Property 9: Auto-association — created records get userId from token**
    - **Property 10: Update preserves ownership**
    - **Property 11: Cross-user access denied**
    - **Validates: Requirements 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 6.7, 10.2, 10.3, 10.4**

- [x] 4. Checkpoint — Backend models and route protection
  - Ensure all tests pass, ask the user if questions arise.

- [x] 5. Flutter authentication layer
  - [x] 5.1 Add flutter_secure_storage dependency
    - Add `flutter_secure_storage` to pubspec.yaml dependencies
    - _Requirements: 8.1_

  - [x] 5.2 Create TokenService
    - Create `lib/data/services/token_service.dart`
    - Implement saveTokens, getAccessToken, getRefreshToken, clearTokens, hasTokens using flutter_secure_storage
    - _Requirements: 8.1, 8.6_

  - [x] 5.3 Create AuthRepository
    - Create `lib/data/repositories/auth_repository.dart`
    - Implement login(email, password), register(name, email, password), refresh(refreshToken) calling ApiClient
    - Define AuthResponse model (accessToken, refreshToken, userId, name, email)
    - _Requirements: 7.4, 7.7_

  - [x] 5.4 Refactor ApiClient to support auth tokens
    - Convert ApiClient from static to instance-based, accepting TokenService
    - Add Authorization: Bearer header to all requests
    - Implement 401 interceptor: on "Token expirado" response, call refresh endpoint, retry original request
    - Add onSessionExpired callback for when refresh fails (clears tokens)
    - _Requirements: 8.2, 8.3, 8.4, 8.5, 8.6_

  - [x] 5.5 Create AuthViewModel
    - Create `lib/features/auth/view_model/auth_view_model.dart`
    - Implement isAuthenticated, isLoading, error state
    - Implement login, register, logout, tryRestoreSession methods
    - Extend ChangeNotifier for GoRouter refreshListenable
    - _Requirements: 9.1, 9.2, 9.3, 9.5_

  - [ ]* 5.6 Write property tests for Flutter auth (glados)
    - **Property 12: Token storage round-trip**
    - **Property 13: Authorization header included in authenticated requests**
    - **Property 14: Route protection redirects unauthenticated users**
    - **Validates: Requirements 8.1, 8.2, 8.6, 9.4, 9.6**

- [x] 6. Flutter auth UI and routing
  - [x] 6.1 Create Login View
    - Create `lib/features/auth/view/login_view.dart`
    - Email and password fields, "Entrar" button, "Criar conta" link
    - Loading indicator and disabled button during submit
    - Error message display below form
    - _Requirements: 7.1, 7.2, 7.4, 7.5, 7.6, 7.10_

  - [x] 6.2 Create Register View
    - Create `lib/features/auth/view/register_view.dart`
    - Name, email, password fields, "Criar conta" button
    - Loading indicator and disabled button during submit
    - Error message display below form
    - _Requirements: 7.3, 7.7, 7.8, 7.9, 7.10_

  - [x] 6.3 Update GoRouter with auth guard
    - Add `/login` and `/register` routes (outside ShellRoute)
    - Add redirect guard checking AuthViewModel.isAuthenticated
    - Set refreshListenable to AuthViewModel
    - Redirect unauthenticated users to /login, authenticated users away from /login
    - _Requirements: 9.2, 9.3, 9.4, 9.6_

  - [x] 6.4 Add logout action to ConfiguracoesView
    - Add logout button that calls AuthViewModel.logout()
    - _Requirements: 9.5_

  - [ ]* 6.5 Write unit tests for login and register views
    - Test login form fields and button presence
    - Test register form fields and button presence
    - Test loading state during submit
    - Test error message display
    - _Requirements: 7.1, 7.3, 7.10_

- [x] 7. Checkpoint — Flutter auth complete
  - Ensure all tests pass, ask the user if questions arise.

- [x] 8. Flutter mock data removal and API migration
  - [x] 8.1 Create WorkoutPlan and DietPlan repositories
    - Create `lib/data/repositories/api_workout_plan_repository.dart` with getWorkoutPlans, createWorkoutPlan, updateWorkoutPlan
    - Create `lib/data/repositories/api_diet_plan_repository.dart` with getDietPlans, createDietPlan, updateDietPlan
    - _Requirements: 2.1, 2.4_

  - [x] 8.2 Update RotinaViewModel to use API
    - Remove mock_data imports (workoutPlan, dietPlan, lastWeekResults)
    - Load WorkoutPlan and DietPlan from API repositories
    - Load lastWeekResults from ApiWorkoutRepository
    - Add loading and empty states
    - _Requirements: 1.10, 1.11_

  - [x] 8.3 Update DashboardView/ViewModel to use API
    - Remove mock_data references
    - Load today's workout and weekly summary from API
    - Add empty state: "Nenhum treino planejado para hoje"
    - _Requirements: 1.1, 1.2_

  - [x] 8.4 Update ProgressoView/ViewModel to use API
    - Remove mock_data references
    - Load progress data from ApiProgressRepository
    - Add empty state: "Nenhum dado de progresso disponível"
    - _Requirements: 1.3, 1.4_

  - [x] 8.5 Update RelatorioView/ViewModel to use API
    - Remove mock_data references
    - Load weight, activities, report data from API
    - Add empty state for insufficient data
    - _Requirements: 1.5, 1.6_

  - [x] 8.6 Update FichasView/ViewModel to use API
    - Remove mock_data references
    - Load WorkoutPlan and DietPlan from API repositories
    - Add empty state: "Nenhuma ficha anexada" with action button
    - _Requirements: 1.7, 1.8_

  - [x] 8.7 Update ConfiguracoesView to use API
    - Remove mock_data references
    - Load integrations from API
    - _Requirements: 1.9_

  - [x] 8.8 Remove mock_data.dart module
    - Delete `lib/data/mock_data.dart`
    - Verify no remaining imports reference mock_data
    - _Requirements: 1.12_

  - [ ]* 8.9 Write unit tests for empty states and API loading
    - Test each view displays correct empty state when API returns empty data
    - Test loading indicators during API calls
    - _Requirements: 1.2, 1.4, 1.6, 1.8, 1.11_

- [x] 9. Backend seed script
  - [x] 9.1 Create seed script
    - Create `backend/src/seed.js`
    - Register a test user (or use first existing user)
    - Populate WorkoutPlan with current mock_data workoutPlan structure
    - Populate DietPlan with current mock_data dietPlan structure
    - Add sample WorkoutLog, DietLog, Weight, Activity entries with userId
    - Add "seed" script to package.json
    - _Requirements: 2.7_

- [x] 10. Final checkpoint
  - Ensure all tests pass, ask the user if questions arise.
  - Verify all routes return 401 without token
  - Verify public routes (/health, /api/auth/*) work without token
  - Verify data isolation between users

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Backend auth (tasks 1–2) must be completed before Flutter auth (tasks 5–6)
- Data models (task 3) must be completed before Flutter API migration (task 8)
- The seed script (task 9) can run after backend models are in place
- Property tests use `fast-check` for Node.js backend and `glados` for Flutter
- Each task references specific requirements for traceability
