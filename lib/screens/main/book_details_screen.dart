import 'package:book_reader_app/helpers/consts.dart';
import 'package:book_reader_app/helpers/cover_utils.dart';
import 'package:book_reader_app/helpers/ui_utils.dart';
import 'package:book_reader_app/providers/book_provider.dart';
import 'package:book_reader_app/providers/library_provider.dart';
import 'package:book_reader_app/screens/main/book_reader_screen.dart';
import 'package:book_reader_app/theme/app_colors.dart';
import 'package:book_reader_app/widgets/common/app_button.dart';
import 'package:provider/provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BookDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> book;

  const BookDetailsScreen({super.key, required this.book});

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  bool _isDownloading = false;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    final title = widget.book['title']?.toString() ?? 'Untitled';
    final author = widget.book['author']?.toString() ?? 'Unknown Author';
    final pages =
        widget.book['number_of_pages']?.toString() ??
        widget.book['pages']?.toString() ??
        'Unknown';
    final format =
        widget.book['file_type']?.toString() ??
        widget.book['format']?.toString() ??
        'E-Book';
    final description =
        widget.book['description']?.toString() ??
        'No description available for this book.';

    final coverColor = CoverUtils.colorFor(title);
    final coverUrl = CoverUtils.resolveUrl(widget.book);
    final heroTag = 'book-cover-${widget.book['id']}';

    return Scaffold(
      backgroundColor: colors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 380,
            pinned: true,
            stretch: true,
            backgroundColor: colors.background,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: isDark
                  ? Brightness.light
                  : Brightness.dark,
              statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: colors.onSurface),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              Consumer<BookProvider>(
                builder: (context, bookProvider, child) {
                  final isFav = bookProvider.isFavorite(widget.book);
                  return IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? colors.danger : colors.onSurface,
                    ),
                    onPressed: () async {
                      try {
                        await bookProvider.toggleFavorite(widget.book);
                      } catch (e) {
                        if (context.mounted) {
                          UiUtils.showErrorSnackBar(
                            context,
                            'Failed to update favorite: ${e.toString()}',
                          );
                        }
                      }
                    },
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: spacingLarge),
                  child: Center(
                    child: Hero(
                      tag: heroTag,
                      child: _CoverArtwork(
                        coverColor: coverColor,
                        coverUrl: coverUrl,
                        shadowColor: colors.shadow,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(spacingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _stagger(
                    reduceMotion,
                    0,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: displayMedium.copyWith(
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: spacingSmall),
                        Text(
                          author,
                          style: bodyMedium.copyWith(
                            color: colors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: spacingLarge),
                  _stagger(
                    reduceMotion,
                    1,
                    Row(
                      children: [
                        _buildBadge(context, Icons.menu_book, '$pages pages'),
                        const SizedBox(width: spacingMedium),
                        _buildBadge(
                          context,
                          Icons.description,
                          format.toUpperCase(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: spacingXLarge),
                  _stagger(
                    reduceMotion,
                    2,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Description',
                          style: labelLarge.copyWith(color: colors.onSurface),
                        ),
                        const SizedBox(height: spacingMedium),
                        Text(
                          description,
                          style: bodyMedium.copyWith(
                            color: colors.secondaryText,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: spacingXLarge),
                  _stagger(
                    reduceMotion,
                    3,
                    PrimaryButton(
                      label: 'Download & Read',
                      icon: Icons.download,
                      busy: _isDownloading,
                      onPressed: _downloadAndRead,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Fades a section in (always) and slides it up (only when motion is allowed),
  /// staggered by [index] so sections cascade into place.
  Widget _stagger(bool reduceMotion, int index, Widget child) {
    final animated = child
        .animate(delay: staggerStep * index)
        .fadeIn(duration: animationDurationShort, curve: easeOutStrong);
    if (reduceMotion) return animated;
    return animated.slideY(
      begin: 0.12,
      end: 0,
      duration: animationDurationShort,
      curve: easeOutStrong,
    );
  }

  Future<void> _downloadAndRead() async {
    final bookId = widget.book['id'];
    if (bookId == null) {
      UiUtils.showErrorSnackBar(context, 'Unable to download book');
      return;
    }

    setState(() => _isDownloading = true);

    try {
      // Mark as reading in library
      final libraryProvider = Provider.of<LibraryProvider>(
        context,
        listen: false,
      );
      await libraryProvider.markAsReading(bookId);

      if (mounted) {
        // Navigate to book reader
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookReaderScreen(book: widget.book),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        UiUtils.showErrorSnackBar(
          context,
          'Failed to start reading: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  Widget _buildBadge(BuildContext context, IconData icon, String text) {
    final colors = AppColors.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: spacingMedium,
        vertical: spacingSmall,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(borderRadiusXLarge),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colors.primary),
          const SizedBox(width: spacingSmall - 2),
          Text(text, style: labelSmall.copyWith(color: colors.onSurface)),
        ],
      ),
    );
  }
}

/// The centered book cover shown in the collapsing header. Renders the network
/// cover when available, otherwise a deterministic colored placeholder.
class _CoverArtwork extends StatelessWidget {
  const _CoverArtwork({
    required this.coverColor,
    required this.coverUrl,
    required this.shadowColor,
  });

  final Color coverColor;
  final String? coverUrl;
  final Color shadowColor;

  @override
  Widget build(BuildContext context) {
    const width = 170.0;
    const height = 250.0;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: coverColor,
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: coverUrl != null && coverUrl!.isNotEmpty
          ? Image.network(
              coverUrl!,
              fit: BoxFit.cover,
              width: width,
              height: height,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                    strokeWidth: 2,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) => _placeholder(),
            )
          : _placeholder(),
    );
  }

  Widget _placeholder() {
    return Center(
      child: Icon(
        Icons.book,
        size: 64,
        color: Colors.white.withValues(alpha: 0.5),
      ),
    );
  }
}
