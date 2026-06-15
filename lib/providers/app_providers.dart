import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import '../config/app_router.dart';
import '../database/app_database.dart';
import '../models/app_user.dart';
import '../models/business_card_record.dart';
import '../models/organization.dart';
import '../services/auth_service.dart';
import '../services/card_repository.dart';
import '../services/firebase_bootstrap_service.dart';
import '../services/google_sheets_service.dart';
import '../services/ocr_parser_service.dart';
import '../services/secure_storage_service.dart';
import '../services/subscription_service.dart';

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void update(ThemeMode mode) => state = mode;
}

final routerProvider = Provider<GoRouter>((ref) => AppRouter.buildRouter(ref));

final firebaseBootstrapProvider = FutureProvider<FirebaseBootstrapState>((ref) async {
  return FirebaseBootstrapService().initialize();
});

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return const SecureStorageService(FlutterSecureStorage());
});

final appDatabaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

final authServiceProvider = Provider<AuthService>((ref) {
  final bootstrap = ref.watch(firebaseBootstrapProvider).asData?.value;
  final firebaseAuth = bootstrap?.isReady == true ? FirebaseAuth.instance : null;
  return AuthService(firebaseAuth);
});

final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges();
});

final currentUserProvider = Provider<AppUser?>((ref) {
  return ref.watch(authStateProvider).asData?.value;
});

final cardRepositoryProvider = Provider<CardRepository>((ref) {
  final bootstrap = ref.watch(firebaseBootstrapProvider).asData?.value;
  return CardRepository(
    database: ref.watch(appDatabaseProvider),
    firestoreInstance: bootstrap?.isReady == true ? FirebaseFirestore.instance : null,
  );
});

final cardsProvider = AsyncNotifierProvider<CardsNotifier, List<BusinessCardRecord>>(CardsNotifier.new);

class CardsNotifier extends AsyncNotifier<List<BusinessCardRecord>> {
  @override
  Future<List<BusinessCardRecord>> build() async {
    return ref.read(cardRepositoryProvider).fetchAll();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await ref.read(cardRepositoryProvider).fetchAll());
  }

  Future<void> save(BusinessCardRecord record, {bool sync = true}) async {
    await ref.read(cardRepositoryProvider).save(record);
    if (sync) {
      await ref.read(cardRepositoryProvider).syncRecord(record);
    }
    await refresh();
  }

  Future<void> delete(String id) async {
    await ref.read(cardRepositoryProvider).delete(id);
    await refresh();
  }
}

final subscriptionServiceProvider = Provider<SubscriptionService>((ref) => SubscriptionService());
final subscriptionProvider = FutureProvider<SubscriptionState>((ref) async {
  return ref.watch(subscriptionServiceProvider).loadState();
});

final sheetsServiceProvider = Provider<GoogleSheetsService>((ref) => const GoogleSheetsService());
final ocrParserProvider = Provider<OcrParserService>((ref) {
  final service = OcrParserService();
  ref.onDispose(service.dispose);
  return service;
});

final organizationsProvider = Provider<List<Organization>>((ref) {
  return const [
    Organization(
      id: 'org-demo',
      name: 'CardSync Enterprise',
      adminEmail: 'admin@company.com',
      employeeCount: 18,
      sharedSheetId: 'team-pipeline-sheet',
      totalScans: 1438,
    ),
  ];
});
