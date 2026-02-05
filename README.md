# TODO App

A Flutter todo application built with clean architecture principles. This project focuses on proper app architecture, offline support, and production-ready code practices.

## Why I Built This

I wanted to build something that goes beyond basic tutorials - focusing on how real apps are structured in production. The UI is intentionally simple because the goal here is architecture, not design.

## What's Inside

The app is organized into clear layers:

```
lib/
├── config/          # Environment settings
├── core/            # Utilities, error handling, security
├── data/            # Everything data-related
│   ├── models/      
│   ├── local/       # SQLite database
│   ├── remote/      # API calls
│   └── repositories/
├── providers/       # State management
└── presentation/    # UI stuff
    ├── screens/
    └── widgets/
```

I'm using:
- **Provider** for state management (simpler than Bloc for this scope)
- **SQLite** for local storage
- **Repository pattern** to handle online/offline data
- **Multiple app flavors** (dev, staging, qa, production)

The API is JSONPlaceholder since this is a demo, but the architecture supports any REST API.

## Key Features

**Offline Mode**  
The app works completely offline. Changes are saved locally and synced when you're back online. No data loss.

**Multiple Environments**  
Four flavors set up - each with its own API endpoint and configs. Run them with `--dart-define=FLAVOR=dev` (or staging, qa, production).

**Security**  
Production builds check for rooted/jailbroken devices. Development builds skip this so you can test on emulators.

**Error Recovery**  
Instead of crashing to a blank screen, the app shows a recovery page and preserves your data.

**State Management**  
Using optimistic updates - the UI responds instantly, then syncs in the background. If something fails, it rolls back automatically.

## Getting Started

You'll need Flutter installed (3.9.2+). Then:

```bash
git clone <repo-url>
cd TODO-App
flutter pub get
flutter run --dart-define=FLAVOR=dev
```

## Building Releases

For Android:
```bash
flutter build apk --dart-define=FLAVOR=production --release
```

For iOS:
```bash
flutter build ios --dart-define=FLAVOR=production --release
```

The built APKs end up in `build/app/outputs/flutter-apk/`.

## Environment Setup

Each flavor loads its own `.env` file:
- `.env.dev` → Development
- `.env.staging` → Staging  
- `.env.qa` → QA
- `.env.prod` → Production

Change API URLs, app names, or logging settings there.

## How It Works

**Data Flow:**  
User action → Provider → Repository (checks if online) → API or Database → Update UI

**Offline Sync:**  
Todos have a sync status (0=synced, 1=needs create, 2=needs update, 3=needs delete). When you're offline, changes get marked. Pull to refresh when online pushes everything to the server.

**Security:**  
On production builds, the app checks if the device is jailbroken/rooted before loading. Development/staging skips this.

## Project Structure

**TodoProvider** handles all state. It uses optimistic updates - shows changes immediately, then confirms with the backend.

**TodoRepository** decides whether to hit the API or use local data. It also handles syncing pending changes.

The **DatabaseService** manages SQLite operations. The **TodoApiService** handles HTTP requests.

## Testing

```bash
flutter test
```

Currently has model tests. Repository and provider layers are structured to be testable with mocks.

## Common Issues

**Can't find .env files**  
Make sure all four .env files are in the project root.

**App won't install**  
Uninstall the old version first if you're switching between flavors.

**Security check blocking app**  
Only runs in production flavor. Use dev/staging for testing on emulators.

## What's Next

Things I'd add if this was a real app:
- User authentication
- Cloud sync (Firebase or custom backend)
- Categories and tags
- Reminders
- Dark mode
- Better UI design

## Notes

This project is about architecture, not UI. The interface is basic on purpose - the focus is on how the code is organized and how data flows through the app.

## Documentation

More detailed docs in the `docs/` folder:
- Architecture breakdown
- Implementation details
- How everything works under the hood

---

Built with Flutter. Feel free to use this as a reference for your own projects.
