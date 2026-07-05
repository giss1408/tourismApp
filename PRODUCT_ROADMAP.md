# Tourism App Product & UX Roadmap

## Priority Features

1. Smart search and filters
- Multi-filter search by budget, duration, climate, family-friendly, and visa-free options.
- Sorting by popularity, rating, and price.

2. Real backend data and caching
- Replace sample data with Firestore/REST-backed content.
- Add offline cache and pull-to-refresh.

3. Destination personalization
- Recommendations based on behavior: recently viewed destinations, preferred categories, and budget.

4. Favorites and collections
- Save favorites.
- Organize destinations into custom collections (for example: Summer 2026, Honeymoon, Family).

5. Full booking flow
- Dates, guests, add-ons, cancellation policy, payment simulation, and confirmation with invoice reference.

6. Map-first exploration
- Interactive exploration with destination pins and quick detail actions.

7. Trust layer
- Verified reviews, safety indicators, and accessibility-friendly metadata.

8. Localization depth
- Regional currency, date formats, units, and content ranking by locale.

9. Performance and media polish
- Image placeholders, prefetching, responsive image sizing, and smoother transitions.

10. Notifications and lifecycle
- Price-drop alerts, reminder notifications, and itinerary milestones.

11. User metrics and analytics
- Instrument product events across discovery, booking, and retention funnels.
- Track activation, engagement, conversion, and retention KPIs by locale and acquisition source.
- Add dashboard-ready definitions for DAU/WAU/MAU, booking conversion, drop-off steps, and repeat-booking rate.

## Implemented In This Iteration

- Advanced filter/sort UX
- Favorites + saved collections
- Map exploration screen
- Booking flow (multi-step review and confirmation)

## Pre-Backend Readiness Checks

Use this checklist while backend is pending so product quality keeps moving.

### 1. Product Flow Validation

- Verify core user journeys are complete with mock data:
	- Discover destinations -> filter/sort -> open details
	- Favorite/save into collections -> retrieve later
	- Open map -> inspect pins -> open destination details
	- Create booking -> review -> confirm -> modify/cancel
- Confirm every journey has clear empty states, loading states, and error states.
- Confirm no dead-end screens (every major screen has an obvious next action).

### 2. Contract and Data Boundary Validation

- Verify repository contracts are stable:
	- DestinationRepository
	- BookingRepository
	- AuthRepository
- Verify DTO mapping handles null/missing/malformed payload fields safely.
- Verify GraphQL query option models are present and tested:
	- search/filter
	- sort
	- pagination
- Verify mock repositories emulate server-side behavior for filter/sort/pagination.

### 3. Session and Auth Safety

- Verify unauthorized events trigger local session clear and user-visible re-login message.
- Verify sign-in/sign-out/reset-password states remain consistent across app restart.
- Verify GraphQL mode and Firebase mode both boot correctly through config toggles.

### 4. UX and Accessibility Quality

- Check small-screen overflow risks on auth, booking, and card-heavy pages.
- Validate tap target sizes and keyboard/focus behavior for forms.
- Verify contrast and readability in light and dark themes.
- Verify empty-state copy is actionable and localized where applicable.

### 5. Performance and Resilience

- Verify no unnecessary repeated loads when switching tabs.
- Verify map and image-heavy screens remain responsive on lower-end devices.
- Verify request timeout/retry behavior is user-safe (no infinite spinner loops).
- Verify startup error screen appears with helpful guidance if config is invalid.

### 6. QA Gate Before Backend Integration

- flutter analyze passes for full project.
- flutter test passes for full project.
- Optional GraphQL integration tests can run in CI when endpoint is available.
- Regression checklist executed for:
	- navigation
	- booking state changes
	- favorites/collections persistence
	- auth transitions

### 8. User Metrics Validation

- Verify event schema is documented and versioned (event name, required properties, user/session IDs, timestamp).
- Verify key funnel events are emitted:
	- destination_list_viewed
	- destination_opened
	- booking_started
	- booking_confirmed
	- booking_canceled
	- favorite_added
- Verify user properties are set safely (locale, preferred currency, app version, platform) with privacy controls.
- Verify metric definitions are stable and dashboard-ready:
	- activation rate
	- destination-to-booking conversion
	- booking completion rate
	- D1/D7 retention
	- repeat-booking rate
- Verify analytics failures never block user flows (fire-and-forget, retry with backoff, local queue optional).

### 7. Definition of Ready for Backend Cutover

- Backend schema fields aligned to DTOs and query variables.
- Environment config defined for dev/staging/prod GraphQL endpoints.
- Error codes and unauthorized behavior agreed between frontend and backend.
- Sample production-like fixtures available for smoke testing.
