import 'package:book_reader_app/helpers/consts.dart';
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
                  Text(label!, style: labelSmall.copyWith(color: primaryColor)),
                ],
              ),
            ),
          TextFormField(
            obscureText: obsecureText,
            inputFormatters: inputFormatters,
            validator: validator,
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: bodyMedium.copyWith(color: Colors.grey[400]),
              filled: true,
              fillColor: Colors.white,
              suffixIcon: suffixWidget,
              prefixIcon: prefixWidget,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(borderRadiusMedium),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(borderRadiusMedium),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: primaryColor, width: 2),
                borderRadius: BorderRadius.circular(borderRadiusMedium),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: redColor),
                borderRadius: BorderRadius.circular(borderRadiusMedium),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: redColor, width: 2),
                borderRadius: BorderRadius.circular(borderRadiusMedium),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(borderRadiusMedium),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
