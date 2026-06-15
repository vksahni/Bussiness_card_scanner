import 'package:cloud_firestore/cloud_firestore.dart';

import '../database/app_database.dart';
import '../models/app_enums.dart';
import '../models/business_card_record.dart';

class CardRepository {
  CardRepository({
    required this.database,
    FirebaseFirestore? firestoreInstance,
  }) : firestore = firestoreInstance;

  final AppDatabase database;
  final FirebaseFirestore? firestore;

  Future<List<BusinessCardRecord>> fetchAll() => database.fetchCards();

  Future<void> save(BusinessCardRecord record) async {
    await database.upsertCard(record);
  }

  Future<void> delete(String id) => database.deleteCard(id);

  Future<BusinessCardRecord> syncRecord(BusinessCardRecord record) async {
    try {
      String imageUrl = record.cardImageUrl;
      if (firestore != null) {
        await firestore!.collection('cardRecords').doc(record.id).set({
          ...record.copyWith(cardImageUrl: imageUrl, syncStatus: SyncStatus.synced).toMap(),
          'phone_numbers': record.phoneNumbers,
          'social_links': record.socialLinks,
        });
      }
      final synced = record.copyWith(cardImageUrl: imageUrl, syncStatus: SyncStatus.synced);
      await database.upsertCard(synced);
      return synced;
    } catch (_) {
      final failed = record.copyWith(syncStatus: SyncStatus.failed);
      await database.upsertCard(failed);
      return failed;
    }
  }
}
