import 'package:book_reader_app/providers/book_provider.dart';
import 'package:book_reader_app/screens/main/book_details_screen.dart';
import 'package:book_reader_app/theme/app_colors.dart';
import 'package:book_reader_app/widgets/books_grid.dart';
import 'package:book_reader_app/widgets/common/app_header.dart';
import 'package:book_reader_app/widgets/common/empty_state.dart';
import 'package:book_reader_app/widgets/common/skeletons.dart';
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
    final colors = AppColors.of(context);

    return Scaffold(
      body: Column(
        children: [
          const AppHeader(title: 'Favourites'),
          Divider(color: colors.border, height: 1),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                final bookProvider = Provider.of<BookProvider>(
                  context,
                  listen: false,
                );
                await bookProvider.loadFavorites();
              },
              color: colors.primary,
              child: Consumer<BookProvider>(
                builder: (context, bookProvider, child) {
                  final favorites = bookProvider.favorites;

                  if (bookProvider.busy && favorites.isEmpty) {
                    return const BooksGridSkeleton();
                  }

                  if (favorites.isEmpty) {
                    return const EmptyState(
                      icon: Icons.favorite_border,
                      title: 'No favourites yet',
                      message: 'Add books to your favourites',
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
