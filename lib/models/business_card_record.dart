import 'app_enums.dart';

class BusinessCardRecord {
  const BusinessCardRecord({
    required this.id,
    required this.personName,
    required this.companyName,
    required this.designation,
    required this.phoneNumbers,
    required this.email,
    required this.website,
    required this.address,
    required this.qrData,
    required this.socialLinks,
    required this.cardImagePath,
    required this.cardImageUrl,
    required this.userEmail,
    required this.scanDate,
    required this.confidenceScore,
    required this.syncStatus,
    required this.rawOcrText,
  });

  final String id;
  final String personName;
  final String companyName;
  final String designation;
  final List<String> phoneNumbers;
  final String email;
  final String website;
  final String address;
  final String qrData;
  final List<String> socialLinks;
  final String cardImagePath;
  final String cardImageUrl;
  final String userEmail;
  final DateTime scanDate;
  final double confidenceScore;
  final SyncStatus syncStatus;
  final String rawOcrText;

  BusinessCardRecord copyWith({
    String? id,
    String? personName,
    String? companyName,
    String? designation,
    List<String>? phoneNumbers,
    String? email,
    String? website,
    String? address,
    String? qrData,
    List<String>? socialLinks,
    String? cardImagePath,
    String? cardImageUrl,
    String? userEmail,
    DateTime? scanDate,
    double? confidenceScore,
    SyncStatus? syncStatus,
    String? rawOcrText,
  }) {
    return BusinessCardRecord(
      id: id ?? this.id,
      personName: personName ?? this.personName,
      companyName: companyName ?? this.companyName,
      designation: designation ?? this.designation,
      phoneNumbers: phoneNumbers ?? this.phoneNumbers,
      email: email ?? this.email,
      website: website ?? this.website,
      address: address ?? this.address,
      qrData: qrData ?? this.qrData,
      socialLinks: socialLinks ?? this.socialLinks,
      cardImagePath: cardImagePath ?? this.cardImagePath,
      cardImageUrl: cardImageUrl ?? this.cardImageUrl,
      userEmail: userEmail ?? this.userEmail,
      scanDate: scanDate ?? this.scanDate,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      syncStatus: syncStatus ?? this.syncStatus,
      rawOcrText: rawOcrText ?? this.rawOcrText,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'person_name': personName,
      'company_name': companyName,
      'designation': designation,
      'phone_numbers': phoneNumbers.join('|'),
      'email': email,
      'website': website,
      'address': address,
      'qr_data': qrData,
      'social_links': socialLinks.join('|'),
      'card_image_path': cardImagePath,
      'card_image_url': cardImageUrl,
      'user_email': userEmail,
      'scan_date': scanDate.toIso8601String(),
      'confidence_score': confidenceScore,
      'sync_status': syncStatus.name,
      'raw_ocr_text': rawOcrText,
    };
  }

  factory BusinessCardRecord.fromMap(Map<String, Object?> map) {
    return BusinessCardRecord(
      id: map['id'] as String,
      personName: map['person_name'] as String? ?? '',
      companyName: map['company_name'] as String? ?? '',
      designation: map['designation'] as String? ?? '',
      phoneNumbers: ((map['phone_numbers'] as String? ?? '').split('|')..removeWhere((e) => e.isEmpty)),
      email: map['email'] as String? ?? '',
      website: map['website'] as String? ?? '',
      address: map['address'] as String? ?? '',
      qrData: map['qr_data'] as String? ?? '',
      socialLinks: ((map['social_links'] as String? ?? '').split('|')..removeWhere((e) => e.isEmpty)),
      cardImagePath: map['card_image_path'] as String? ?? '',
      cardImageUrl: map['card_image_url'] as String? ?? '',
      userEmail: map['user_email'] as String? ?? '',
      scanDate: DateTime.tryParse(map['scan_date'] as String? ?? '') ?? DateTime.now(),
      confidenceScore: (map['confidence_score'] as num?)?.toDouble() ?? 0,
      syncStatus: SyncStatus.values.firstWhere(
        (value) => value.name == map['sync_status'],
        orElse: () => SyncStatus.localOnly,
      ),
      rawOcrText: map['raw_ocr_text'] as String? ?? '',
    );
  }
}
