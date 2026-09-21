# Architecture

## Scope boundary

COCOPER is a role-aware transaction and reporting client. It consumes master
data through read-only lookup endpoints. It has no UI route, controller or
repository for creating or modifying master/setup/configuration data.

## Layers

```text
lib/app/
├── bindings/       GetX dependency ownership per route
├── config/         compile-time environment and constants
├── controllers/    reactive screen state and workflows
├── helpers/        storage, validation, caching and date utilities
├── localization/   one translation map per supported language
├── models/         typed transport/domain models
├── repositories/   data-source policy, cache and demo adapters
├── routes/         named route table and URL builders
├── services/       Dio, endpoints, exceptions and offline sync
├── theme/          Material 3 brand tokens
├── views/          phone/tablet presentation
└── widgets/        reusable presentation components
```

### Dependency rule

- Views depend on their GetX controller and presentation widgets.
- Controllers depend on typed models and repositories.
- Repositories depend on `ApiService`, cache helpers and models.
- `ApiService` is the only REST gateway and owns Dio configuration.
- No lower layer imports a view or route.

## Runtime flows

### Read

1. A route binding creates the controller.
2. The controller requests a typed result from its repository.
3. The repository returns a fresh encrypted cache entry when available.
4. Otherwise it fetches through Dio and updates the cache.
5. On a network error, a stale cache entry is returned when available.
6. The controller publishes loading/data/error with GetX observables.

### Transaction write

1. The controller validates the active step and builds a typed create request.
2. The repository submits it to the backend.
3. If connectivity fails, the payload is encrypted and queued locally.
4. The UI receives a local pending record immediately.
5. Connectivity recovery triggers ordered queue replay.
6. Every replay sends `X-Idempotency-Key`; the server must return the original
   outcome for a repeated key.
7. Validation failures stay queued for reconciliation and are never discarded.

## State and lifecycle

- `AppBinding`: session controller and repositories for app lifetime.
- Route bindings: catalog, list, form, detail and report controllers.
- `Obx`: rebuilds only regions driven by `Rx` state.
- Drafts: one encrypted draft per transaction type, restored on route creation.
- Session: role and branch come from the authenticated server context.

## Responsive behavior

- Under 840 logical pixels: touch-first single-column content and bottom
  navigation.
- From 840 pixels: persistent navigation rail, multi-column cards and form review
  beside the active step.
- From 1120 pixels: extended navigation and constrained content widths.
- The shell owns navigation placement, so page content scrolls independently and
  never pushes or pins the footer in the middle of a screen.

## Security

- Access/refresh tokens: platform secure storage.
- Language and non-sensitive preferences: SharedPreferences.
- Cached business data, drafts and pending payloads: AES-encrypted Hive boxes.
- Logging: no request/response bodies; debug-only metadata outside production.
- Authentication refresh: one retry maximum, then secure session clearing.
- Authorization: enforced by backend on every branch-scoped endpoint.

## Extending a feature

1. Add or extend the typed model.
2. Add endpoint constants in `EndPoints`.
3. Add repository behavior and cache policy.
4. Add controller state/actions.
5. Register a binding and named route.
6. Add a responsive view using translated keys.
7. Add unit, controller and widget tests.
