import 'package:flutter/material.dart';

void showTopBar({
  required BuildContext context,
  required String message,
  Color? color,
}) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).padding.top + 30, // يظهر بعد شريط الحالة
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: color ?? Colors.green,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                (color ?? Colors.green) == Colors.red
                    ? Icons.error // ❌ عند اللون الأحمر
                    : Icons.check_circle, // ✅ عند أي لون آخر
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);

  // إخفاء الإشعار بعد 2 ثانية
  Future.delayed(const Duration(seconds: 2), () {
    overlayEntry.remove();
  });
}
