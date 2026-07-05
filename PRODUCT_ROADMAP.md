# Tourism App Product & UX Roadmap

---

## ✅ Completed

### Flutter App
- Advanced filter/sort UX (budget, duration, category, rating, price)
- Favorites + saved collections (LocalStorage-persisted, analytics-instrumented)
- Map exploration screen (flutter_map, destination pins, quick actions)
- Full booking flow (multi-step setup → review → confirm → Trip Details screen with post-booking info)
- Destination personalization (recently viewed, category scoring, budget preference)
- Mock payment methods (add, remove, set default, persisted, localized)
- Request Info flow (bottom-sheet form, prefilled email, analytics payload)
- User metrics and analytics (AnalyticsService abstraction, mock + API transport, event hooks across discovery/booking/favorites funnels)
- Performance and media polish (OptimizedNetworkImage, cache dimension safety, responsive layout helpers, loading skeletons, prefetching)
- Pull-to-refresh on Home and Destinations screens
- Firebase Authentication — email/password sign-in and sign-up
- Firebase Authentication — Google OAuth (real device, requires SHA-1 in Firebase Console)
- Firebase Authentication — profile edit: update display name, change password, email verification banner
- Social sign-in backend sync (HybridAuthRepository → Django `socialSignIn` → JWT returned)
- GraphQL security hardening (HTTPS enforcement, JWT middleware, session lifecycle, token sanitization)
- Full localization — EN / FR / DE for all screens and new features
- LAN Android HTTP policy (`network_security_config.xml` allows `http://192.168.178.148`)
- JSON cache hardening (malformed SharedPreferences payload recovery in all providers)
- PII reduction (removed email/display name/photo from SharedPreferences; only uid marker persisted)
- `flutter analyze` — clean (zero issues)
- Unit + widget test suite — 44 tests

### Django Backend
- Django 4.2 + Graphene-Django GraphQL API
- AppUser model with firebase_uid field for social auth
- Destinations — seeded with 14 entries matching Flutter mock data, filtered/sorted/paginated query
- Bookings — authenticated `upsertBookings` mutation + `bookings` query
- Auth — `signIn`, `signUp`, `signOut`, `resetPassword`, `socialSignIn` mutations with JWT
- Analytics — `trackAnalyticsEvent` + `setAnalyticsUserProperties` mutations
- JWT bearer middleware (per-request auth, log once per root resolver)
- CORS, ALLOWED_HOSTS, LAN IP support
- Django admin for all models
- Seed management commands (`seed_destinations`, `seed_users`, `create_admin`)
- 18 backend tests — all passing
- `.env`-driven config, `Makefile`, `Dockerfile`, `docker-compose.yml`, `.gitignore`

---

## 🔧 In Progress / Partially Done

- **Google Sign-In** — works, but requires registering debug SHA-1 (`79:52:3E:1F:ED:75:30:24:3B:70:BC:40:27:7F:EA:DD:4B:71:A9:73`) in Firebase Console + downloading updated `google-services.json`
- **Facebook Sign-In** — code is in place, shows clear error; needs Facebook App ID registered in `AndroidManifest.xml` + Firebase Console
- **Offline cache** — pull-to-refresh implemented; persistent offline-first cache not yet added
- **Currency / date locale depth** — strings are localized (EN/FR/DE) but prices display as `$` and dates are not yet formatted via `NumberFormat.currency` / `DateFormat`

---

## 🚀 Flutter App — Next Steps

### Auth & Profile
1. Profile photo upload — add `image_picker` + `firebase_storage` once Gradle version conflict is resolved; `updateProfilePhoto` stub is already in `AuthRepository`
2. Account deletion — add Firebase `user.delete()` + backend cleanup mutation

### Data & Offline
3. Persistent offline cache — cache destinations/bookings to `Hive` or `sqflite`; load from cache first, refresh in background
4. Real destination data — replace picsum.photos URLs with actual destination images from a CDN or CMS

### UX & Notifications
5. Push notifications — integrate `firebase_messaging`; implement price-drop and booking-reminder alerts
6. Currency formatting — use `NumberFormat.currency(locale: locale.toString())` for price display
7. Date formatting — use `DateFormat` from `intl` package for check-in/check-out dates

### Trust Layer
8. Destination reviews — add star rating + text review submission flow; display aggregate rating + review count on detail screen

---

## 🚀 Django Backend — Next Steps

### Security & Production
1. Firebase ID token verification — harden `socialSignIn` by verifying the Firebase ID token server-side using `firebase-admin` SDK instead of trusting client-sent uid/email
2. Rate limiting — add `django-ratelimit` or DRF throttling to the `/graphql/` endpoint
3. PostgreSQL — swap SQLite for Postgres; update `.env` with `DATABASE_URL`
4. Production server — replace `runserver` with `gunicorn` behind `nginx`; add SSL termination

### Features
5. Booking status mutations — add `confirmBooking` and `cancelBooking` mutations (currently only `upsertBookings` from the app side)
6. Destination CRUD API — add `createDestination`, `updateDestination`, `deleteDestination` mutations for admin use
7. Analytics query endpoint — add `analyticsEvents(from, to, name)` query for dashboard/BI tools
8. File upload endpoint — add a `uploadFile` mutation or REST endpoint for profile photos and destination images

### DevOps
9. CI pipeline — add GitHub Actions running `python manage.py test apps` + `flutter test` + `flutter analyze` on every push
10. Environment config — define `dev` / `staging` / `prod` GraphQL endpoint configs in `.env` variants

