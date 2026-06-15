import 'package:googleapis/sheets/v4.dart';

import '../core/constants/app_constants.dart';
import '../core/extensions/date_extensions.dart';
import '../models/business_card_record.dart';

class GoogleSheetsService {
  const GoogleSheetsService();

  Future<ValueRange> buildAppendPayload(BusinessCardRecord record) async {
    return ValueRange(
      values: [
        [
          record.id,
          record.personName,
          record.companyName,
          record.designation,
          record.phoneNumbers.join(', '),
          record.email,
          record.website,
          record.address,
          record.qrData,
          record.cardImageUrl,
          record.userEmail,
          record.scanDate.toShortDate(),
          record.scanDate.toSheetTimestamp(),
        ],
      ],
      majorDimension: 'ROWS',
      range: 'A:M',
    );
  }

  List<String> get headers => AppConstants.spreadsheetColumns;
}
