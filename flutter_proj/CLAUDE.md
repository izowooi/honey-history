# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A Flutter application called "Honey History" that presents daily historical events. The app displays different historical events based on the current date, with features including audio playback, YouTube video integration, and Firebase push notifications.

## Key Architecture Components

### Database Layer (Drift/SQLite)
- **Database**: `lib/db/app_database.dart` - Uses Drift ORM with SQLite backend
- **Table Schema**: `HistoryEvents` table with fields: id (MM-dd format), title, year, simple, detail, youtube_url
- **Initialization**: Pre-built SQLite database copied from `assets/data/history_events.sqlite` on first launch
- **Data Provider**: `lib/providers/historical_event_provider.dart` manages date-based event queries

### State Management (Riverpod)
- **Provider Pattern**: Uses flutter_riverpod for state management
- **Key Providers**:
  - `selectedDateProvider`: Current date selection
  - `driftDbProvider`: Database singleton instance
  - `historicalEventProvider`: Fetches events by date
  - `audioProvider`: Manages audio playback state
  - `settingsProvider`: App configuration settings

### Audio System
- **Streaming Architecture**: Audio files streamed from remote URLs (pattern: `https://honeyhistory.zowoo.uk/audio/{MMDD}.mp3`)
- **Caching**: Files cached locally in temp directory after first download
- **Provider**: `lib/providers/audio_provider.dart` handles playback and caching
- **Bulk Download**: `lib/providers/bulk_audio_download_provider.dart` for WiFi-based batch downloading

### Firebase Integration
- **Push Notifications**: Topic-based notifications via Firebase Messaging
- **Remote Config**: Feature flags and configuration management
- **Service**: `lib/services/push_notification_service.dart`

## Common Development Commands

### Dependencies and Setup
```bash
# Install dependencies
flutter pub get

# Generate code (for Drift database changes)
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run

# Run on specific device
flutter run -d <device_id>
```

### Build Commands
```bash
# Android release build (AAB for Play Store)
flutter build appbundle --release

# iOS release build
flutter build ios --release

# Clean build files
flutter clean
```

### iOS-Specific Commands
```bash
# Clean and reinstall CocoaPods (for iOS build issues)
cd ios
rm -rf Pods Podfile.lock
pod repo update
pod install
cd ..
flutter clean
flutter pub get
```

### App Icon Generation
```bash
# Generate app icons (configured in pubspec.yaml)
dart run flutter_launcher_icons
```

### Linting and Analysis
```bash
# Run static analysis
flutter analyze

# Run tests
flutter test
```

## Development Guidelines

### Database Schema Changes
1. Modify table definition in `lib/db/app_database.dart`
2. Run code generation: `dart run build_runner build --delete-conflicting-outputs`
3. Update schema version and migration strategy if needed
4. Test with fresh database install

### Audio File Management
- Audio files are fetched on-demand from remote server
- Format: `https://honeyhistory.zowoo.uk/audio/{MMDD}.mp3` where MMDD is zero-padded month-day (e.g., 0815 for August 15)
- Local caching in temporary directory prevents re-downloading
- Bulk download feature available for WiFi connections

### Date-Based Content
- Events identified by MM-dd format (e.g., "07-15" for July 15)
- Images located at `assets/illustration/{MMDD}.webp`
- Date formatting handled by `DateFormat('MM-dd')` from intl package

### Firebase Configuration
- Android: `android/app/google-services.json`
- iOS: Configuration in `ios/Runner/GoogleService-Info.plist`
- Push notification topics: Subscribe to "history" topic for daily notifications

### Asset Management
- Historical event data seeded from `assets/data/history_events.sqlite`
- Illustrations in `assets/illustration/` with {MMDD}.webp naming
- JSON fallback data in `lib/historical_events.json`

## Project Structure Notes

### Key Directories
- `lib/db/`: Database layer and models
- `lib/providers/`: Riverpod state management
- `lib/widgets/`: Reusable UI components  
- `lib/services/`: Platform services (notifications, etc.)
- `assets/data/`: Static data files and pre-built database
- `assets/illustration/`: Historical event illustrations

### Important Files
- `lib/main.dart`: App entry point with database initialization
- `lib/widget/daily_calendar_widget.dart`: Main UI screen
- `pubspec.yaml`: Dependencies including Drift, Firebase, audio packages
- `analysis_options.yaml`: Lint rules (uses flutter_lints standard)

### Data Flow
1. App launches → Copy pre-built SQLite DB if first run
2. User selects/views date → Query HistoryEvents table by MM-dd ID  
3. UI displays event data, loads illustration, enables audio playback
4. Audio streams from remote URL with local caching
5. YouTube videos displayed via youtube_player_flutter widget

## Build Configuration

### Version Management
- Current version: 1.0.1+20 (semantic versioning + build number)
- iOS deployment target: iOS 12.0+
- Android minSdkVersion: 21 (Android 5.0+)

### Platform-Specific Notes
- iOS: App icons generated automatically, requires proper provisioning profiles
- Android: Uses adaptive icons, requires keystore for release signing
- Push notifications require platform-specific setup and permissions