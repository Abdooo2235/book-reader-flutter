import 'package:book_reader_app/helpers/consts.dart';
import 'package:book_reader_app/widgets/book_card.dart';
import 'package:flutter/material.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({super.key});

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  // Placeholder data - will be replaced with API data
  final List<Map<String, dynamic>> favouriteBooks = [
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Favourites',
                  style: bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.black87,
                  ),
                ),
                IconButton(onPressed: ( ) {
                  
                }, icon: Icon(Icons.more_vert)),
              ],
            ),
          ),
          Divider(color: primaryColor, thickness: 0.25),
          Expanded(
            child: favouriteBooks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 64,
                          color: primaryColor.withOpacity(0.5),
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
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.52,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 24,
                        ),
                    itemCount: favouriteBooks.length,
                    itemBuilder: (context, index) {
                      final book = favouriteBooks[index];
                      return BookCard(
                        title: book['title'],
                        progress: book['progress'],
                        coverColor: book['color'],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
