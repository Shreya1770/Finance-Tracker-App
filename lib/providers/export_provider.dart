import 'package:expense_tracker/services/export_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final exportServiceProvider = Provider<ExportService>((ref) {
  return ExportService();
});
