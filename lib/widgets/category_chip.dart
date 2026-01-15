import 'package:flutter/material.dart';
import '../helpers/consts.dart'; // your colors

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activePrimaryColor = isDark ? primaryColorDark : primaryColor;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: widget.isSelected ? activePrimaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: activePrimaryColor,
            width: 1.5,
          ),
          boxShadow: [
            if (widget.isSelected)
              BoxShadow(
                color: activePrimaryColor.withValues(alpha: 0.3),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Text(
          widget.label,
          style: TextStyle(
            color: widget.isSelected 
                ? Colors.white 
                : (isDark ? whiteColorDark : blackColor),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
