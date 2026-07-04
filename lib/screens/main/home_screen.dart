import 'package:book_reader_app/helpers/consts.dart';
import 'package:book_reader_app/providers/book_provider.dart';
import 'package:book_reader_app/providers/category_provider.dart';
import 'package:book_reader_app/screens/main/book_details_screen.dart';
import 'package:book_reader_app/theme/app_colors.dart';
import 'package:book_reader_app/widgets/books_grid.dart';
import 'package:book_reader_app/widgets/category_chip.dart';
import 'package:book_reader_app/widgets/common/app_header.dart';
import 'package:book_reader_app/widgets/common/empty_state.dart';
import 'package:book_reader_app/widgets/common/skeletons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load books and categories on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookProvider = Provider.of<BookProvider>(context, listen: false);
      final categoryProvider = Provider.of<CategoryProvider>(
        context,
        listen: false,
      );
      bookProvider.loadBooks();
      categoryProvider.loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Consumer2<BookProvider, CategoryProvider>(
      builder: (context, bookProvider, categoryProvider, child) {
        return Column(
          children: [
            // Header with Search
            AppHeader(
              title: 'Home',
              trailing: IconButton(
                icon: Icon(
                  bookProvider.isSearching ? Icons.close : Icons.search,
                  color: colors.onSurface,
                ),
                onPressed: () => bookProvider.toggleSearch(),
              ),
            ),
            if (bookProvider.isSearching)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  spacingLarge,
                  0,
                  spacingLarge,
                  spacingSmall,
                ),
                child: TextField(
                  autofocus: true,
                  onChanged: (value) => bookProvider.setSearchQuery(value),
                  style: bodyMedium.copyWith(color: colors.onSurface),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: colors.surface,
                    prefixIcon: Icon(Icons.search, color: colors.secondaryText),
                    suffixIcon: bookProvider.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.backspace,
                              color: colors.secondaryText,
                            ),
                            onPressed: () => bookProvider.clearSearch(),
                          )
                        : null,
                    hintText: "Search",
                    hintStyle: bodyMedium.copyWith(color: colors.secondaryText),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            // Category Chips Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                vertical: 4,
                horizontal: spacingSmall,
              ),
              child: Row(
                children: List.generate(
                  categoryProvider.categories.length,
                  (index) => CategoryChip(
                    label: categoryProvider.categories[index]['name'] ?? '',
                    isSelected: categoryProvider.selectedIndex == index,
                    onTap: () {
                      categoryProvider.selectCategory(index);
                      // Load books with selected category (null means all books)
                      bookProvider.loadBooks(
                        categoryId: categoryProvider.selectedCategoryId,
                      );
                    },
                  ),
                ),
              ),
            ),

            // Books Grid with Pull-to-Refresh
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  final bookProvider = Provider.of<BookProvider>(
                    context,
                    listen: false,
                  );
                  final categoryProvider = Provider.of<CategoryProvider>(
                    context,
                    listen: false,
                  );
                  // Reload books and categories
                  await Future.wait([
                    bookProvider.loadBooks(
                      categoryId: categoryProvider.selectedCategoryId,
                    ),
                    categoryProvider.loadCategories(),
                  ]);
                },
                color: colors.primary,
                child: bookProvider.busy && bookProvider.books.isEmpty
                    ? const BooksGridSkeleton()
                    : _buildBooksContent(context, bookProvider),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBooksContent(BuildContext context, BookProvider bookProvider) {
    final displayBooks = bookProvider.filteredBooks;

    if (displayBooks.isEmpty && bookProvider.searchQuery.isNotEmpty) {
      return const EmptyState(
        icon: Icons.search_off,
        title: 'No books found',
        message: 'Try a different search term',
      );
    }

    if (displayBooks.isEmpty) {
      return const EmptyState(
        icon: Icons.book_outlined,
        title: 'No books available',
        message: 'Pull down to refresh',
      );
    }

    return BooksGrid(
      books: displayBooks,
      onBookTap: (book) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookDetailsScreen(book: book),
          ),
        );
      },
    );
  }
}
