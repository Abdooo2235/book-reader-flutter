import 'package:book_reader_app/helpers/consts.dart';
import 'package:book_reader_app/widgets/book_card_shimmer.dart';
import 'package:book_reader_app/widgets/books_grid.dart';
import 'package:book_reader_app/widgets/category_chip.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> categories = [
    "Fiction",
    "Non-Fiction",
    "Science",
    "History",
    "Romance",
  ];
  int selectedIndex = 0;
  bool isLoading = true; // Show shimmer temporarily
  bool isSearching = false;
  String searchQuery = '';
  List<Map<String, dynamic>> books = []; // Will show placeholders then API data

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
    // Show shimmer temporarily, then show placeholders
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          isLoading = false;
          books = placeholderBooks; // Show placeholders until API data arrives
        });
      }
    });
    // TODO: Load books from API here
    // Example:
    // loadBooks();
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

  // TODO: Replace this with your actual API call
  // Future<void> loadBooks() async {
  //   setState(() {
  //     isLoading = true; // Show shimmer while loading
  //   });
  //   try {
  //     final data = await yourApiService.getBooks(categories[selectedIndex]);
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

  void _showAddBookDialog() {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final authorController = TextEditingController();
    final publishYearController = TextEditingController();
    final descriptionController = TextEditingController();
    final imageUrlController = TextEditingController();
    final pagesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 650),
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with accent border
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.05),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: primaryColor.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.add_circle_outline,
                              color: primaryColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Add New Book',
                            style: labelLarge.copyWith(color: blackColor),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.grey[600]),
                        onPressed: () => Navigator.pop(context),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey[100],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Form Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title Field
                        TextFormField(
                          controller: titleController,
                          decoration: InputDecoration(
                            labelText: 'Title',
                            prefixIcon: Icon(Icons.title, color: primaryColor),
                            labelStyle: bodyMedium.copyWith(
                              color: Colors.grey[600],
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: primaryColor.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: primaryColor.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: primaryColor,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: scaffoldBackgroundColor,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          style: bodyMedium.copyWith(color: blackColor),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter book title';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Author Field
                        TextFormField(
                          controller: authorController,
                          decoration: InputDecoration(
                            labelText: 'Author',
                            prefixIcon: Icon(Icons.person, color: primaryColor),
                            labelStyle: bodyMedium.copyWith(
                              color: Colors.grey[600],
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: primaryColor.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: primaryColor.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: primaryColor,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: scaffoldBackgroundColor,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          style: bodyMedium.copyWith(color: blackColor),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter author name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Publish Year and Pages Row
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: publishYearController,
                                decoration: InputDecoration(
                                  labelText: 'Publish Year',
                                  prefixIcon: Icon(
                                    Icons.calendar_today,
                                    color: primaryColor,
                                    size: 20,
                                  ),
                                  labelStyle: bodyMedium.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: primaryColor.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: primaryColor.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: primaryColor,
                                      width: 2,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: scaffoldBackgroundColor,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                ),
                                style: bodyMedium.copyWith(color: blackColor),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  final year = int.tryParse(value);
                                  if (year == null ||
                                      year < 1000 ||
                                      year > DateTime.now().year) {
                                    return 'Invalid year';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: pagesController,
                                decoration: InputDecoration(
                                  labelText: 'Number of Pages',
                                  prefixIcon: Icon(
                                    Icons.menu_book,
                                    color: primaryColor,
                                    size: 20,
                                  ),
                                  labelStyle: bodyMedium.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: primaryColor.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: primaryColor.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: primaryColor,
                                      width: 2,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: scaffoldBackgroundColor,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                ),
                                style: bodyMedium.copyWith(color: blackColor),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  final pages = int.tryParse(value);
                                  if (pages == null || pages <= 0) {
                                    return 'Invalid';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Image URL Field
                        TextFormField(
                          controller: imageUrlController,
                          decoration: InputDecoration(
                            labelText: 'Image URL',
                            prefixIcon: Icon(Icons.image, color: primaryColor),
                            labelStyle: bodyMedium.copyWith(
                              color: Colors.grey[600],
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: primaryColor.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: primaryColor.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: primaryColor,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: scaffoldBackgroundColor,
                            hintText: 'Enter image URL or leave empty',
                            hintStyle: bodySmall.copyWith(
                              color: Colors.grey[400],
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          style: bodyMedium.copyWith(color: blackColor),
                        ),
                        const SizedBox(height: 16),

                        // Description Field
                        TextFormField(
                          controller: descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(bottom: 60),
                              child: Icon(
                                Icons.description,
                                color: primaryColor,
                              ),
                            ),
                            alignLabelWithHint: true,
                            labelStyle: bodyMedium.copyWith(
                              color: Colors.grey[600],
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: primaryColor.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: primaryColor.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: primaryColor,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: scaffoldBackgroundColor,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          style: bodyMedium.copyWith(color: blackColor),
                          maxLines: 4,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter book description';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // Action Buttons Footer
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    border: Border(
                      top: BorderSide(
                        color: primaryColor.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          side: BorderSide(color: Colors.grey[400]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: bodyMedium.copyWith(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            // TODO: Save book to API
                            // final newBook = {
                            //   'title': titleController.text,
                            //   'author': authorController.text,
                            //   'publishYear': int.parse(publishYearController.text),
                            //   'description': descriptionController.text,
                            //   'imageUrl': imageUrlController.text,
                            //   'pages': int.parse(pagesController.text),
                            // };
                            // await yourApiService.addBook(newBook);

                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Book "${titleController.text}" added successfully!',
                                        style: bodyMedium.copyWith(
                                          color: Colors.white,
                                        ),
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
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Add Book',
                              style: labelSmall.copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Home',
                      style: bodySmall.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isSearching ? Icons.close : Icons.search,
                        color: Colors.black87,
                      ),
                      onPressed: _toggleSearch,
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
          // Category Chips Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: Row(
              children: List.generate(
                categories.length,
                (index) => CategoryChip(
                  label: categories[index],
                  isSelected: selectedIndex == index,
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                      isLoading = true; // Show shimmer when changing category
                    });
                    // Show shimmer briefly, then placeholders
                    Future.delayed(const Duration(milliseconds: 1200), () {
                      if (mounted) {
                        setState(() {
                          isLoading = false;
                          books = placeholderBooks;
                        });
                      }
                    });
                    // TODO: filter books by category here
                    // loadBooks(); // Reload books when category changes
                  },
                ),
              ),
            ),
          ),

          // Books Grid with Shimmer Loading Placeholders
          Expanded(
            child: isLoading || books.isEmpty
                ? GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.52,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 24,
                        ),
                    itemCount: 9, // Show 9 shimmer placeholders
                    itemBuilder: (context, index) {
                      return const BookCardShimmer();
                    },
                  )
                : _buildBooksContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildBooksContent() {
    final displayBooks = _filterBooks(searchQuery);

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

    return BooksGrid(books: displayBooks);
  }
}
