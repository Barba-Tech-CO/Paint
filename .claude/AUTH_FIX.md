Aqui está um prompt pronto para você colar no seu agente 👇

---

# Agent Brief — Flutter MVVM Auth Bugfix (`/user` 500 after login)

**Role:** You are a senior Flutter engineer (GetX/MVVM-friendly), obsessed with Clean Code and SOLID.
**Objective:** Diagnose and fix a post-login failure where the `/user` endpoint returns **HTTP 500** even though the login flow succeeds. The login uses a WebView to a fixed GoHighLevel CRM URL; after a **200** on `/auth/callback`, the backend (Laravel) returns an `auth_token`. The app then navigates to Home and calls `/user`, which currently fails with 500 due to an issue handling that `auth_token`.

**Constraints (read carefully):**

* Do **not** run `flutter run`, build APK, or perform runtime commands. Your work must be static analysis + code changes.
* Deliver a precise diagnosis and a minimal, production-grade fix following MVVM and Clean Code practices.
* Use English in your outputs (comments, report, commit message).
* Consult the **`/docs`** folder in the repo for API specs (routes, header format, token type, expected `/user` path).
* Do not refactor unrelated code or change UI/UX.

---

## Inputs & Clues

* Login happens in a **WebView** that hits a fixed GoHighLevel CRM URL and completes via `/auth/callback`.
* `/auth/callback` returns `auth_token` (Laravel issues it after the GoHighLevel callback succeeds).
* Only after navigating to **Home**, the first call to `/user` returns **500**.
* Prior logs in this codebase show files like:

  * `view/auth/auth_webview.dart`
  * `utils/logger/logger_app_logger_impl.dart`
* Suspicions to check:

  * Token capture/parsing from the callback (query/body/JS bridge) might be wrong (extra quotes/whitespace).
  * Token persistence/read timing (race between saving token and first `/user` call).
  * HTTP client not injecting `Authorization: Bearer <token>` or using stale instance without header.
  * Wrong base URL or path (`/api/user` vs `/user`) vs. what `/docs` specify (Sanctum/Passport differences).
  * Interceptor order or missing `await` when writing/reading secure storage.
  * Multiple HTTP clients (one with header, one without).

---

## Tasks (do in order)

1. **Map the Auth Flow (static):**

   * Trace from WebView login → `/auth/callback` → token extraction → token storage → navigation to Home → first `/user` request.
   * Identify exact code paths and timing (awaits) for token write/read and client header injection.

2. **Token Extraction Audit:**

   * In `view/auth/auth_webview.dart` (or equivalent), locate where the `auth_token` is captured:

     * From URL (query param) or page body (via `JavaScriptChannel` or `NavigationDelegate`).
   * Normalize the token:

     * Trim whitespace/newlines.
     * Remove wrapping quotes if present.
     * Ensure it is the raw token **without** the word `Bearer`.
     * Validate it matches a JWT-like pattern (`^[A-Za-z0-9-_\.]+$`) or what `/docs` define.

3. **Persistence & Availability:**

   * Identify where token is stored (e.g., `flutter_secure_storage`, Hive, GetStorage).
   * Ensure `await` on **write** completion before navigation.
   * Ensure **read** happens before creating/using the HTTP client for `/user`.
   * Centralize token access in an `AuthRepository`/`AuthService` used by the `AuthViewModel`.

4. **HTTP Client / Interceptors:**

   * Find the client (`Dio`/`http`) and its setup (e.g., `api_client.dart`, `dio_client.dart`).
   * Guarantee a single, shared instance injects `Authorization: Bearer <token>` on **every** request.
   * Add an `AuthInterceptor` that:

     * Reads token from the centralized source (in-memory cache updated after login).
     * Sets `Authorization` exactly as `Bearer <token>`.
     * Never logs the token value (security).
   * Reinitialize or update the client **after** token is stored so the very first `/user` call has the header.

5. **Route & Config Verification:**

   * Cross-check `/docs` for the **exact** `/user` path and requirements (e.g., `/api/user` vs `/user`).
   * Confirm base URL and environment config matches backend expectations (prod/staging).
   * Ensure no trailing slash or wrong scheme/host mismatch.

6. **Race Condition Guard:**

   * In the ViewModel for the post-login transition, block navigation to Home (or defer initial fetch) until:

     * Token is stored,
     * In-memory cache is updated,
     * HTTP client confirms header injection is active.
   * Expose an `authReady` flag and only then trigger `fetchUser()`.

7. **Minimal Logging (no secrets):**

   * Add temporary debug logs (info level) around:

     * Token **presence** (boolean only, never print token),
     * Header **attached** (boolean),
     * Target URL and HTTP status for `/user`.
   * Use existing logger (`utils/logger/logger_app_logger_impl.dart`).

8. **Implement the Fix:**

   * Patch only the files directly involved:

     * `view/auth/auth_webview.dart` (token capture/bridge)
     * `data/auth/auth_repository.dart` (or equivalent)
     * `core/network/dio_client.dart` / `data/remote/api_client.dart` (interceptor)
     * `presentation/auth/auth_view_model.dart` (authReady gating)
     * `core/config/env.dart` / config files (baseUrl/path if needed)

9. **Lightweight Tests (static authoring only):**

   * Add unit tests for:

     * Token sanitization function (quotes/whitespace cases).
     * Interceptor attaches `Authorization: Bearer <token>`.
     * ViewModel blocks `/user` call until `authReady == true`.

10. **Deliverables:**

    * **Diagnosis report** (short, in English): root cause, how it produced the 500, and why it only happens after login.
    * **Changeset summary**: files touched and rationale per file.
    * **Patch/diff** with only the necessary code (no boilerplate, no unrelated refactors).
    * **Commit message** (conventional): `fix(auth): ensure token extraction and header injection before /user fetch`
    * **Verification steps (manual)** without running the app: describe what the logs will show and which code paths now guarantee header presence before `/user`.

---

## Acceptance Criteria (Definition of Done)

* `auth_token` is correctly extracted, sanitized, persisted, and cached in memory.
* HTTP client uses a single source of truth and **always** sends `Authorization: Bearer <token>` to `/user`.
* First request to `/user` after login is made **only after** `authReady` is true.
* Base URL and `/user` path match `/docs`; no accidental `/api` mismatch.
* No sensitive data (token) is logged; only booleans/metadata.
* Unit tests cover token sanitization and interceptor behavior.
* The diagnosis clearly explains the previous failure mode and why the fix prevents it.

---

## Guardrails

* Do not change UI or navigation flows beyond the minimal gating for `authReady`.
* Do not introduce new packages unless strictly necessary.
* Keep diffs tight and idiomatic (Clean Architecture/MVVM, SRP, small functions).
* Prefer small pure functions (e.g., `sanitizeToken(String raw)`), tested in isolation.

---

**Now proceed:**

1. Perform the static analysis,
2. Produce the diagnosis,
3. Implement the minimal fix (diffs),
4. Provide the tests and the final verification checklist.
