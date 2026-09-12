# nuvra — Flutter MVP (Madiwala Pilot)

Safety-first marketplace connecting people who have a **need** with people who have **time**.
Tasks · Company · Offers — paid, free, treat, expenses-covered, barter.

Built from the nuvra project blueprint. UI adapted from the travel-app reference
(pale canvas, rounded cards, mint/lavender gradients, ink pill CTAs).

---

## Quick start

```bash
cd time_need_app
flutter create . --platforms=android --org com.timeneed --project-name time_need
flutter pub get
flutter run
```

> `flutter create .` generates the android/ios runner folders around this source tree
> (safe: it does not overwrite existing lib/ or pubspec.yaml).
> Demo OTP is **424242**. Seeded Madiwala feed loads immediately after signup.

## Stack (2026 standards)

| Layer | Choice | Notes |
|---|---|---|
| Framework | Flutter 3.47 · Material 3 | Impeller default renderer |
| State | Riverpod 3 (Notifier API) | Single `storeProvider` bridging mock backend |
| Navigation | go_router 14 | Shell route for bottom nav, deep links ready |
| Time/Intl | intl | Kolkata time formatting |
| Backend (Stage 2) | Django 6 + DRF | Contracts in `lib/data/repositories.dart` |
| Realtime (Stage 3) | Centrifugo | Polling first — see blueprint §15 |

## Architecture

```
lib/
├── main.dart               # entry, ProviderScope
├── app_router.dart         # go_router, auth redirects
├── app_shell.dart          # bottom nav (Home·Discover·+·Activity·Messages)
├── core/
│   ├── models/             # Member, Task, enums (mirror Django schema)
│   └── theme/              # tokens + component themes
├── data/
│   ├── mock_backend.dart   # in-memory Madiwala seeds + use-cases
│   └── repositories.dart   # Stage-2 API contracts
├── state/
│   └── providers.dart      # Riverpod store
└── ui/
    ├── widgets/            # SoftCard, PrimaryButton, chips, TaskCard…
    └── screens/            # 19 screens (see below)
```

**Swap rule:** UI only talks to `MockBackend` through the store provider.
Stage 2 = implement `repositories.dart` against Django, replace the store's
backend instance. Zero screen changes.

## Screens (19)

| Flow | Screens |
|---|---|
| Onboarding | Splash · Email · OTP (demo 424242) · Intent + 18+ gate · Profile setup · Welcome |
| Core tabs | Home (Free-Now hero) · Discover (filters) · Activity · Messages |
| Task | Task detail · Create wizard (4-step, safety review) · Session (check-in/SOS) · Completion + rating |
| Chat | Applicant room (private, safety strip, select/decline) · Messages list |
| Misc | Profile (trust ladder) · Settings · Safety Center · Notifications · Report |

## Safety features in this build

- 18+ gate at intent step (self-declared; policy in Email screen + ToS slot)
- Email-OTP only — no phone number collected
- Risk tiers (low/med/high) auto-computed (night/private → high)
- Check-in timeline on risky tasks ("I'm safe")
- SOS sheet: 112 call · opt-in location share · trusted contact
- Safety strip in every chat: no OTP/PIN/UPI talk
- Report flow with 8 reasons → moderation queue
- Exchange-mode honesty: "platform holds no funds" noted at creation + safety tips

## Known MVP simplifications

- Mock backend (in-memory; resets on restart)
- Demo OTP 424242, no real email yet
- No images/media — emoji avatars
- Polling chat (no WebSocket yet)
- No localization (English only), no dark mode

## Stage 2 swap list

1. `AuthRepository` → `/api/auth/otp/request`, `/verify`, `/profile`
2. `TaskRepository` → `/api/tasks` CRUD + feed query params
3. `ApplicationRepository` → `/api/applications` (+ server-side selection in transaction)
4. `ChatRepository` → `/api/rooms/{id}/messages` (poll → Centrifugo subscribe)
5. `SafetyRepository` → `/api/reports`, `/api/safety/checkin`, `/api/safety/sos`
6. Real OTP email via Brevo/Resend; SPF/DKIM/DMARC DNS records
