import 'app_enums.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    required this.plan,
    this.organizationId,
    this.emailVerified = false,
  });

  final String id;
  final String email;
  final String displayName;
  final UserRole role;
  final SubscriptionPlan plan;
  final String? organizationId;
  final bool emailVerified;

  AppUser copyWith({
    String? id,
    String? email,
    String? displayName,
    UserRole? role,
    SubscriptionPlan? plan,
    String? organizationId,
    bool? emailVerified,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      plan: plan ?? this.plan,
      organizationId: organizationId ?? this.organizationId,
      emailVerified: emailVerified ?? this.emailVerified,
    );
  }
}
