import 'package:book_reader_app/helpers/consts.dart';
import 'package:book_reader_app/providers/book_provider.dart';
import 'package:book_reader_app/providers/category_provider.dart';
import 'package:book_reader_app/screens/main/book_details_screen.dart';
import 'package:book_reader_app/widgets/app_logo.dart';
import 'package:book_reader_app/widgets/book_card_shimmer.dart';
import 'package:book_reader_app/widgets/books_grid.dart';
import 'package:book_reader_app/widgets/category_chip.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? whiteColorDark : blackColor;
    final searchFieldColor = isDark ? surfaceColorDark : Colors.white;

    return Consumer2<BookProvider, CategoryProvider>(
      builder: (context, bookProvider, categoryProvider, child) {
        return Column(
          children: [
            // Header with Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Home text on the left
                      Text(
                        'Home',
                        style: bodySmall.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: textColor,
                        ),
                      ),
                      // Logo centered
                      Expanded(
                        child: Center(
                          child:
                              //contol app logo size
                              AppLogo.large(size: 150),
                        ),
                      ),
                      // Search icon on the right
                      IconButton(
                        icon: Icon(
                          bookProvider.isSearching ? Icons.close : Icons.search,
                          color: textColor,
                        ),
                        onPressed: () => bookProvider.toggleSearch(),
                      ),
                    ],
                  ),
                  if (bookProvider.isSearching)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: TextField(
                        autofocus: true,
                        onChanged: (value) =>
                            bookProvider.setSearchQuery(value),
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: searchFieldColor,
                          prefixIcon: Icon(
                            Icons.search,
                            color: textColor.withValues(alpha: 0.7),
                          ),
                          suffixIcon: bookProvider.searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.backspace,
                                    color: textColor.withValues(alpha: 0.5),
                                  ),
                                  onPressed: () => bookProvider.clearSearch(),
                                )
                              : null,
                          hintText: "Search",
                          hintStyle: TextStyle(
                            color: textColor.withValues(alpha: 0.5),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Category Chips Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
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
                color: isDark ? primaryColorDark : primaryColor,
                child: bookProvider.busy && bookProvider.books.isEmpty
                    ? GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 0.52,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                        itemCount: 9, // Show 9 shimmer placeholders
                        itemBuilder: (context, index) {
                          return const BookCardShimmer();
                        },
                      )
                    : _buildBooksContent(context, bookProvider),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBooksContent(BuildContext context, BookProvider bookProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryTextColor = isDark
        ? whiteColorDark.withValues(alpha: 0.7)
        : Colors.grey[700];
    final tertiaryTextColor = isDark
        ? whiteColorDark.withValues(alpha: 0.5)
        : Colors.grey[500];
    final accentColor = isDark ? primaryColorDark : primaryColor;

    final displayBooks = bookProvider.filteredBooks;

    if (displayBooks.isEmpty && bookProvider.searchQuery.isNotEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: accentColor.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No books found',
                    style: bodyLarge.copyWith(
                      color: secondaryTextColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try a different search term',
                    style: bodyMedium.copyWith(color: tertiaryTextColor),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (displayBooks.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.book_outlined,
                    size: 64,
                    color: accentColor.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No books available',
                    style: bodyLarge.copyWith(
                      color: secondaryTextColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pull down to refresh',
                    style: bodyMedium.copyWith(color: tertiaryTextColor),
                  ),
                ],
              ),
            ),
          ),
        ],
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
