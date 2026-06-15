import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../../core/extensions/date_extensions.dart';
import '../../../core/widgets/section_card.dart';
import '../../../models/business_card_record.dart';
import '../../../providers/app_providers.dart';

class SpreadsheetScreen extends ConsumerStatefulWidget {
  const SpreadsheetScreen({super.key});

  @override
  ConsumerState<SpreadsheetScreen> createState() => _SpreadsheetScreenState();
}

class _SpreadsheetScreenState extends ConsumerState<SpreadsheetScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final cards = ref.watch(cardsProvider).asData?.value ?? const [];
    final filtered = cards.where((record) {
      final haystack = [
        record.personName,
        record.companyName,
        record.designation,
        record.email,
        record.phoneNumbers.join(' '),
      ].join(' ').toLowerCase();
      return haystack.contains(_query.toLowerCase());
    }).toList();
    final source = _CardGridSource(filtered);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Spreadsheet Viewer', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          const Text('Use this in-app grid as the operational spreadsheet for offline edits, review, and later sync to Google Sheets.'),
          const SizedBox(height: 24),
          SectionCard(
            title: 'Search & Filters',
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search_rounded),
                labelText: 'Search by name, company, phone, email, designation',
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Records',
            subtitle: '${filtered.length} rows ready for local review and sync.',
            child: SizedBox(
              height: 520,
              child: SfDataGrid(
                source: source,
                allowSorting: true,
                columnWidthMode: ColumnWidthMode.fill,
                columns: [
                  GridColumn(columnName: 'name', label: const _GridHeader('Name')),
                  GridColumn(columnName: 'company', label: const _GridHeader('Company')),
                  GridColumn(columnName: 'designation', label: const _GridHeader('Designation')),
                  GridColumn(columnName: 'phone', label: const _GridHeader('Phone')),
                  GridColumn(columnName: 'email', label: const _GridHeader('Email')),
                  GridColumn(columnName: 'scanDate', label: const _GridHeader('Scan Date')),
                  GridColumn(columnName: 'sync', label: const _GridHeader('Sync')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GridHeader extends StatelessWidget {
  const _GridHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}

class _CardGridSource extends DataGridSource {
  _CardGridSource(List<BusinessCardRecord> cards)
      : _rows = cards
            .map(
              (record) => DataGridRow(
                cells: [
                  DataGridCell(columnName: 'name', value: record.personName),
                  DataGridCell(columnName: 'company', value: record.companyName),
                  DataGridCell(columnName: 'designation', value: record.designation),
                  DataGridCell(columnName: 'phone', value: record.phoneNumbers.join(', ')),
                  DataGridCell(columnName: 'email', value: record.email),
                  DataGridCell(columnName: 'scanDate', value: record.scanDate.toShortDate()),
                  DataGridCell(columnName: 'sync', value: record.syncStatus.name),
                ],
              ),
            )
            .toList();

  final List<DataGridRow> _rows;

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map((cell) {
        return Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text('${cell.value}'),
        );
      }).toList(),
    );
  }
}
