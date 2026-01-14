import 'package:book_reader_app/helpers/consts.dart';
import 'package:book_reader_app/providers/book_provider.dart';
import 'package:book_reader_app/screens/main/book_details_screen.dart';
import 'package:book_reader_app/widgets/books_grid.dart';
import 'package:provider/provider.dart';

import 'package:flutter/material.dart';

class FavouriteScreen extends StatelessWidget {
  const FavouriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Favourites',
                  style: bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: primaryColor, thickness: 0.25),
          Expanded(
            child: Consumer<BookProvider>(
              builder: (context, bookProvider, child) {
                final favorites = bookProvider.favorites;

                if (favorites.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 64,
                          color: primaryColor.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No favourites yet',
                          style: bodyLarge.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add books to your favourites',
                          style: bodyMedium.copyWith(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                return BooksGrid(
                  books: favorites,
                  onBookTap: (book) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookDetailsScreen(book: book),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
