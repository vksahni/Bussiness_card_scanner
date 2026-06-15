# CardSync AI

Enterprise-ready Flutter Android application scaffold for scanning business cards, extracting details with OCR, storing records locally, and syncing premium/company data to cloud services and Google Sheets.

## What is implemented

- Flutter Android app with Riverpod, GoRouter, Material 3, light/dark theme
- Email/password auth, Google Sign-In wiring, password reset, session stream
- Offline-first SQLite storage for business card records
- Camera capture flow with manual crop handoff
- ML Kit OCR parsing into structured business-card fields
- QR payload capture using `mobile_scanner`
- OCR review/edit screen with confidence score
- In-app spreadsheet viewer using Syncfusion DataGrid
- Subscription service wrapper for RevenueCat / Play Billing rollout
- Company dashboard, employee management, profile, settings, onboarding
- Firebase bootstrap fallback so the app still runs locally before live config is added
- Firestore/storage rule templates and deployment guide

## Structure

```text
lib/
├── core/
├── config/
├── database/
├── features/
├── models/
├── providers/
└── services/
```

## Required live setup

1. Firebase
   - Add `google-services.json` to `android/app/`
   - Enable Authentication, Firestore, Storage
   - Create collections for `cardRecords`, `organizations`, `users`
2. Google Sign-In
   - Configure OAuth client IDs in Firebase and Google Cloud
3. Google Sheets sync
   - Add OAuth consent and Android client
   - Request Sheets + Drive scopes before append/update/delete operations
4. RevenueCat
   - Create entitlements `pro` and `company`
   - Inject your Android public SDK key
5. Syncfusion
   - Register your license key in `main()` if your license requires it

## Run

```bash
flutter pub get
flutter run
```

## Notes

- No sample business-card image was present in the workspace, so OCR testing uses live captures instead of a bundled reference image.
- Full automatic edge detection and perspective correction are the remaining camera-specific enhancements that should be completed with a dedicated native/OpenCV pipeline if you need strict production OCR framing.
- SQLite is implemented with `sqflite`; if you need hard database-at-rest encryption, swap this layer to SQLCipher or field-level encryption before store release.

See [docs/setup.md](docs/setup.md) for the deployment checklist.
