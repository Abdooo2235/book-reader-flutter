import 'package:book_reader_app/helpers/consts.dart';
import 'package:book_reader_app/theme/app_colors.dart';
import 'package:book_reader_app/widgets/book_card_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// A single shimmering placeholder block — reusable loading primitive so every
/// screen shows a consistent skeleton instead of a bare spinner.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.radius = borderRadiusSmall,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Shimmer.fromColors(
      baseColor: colors.border,
      highlightColor: colors.surface,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: colors.border,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

/// Grid of book-card skeletons — the shared loading state for the book grids
/// (Home already used one inline; Favourite/Library had none).
class BooksGridSkeleton extends StatelessWidget {
  const BooksGridSkeleton({super.key, this.itemCount = 9});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(spacingMedium),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.48,
        crossAxisSpacing: spacingMedium,
        mainAxisSpacing: spacingMedium,
      ),
      itemCount: itemCount,
      itemBuilder: (_, _) => const BookCardShimmer(),
    );
  }
}
