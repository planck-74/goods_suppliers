import 'package:flutter/material.dart';

class AvailabilitySwitch extends StatelessWidget {
  final bool isAvailable;
  final ValueChanged<bool> onToggle;

  const AvailabilitySwitch({
    super.key,
    required this.isAvailable,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Switch(
          value: isAvailable,
          onChanged: onToggle,
          activeColor: Colors.green,
          inactiveThumbColor: Colors.red,
        ),
        const SizedBox(height: 4),
        Text(
          isAvailable ? 'موجود' : 'غير موجود',
          style: TextStyle(
            color: isAvailable ? Colors.green : Colors.red,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
