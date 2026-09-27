# Akwaba Ivoire – mobile app

Flutter app for European travellers discovering Côte d'Ivoire: destinations,
bookings with Stripe payment, local guides on WhatsApp, verified reviews,
practical travel information, in French, English and German.

Backend: [tourismBE](https://github.com/giss1408/tourismBE).

## Run

Two Android flavors:

| Flavor | Application id | Backend |
| --- | --- | --- |
| `dev` | `com.regisse.tourism` | `config/dev.json` (local backend) |
| `prod` | `com.akwabaivoire.app` | `config/prod.json` (production API) |

```sh
# Phone over USB, backend running on this machine (tourismBE: make run)
adb reverse tcp:8000 tcp:8000
flutter run --flavor dev --dart-define-from-file=config/dev.json
```

Debug builds prefill the login with the backend's seeded test account
(`test@example.com` / `Test1234!`). Without a backend, omit the
`--dart-define-from-file` to use the built-in demo data. VS Code launch
configurations for each case are in `.vscode/launch.json`.

## Test

```sh
flutter analyze
flutter test        # every test must finish within 10 s (dart_test.yaml)
```

CI (`.github/workflows/ci.yml`) runs both and builds the dev APK.

## Release (Google Play)

1. **Firebase**: register the Android app `com.akwabaivoire.app` in the
   Firebase project, download its `google-services.json` to
   `android/app/src/prod/google-services.json`, and add the release SHA-1 for
   Google sign-in.
2. **Signing**: create an upload key and `android/key.properties` (see
   `android/key.properties.example`; both stay out of git).
3. **Build**:
   ```sh
   flutter build appbundle --flavor prod --dart-define-from-file=config/prod.json
   ```
4. **Store listing** texts (FR/EN/DE) are in `store_listing/`. The privacy
   policy URL is `https://<API_DOMAIN>/legal/privacy/`.

iOS: flavors are Android-only for now; add Xcode schemes before the App Store
release.

## Features and where they live

| Feature | Code |
| --- | --- |
| Operator settings (fees, cancellation, contacts, legal links) | `providers/app_settings_provider.dart` |
| Stripe payment sheet (card, PayPal, Apple/Google Pay) | `services/payment_service.dart` |
| Push notifications | `services/push_service.dart` |
| Reviews, guides, WhatsApp | `screens/destination_detail/` |
| GDPR: statistics consent, account deletion, legal pages | `providers/consent_provider.dart`, `screens/profile/` |
| Offline catalogue | `providers/destination_provider.dart` |
| Prices in EUR + FCFA, localized dates | `utils/money.dart`, `utils/dates.dart` |
| Icon and splash (regenerate from `assets/branding/`) | `dart run flutter_launcher_icons`, `dart run flutter_native_splash:create` |
