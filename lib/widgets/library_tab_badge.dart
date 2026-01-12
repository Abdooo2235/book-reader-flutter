import 'package:book_reader_app/helpers/consts.dart';
import 'package:flutter/material.dart';

class LibraryTabBadge extends StatelessWidget {
  final String count;

  const LibraryTabBadge({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha(50),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count,
        style: bodySmall.copyWith(fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
