import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/business_card_record.dart';

class AppDatabase {
  Database? _database;

  Future<Database> get instance async {
    if (_database != null) {
      return _database!;
    }
    final directory = await getApplicationDocumentsDirectory();
    final path = p.join(directory.path, 'cardsync_ai.db');
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE card_records(
            id TEXT PRIMARY KEY,
            person_name TEXT,
            company_name TEXT,
            designation TEXT,
            phone_numbers TEXT,
            email TEXT,
            website TEXT,
            address TEXT,
            qr_data TEXT,
            social_links TEXT,
            card_image_path TEXT,
            card_image_url TEXT,
            user_email TEXT,
            scan_date TEXT,
            confidence_score REAL,
            sync_status TEXT,
            raw_ocr_text TEXT
          )
        ''');
      },
    );
    return _database!;
  }

  Future<List<BusinessCardRecord>> fetchCards() async {
    final db = await instance;
    final rows = await db.query('card_records', orderBy: 'scan_date DESC');
    return rows.map(BusinessCardRecord.fromMap).toList();
  }

  Future<void> upsertCard(BusinessCardRecord record) async {
    final db = await instance;
    await db.insert(
      'card_records',
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteCard(String id) async {
    final db = await instance;
    await db.delete('card_records', where: 'id = ?', whereArgs: [id]);
  }
}
