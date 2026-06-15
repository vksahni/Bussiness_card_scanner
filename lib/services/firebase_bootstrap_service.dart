import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseBootstrapState {
  const FirebaseBootstrapState({
    required this.isReady,
    required this.message,
  });

  final bool isReady;
  final String message;
}

class FirebaseBootstrapService {
  Future<FirebaseBootstrapState> initialize() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      return const FirebaseBootstrapState(
        isReady: true,
        message: 'Firebase connected.',
      );
    } catch (error) {
      debugPrint('Firebase init skipped: $error');
      return FirebaseBootstrapState(
        isReady: false,
        message: 'Firebase not configured yet. The app still runs in local-first mode.',
      );
    }
  }
}
