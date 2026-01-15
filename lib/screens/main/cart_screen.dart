import 'package:book_reader_app/helpers/consts.dart';
import 'package:book_reader_app/providers/cart_provider.dart';
import 'package:book_reader_app/widgets/cart_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    // Load cart on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      cartProvider.loadCart();
    });
  }

  Future<void> _handleCheckout() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    if (cartProvider.cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Your cart is empty',
            style: bodyMedium.copyWith(color: Colors.white),
          ),
          backgroundColor: redColor,
        ),
      );
      return;
    }

    // Show loading indicator
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
    }

    try {
      final result = await cartProvider.checkout();

      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        if (result != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Checkout successful!',
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
        }
      }
    } catch (e) {
      if (mounted) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop(); // Close loading dialog
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    cartProvider.errorMessage ??
                        'Checkout failed. Please try again.',
                    style: bodyMedium.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: redColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? surfaceColorDark : Colors.white;
    final textColor = isDark ? whiteColorDark : blackColor;
    final secondaryTextColor = isDark
        ? whiteColorDark.withValues(alpha: 0.6)
        : Colors.grey[600];
    final tertiaryTextColor = isDark
        ? whiteColorDark.withValues(alpha: 0.5)
        : Colors.grey[500];
    final accentColor = isDark ? primaryColorDark : primaryColor;
    final dividerColor = isDark
        ? whiteColorDark.withValues(alpha: 0.1)
        : Colors.grey[300];

    return Consumer<CartProvider>(
      builder: (context, cartProvider, _) {
        return Scaffold(
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 1,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cart',
                      style: bodySmall.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(color: accentColor, thickness: 0.25),
              Expanded(
                child: cartProvider.busy
                    ? Center(
                        child: CircularProgressIndicator(color: accentColor),
                      )
                    : cartProvider.cartItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 64,
                              color: accentColor.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Your cart is empty',
                              style: bodyLarge.copyWith(
                                color: secondaryTextColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add books to your cart',
                              style: bodyMedium.copyWith(
                                color: tertiaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 8),
                        itemCount: cartProvider.cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartProvider.cartItems[index];
                          final book = item['book'] ?? {};
                          final bookId = book['id'];

                          return CartItem(
                            title: book['title']?.toString() ?? 'Unknown',
                            author: book['author']?.toString() ?? 'Unknown',
                            imageUrl: book['cover_image']?.toString() ?? '',
                            price: (book['price'] ?? 0.0).toDouble(),
                            quantity: (item['quantity'] ?? 1).toInt(),
                            onRemove: () {
                              if (bookId != null) {
                                cartProvider.removeBookFromCart(bookId);
                              }
                            },
                            onIncrease: () {
                              // Note: API might not support quantity update directly
                              // This is a placeholder - you may need to implement quantity update in API
                            },
                            onDecrease: () {
                              // Note: API might not support quantity update directly
                              // This is a placeholder - you may need to implement quantity update in API
                            },
                          );
                        },
                      ),
              ),
              // Total and Checkout Section
              if (cartProvider.cartItems.isNotEmpty)
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(isDark ? 50 : 25),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Subtotal',
                                  style: bodyMedium.copyWith(
                                    color: secondaryTextColor,
                                  ),
                                ),
                                Text(
                                  '\$${cartProvider.subtotal.toStringAsFixed(2)}',
                                  style: bodyMedium.copyWith(
                                    color: secondaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total',
                                  style: labelMedium.copyWith(color: textColor),
                                ),
                                Text(
                                  '\$${cartProvider.total.toStringAsFixed(2)}',
                                  style: labelMedium.copyWith(
                                    color: accentColor,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Divider(color: dividerColor, height: 1),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: cartProvider.busy
                                ? null
                                : _handleCheckout,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: cartProvider.busy
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Checkout',
                                    style: labelMedium.copyWith(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
