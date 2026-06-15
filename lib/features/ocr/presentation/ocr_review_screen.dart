import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/section_card.dart';
import '../../../models/business_card_record.dart';
import '../../../providers/app_providers.dart';

class OcrReviewScreen extends ConsumerStatefulWidget {
  const OcrReviewScreen({super.key, required this.record});

  final BusinessCardRecord record;

  @override
  ConsumerState<OcrReviewScreen> createState() => _OcrReviewScreenState();
}

class _OcrReviewScreenState extends ConsumerState<OcrReviewScreen> {
  late final TextEditingController _name;
  late final TextEditingController _company;
  late final TextEditingController _designation;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _website;
  late final TextEditingController _address;
  late final TextEditingController _qr;
  late final TextEditingController _social;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.record.personName);
    _company = TextEditingController(text: widget.record.companyName);
    _designation = TextEditingController(text: widget.record.designation);
    _phone = TextEditingController(text: widget.record.phoneNumbers.join(', '));
    _email = TextEditingController(text: widget.record.email);
    _website = TextEditingController(text: widget.record.website);
    _address = TextEditingController(text: widget.record.address);
    _qr = TextEditingController(text: widget.record.qrData);
    _social = TextEditingController(text: widget.record.socialLinks.join(', '));
  }

  @override
  void dispose() {
    _name.dispose();
    _company.dispose();
    _designation.dispose();
    _phone.dispose();
    _email.dispose();
    _website.dispose();
    _address.dispose();
    _qr.dispose();
    _social.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final updated = widget.record.copyWith(
      personName: _name.text.trim(),
      companyName: _company.text.trim(),
      designation: _designation.text.trim(),
      phoneNumbers: _phone.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      email: _email.text.trim(),
      website: _website.text.trim(),
      address: _address.text.trim(),
      qrData: _qr.text.trim(),
      socialLinks: _social.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
    );
    await ref.read(cardsProvider.notifier).save(updated);
    if (!mounted) {
      return;
    }
    context.go('/spreadsheet');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OCR Review')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          SectionCard(
            title: 'Confidence Summary',
            subtitle: 'Review extracted fields before the record hits local DB, cloud backup, and sheet sync.',
            child: Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(value: widget.record.confidenceScore),
                ),
                const SizedBox(width: 12),
                Text('${(widget.record.confidenceScore * 100).toStringAsFixed(0)}%'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Extracted Fields',
            child: Column(
              children: [
                _field(_name, 'Person Name'),
                _field(_company, 'Company Name'),
                _field(_designation, 'Designation'),
                _field(_phone, 'Phone Numbers'),
                _field(_email, 'Email'),
                _field(_website, 'Website'),
                _field(_address, 'Office Address', lines: 3),
                _field(_qr, 'QR Data', lines: 2),
                _field(_social, 'Social Links', lines: 2),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Raw OCR',
            child: Text(widget.record.rawOcrText.isEmpty ? 'No raw OCR text found.' : widget.record.rawOcrText),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _saving ? null : _save,
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
            child: Text(_saving ? 'Saving...' : 'Save Record'),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController controller, String label, {int lines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        minLines: lines,
        maxLines: lines,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
