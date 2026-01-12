import 'package:flutter/material.dart';

class QuantityButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const QuantityButton({super.key, required this.icon, required this.onTap});

  @override
  State<QuantityButton> createState() => _QuantityButtonState();
}

class _QuantityButtonState extends State<QuantityButton> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(widget.icon, size: 20),
      ),
    );
  }
}
