import 'package:book_reader_app/helpers/consts.dart';
import 'package:book_reader_app/providers/book_provider.dart';
import 'package:book_reader_app/providers/category_provider.dart';
import 'package:book_reader_app/screens/main/book_details_screen.dart';
import 'package:book_reader_app/widgets/app_logo.dart';
import 'package:book_reader_app/widgets/book_card_shimmer.dart';
import 'package:book_reader_app/widgets/books_grid.dart';
import 'package:book_reader_app/widgets/category_chip.dart';
import 'package:book_reader_app/widgets/submit_book_dialog.dart';
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

  void _showAddBookDialog() {
    showDialog(
      context: context,
      builder: (context) => const SubmitBookDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<BookProvider, CategoryProvider>(
      builder: (context, bookProvider, categoryProvider, child) {
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: _showAddBookDialog,
            backgroundColor: primaryColor,
            child: const Icon(Icons.add, color: Colors.white),
          ),
          body: Column(
            children: [
              // Header with Search
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 1,
                ),
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
                            color: Colors.black87,
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
                            bookProvider.isSearching
                                ? Icons.close
                                : Icons.search,
                            color: Colors.black87,
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
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: bookProvider.searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.backspace,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () => bookProvider.clearSearch(),
                                  )
                                : null,
                            hintText: "Search",
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

              // Books Grid with Shimmer Loading Placeholders
              Expanded(
                child: bookProvider.busy || bookProvider.books.isEmpty
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
                    : _buildBooksContent(bookProvider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBooksContent(BookProvider bookProvider) {
    final displayBooks = bookProvider.filteredBooks;

    if (displayBooks.isEmpty && bookProvider.searchQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: primaryColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No books found',
              style: bodyLarge.copyWith(
                color: Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search term',
              style: bodyMedium.copyWith(color: Colors.grey[500]),
            ),
          ],
        ),
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
