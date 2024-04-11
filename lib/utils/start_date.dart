import 'package:dart_holodex_api/dart_holodex_api.dart';
import 'package:intl/intl.dart';

extension StartDate on VideoFull {
  DateTime get startDate => DateFormat('yyyy-MM-ddTHH:mm:ssZ').parse(startScheduled!, true);

  DateTime? get startDateOrNull => startScheduled == null ? null : startDate;

  DateTime get localStartDate => startDate.toLocal();

  DateTime? get localStartDateOrNull => startDateOrNull?.toLocal();
}