# CardSync AI Setup Guide

## 1. Firebase

1. Create a Firebase project.
2. Add an Android app with package name `com.cardsyncai.bussiness_card_scanner`.
3. Download `google-services.json` into `android/app/`.
4. Enable:
   - Email/Password auth
   - Google auth
   - Firestore
   - Storage
5. Deploy the included security rules after reviewing them.

## 2. RevenueCat

1. Create products for monthly, yearly, and company plans.
2. Create entitlements:
   - `pro`
   - `company`
3. Provide the Android public SDK key to `SubscriptionService.initialize`.

## 3. Google Sheets and Drive API

1. Open Google Cloud Console.
2. Enable:
   - Google Sheets API
   - Google Drive API
3. Configure OAuth consent screen.
4. Create an Android OAuth client.
5. Request scopes for:
   - `https://www.googleapis.com/auth/spreadsheets`
   - `https://www.googleapis.com/auth/drive.file`

## 4. Android release

1. Replace debug signing with release signing in `android/app/build.gradle.kts`.
2. Set Play Billing and RevenueCat product identifiers.
3. Add privacy policy and data safety disclosures for:
   - Camera
   - Cloud sync
   - OCR text processing
   - Google account connection

## 5. Production hardening

1. Replace demo company/account derivation logic in `AuthService`.
2. Add background workers for deferred cloud/sheets sync.
3. Add duplicate detection before insert based on normalized name + email + phone.
4. Replace local-only fallback analytics with real Firestore aggregation or backend endpoints.
5. Introduce SQLCipher or encrypted field storage if at-rest DB encryption is mandatory.
