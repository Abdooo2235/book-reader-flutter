import 'package:book_reader_app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../helpers/consts.dart'; // spacing / radius / text tokens

class CategoryChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  @override
  State<CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<CategoryChip> {
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: animationDurationShort,
        curve: easeOutStrong,
        padding: const EdgeInsets.symmetric(
          horizontal: spacingMedium,
          vertical: spacingSmall,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: widget.isSelected ? colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(30), // pill
          border: Border.all(color: colors.primary, width: 1.5),
          boxShadow: [
            if (widget.isSelected)
              BoxShadow(
                color: colors.primary.withValues(alpha: 0.3),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Text(
          widget.label,
          style: labelSmall.copyWith(
            color: widget.isSelected ? colors.onPrimary : colors.onSurface,
          ),
        ),
      ),
    );
  }
}
