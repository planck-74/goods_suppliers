import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods/business_logic/cubits/dynamic_cubit/dynamic_product_cubit.dart';
import 'package:goods/business_logic/cubits/dynamic_cubit/dynamic_product_state.dart';
import 'package:goods/business_logic/cubits/unavailable/unavailable_cubit.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/data/models/supplier_product_model.dart';
import 'package:goods/presentation/custom_widgets/counter.dart';
import 'package:goods/presentation/sheets/price_quantity_section.dart';

class SheetAvailable extends StatefulWidget {
  final Map<String, dynamic> product;
  final List<dynamic> productData;
  final int index;

  const SheetAvailable({
    super.key,
    required this.product,
    required this.productData,
    required this.index,
  });

  @override
  _SheetAvailableState createState() => _SheetAvailableState();
}

class _SheetAvailableState extends State<SheetAvailable>
    with TickerProviderStateMixin {
  bool isAvailable = true;
  bool checkBoxState = false;
  bool _isFormValid = false;
  DateTime? selectedDate;

  // Animation controllers
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // Form key for validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Text controllers
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

    // Start animations
    _slideController.forward();
    _fadeController.forward();
  }

  void _initializeTextControllers() {
    priceController = TextEditingController(
      text: widget.product['price']?.toString() ?? '',
    );
    minQuantityController = TextEditingController(
      text: widget.product['minOrderQuantity']?.toString() ?? '1',
    );
    maxQuantityController = TextEditingController(
      text: widget.product['maxOrderQuantity']?.toString() ?? '50',
    );
    offerPriceController = TextEditingController(
      text: widget.product['offerPrice']?.toString() ?? '',
    );
    maxQuantityControllerOffer = TextEditingController(
      text: widget.product['maxOrderQuantityForOffer']?.toString() ?? '10',
    );
  }

  void _addListeners() {
    priceController.addListener(_validateForm);
    minQuantityController.addListener(_validateForm);
    maxQuantityController.addListener(_validateForm);
    offerPriceController.addListener(_validateForm);
    maxQuantityControllerOffer.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      bool hasValidPrice = priceController.text.isNotEmpty &&
          double.tryParse(priceController.text) != null &&
          double.parse(priceController.text) > 0;

      bool hasValidQuantities = minQuantityController.text.isNotEmpty &&
          maxQuantityController.text.isNotEmpty &&
          int.tryParse(minQuantityController.text) != null &&
          int.tryParse(maxQuantityController.text) != null &&
          int.parse(minQuantityController.text) > 0 &&
          int.parse(maxQuantityController.text) >=
              int.parse(minQuantityController.text);

      bool offerValid = !checkBoxState ||
          (checkBoxState &&
              offerPriceController.text.isNotEmpty &&
              maxQuantityControllerOffer.text.isNotEmpty &&
              double.tryParse(offerPriceController.text) != null &&
              int.tryParse(maxQuantityControllerOffer.text) != null &&
              double.parse(offerPriceController.text) > 0 &&
              int.parse(maxQuantityControllerOffer.text) > 0 &&
              selectedDate != null &&
              selectedDate!.isAfter(DateTime.now()));

      _isFormValid = hasValidPrice && hasValidQuantities && offerValid;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.red,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      _validateForm();

      // Show success feedback
      HapticFeedback.selectionClick();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تحديد تاريخ انتهاء العرض: ${_formatDate(picked)}'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
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
      return;
    }

    HapticFeedback.heavyImpact();

    try {
      final product = Product(
        productId: widget.product['productId'],
        availability: isAvailable,
        price: int.parse(priceController.text),
        maxOrderQuantity: int.parse(maxQuantityController.text),
        minOrderQuantity: int.parse(minQuantityController.text),
        offerPrice: checkBoxState ? int.parse(offerPriceController.text) : null,
        maxOrderQuantityForOffer:
            checkBoxState ? int.parse(maxQuantityControllerOffer.text) : null,
        endDate: checkBoxState ? selectedDate : null,
        isOnSale: checkBoxState,
        name: widget.product['name'],
        classification: widget.product['classification'],
        imageUrl: widget.product['imageUrl'],
        note: widget.product['note'] ?? '',
        manufacturer: widget.product['manufacturer'],
        size: widget.product['size'],
        package: widget.product['package'],
        salesCount: widget.product['salesCount'],
      );

      context.read<DynamicProductCubit>().addDynamicProduct(
            context,
            product,
            storeId,
            message: checkBoxState
                ? 'تم إضافة المنتج كعرض بنجاح!'
                : 'أصبح المنتج الان معروض للعميل',
          );

      context.read<UnAvailableCubit>().eliminateProduct(index: widget.index);

      // Success feedback
      HapticFeedback.heavyImpact();

      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        await _slideController.reverse();
        Navigator.pop(context);
      }
    } catch (e) {
      _showValidationError('حدث خطأ في حفظ البيانات، يرجى المحاولة مرة أخرى');
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
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
          child: Form(
            key: _formKey,
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
                  _buildPriceQuantitySection(),
                  const SizedBox(height: 16),
                  _buildOfferToggle(),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    height: checkBoxState ? null : 0,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: checkBoxState ? 1.0 : 0.0,
                      child: checkBoxState
                          ? _buildOfferSection()
                          : const SizedBox.shrink(),
                    ),
                  ),
                  _buildDivider(),
                  _buildBottomActions(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 4,
      width: 50,
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
      alignment: Alignment.center,
    );
  }

  Widget _buildProductInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              image: widget.product['imageUrl'] != null
                  ? DecorationImage(
                      image: NetworkImage(widget.product['imageUrl']),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: widget.product['imageUrl'] == null
                ? const Icon(Icons.inventory, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product['name'] ?? 'اسم المنتج غير متوفر',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (widget.product['size'] != null)
                  Text(
                    'الحجم: ${widget.product['size']}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                if (widget.product['manufacturer'] != null)
                  Text(
                    'الشركة المصنعة: ${widget.product['manufacturer']}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
              ],
            ),
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: PriceQuantitySection(
        priceController: priceController,
        maxQuantityController: maxQuantityController,
        minQuantityController: minQuantityController,
      ),
    );
  }

  Widget _buildOfferToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            checkBoxState = !checkBoxState;
          });
          _validateForm();
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: checkBoxState ? Colors.red : Colors.transparent,
                  border: Border.all(
                    color: Colors.red,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: checkBoxState
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              const Text(
                'إضافة إلى قائمة العروض',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Icon(
                checkBoxState ? Icons.expand_less : Icons.expand_more,
                color: Colors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfferSection() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_offer, color: Colors.red[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'تفاصيل العرض',
                style: TextStyle(
                  color: Colors.red[700],
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildExpirationDateButton(context),
          const SizedBox(height: 16),
          _buildOfferPriceSection(),
        ],
      ),
    );
  }

  Widget _buildExpirationDateButton(BuildContext context) {
    bool hasValidDate =
        selectedDate != null && selectedDate!.isAfter(DateTime.now());

    return InkWell(
      onTap: () => _selectDate(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: hasValidDate ? Colors.green : Colors.grey[300]!,
            width: hasValidDate ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.date_range_outlined,
              color: hasValidDate ? Colors.green : Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              selectedDate != null
                  ? "تاريخ انتهاء العرض: ${_formatDate(selectedDate!)}"
                  : 'اضغط لتحديد تاريخ انتهاء العرض',
              style: TextStyle(
                color: hasValidDate ? Colors.green : Colors.grey[600],
                fontWeight: hasValidDate ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferPriceSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'سعر العرض',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
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
                const Text(
                  'أقصى كمية للعرض',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
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

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      height: 1,
      color: Colors.grey[200],
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
                  duration: const Duration(milliseconds: 200),
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isFormValid ? Colors.green : Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: _isFormValid ? 2 : 0,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            checkBoxState ? 'إضافة عرض' : 'تعديل المنتج',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
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
                await _slideController.reverse();
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
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
