import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

String formatTimestamp(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate();
  // List of Arabic weekdays
  const arabicWeekdays = [
    'الأحد',
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت'
  ];

  // Extract the weekday in Arabic
  String arabicDay = arabicWeekdays[dateTime.weekday % 7];

  // Format the date and time
  String formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);
  String formattedTime = DateFormat('h:mm').format(dateTime);

  // Combine the parts
  return '$arabicDay   $formattedDate   $formattedTime';
}
