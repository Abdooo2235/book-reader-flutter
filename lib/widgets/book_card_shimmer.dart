import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../helpers/consts.dart';

class BookCardShimmer extends StatelessWidget {
  const BookCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Shimmer colors based on theme
    final baseColor = isDark 
        ? primaryColorDark.withValues(alpha: 0.3)
        : Colors.grey[300]!;
    final highlightColor = isDark 
        ? primaryColorDark.withValues(alpha: 0.6)
        : Colors.grey[100]!;
    final containerColor = isDark 
        ? surfaceColorDark 
        : Colors.white;
    final shadowColor = isDark 
        ? Colors.black.withValues(alpha: 0.4)
        : Colors.black.withAlpha(25);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Book Cover Shimmer
        AspectRatio(
          aspectRatio: 0.7,
          child: Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Container(
              decoration: BoxDecoration(
                color: containerColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Title Shimmer
        Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 14,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: containerColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                height: 14,
                width: 120,
                decoration: BoxDecoration(
                  color: containerColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

