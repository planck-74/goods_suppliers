import 'package:flutter/material.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:intl/intl.dart';

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

class _DatePickerState extends State<DatePicker> with TickerProviderStateMixin {
  DateTime? _startDate;
  DateTime? _endDate;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Set initial dates: first day of current month to today
    DateTime now = DateTime.now();
    _startDate = DateTime(now.year, now.month, 1); // First day of current month
    _endDate = now; // Today

    // Start animation
    _animationController.forward();

    // Notify parent with initial dates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifyDateSelection();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    DateTime? picked = await showDatePicker(
      context: widget.context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('ar', 'EG'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: darkBlueColor,
                  onPrimary: Colors.white,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != _startDate) {
      setState(() {
        _startDate = picked;
        // Auto-adjust end date if it's before start date
        if (_endDate != null && _endDate!.isBefore(picked!)) {
          _endDate = picked.add(const Duration(days: 1));
        }
      });
      _animateSelection();
      _notifyDateSelection();
    }
  }

  Future<void> _selectEndDate() async {
    DateTime? picked = await showDatePicker(
      context: widget.context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('ar', 'EG'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: darkBlueColor,
                  onPrimary: Colors.white,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != _endDate) {
      setState(() {
        _endDate = picked;
        // Auto-adjust start date if it's after end date
        if (_startDate != null && _startDate!.isAfter(picked!)) {
          _startDate = picked.subtract(const Duration(days: 1));
        }
      });
      _animateSelection();
      _notifyDateSelection();
    }
  }

  void _animateSelection() {
    _animationController.reset();
    _animationController.forward();
  }

  /// Calls the callback if both dates are selected.
  void _notifyDateSelection() {
    if (_startDate != null &&
        _endDate != null &&
        widget.onDateSelected != null) {
      widget.onDateSelected!(_startDate!, _endDate!);
    }
  }

  void _setQuickPeriod(String period) {
    DateTime now = DateTime.now();
    DateTime start;
    DateTime end = now;

    switch (period) {
      case 'اليوم':
        start = DateTime(now.year, now.month, now.day);
        break;
      case 'الأسبوع':
        start = now.subtract(Duration(days: now.weekday - 1));
        break;
      case 'الشهر':
        start = DateTime(now.year, now.month, 1);
        break;
      case '3 أشهر':
        start = DateTime(now.year, now.month - 2, 1);
        break;
      case 'السنة':
        start = DateTime(now.year, 1, 1);
        break;
      default:
        start = DateTime(now.year, now.month, 1);
    }

    setState(() {
      _startDate = start;
      _endDate = end;
    });
    _animateSelection();
    _notifyDateSelection();
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'ar').format(date);
  }

  String _getDateRangeText() {
    if (_startDate == null || _endDate == null) return '';

    int daysDifference = _endDate!.difference(_startDate!).inDays + 1;
    return '$daysDifference يوم';
  }

  Widget _buildDateButton({
    required String label,
    required DateTime? date,
    required VoidCallback onPressed,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0, bottom: 6.0),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: darkBlueColor,
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: darkBlueColor.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onPressed,
              child: Container(
                width: widget.screenWidth * 0.42,
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: darkBlueColor.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      color: darkBlueColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        date != null ? _formatDate(date) : 'اختر التاريخ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color:
                              date != null ? darkBlueColor : Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickPeriodChip(String label) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        borderRadius: BorderRadius.circular(20),
        color: darkBlueColor.withOpacity(0.1),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _setQuickPeriod(label),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: darkBlueColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: darkBlueColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with period info
            if (_startDate != null && _endDate != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: darkBlueColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: darkBlueColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: darkBlueColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'فترة التقرير: ${_getDateRangeText()}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: darkBlueColor,
                      ),
                    ),
                  ],
                ),
              ),

            // Date selection buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDateButton(
                  label: 'تاريخ البداية',
                  date: _startDate,
                  onPressed: _selectStartDate,
                  icon: Icons.calendar_today,
                ),
                _buildDateButton(
                  label: 'تاريخ النهاية',
                  date: _endDate,
                  onPressed: _selectEndDate,
                  icon: Icons.event,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Quick period selection
            const Text(
              'فترات سريعة:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: darkBlueColor,
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildQuickPeriodChip('اليوم'),
                  const SizedBox(width: 8),
                  _buildQuickPeriodChip('الأسبوع'),
                  const SizedBox(width: 8),
                  _buildQuickPeriodChip('الشهر'),
                  const SizedBox(width: 8),
                  _buildQuickPeriodChip('3 أشهر'),
                  const SizedBox(width: 8),
                  _buildQuickPeriodChip('السنة'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
