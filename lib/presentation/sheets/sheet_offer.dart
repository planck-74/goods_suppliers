import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods/business_logic/cubits/dynamic_cubit/dynamic_product_cubit.dart';
import 'package:goods/business_logic/cubits/dynamic_cubit/dynamic_product_state.dart';
import 'package:goods/business_logic/cubits/unavailable/unavailable_cubit.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/presentation/custom_widgets/counter.dart';
import 'package:goods/presentation/custom_widgets/custom_buttons/custom_buttons.dart';
import 'package:goods/presentation/custom_widgets/custom_progress_indicator.dart';
import 'package:goods/presentation/sheets/price_quantity_section.dart';

class SheetOffer extends StatefulWidget {
  final Map<String, dynamic> product;
  final List<dynamic> productData;
  final int index;

  const SheetOffer({
    super.key,
    required this.product,
    required this.productData,
    required this.index,
  });

  @override
  _SheetOfferState createState() => _SheetOfferState();
}

class _SheetOfferState extends State<SheetOffer> with TickerProviderStateMixin {
  bool isAvailable = true;
  bool checkBoxState = true;
  bool _isFormValid = false;
  DateTime? selectedDate;

  // Animation controllers
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _shakeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _shakeAnimation;

  late TextEditingController priceController;
  late TextEditingController minQuantityController;
  late TextEditingController maxQuantityController;
  late TextEditingController offerPriceController;
  late TextEditingController maxQuantityControllerOffer;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeTextControllers();
    _addListeners();
    _validateForm();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _shakeAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    _slideController.forward();
    _fadeController.forward();
  }

  void _initializeTextControllers() {
    priceController = TextEditingController(
      text: widget.product['price']?.toString() ?? '0',
    );
    minQuantityController = TextEditingController(
      text: widget.product['minOrderQuantity']?.toString() ?? '1',
    );
    maxQuantityController = TextEditingController(
      text: widget.product['maxOrderQuantity']?.toString() ?? '50',
    );
    offerPriceController = TextEditingController(
      text: widget.product['offerPrice']?.toString() ?? '0',
    );
    maxQuantityControllerOffer = TextEditingController(
      text: widget.product['maxOrderQuantityForOffer']?.toString() ?? '',
    );
  }

  void _addListeners() {
    priceController.addListener(_validateForm);
    minQuantityController.addListener(_validateForm);
    maxQuantityController.addListener(_validateForm);
    offerPriceController.addListener(() {
      _validateOfferPrice();
      _validateForm();
    });
    maxQuantityControllerOffer.addListener(() {
      _validateOfferQuantity();
      _validateForm();
    });
  }

  void _validateOfferPrice() {
    if (offerPriceController.text.isEmpty ||
        priceController.text.isEmpty ||
        priceController.text == '0') {
      return;
    }

    final offerPrice = double.tryParse(offerPriceController.text);
    final mainPrice = double.tryParse(priceController.text);

    if (offerPrice != null && mainPrice != null && offerPrice >= mainPrice) {
      _showTopWarning('سعر العرض يجب أن يكون أقل من السعر الأساسي');
      _triggerShake();

      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          final correctedPrice = (mainPrice - 1).toInt();
          offerPriceController.text =
              correctedPrice > 0 ? correctedPrice.toString() : '1';
        }
      });
    }
  }

  void _validateOfferQuantity() {
    if (maxQuantityControllerOffer.text.isEmpty ||
        maxQuantityController.text.isEmpty) {
      return;
    }

    final offerMaxQty = int.tryParse(maxQuantityControllerOffer.text);
    final mainMaxQty = int.tryParse(maxQuantityController.text);

    if (offerMaxQty != null && mainMaxQty != null && offerMaxQty > mainMaxQty) {
      _showTopWarning(
          'الحد الأقصى لكمية العرض يجب أن لا يتجاوز الحد الأقصى للكمية الأساسية');
      _triggerShake();

      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          maxQuantityControllerOffer.text = mainMaxQty.toString();
        }
      });
    }
  }

  void _triggerShake() {
    _shakeController.reset();
    _shakeAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
    _shakeController.forward();
  }

  void _validateForm() {
    setState(() {
      bool hasValidPrice = priceController.text.isNotEmpty &&
          priceController.text != '0' &&
          double.tryParse(priceController.text) != null &&
          double.parse(priceController.text) > 0;

      bool hasValidOfferPrice = offerPriceController.text.isNotEmpty &&
          offerPriceController.text != '0' &&
          double.tryParse(offerPriceController.text) != null &&
          double.parse(offerPriceController.text) > 0 &&
          double.parse(offerPriceController.text) <
              double.parse(priceController.text);

      bool hasValidQuantities = minQuantityController.text.isNotEmpty &&
          maxQuantityController.text.isNotEmpty &&
          int.tryParse(minQuantityController.text) != null &&
          int.tryParse(maxQuantityController.text) != null &&
          int.parse(minQuantityController.text) > 0 &&
          int.parse(maxQuantityController.text) >=
              int.parse(minQuantityController.text);

      bool hasValidOfferQuantity = maxQuantityControllerOffer.text.isNotEmpty &&
          int.tryParse(maxQuantityControllerOffer.text) != null &&
          int.parse(maxQuantityControllerOffer.text) > 0 &&
          int.parse(maxQuantityControllerOffer.text) <=
              int.parse(maxQuantityController.text);

      _isFormValid = hasValidPrice &&
          hasValidOfferPrice &&
          hasValidQuantities &&
          hasValidOfferQuantity;
    });
  }

  void _showTopWarning(String message) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 300),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, -50 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber[700],
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      overlayEntry.remove();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'حسناً',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    HapticFeedback.mediumImpact();

    Future.delayed(const Duration(seconds: 3), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 100,
          left: 16,
          right: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'موافق',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_isFormValid) {
      _showValidationError('يرجى التأكد من صحة جميع البيانات المدخلة');
      _triggerShake();
      return;
    }

    // Additional validation before submission
    final offerPrice = double.parse(offerPriceController.text);
    final mainPrice = double.parse(priceController.text);
    final offerMaxQty = int.parse(maxQuantityControllerOffer.text);
    final mainMaxQty = int.parse(maxQuantityController.text);

    if (offerPrice >= mainPrice) {
      _showTopWarning('سعر العرض يجب أن يكون أقل من السعر الأساسي');
      return;
    }

    if (offerMaxQty > mainMaxQty) {
      _showTopWarning(
          'الحد الأقصى لكمية العرض يجب أن لا يتجاوز الحد الأقصى للكمية الأساسية');
      return;
    }

    if (widget.product['productId'] == null) {
      _showValidationError('خطأ: معرف المنتج غير موجود');
      return;
    }

    HapticFeedback.heavyImpact();

    try {
      context.read<DynamicProductCubit>().updateOffer(
            context: context,
            availability: isAvailable,
            productId: widget.product['productId'],
            maxOrderQuantityForOffer:
                int.tryParse(maxQuantityControllerOffer.text) ?? 0,
            offerPrice: int.tryParse(offerPriceController.text) ?? 0,
            price: int.tryParse(priceController.text) ?? 0,
            maxOrderQuantity: int.tryParse(maxQuantityController.text) ?? 0,
            minOrderQuantity: int.tryParse(minQuantityController.text) ?? 0,
            name: widget.product['name'],
            isOnSale: checkBoxState,
            classification: widget.product['classification'],
            imageUrl: widget.product['imageUrl'],
            note: widget.product['note'] ?? '',
            manufacturer: widget.product['manufacturer'],
            size: widget.product['size'],
            package: widget.product['package'],
            salesCount: widget.product['salesCount'],
          );

      context.read<UnAvailableCubit>().eliminateProduct(index: widget.index);

      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        await _slideController.reverse();
        Navigator.pop(context);
      }
    } catch (e) {
      _showValidationError('حدث خطأ في حفظ البيانات، يرجى المحاولة مرة أخرى');
      print('Error updating offer: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _shakeController.dispose();
    priceController.dispose();
    minQuantityController.dispose();
    maxQuantityController.dispose();
    offerPriceController.dispose();
    maxQuantityControllerOffer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildProductInfoSection(),
                _buildDivider(),
                _buildOfferSection(),
                _buildDivider(),
                _buildPriceQuantitySection(),
                _buildDivider(),
                _buildBottomActions(),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Container(
        height: 4,
        width: 50,
        margin: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildProductInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red[50]!, Colors.orange[50]!],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red[200]!, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red[300]!, width: 2),
                  image: widget.product['imageUrl'] != null
                      ? DecorationImage(
                          image: NetworkImage(widget.product['imageUrl']),
                          fit: BoxFit.contain,
                        )
                      : null,
                ),
                child: widget.product['imageUrl'] == null
                    ? Icon(Icons.inventory_2_outlined,
                        color: Colors.grey[400], size: 32)
                    : null,
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.product['name'],
                        style: TextStyle(
                          color: Colors.red[900],
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red[600],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'عرض خاص',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (widget.product['size'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        Icon(Icons.straighten,
                            size: 14, color: Colors.red[700]),
                        const SizedBox(width: 4),
                        Text(
                          widget.product['size'],
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferSection() {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset:
              Offset(_shakeAnimation.value * (1 - _shakeController.value), 0),
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange[50]!, Colors.red[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.orange[200]!, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange[600],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.edit_note,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'تعديل تفاصيل العرض',
                  style: TextStyle(
                    color: Colors.orange[900],
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildOfferPriceRow(),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferPriceRow() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.price_change,
                        color: Colors.orange[700], size: 18),
                    const SizedBox(width: 6),
                    const Text(
                      'سعر العرض',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Counter(
                  controller: offerPriceController,
                  minLimit: 1,
                  maxLimit: 50000,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.inventory, color: Colors.blue[700], size: 18),
                    const SizedBox(width: 6),
                    const Text(
                      'أقصى كمية للعرض',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Counter(
                  controller: maxQuantityControllerOffer,
                  minLimit: 1,
                  maxLimit: 50000,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFieldRow({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    required int minLimit,
    required int maxLimit,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.remove_circle, color: Colors.red[600]),
            onPressed: () {
              int currentValue = int.tryParse(controller.text) ?? minLimit;
              if (currentValue > minLimit) {
                controller.text = (currentValue - 1).toString();
              }
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.add_circle, color: Colors.green[600]),
            onPressed: () {
              int currentValue = int.tryParse(controller.text) ?? minLimit;
              if (currentValue < maxLimit) {
                controller.text = (currentValue + 1).toString();
              }
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceQuantitySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.attach_money, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'السعر والكمية الأساسية',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          PriceQuantitySection(
            priceController: priceController,
            maxQuantityController: maxQuantityController,
            minQuantityController: minQuantityController,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.grey[300]!,
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: BlocBuilder<DynamicProductCubit, DynamicProductState>(
              builder: (context, state) {
                bool isLoading = state is DynamicProductLoading;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: ElevatedButton(
                    onPressed:
                        isLoading || !_isFormValid ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isFormValid ? Colors.orange[600] : Colors.grey[400],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: _isFormValid ? 4 : 0,
                      shadowColor: Colors.orange.withOpacity(0.4),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.save, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                checkBoxState ? 'حفظ التعديلات' : 'تعديل',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextButton(
              onPressed: () async {
                HapticFeedback.lightImpact();
                await _slideController.reverse();
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: Colors.grey[300]!, width: 2),
                ),
                backgroundColor: Colors.grey[50],
              ),
              child: const Text(
                'إلغاء',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
