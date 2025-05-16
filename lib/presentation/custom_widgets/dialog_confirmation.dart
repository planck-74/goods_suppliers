import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final String? title;
  final String content;
  final VoidCallback onConfirm;
  final Color? elevatedButtonbackgroundColor;
  final String? elevatedButtonName;
  const ConfirmationDialog(
      {super.key,
      this.title,
      required this.content,
      required this.onConfirm,
      this.elevatedButtonbackgroundColor,
      this.elevatedButtonName});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title ?? '',
          style: const TextStyle(fontWeight: FontWeight.bold)),
      content: Text(content),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(), // إغلاق النافذة
          child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                elevatedButtonbackgroundColor ?? Colors.green, // لون الخلفية
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // تعديل الزوايا
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop(); // إغلاق النافذة
            onConfirm(); // تنفيذ الإجراء عند التأكيد
          },
          child: Text(
            elevatedButtonName ?? 'تاكيد',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

Future<void> showConfirmationDialog(
    {required BuildContext context,
    String? title,
    required String content,
    required VoidCallback onConfirm,
    Color? elevatedButtonbackgroundColor,
    String? elevatedButtonName}) {
  return showDialog(
    context: context,
    builder: (context) => ConfirmationDialog(
        title: title,
        content: content,
        onConfirm: onConfirm,
        elevatedButtonbackgroundColor: elevatedButtonbackgroundColor,
        elevatedButtonName: elevatedButtonName),
  );
}
