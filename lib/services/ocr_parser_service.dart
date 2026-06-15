import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:uuid/uuid.dart';

import '../models/app_enums.dart';
import '../models/business_card_record.dart';

class OcrParserService {
  OcrParserService() : _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  final TextRecognizer _recognizer;

  Future<BusinessCardRecord> extractFromImage({
    required File imageFile,
    required String userEmail,
    String qrData = '',
  }) async {
    final input = InputImage.fromFile(imageFile);
    final recognized = await _recognizer.processImage(input);
    final text = recognized.text.trim();
    final lines = recognized.blocks.expand((block) => block.lines).map((line) => line.text.trim()).where((line) => line.isNotEmpty).toList();

    final email = _firstMatch(text, RegExp(r'[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}', caseSensitive: false));
    final phones = RegExp(r'(\+?\d[\d\s().-]{7,}\d)').allMatches(text).map((e) => e.group(0)!.trim()).toSet().toList();
    final website = _firstMatch(text, RegExp(r'((https?:\/\/)?(www\.)?[A-Z0-9.-]+\.[A-Z]{2,}(/[^\s]*)?)', caseSensitive: false));
    final social = RegExp(r'(linkedin\.com\/[^\s]+|x\.com\/[^\s]+|twitter\.com\/[^\s]+|instagram\.com\/[^\s]+)', caseSensitive: false)
        .allMatches(text)
        .map((e) => e.group(0)!)
        .toList();

    final likelyName = lines.isNotEmpty ? lines.first : '';
    final designationKeywords = ['manager', 'director', 'engineer', 'founder', 'ceo', 'cto', 'sales', 'marketing', 'consultant', 'president'];
    final designation = lines.firstWhere(
      (line) => designationKeywords.any((keyword) => line.toLowerCase().contains(keyword)),
      orElse: () => lines.length > 1 ? lines[1] : '',
    );
    final company = lines.firstWhere(
      (line) => RegExp(r'(llc|ltd|inc|solutions|technologies|systems|corp|company|studio)', caseSensitive: false).hasMatch(line),
      orElse: () => lines.length > 2 ? lines[2] : '',
    );
    final addressLines = lines.where((line) => RegExp(r'\d').hasMatch(line) && line.length > 12).take(2).toList();

    return BusinessCardRecord(
      id: const Uuid().v4(),
      personName: likelyName,
      companyName: company,
      designation: designation,
      phoneNumbers: phones,
      email: email,
      website: website,
      address: addressLines.join(', '),
      qrData: qrData,
      socialLinks: social,
      cardImagePath: imageFile.path,
      cardImageUrl: '',
      userEmail: userEmail,
      scanDate: DateTime.now(),
      confidenceScore: _estimateConfidence(email: email, phones: phones, company: company, name: likelyName),
      syncStatus: SyncStatus.pending,
      rawOcrText: text,
    );
  }

  String _firstMatch(String input, RegExp regex) {
    final match = regex.firstMatch(input);
    return match?.group(0)?.trim() ?? '';
  }

  double _estimateConfidence({
    required String email,
    required List<String> phones,
    required String company,
    required String name,
  }) {
    var score = 0.35;
    if (name.isNotEmpty) score += 0.2;
    if (company.isNotEmpty) score += 0.15;
    if (phones.isNotEmpty) score += 0.15;
    if (email.isNotEmpty) score += 0.15;
    return score.clamp(0.0, 0.98);
  }

  void dispose() {
    _recognizer.close();
  }
}
