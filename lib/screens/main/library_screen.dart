import 'package:book_reader_app/helpers/consts.dart';
import 'package:book_reader_app/widgets/book_card.dart';
import 'package:book_reader_app/widgets/book_card_shimmer.dart';
import 'package:flutter/material.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isLoading = true; // Show shimmer temporarily
  List<Map<String, dynamic>> books = []; // Will show placeholders then API data
  bool isSelecting = false;
  bool isSearching = false;
  String searchQuery = '';
  Set<int> selectedBooks = {};

  // Placeholder books - will be replaced with API data
  final List<Map<String, dynamic>> placeholderBooks = [
    {
      'title': 'The Great Adventure',
      'progress': 45.0,
      'color': const Color(0xff7A4A2E),
    },
    {
      'title': 'Mystery of the Night',
      'progress': 78.0,
      'color': const Color(0xffB5533C),
    },
    {
      'title': 'Journey to Success',
      'progress': 23.0,
      'color': const Color(0xff6B8E4E),
    },
    {
      'title': 'Ocean Dreams',
      'progress': 90.0,
      'color': const Color(0xff4A7C8E),
    },
    {
      'title': 'Mountain Tales',
      'progress': 12.0,
      'color': const Color(0xff8B6F47),
    },
    {
      'title': 'City Lights',
      'progress': 56.0,
      'color': const Color(0xff9B7A5A),
    },
    {
      'title': 'Forest Secrets',
      'progress': 34.0,
      'color': const Color(0xff5A7A4A),
    },
    {
      'title': 'Desert Winds',
      'progress': 67.0,
      'color': const Color(0xffC4A484),
    },
    {
      'title': 'Starry Nights',
      'progress': 89.0,
      'color': const Color(0xff6B5A7A),
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _onTabChanged();
      }
    });
    // Show shimmer temporarily, then show placeholders
    _loadBooks();
  }

  void _onTabChanged() {
    setState(() {
      isLoading = true; // Show shimmer when tab changes
    });
    _loadBooks();
  }

  void _loadBooks() {
    // Show shimmer temporarily, then show placeholders
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          isLoading = false;
          books = placeholderBooks; // Show placeholders until API data arrives
        });
      }
    });
    // TODO: Load books from API based on selected tab
    // Example:
    // loadBooks(_tabController.index);
  }

  // TODO: Replace this with your actual API call
  // Future<void> loadBooks(int tabIndex) async {
  //   setState(() {
  //     isLoading = true; // Show shimmer while loading
  //   });
  //   try {
  //     final data = await yourApiService.getLibraryBooks(tabIndex);
  //     setState(() {
  //       books = data; // Replace placeholders with real data
  //       isLoading = false;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       books = placeholderBooks; // Keep placeholders on error
  //       isLoading = false;
  //     });
  //   }
  // }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      isSearching = !isSearching;
      if (!isSearching) {
        searchQuery = '';
      }
    });
  }

  List<Map<String, dynamic>> _filterBooks(String query) {
    if (query.isEmpty) {
      return books;
    }

    final lowerQuery = query.toLowerCase();
    return books.where((book) {
      final title = (book['title'] ?? '').toString().toLowerCase();
      final author = (book['author'] ?? '').toString().toLowerCase();
      return title.contains(lowerQuery) || author.contains(lowerQuery);
    }).toList();
  }

  PopupMenuItem _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return PopupMenuItem(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: iconColor ?? primaryColor, size: 20),
              const SizedBox(width: 12),
              Text(
                title,
                style: bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: textColor ?? blackColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _removeSelectedBooks() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Remove Books',
          style: labelMedium.copyWith(color: blackColor),
        ),
        content: Text(
          'Are you sure you want to remove ${selectedBooks.length} book(s) from your library?',
          style: bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: bodyMedium.copyWith(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                // Remove selected books
                books.removeWhere((book) {
                  final index = books.indexOf(book);
                  return selectedBooks.contains(index);
                });
                selectedBooks.clear();
                isSelecting = false;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Books removed successfully',
                          style: bodyMedium.copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: greenColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(16),
                ),
              );
              // TODO: Remove books from API
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: redColor,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Remove',
              style: bodyMedium.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (isSelecting)
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.black87,
                            ),
                            onPressed: () {
                              setState(() {
                                isSelecting = false;
                                selectedBooks.clear();
                              });
                            },
                          ),
                          Text(
                            '${selectedBooks.length} selected',
                            style: bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        'Library',
                        style: bodySmall.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: Colors.black87,
                        ),
                      ),
                    Row(
                      children: [
                        if (isSelecting && selectedBooks.isNotEmpty)
                          IconButton(
                            icon: Icon(Icons.delete_outline, color: redColor),
                            onPressed: _removeSelectedBooks,
                          ),
                        if (!isSelecting)
                          IconButton(
                            icon: Icon(
                              isSearching ? Icons.close : Icons.search,
                              color: Colors.black87,
                            ),
                            onPressed: _toggleSearch,
                          ),
                        PopupMenuButton(
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.black87,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 8,
                          color: whiteColor,
                          itemBuilder: (context) => [
                            _buildMenuItem(
                              icon: Icons.select_all,
                              title: isSelecting
                                  ? 'Exit Selection'
                                  : 'Select Items',
                              iconColor: primaryColor,
                              onTap: () {
                                Navigator.pop(context);
                                setState(() {
                                  isSelecting = !isSelecting;
                                  if (!isSelecting) {
                                    selectedBooks.clear();
                                  }
                                });
                              },
                            ),
                            if (isSelecting && selectedBooks.isNotEmpty)
                              _buildMenuItem(
                                icon: Icons.delete_outline,
                                title:
                                    'Remove Selected (${selectedBooks.length})',
                                iconColor: redColor,
                                textColor: redColor,
                                onTap: () {
                                  Navigator.pop(context);
                                  _removeSelectedBooks();
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                if (isSearching)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    child: TextField(
                      autofocus: true,
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.backspace,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    searchQuery = '';
                                  });
                                },
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
          TabBar(
            controller: _tabController,
            indicatorColor: primaryColor,
            labelStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
            unselectedLabelColor: Colors.grey[600],
            tabs: const [
              Tab(text: 'Reading'),
              Tab(text: 'Already Read'),
              Tab(text: 'Shelves'),
            ],
          ),
          // Books Grid with Shimmer Loading Placeholders
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Reading Tab
                _buildTabContent(),
                // Already Read Tab
                _buildTabContent(),
                // Shelves Tab
                _buildTabContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    final displayBooks = _filterBooks(searchQuery);

    if (isLoading || books.isEmpty) {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.52,
          crossAxisSpacing: 12,
          mainAxisSpacing: 24,
        ),
        itemCount: 9, // Show 9 shimmer placeholders
        itemBuilder: (context, index) {
          return const BookCardShimmer();
        },
      );
    }

    if (displayBooks.isEmpty && searchQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: primaryColor.withOpacity(0.5),
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

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.52,
        crossAxisSpacing: 12,
        mainAxisSpacing: 24,
      ),
      itemCount: displayBooks.length,
      itemBuilder: (context, index) {
        final book = displayBooks[index];
        final originalIndex = books.indexOf(book);
        final isSelected = selectedBooks.contains(originalIndex);

        return GestureDetector(
          onTap: () {
            if (isSelecting) {
              setState(() {
                if (isSelected) {
                  selectedBooks.remove(originalIndex);
                } else {
                  selectedBooks.add(originalIndex);
                }
              });
            }
            // TODO: Navigate to book details
          },
          onLongPress: () {
            if (!isSelecting) {
              setState(() {
                isSelecting = true;
                selectedBooks.add(originalIndex);
              });
            }
          },
          child: Stack(
            children: [
              BookCard(
                title: book['title'] ?? '',
                progress: book['progress']?.toDouble() ?? 0.0,
                coverColor: book['color'] ?? primaryColor,
              ),
              if (isSelecting)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isSelected ? primaryColor : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? primaryColor : Colors.grey,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
