import 'package:flutter/material.dart';
import 'package:goods/data/global/theme/theme_data.dart';

class AvailableCardSkeleton extends StatefulWidget {
  const AvailableCardSkeleton({super.key});

  @override
  State<AvailableCardSkeleton> createState() => _AvailableCardSkeletonState();
}

class _AvailableCardSkeletonState extends State<AvailableCardSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildShimmerBox({
    required double width,
    required double height,
    BorderRadius? borderRadius,
  }) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey[300]!.withOpacity(_animation.value),
            borderRadius: borderRadius ?? BorderRadius.circular(4),
          ),
        );
      },
    );
  }

  Widget _buildImageSkeleton() {
    return SizedBox(
      height: 115,
      width: 100,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: _buildShimmerBox(
          width: 100,
          height: 115,
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  Widget _buildProductDetailsSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product title - 2 lines
        _buildShimmerBox(width: double.infinity, height: 16),
        const SizedBox(height: 4),
        _buildShimmerBox(width: 150, height: 16),
        const SizedBox(height: 8),

        // Price section
        Row(
          children: [
            _buildShimmerBox(width: 60, height: 18),
            const SizedBox(width: 12),
            _buildShimmerBox(width: 50, height: 16),
          ],
        ),
        const SizedBox(height: 4),

        // Max order quantity for offer
        _buildShimmerBox(width: 180, height: 14),
        const SizedBox(height: 4),

        // Min order quantity
        _buildShimmerBox(width: 120, height: 12),
        const SizedBox(height: 2),

        // Max order quantity
        _buildShimmerBox(width: 130, height: 12),
      ],
    );
  }

  Widget _buildButtonSkeleton({required double width}) {
    return Container(
      height: 36,
      width: width,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Center(
        child: _buildShimmerBox(width: width * 0.6, height: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
      child: Container(
        decoration: BoxDecoration(
          color: whiteColor,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildImageSkeleton(),
                      const SizedBox(width: 6),
                      Container(
                        height: 60,
                        width: 1.0,
                        color: darkBlueColor.withOpacity(0.3),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _buildProductDetailsSkeleton(),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12.0, 0, 18, 8),
                  child: Row(
                    children: [
                      _buildButtonSkeleton(width: 80),
                      const SizedBox(width: 12),
                      _buildButtonSkeleton(width: 100),
                    ],
                  ),
                ),
              ],
            ),
            // Sale indicator skeleton (optional - can be shown randomly)
            if (DateTime.now().millisecond % 3 ==
                0) // Show randomly for variety
              Positioned(
                right: 0,
                top: 0,
                child: Opacity(
                  opacity: 0.3,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(6),
                      ),
                    ),
                    child: _buildShimmerBox(width: 40, height: 12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Usage example - you can create multiple skeletons for a list
class AvailableCardSkeletonList extends StatelessWidget {
  final int itemCount;

  const AvailableCardSkeletonList({
    super.key,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return const AvailableCardSkeleton();
      },
    );
  }
}
