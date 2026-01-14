import 'package:book_reader_app/providers/base_provider.dart';
import 'package:book_reader_app/services/api.dart';

class CartProvider extends BaseProvider {
  Map<String, dynamic>? _cart;
  List<Map<String, dynamic>> _cartItems = [];

  final Api _api = Api();

  // Getters
  Map<String, dynamic>? get cart => _cart;
  List<Map<String, dynamic>> get cartItems => _cartItems;
  double get total => _calculateTotal();
  double get subtotal => _calculateSubtotal();
  int get itemCount => _cartItems.length;

  double _calculateTotal() {
    return _calculateSubtotal(); // Add tax/shipping if needed
  }

  double _calculateSubtotal() {
    double total = 0.0;
    for (var item in _cartItems) {
      final book = item['book'] ?? {};
      final price = (book['price'] ?? 0.0).toDouble();
      final quantity = (item['quantity'] ?? 1).toInt();
      total += price * quantity;
    }
    return total;
  }

  // Load cart from API
  Future<void> loadCart() async {
    setBusy(true);
    try {
      final response = await _api.getCart();
      if (response['success'] == true) {
        _cart = response['data'];
        _cartItems = List<Map<String, dynamic>>.from(
          _cart?['items'] ?? [],
        );
        setBusy(false);
      } else {
        setFailed(true);
        setErrorMessage(response['message'] ?? 'Failed to load cart');
        setBusy(false);
      }
    } catch (e) {
      setFailed(true);
      setErrorMessage(e.toString());
      setBusy(false);
    }
  }

  // Add book to cart
  Future<void> addBookToCart(int bookId) async {
    setBusy(true);
    try {
      await _api.addBookToCart(bookId);
      // Reload cart
      await loadCart();
      setBusy(false);
    } catch (e) {
      setFailed(true);
      setErrorMessage(e.toString());
      setBusy(false);
    }
  }

  // Remove book from cart
  Future<void> removeBookFromCart(int bookId) async {
    setBusy(true);
    try {
      await _api.removeBookFromCart(bookId);
      // Reload cart
      await loadCart();
      setBusy(false);
    } catch (e) {
      setFailed(true);
      setErrorMessage(e.toString());
      setBusy(false);
    }
  }

  // Checkout
  Future<Map<String, dynamic>?> checkout() async {
    setBusy(true);
    try {
      final response = await _api.checkout();
      if (response['success'] == true) {
        // Clear cart after successful checkout
        _cart = null;
        _cartItems = [];
        setBusy(false);
        return response['data'];
      } else {
        setFailed(true);
        setErrorMessage(response['message'] ?? 'Checkout failed');
        setBusy(false);
        return null;
      }
    } catch (e) {
      setFailed(true);
      setErrorMessage(e.toString());
      setBusy(false);
      return null;
    }
  }
}

