import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods/business_logic/cubits/orders/orders_cubit.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/data/models/client_model.dart';
import 'package:goods/data/models/order_model.dart';
import 'package:goods/presentation/custom_widgets/rectangle_Elevated_button.dart';
import 'package:goods/presentation/screens/navigator_bar_screens/orders/widgets/upper_rows.dart';
import 'package:goods/presentation/sheets/client_sheet.dart';

class RecentOrdersCard extends StatefulWidget {
  final ClientModel client;
  final OrderModel order;
  final List orders;
  final String state;
  final String navigatorScreen;
  final VoidCallback onPressed1;
  final VoidCallback? onPressed2;

  const RecentOrdersCard({
    super.key,
    required this.order,
    required this.client,
    required this.state,
    required this.onPressed1,
    this.onPressed2,
    required this.orders,
    required this.navigatorScreen,
  });

  @override
  State<RecentOrdersCard> createState() => _RecentOrdersCardState();
}

class _RecentOrdersCardState extends State<RecentOrdersCard>
    with SingleTickerProviderStateMixin {
  List<int> initControllers = [];
  bool _isNoteExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    initControllers = List.generate(
      widget.order.products.length,
      (index) {
        final controllerValue = widget.order.products[index]['controller'] ?? 0;
        return controllerValue;
      },
    );

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool get _hasNote {
    return widget.order.note.isNotEmpty && widget.order.note != '';
  }

  void _toggleNoteDrawer() {
    setState(() {
      _isNoteExpanded = !_isNoteExpanded;
      if (_isNoteExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final client = widget.client;
    final selectedProducts = context.read<OrdersCubit>().selectedProducts;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Main Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              elevation: 10,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    upperRows(context, order, client),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton2(
                            elevation: 5,
                            height: 50,
                            width: double.infinity,
                            color: Colors.green,
                            sideColor: Colors.green,
                            child: Text(
                              widget.state,
                              style: const TextStyle(
                                  fontSize: 18, color: whiteColor),
                            ),
                            onPressed: widget.onPressed1,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton2(
                            elevation: 5,
                            height: 50,
                            width: double.infinity,
                            color: whiteColor,
                            sideColor: const Color.fromARGB(255, 215, 215, 215),
                            child: const Text(
                              'الفاتورة',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.black),
                            ),
                            onPressed: () async {
                              final c = context
                                  .read<OrdersCubit>()
                                  .controllersList(order);
                              final k = context
                                  .read<OrdersCubit>()
                                  .productSelection(order);
                              await context
                                  .read<OrdersCubit>()
                                  .initselectedProducts(
                                      order.products, k, selectedProducts, c);
                              Navigator.pushNamed(
                                  context, widget.navigatorScreen,
                                  arguments: {
                                    'order': order,
                                    'client': client,
                                    'initControllers': initControllers,
                                  });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton2(
                            elevation: 5,
                            height: 50,
                            width: double.infinity,
                            color: const Color(0xFF012340),
                            sideColor: const Color(0xFF012340),
                            child: const Text(
                              'العميل',
                              style: TextStyle(fontSize: 18, color: whiteColor),
                            ),
                            onPressed: () async {
                              showModalBottomSheet(
                                backgroundColor: whiteColor,
                                context: context,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(16)),
                                ),
                                builder: (BuildContext context) {
                                  return ClientDetailsSheet(
                                      client: widget.client);
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton2(
                            elevation: 5,
                            height: 50,
                            width: double.infinity,
                            color: Colors.red.withOpacity(0.9),
                            sideColor: Colors.red,
                            child: const Text(
                              'رفض',
                              style: TextStyle(fontSize: 18, color: whiteColor),
                            ),
                            onPressed: widget.onPressed2,
                          ),
                        ),
                      ],
                    ),

                    // Note Toggle Button - only show if note exists
                    if (_hasNote) ...[
                      const SizedBox(height: 12),
                      Center(
                        child: GestureDetector(
                          onTap: _toggleNoteDrawer,
                          child: AnimatedRotation(
                            duration: const Duration(milliseconds: 300),
                            turns: _isNoteExpanded ? 0.5 : 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.blue.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.sticky_note_2,
                                    color: Colors.blue.shade700,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'ملاحظة الطلب',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Colors.blue.shade700,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (_hasNote)
              Positioned(
                left: 10,
                right: 10,
                top: 0,
                child: AnimatedBuilder(
                  animation: _slideAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(
                        0,
                        -_slideAnimation.value * 120 + 120, // Slide from bottom
                      ),
                      child: Opacity(
                        opacity: _slideAnimation.value,
                        child: Container(
                          margin: EdgeInsets.only(
                            top: _slideAnimation.value * 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                            border: Border.all(
                              color: Colors.blue.shade200,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.order.note,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade800,
                                    height: 1.4,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}
