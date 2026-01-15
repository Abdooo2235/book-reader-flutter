import 'package:book_reader_app/helpers/consts.dart';
import 'package:book_reader_app/providers/book_provider.dart';
import 'package:book_reader_app/screens/main/book_details_screen.dart';
import 'package:book_reader_app/widgets/books_grid.dart';
import 'package:provider/provider.dart';

import 'package:flutter/material.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({super.key});

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  @override
  void initState() {
    super.initState();
    // Load favorites when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookProvider = Provider.of<BookProvider>(context, listen: false);
      bookProvider.loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? whiteColorDark : blackColor;
    final secondaryTextColor = isDark
        ? whiteColorDark.withValues(alpha: 0.6)
        : Colors.grey[600];
    final tertiaryTextColor = isDark
        ? whiteColorDark.withValues(alpha: 0.5)
        : Colors.grey[500];
    final accentColor = isDark ? primaryColorDark : primaryColor;

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
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: accentColor, thickness: 0.25),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                final bookProvider = Provider.of<BookProvider>(
                  context,
                  listen: false,
                );
                await bookProvider.loadFavorites();
              },
              color: accentColor,
              child: Consumer<BookProvider>(
                builder: (context, bookProvider, child) {
                  final favorites = bookProvider.favorites;

                  if (favorites.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.favorite_border,
                                  size: 64,
                                  color: accentColor.withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No favourites yet',
                                  style: bodyLarge.copyWith(
                                    color: secondaryTextColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Add books to your favourites',
                                  style: bodyMedium.copyWith(
                                    color: tertiaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
          ),
        ],
      ),
    );
  }
}
