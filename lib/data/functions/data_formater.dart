import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

String formatTimestamp(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate();

  // أيام الأسبوع بالعربية
  const arabicWeekdays = [
    'الأحد',
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت'
  ];
  String arabicDay = arabicWeekdays[dateTime.weekday % 7];
  String formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);
  String period = dateTime.hour < 12 ? 'صباحًا' : 'مساءً';
  String formattedTime = DateFormat('h:mm').format(dateTime);
  return '$arabicDay   $formattedDate   $formattedTime $period';
}
