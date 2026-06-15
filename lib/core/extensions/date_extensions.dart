import 'package:intl/intl.dart';

extension DateFormatting on DateTime {
  String toShortDate() => DateFormat('dd MMM yyyy').format(this);
  String toSheetTimestamp() => DateFormat('yyyy-MM-dd HH:mm:ss').format(this);
}
