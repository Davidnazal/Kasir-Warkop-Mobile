import 'package:flutter/foundation.dart';

import '../data/models/cart_item_model.dart';
import '../data/models/product_model.dart';
import '../data/models/transaction_model.dart';
import '../data/services/api_service.dart';

/// Mengelola state keranjang belanja, pencarian menu, dan proses checkout.
class PosProvider extends ChangeNotifier {
  PosProvider({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  final ApiService _apiService;
  final List<CartItemModel> _cart = [];
  String _searchQuery = '';
  PaymentMethod _paymentMethod = PaymentMethod.cash;
  bool _isSubmitting = false;

  List<CartItemModel> get cart => List.unmodifiable(_cart);
  String get searchQuery => _searchQuery;
  PaymentMethod get paymentMethod => _paymentMethod;
  bool get isSubmitting => _isSubmitting;

  int get totalItems => _cart.fold(0, (sum, item) => sum + item.quantity);
  int get subtotal => _cart.fold(0, (sum, item) => sum + item.subtotal);

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setPaymentMethod(PaymentMethod method) {
    _paymentMethod = method;
    notifyListeners();
  }

  void addToCart(ProductModel product) {
    final index = _cart.indexWhere((e) => e.product.id == product.id);
    if (index >= 0) {
      if (_cart[index].quantity < product.stock) {
        _cart[index].quantity++;
      }
    } else if (product.stock > 0) {
      _cart.add(CartItemModel(product: product));
    }
    notifyListeners();
  }

  void updateQuantity(int productId, int delta) {
    final index = _cart.indexWhere((e) => e.product.id == productId);
    if (index < 0) return;

    final newQty = _cart[index].quantity + delta;
    if (newQty <= 0) {
      _cart.removeAt(index);
    } else if (newQty <= _cart[index].product.stock) {
      _cart[index].quantity = newQty;
    }
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  Future<TransactionModel> submitTransaction(
    int payAmount, {
    bool isDemoMode = false,
  }) async {
    _isSubmitting = true;
    notifyListeners();
    try {
      if (isDemoMode) {
        if (payAmount < subtotal) {
          throw Exception('Uang pembayaran kurang!');
        }
        final details = _cart
            .map(
              (item) => TransactionDetailModel(
                productId: item.product.id,
                productName: item.product.name,
                quantity: item.quantity,
                price: item.product.price,
                subtotal: item.subtotal,
              ),
            )
            .toList();
        final tx = TransactionModel(
          invoiceNumber:
              'INV-DEMO-${DateTime.now().millisecondsSinceEpoch % 10000}',
          totalPrice: subtotal,
          payAmount: payAmount,
          changeAmount: payAmount - subtotal,
          paymentMethod: _paymentMethod,
          createdAt: DateTime.now(),
          details: details,
        );
        _cart.clear();
        return tx;
      }

      final result = await _apiService.createTransaction(
        items: _cart,
        payAmount: payAmount,
        paymentMethod: _paymentMethod,
      );
      _cart.clear();
      return result;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
