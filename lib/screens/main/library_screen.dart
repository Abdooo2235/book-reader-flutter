import 'package:book_reader_app/helpers/consts.dart';
import 'package:book_reader_app/providers/library_provider.dart';
import 'package:book_reader_app/providers/progress_provider.dart';
import 'package:book_reader_app/screens/main/book_details_screen.dart';
import 'package:book_reader_app/widgets/books_grid.dart';
import 'package:book_reader_app/widgets/library_tab_badge.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LibraryProvider>(context, listen: false).loadLibrary();
      Provider.of<ProgressProvider>(context, listen: false).loadAllProgress();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildBookList(
    BuildContext context,
    List<Map<String, dynamic>> books,
    String emptyMessage,
    IconData emptyIcon,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryTextColor = isDark
        ? whiteColorDark.withValues(alpha: 0.6)
        : Colors.grey[600];
    final iconColor = isDark
        ? whiteColorDark.withValues(alpha: 0.3)
        : Colors.grey[300];

    if (books.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(emptyIcon, size: 64, color: iconColor),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: bodyLarge.copyWith(color: secondaryTextColor),
            ),
          ],
        ),
      );
    }
    return BooksGrid(
      books: books,
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? scaffoldBackgroundColorDark
        : scaffoldBackgroundColor;
    final textColor = isDark ? whiteColorDark : blackColor;
    final accentColor = isDark ? primaryColorDark : primaryColor;
    final unselectedTabColor = isDark
        ? whiteColorDark.withValues(alpha: 0.5)
        : Colors.grey;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          'My Library',
          style: displaySmall.copyWith(fontSize: 24, color: textColor),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: accentColor,
          unselectedLabelColor: unselectedTabColor,
          indicatorColor: accentColor,
          labelPadding: const EdgeInsets.symmetric(horizontal: 2),
          tabs: [
            Tab(
              child: Consumer2<LibraryProvider, ProgressProvider>(
                builder: (context, libraryProvider, progressProvider, _) {
                  final readingBooks = libraryProvider.getReadingBooks(
                    progressProvider.bookProgress,
                  );
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Reading'),
                      const SizedBox(width: 4),
                      LibraryTabBadge(count: readingBooks.length.toString()),
                    ],
                  );
                },
              ),
            ),
            Tab(
              child: Consumer2<LibraryProvider, ProgressProvider>(
                builder: (context, libraryProvider, progressProvider, _) {
                  final completedBooks = libraryProvider.getAlreadyReadBooks(
                    progressProvider.bookProgress,
                  );
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already Read'),
                      const SizedBox(width: 4),
                      LibraryTabBadge(count: completedBooks.length.toString()),
                    ],
                  );
                },
              ),
            ),
            Tab(
              child: Consumer<LibraryProvider>(
                builder: (context, libraryProvider, _) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Shelves'),
                      const SizedBox(width: 4),
                      LibraryTabBadge(
                        count: libraryProvider.libraryBooks.length.toString(),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: Consumer2<LibraryProvider, ProgressProvider>(
        builder: (context, libraryProvider, progressProvider, child) {
          if (libraryProvider.busy || progressProvider.busy) {
            return Center(child: CircularProgressIndicator(color: accentColor));
          }

          final readingBooks = libraryProvider.getReadingBooks(
            progressProvider.bookProgress,
          );
          final completedBooks = libraryProvider.getAlreadyReadBooks(
            progressProvider.bookProgress,
          );
          final allBooks = libraryProvider.getAllLibraryBooks();

          return TabBarView(
            controller: _tabController,
            children: [
              // Reading Tab
              _buildBookList(
                context,
                readingBooks,
                'You are not reading any books',
                Icons.menu_book,
              ),

              // Already Read Tab
              _buildBookList(
                context,
                completedBooks,
                'You haven\'t finished any books yet',
                Icons.done_all,
              ),

              // Shelves (All Books) Tab
              _buildBookList(
                context,
                allBooks,
                'Your library is empty',
                Icons.library_books,
              ),
            ],
          );
        },
      ),
    );
  }
}
