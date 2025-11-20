# duplicate_building_solution

Internal tool for managing parties, projects, files, and measurement records.
The app now ships with a full offline-first experience, so users can work
without connectivity and automatically sync changes when they come back online.

## Offline-first workflow

1. **Local cache** – All parties, projects, files, and records are cached in an
   encrypted SQLite database located in the app’s documents directory.
2. **Pending queue** – Any mutation executed while offline (or while Firestore
   calls fail) is queued with its payload so we can retry it later.
3. **Auto-sync** – `OfflineSyncService` listens to connectivity changes. As soon
   as a network is available it drains the queue, retries failed operations up
   to five times, and updates the cache so the UI reflects the latest sync
   state.
4. **UI feedback** – Every list screen shows cached data immediately and
   displays a thin banner that reports connectivity/sync status plus per-row
   “Pending sync” badges for unsent changes.

## Running the app

```bash
flutter pub get
flutter run
```

## Testing

```bash
flutter test
```

Tests currently cover the offline JSON codec that powers the cache layer. Add
more tests alongside any new offline-aware repositories or widgets you touch.

## Troubleshooting

- **Stuck in “Pending sync”** – Make sure the device has a network connection.
  After five failed attempts an operation is marked as failed; relaunching the
  app or re-submitting the entity will re-queue it.
- **Cache not updating** – Confirm `OfflineSyncService.initialize()` is called
  before `runApp()` (it is wired up in `main.dart`). If you add new entry
  points, make sure they also wait for initialization.
- **Local DB inspection** – The SQLite file lives in the app documents folder
  (`offline_cache.db`). Use `sqflite` dev tools or a desktop build to inspect it
  when debugging.
