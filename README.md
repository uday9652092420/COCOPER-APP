# COCOPER Operations

Production-oriented Flutter client for COCOS India Pvt. Ltd. It supports phone
and tablet layouts and intentionally contains **transaction and report features
only**. Customer, supplier, item, branch, warehouse, user, role and other
masters are read from the backend; there are no master/setup/configuration
screens in this app.

## Included transactions

- Purchase Order
- Purchase Invoice
- Sales
- Loading & Dispatch
- Customer Receipt
- Supplier Payment
- Cash & Bank Expense
- Labour Payment
- Bag Purchase

## Included reports

- Purchase Register
- Sales Register
- Supplier Statement
- Customer Statement
- Labour Attendance
- Pending Dispatch
- Outstanding
- Profit & Loss

## Architecture

The implementation follows MVC + GetX with repository and service boundaries:

```text
View (GetView + Obx)
  -> Controller (GetxController)
    -> Repository
      -> ApiService (Dio)
        -> REST backend
```

Feature bindings own controller creation and app-level bindings own repositories
and session context. Views do not call repositories or the network directly.
See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) and
[docs/API_CONTRACT.md](docs/API_CONTRACT.md).

## Run locally

Requirements: Flutter stable, Dart 3.5+, Android Studio/Xcode as appropriate.

```bash
flutter pub get
flutter run --dart-define-from-file=env/development.json
```

The development profile uses deterministic demo responses so the full UI can be
reviewed without a backend. Staging and production profiles are configured for
real REST services:

```bash
flutter run --dart-define-from-file=env/staging.json
flutter build appbundle --release \
  --dart-define-from-file=env/production.json \
  --obfuscate \
  --split-debug-info=build/symbols/android
```

For iOS, use `flutter build ipa` with the same production defines and configure
the distribution team/profile in Xcode.

## Backend integration

1. Update base URLs in `env/*.json`.
2. Store access and refresh tokens through `SecureStorageHelper` after the host
   authentication flow completes.
3. Match payloads and envelopes documented in `docs/API_CONTRACT.md`.
4. Keep server-generated IDs and `X-Idempotency-Key` handling enabled.
5. Replace demo session hydration in `ShellController` with the authenticated
   `/me` response while retaining server-provided role and branch restrictions.

## Offline, caching and performance

- Short-lived encrypted Hive caches for transactions, reports and lookups.
- Encrypted local drafts and a FIFO mutation queue.
- Automatic sync on connectivity recovery with idempotency keys.
- Cached data is used when the backend is temporarily unavailable.
- Debounced transaction search and paginated backend contract.
- Responsive one/two/three-column layouts without separate phone/tablet code.
- Lazy GetX bindings and reactive updates scoped to changing UI regions.
- Tokens are held in platform secure storage, never SharedPreferences.

## Quality checks

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

CI runs the same checks for every push and pull request. Before a client release,
complete [docs/RELEASE_CHECKLIST.md](docs/RELEASE_CHECKLIST.md), provide Android
and Apple signing material outside source control, and run backend contract tests.

## Localization

All application labels are translated using GetX keys in English, Hindi, Telugu,
Tamil and Kannada. Backend business data (party names, invoice IDs and free-text
descriptions) is displayed as received.

## Security notes

- Never commit `android/key.properties`, keystores, provisioning profiles,
  certificates, production tokens or API secrets.
- TLS certificate pinning can be added in `ApiService` once the production API
  hostname and certificate rotation policy are finalized.
- Server-side authorization remains mandatory; hiding a module in the app is not
  an authorization boundary.
