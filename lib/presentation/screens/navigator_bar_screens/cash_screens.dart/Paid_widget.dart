import 'package:flutter/material.dart';
import 'package:goods/presentation/custom_widgets/date_picker.dart';

Widget paid({
  required double screenHeight,
  required double screenWidth,
  required BuildContext context,
}) {
  return SingleChildScrollView(
    child: SizedBox(
      height: screenHeight,
      width: screenWidth,
      child: Column(
        children: [
          DatePicker(
              screenHeight: screenHeight,
              screenWidth: screenWidth,
              context: context),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              padding: const EdgeInsets.all(18),
              height: 105,
              width: screenWidth,
              decoration: BoxDecoration(
                  color: Colors.amber, //
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2), // Shadow color
                      spreadRadius: 2, // How much the shadow spreads
                      blurRadius: 2, // The blur radius of the shadow
                      offset: const Offset(0, 0), // Offset of the shadow
                    ),
                  ]),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تم تحويل',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      Text(
                        'تحويلات الشهر الحالي :',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      Text(
                        '+ 0 جـ',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    ],
                  ),
                  SizedBox(
                    width: screenWidth * 0.2,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تم دفع',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      Text(
                        'مدفوعات الشهر الحالي',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      Text(
                        '+ 0 جـ',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: DefaultTabController(
              length: 3,
              child: Container(
                width: screenWidth,
                decoration: BoxDecoration(
                    color: Theme.of(context).hoverColor,
                    borderRadius: const BorderRadius.all(Radius.circular(48)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 1,
                          offset: const Offset(0, 0))
                    ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 12,
                    ),
                    Row(
                      children: [
                        Text(
                          '        كشف الحساب',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const TabBar(
                            isScrollable: true,
                            labelPadding: EdgeInsets.symmetric(horizontal: 2),
                            dividerColor: Colors.transparent,
                            tabs: [
                              Text('الكل'),
                              Text('تحويلات'),
                              Text('مدفوعات'),
                            ]),
                      ],
                    ),
                    SizedBox(
                      width: screenWidth * 0.65,
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    const Flexible(
                        child: TabBarView(
                            children: [Column(), Column(), Column()]))
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    ),
  );
}
