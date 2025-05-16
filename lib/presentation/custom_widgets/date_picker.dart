import 'package:flutter/material.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/presentation/custom_widgets/custom_buttons/custom_buttons.dart';

class DatePicker extends StatefulWidget {
  final double screenHeight;
  final double screenWidth;
  final BuildContext context;
  final void Function(DateTime start, DateTime end)? onDateSelected;

  const DatePicker({
    super.key,
    required this.screenHeight,
    required this.screenWidth,
    required this.context,
    this.onDateSelected,
  });

  @override
  _DatePickerState createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    // Optional default dates:
    _startDate = DateTime.now();
    _endDate = DateTime.now().add(const Duration(days: 1));
  }

  Future<void> _selectStartDate() async {
    DateTime? picked = await showDatePicker(
      context: widget.context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
      _notifyDateSelection();
    }
  }

  Future<void> _selectEndDate() async {
    DateTime? picked = await showDatePicker(
      context: widget.context,
      initialDate: _endDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
      _notifyDateSelection();
    }
  }

  /// Calls the callback if both dates are selected.
  void _notifyDateSelection() {
    if (_startDate != null &&
        _endDate != null &&
        widget.onDateSelected != null) {
      widget.onDateSelected!(_startDate!, _endDate!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Start date column
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '    تاريخ البدء',
                style: TextStyle(
                  fontSize: 12,
                  color: darkBlueColor,
                ),
              ),
              const SizedBox(
                height: 6,
              ),
              customOutlinedButton(
                width: widget.screenWidth * 0.45,
                height: 35,
                context: context,
                onPressed: _selectStartDate,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.date_range_outlined),
                    const SizedBox(width: 6),
                    Text(
                      _startDate != null
                          ? "${_startDate!.day}/${_startDate!.month}/${_startDate!.year}"
                          : 'اختر التاريخ',
                      style: Theme.of(context).textTheme.headlineSmall,
                    )
                  ],
                ),
              ),
            ],
          ),
          SizedBox(width: widget.screenWidth * 0.02),
          // End date column
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '    تاريخ الإنتهاء',
                style: TextStyle(
                  fontSize: 12,
                  color: darkBlueColor,
                ),
              ),
              const SizedBox(
                height: 6,
              ),
              customOutlinedButton(
                width: widget.screenWidth * 0.45,
                height: 35,
                context: context,
                onPressed: _selectEndDate,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.date_range_outlined),
                    const SizedBox(width: 6),
                    Text(
                      _endDate != null
                          ? "${_endDate!.day}/${_endDate!.month}/${_endDate!.year}"
                          : 'اختر التاريخ',
                      style: Theme.of(context).textTheme.headlineSmall,
                    )
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
