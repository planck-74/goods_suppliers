import 'package:flutter/material.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:skeletonizer/skeletonizer.dart';

class DoneOrdersCardSkeleton extends StatelessWidget {
  const DoneOrdersCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enableSwitchAnimation: true,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        elevation: 10,
        child: Container(
          padding: const EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width * .96,
          decoration: const BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.all(Radius.circular(6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUpperRowsSkeleton(context),
              const SizedBox(height: 12),
              // First row of buttons (state and invoice)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _skeletonButton(width: 160, height: 50),
                  const SizedBox(width: 12),
                  _skeletonButton(width: 160, height: 50),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpperRowsSkeleton(BuildContext context) {
    return Column(
      children: [
        // Top row: client details and copy button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Client details skeleton
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Business name
                Container(
                  height: 18,
                  width: 200,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 8),
                // Location row (map icon + location text)
                Row(
                  children: [
                    Container(
                      height: 24,
                      width: 24,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 14,
                      width: 100,
                      color: Colors.grey[300],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Timestamp
                Container(
                  height: 14,
                  width: 150,
                  color: Colors.grey[300],
                ),
              ],
            ),
            // Copy button skeleton
            Container(
              height: 30,
              width: 75,
              color: Colors.grey[300],
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Divider(),
        const SizedBox(height: 8),
        // Bottom row in upper section: total price and product count
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: 14,
              width: 120,
              color: Colors.grey[300],
            ),
            Container(
              height: 14,
              width: 60,
              color: Colors.grey[300],
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Divider(),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _skeletonButton({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey,
    );
  }
}
