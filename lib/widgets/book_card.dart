import 'package:book_reader_app/helpers/consts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BookCard extends StatelessWidget {
  final String title;
  final double progress;
  final Color coverColor;

  const BookCard({
    super.key,
    required this.title,
    required this.progress,
    required this.coverColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fixed Aspect Ratio for Book Cover assures alignment
        AspectRatio(
          aspectRatio: 0.7, // Fixed 0.7 width/height ratio for all covers
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Book Cover
              Container(
                decoration: BoxDecoration(
                  color: coverColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(25),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    CupertinoIcons.book_fill,
                    color: Colors.white.withAlpha(100),
                    size: 40,
                  ),
                ),
              ),

              // Progress Badge (Top Left)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: blackColor.withAlpha(200),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "$progress%",
                    style: bodySmall.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Play/Action Button (Bottom Right)
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(230),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(25),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Icon(
                    CupertinoIcons.play_fill,
                    size: 14,
                    color: blackColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: labelSmall.copyWith(fontSize: 13, height: 1.2),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
