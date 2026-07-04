import 'package:book_reader_app/helpers/consts.dart';
import 'package:book_reader_app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFieldWidget extends StatelessWidget {
  const TextFieldWidget({
    super.key,
    required this.controller,
    this.label,
    this.hintText,
    this.horizontalPadding = 16,
    this.verticalPadding = 8,
    required this.validator,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.prefixWidget,
    this.suffixWidget,
    this.obsecureText = false,
  });
  final TextEditingController controller;
  final String? label;
  final String? hintText;
  final double horizontalPadding;
  final double verticalPadding;
  final FormFieldValidator<String> validator;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixWidget;
  final Widget? suffixWidget;
  final bool obsecureText;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  Text(
                    label!,
                    style: labelSmall.copyWith(color: colors.primary),
                  ),
                ],
              ),
            ),
          TextFormField(
            obscureText: obsecureText,
            inputFormatters: inputFormatters,
            validator: validator,
            controller: controller,
            keyboardType: keyboardType,
            style: bodyMedium.copyWith(color: colors.onSurface),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: bodyMedium.copyWith(color: colors.secondaryText),
              filled: true,
              fillColor: colors.surface,
              suffixIcon: suffixWidget,
              prefixIcon: prefixWidget,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: spacingMedium,
                vertical: spacingMedium,
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: colors.border),
                borderRadius: BorderRadius.circular(borderRadiusMedium),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: colors.border),
                borderRadius: BorderRadius.circular(borderRadiusMedium),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: colors.primary, width: 2),
                borderRadius: BorderRadius.circular(borderRadiusMedium),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: colors.danger),
                borderRadius: BorderRadius.circular(borderRadiusMedium),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: colors.danger, width: 2),
                borderRadius: BorderRadius.circular(borderRadiusMedium),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: colors.border),
                borderRadius: BorderRadius.circular(borderRadiusMedium),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
