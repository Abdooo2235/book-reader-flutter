import 'package:book_reader_app/helpers/consts.dart';
import 'package:book_reader_app/widgets/cart_item.dart';
import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
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
                  'Cart',
                  style: bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: primaryColor, thickness: 0.25),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 8),
              children: [
                CartItem(
                  title: '',
                  author: '',
                  imageUrl: '',
                  price: 1,
                  quantity: 1,
                  onRemove: () {},
                  onIncrease: () {},
                  onDecrease: () {},
                ),
                CartItem(
                  title: '',
                  author: '',
                  imageUrl: '',
                  price: 1,
                  quantity: 1,
                  onRemove: () {},
                  onIncrease: () {},
                  onDecrease: () {},
                ),
                CartItem(
                  title: '',
                  author: '',
                  imageUrl: '',
                  price: 1,
                  quantity: 1,
                  onRemove: () {},
                  onIncrease: () {},
                  onDecrease: () {},
                ),
                CartItem(
                  title: '',
                  author: '',
                  imageUrl: '',
                  price: 1,
                  quantity: 1,
                  onRemove: () {},
                  onIncrease: () {},
                  onDecrease: () {},
                ),
              ],
            ),
          ),
          // Total and Checkout Section
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(25),
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
                            style: bodyMedium.copyWith(color: Colors.grey[700]),
                          ),
                          Text(
                            '\$100.00',
                            style: bodyMedium.copyWith(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: labelMedium.copyWith(color: blackColor),
                          ),
                          Text(
                            '\$100.00',
                            style: labelMedium.copyWith(
                              color: primaryColor,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Divider(color: Colors.grey[300], height: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle checkout
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
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
  }
}
