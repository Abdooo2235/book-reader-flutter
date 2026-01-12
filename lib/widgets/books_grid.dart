import 'package:book_reader_app/widgets/book_card.dart';
import 'package:flutter/material.dart';

class BooksGrid extends StatelessWidget {
  final List<Map<String, dynamic>> books;

  const BooksGrid({super.key, required this.books});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.52,
        crossAxisSpacing: 12,
        mainAxisSpacing: 24,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return BookCard(
          title: book['title'],
          progress: book['progress'],
          coverColor: book['color'],
        );
      },
    );
  }
}
