import 'package:book_reader_app/helpers/consts.dart';
import 'package:book_reader_app/helpers/ui_utils.dart';
import 'package:book_reader_app/providers/library_provider.dart';
import 'package:book_reader_app/providers/progress_provider.dart';
import 'package:book_reader_app/screens/main/book_details_screen.dart';
import 'package:book_reader_app/theme/app_colors.dart';
import 'package:book_reader_app/widgets/books_grid.dart';
import 'package:book_reader_app/widgets/common/empty_state.dart';
import 'package:book_reader_app/widgets/common/skeletons.dart';
import 'package:book_reader_app/widgets/library_tab_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isSelectionMode = false;
  final Set<int> _selectedBookIds = {};

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
    IconData emptyIcon, {
    Map<int, Map<String, dynamic>>? progressMap,
  }) {
    if (books.isEmpty) {
      return EmptyState(icon: emptyIcon, title: emptyMessage);
    }
    return BooksGrid(
      books: books,
      isSelectionMode: _isSelectionMode,
      selectedBookIds: _selectedBookIds,
      progressMap: progressMap,
      onBookTap: _isSelectionMode
          ? (book) {
              setState(() {
                final bookId = book['id'];
                if (bookId != null) {
                  final bookIdInt = bookId is int
                      ? bookId
                      : int.tryParse(bookId.toString());
                  if (bookIdInt != null) {
                    if (_selectedBookIds.contains(bookIdInt)) {
                      _selectedBookIds.remove(bookIdInt);
                    } else {
                      _selectedBookIds.add(bookIdInt);
                    }
                  }
                }
              });
            }
          : (book) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookDetailsScreen(book: book),
                ),
              );
            },
    );
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedBookIds.clear();
      }
    });
  }

  Future<void> _removeSelectedBooks() async {
    if (_selectedBookIds.isEmpty) return;

    final libraryProvider = Provider.of<LibraryProvider>(
      context,
      listen: false,
    );
    final bookIds = _selectedBookIds.toList();

    // Show confirmation dialog
    final confirmed = await UiUtils.showConfirmDialog(
      context,
      title: 'Remove Books',
      message:
          'Are you sure you want to remove ${bookIds.length} book(s) from your library?',
      confirmText: 'Remove',
      confirmColor: AppColors.of(context).danger,
    );

    if (confirmed && mounted) {
      try {
        await libraryProvider.removeBooksFromLibrary(bookIds);
        if (mounted) {
          UiUtils.showSuccessSnackBar(
            context,
            '${bookIds.length} book(s) removed successfully',
          );
        }
        setState(() {
          _selectedBookIds.clear();
          _isSelectionMode = false;
        });
      } catch (e) {
        if (mounted) {
          UiUtils.showErrorSnackBar(
            context,
            libraryProvider.errorMessage ?? 'Failed to remove books',
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
          statusBarBrightness: brightness,
        ),
        title: _isSelectionMode
            ? Text(
                '${_selectedBookIds.length} selected',
                style: displaySmall.copyWith(
                  fontSize: 24,
                  color: colors.onSurface,
                ),
              )
            : Text(
                'My Library',
                style: displaySmall.copyWith(
                  fontSize: 24,
                  color: colors.onSurface,
                ),
              ),
        actions: [
          if (_isSelectionMode)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: colors.onSurface,
              onPressed: _selectedBookIds.isEmpty ? null : _removeSelectedBooks,
            ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: colors.onSurface),
            onSelected: (value) {
              if (value == 'select') {
                _toggleSelectionMode();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'select',
                child: Row(
                  children: [
                    Icon(
                      _isSelectionMode
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      color: colors.primary,
                    ),
                    const SizedBox(width: spacingSmall + 4),
                    Text(_isSelectionMode ? 'Cancel Selection' : 'Select'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: colors.primary,
          unselectedLabelColor: colors.secondaryText,
          indicatorColor: colors.primary,
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
            return const BooksGridSkeleton();
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
              // Reading Tab - Pass progressMap to show progress circles
              RefreshIndicator(
                onRefresh: () async {
                  await Future.wait([
                    libraryProvider.loadLibrary(),
                    progressProvider.loadAllProgress(),
                  ]);
                },
                color: colors.primary,
                child: _buildBookList(
                  context,
                  readingBooks,
                  'You are not reading any books',
                  Icons.menu_book,
                  progressMap: progressProvider.bookProgress,
                ),
              ),

              // Already Read Tab
              RefreshIndicator(
                onRefresh: () async {
                  await Future.wait([
                    libraryProvider.loadLibrary(),
                    progressProvider.loadAllProgress(),
                  ]);
                },
                color: colors.primary,
                child: _buildBookList(
                  context,
                  completedBooks,
                  'You haven\'t finished any books yet',
                  Icons.done_all,
                ),
              ),

              // Shelves (All Books) Tab
              RefreshIndicator(
                onRefresh: () async {
                  await Future.wait([
                    libraryProvider.loadLibrary(),
                    progressProvider.loadAllProgress(),
                  ]);
                },
                color: colors.primary,
                child: _buildBookList(
                  context,
                  allBooks,
                  'Your library is empty',
                  Icons.library_books,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
