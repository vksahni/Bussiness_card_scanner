import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/app_enums.dart';
import '../models/app_user.dart';

class AuthService {
  AuthService(this._firebaseAuth);

  final FirebaseAuth? _firebaseAuth;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final StreamController<AppUser?> _localAuthController = StreamController<AppUser?>.broadcast();
  AppUser? _localUser;
  bool _googleInitialized = false;

  Stream<AppUser?> authStateChanges() {
    final auth = _firebaseAuth;
    if (auth == null) {
      return _localAuthController.stream;
    }
    return auth.authStateChanges().map(_mapUser);
  }

  AppUser? get currentUser {
    final auth = _firebaseAuth;
    return auth == null ? _localUser : _mapUser(auth.currentUser);
  }

  Future<void> initializeGoogle() async {
    if (_googleInitialized) {
      return;
    }
    await _googleSignIn.initialize();
    _googleInitialized = true;
    unawaited(_googleSignIn.attemptLightweightAuthentication());
  }

  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final auth = _firebaseAuth;
    if (auth == null) {
      final user = AppUser(
        id: email,
        email: email,
        displayName: email.split('@').first,
        role: email.endsWith('@company.com') ? UserRole.employee : UserRole.freeUser,
        plan: email.endsWith('@company.com') ? SubscriptionPlan.company : SubscriptionPlan.free,
        organizationId: email.endsWith('@company.com') ? 'org-demo' : null,
        emailVerified: true,
      );
      _localUser = user;
      _localAuthController.add(user);
      return user;
    }
    final credential = await auth.signInWithEmailAndPassword(email: email, password: password);
    return _mapUser(credential.user)!;
  }

  Future<AppUser> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final auth = _firebaseAuth;
    if (auth == null) {
      final user = AppUser(
        id: email,
        email: email,
        displayName: name,
        role: email.endsWith('@company.com') ? UserRole.employee : UserRole.freeUser,
        plan: email.endsWith('@company.com') ? SubscriptionPlan.company : SubscriptionPlan.free,
        organizationId: email.endsWith('@company.com') ? 'org-demo' : null,
        emailVerified: false,
      );
      _localUser = user;
      _localAuthController.add(user);
      return user;
    }
    final credential = await auth.createUserWithEmailAndPassword(email: email, password: password);
    await credential.user?.updateDisplayName(name);
    await credential.user?.sendEmailVerification();
    await credential.user?.reload();
    return _mapUser(auth.currentUser)!;
  }

  Future<AppUser?> signInWithGoogle() async {
    await initializeGoogle();
    final account = await _googleSignIn.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw Exception('Google Sign-In did not return an ID token.');
    }

    final auth = _firebaseAuth;
    if (auth == null) {
      final user = AppUser(
        id: account.email,
        email: account.email,
        displayName: account.displayName ?? account.email.split('@').first,
        role: account.email.endsWith('@company.com') ? UserRole.employee : UserRole.freeUser,
        plan: account.email.endsWith('@company.com') ? SubscriptionPlan.company : SubscriptionPlan.free,
        organizationId: account.email.endsWith('@company.com') ? 'org-demo' : null,
        emailVerified: true,
      );
      _localUser = user;
      _localAuthController.add(user);
      return user;
    }
    final authCredential = GoogleAuthProvider.credential(idToken: idToken);
    final credential = await auth.signInWithCredential(authCredential);
    return _mapUser(credential.user);
  }

  Future<void> sendPasswordReset(String email) async {
    final auth = _firebaseAuth;
    if (auth == null) {
      return;
    }
    await auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    final auth = _firebaseAuth;
    if (auth != null) {
      await auth.signOut();
    } else {
      _localUser = null;
      _localAuthController.add(null);
    }
    try {
      await _googleSignIn.signOut();
    } catch (error) {
      debugPrint('Google sign out skipped: $error');
    }
  }

  AppUser? _mapUser(User? user) {
    if (user == null) {
      return null;
    }
    final email = user.email ?? '';
    final role = email.endsWith('@company.com')
        ? UserRole.employee
        : UserRole.freeUser;
    return AppUser(
      id: user.uid,
      email: email,
      displayName: user.displayName ?? email.split('@').first,
      role: role,
      plan: role == UserRole.employee ? SubscriptionPlan.company : SubscriptionPlan.free,
      organizationId: role == UserRole.employee ? 'org-demo' : null,
      emailVerified: user.emailVerified,
    );
  }
}
