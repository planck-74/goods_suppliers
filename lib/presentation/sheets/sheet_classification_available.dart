import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods/business_logic/cubits/available/available_cubit.dart';
import 'package:goods/business_logic/cubits/offer_cubit/offer_cubit.dart';
import 'package:goods/data/global/theme/theme_data.dart';

class SheetClassificationAvailable extends StatefulWidget {
  const SheetClassificationAvailable({super.key});

  @override
  _SheetClassificationState createState() => _SheetClassificationState();
}

class _SheetClassificationState extends State<SheetClassificationAvailable> {
  String? selectedItem; // العنصر المحدد حاليًا

  @override
  Widget build(BuildContext context) {
    var availableCubit = context.read<AvailableCubit>(); // مرجع لـ OfferCubit
    var offerCubit = context.read<OfferCubit>(); // مرجع لـ OfferCubit

    Map manufacturer = offerCubit.manufacturer;
    Map classification = offerCubit.classification;
    List<dynamic> manufacturerList = manufacturer.values.toList();
    List<dynamic> classificationList = classification.values.toList();

    return Padding(
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 16.0,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('تصنيف المنتجات', style: TextStyle(fontSize: 24)),
            const Divider(),

            // الشركات
            _buildSectionTitle('شركات'),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: manufacturerList.map((item) {
                return _buildSelectableItem(
                    item.toString(), "manufacturer", availableCubit);
              }).toList(),
            ),
            const SizedBox(height: 12),
            const Divider(),

            _buildSectionTitle('الفئة'),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: classificationList.map((item) {
                return _buildSelectableItem(
                    item.toString(), "classification", availableCubit);
              }).toList(),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          Container(height: 2, width: 55, color: Colors.yellow),
        ],
      ),
    );
  }

  Widget _buildSelectableItem(
      String item, String filterType, AvailableCubit availableCubit) {
    bool isSelected = selectedItem == item;
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedItem = null;
            availableCubit.fetchCombinedProducts(storeId);
          } else {
            selectedItem = item;
            availableCubit.filterProducts(filterType, selectedItem!);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [Colors.yellow, Colors.orange.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color:
              isSelected ? Colors.yellow.withOpacity(0.8) : Colors.transparent,
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          border: Border.all(color: darkBlueColor),
        ),
        child: Text(
          item,
          style: TextStyle(
            fontWeight: FontWeight.normal,
            shadows: isSelected
                ? [
                    Shadow(
                      offset: const Offset(0, 0),
                      blurRadius: 8.0,
                      color: Colors.yellow.withOpacity(0.8),
                    ),
                  ]
                : [],
          ),
        ),
      ),
    );
  }
}
