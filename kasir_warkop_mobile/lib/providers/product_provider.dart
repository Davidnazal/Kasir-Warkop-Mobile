import 'package:flutter/foundation.dart';

import '../data/models/product_model.dart';
import '../data/services/api_service.dart';

/// Mengelola daftar produk serta operasi CRUD dan fallback mode demo offline.
class ProductProvider extends ChangeNotifier {
  ProductProvider({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  static const List<ProductModel> _demoProducts = [
    ProductModel(id: 1, name: 'Kopi Susu Aren', price: 18000, stock: 24),
    ProductModel(id: 2, name: 'Indomie Special Telur', price: 16000, stock: 18),
    ProductModel(
      id: 3,
      name: 'Roti Bakar Coklat Keju',
      price: 20000,
      stock: 12,
    ),
    ProductModel(id: 4, name: 'Es Teh Manis Jumbo', price: 8000, stock: 50),
    ProductModel(id: 5, name: 'Pisang Goreng Crispy', price: 15000, stock: 15),
    ProductModel(id: 6, name: 'Kopi Tubruk Gayo', price: 14000, stock: 30),
    ProductModel(id: 7, name: 'Cireng Bumbu Rujak', price: 12000, stock: 5),
    ProductModel(id: 8, name: 'Matcha Latte Ice', price: 22000, stock: 19),
  ];

  final ApiService _apiService;
  List<ProductModel> _products = [];
  bool _isLoading = false;
  bool _isDemoMode = false;
  String? _errorMessage;

  List<ProductModel> get products => List.unmodifiable(_products);
  bool get isLoading => _isLoading;
  bool get isDemoMode => _isDemoMode;
  String? get errorMessage => _errorMessage;

  Future<void> loadProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _apiService.fetchProducts();
      _isDemoMode = false;
    } catch (e) {
      // Fallback ke data demo agar tampilan POS tetap bisa di-preview tanpa server
      _products = List.of(_demoProducts);
      _isDemoMode = true;
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProduct(ProductModel product) async {
    if (_isDemoMode) {
      final nextId =
          (_products.isEmpty
              ? 0
              : _products.map((p) => p.id).reduce((a, b) => a > b ? a : b)) +
          1;
      _products = [..._products, product.copyWith(id: nextId)];
      notifyListeners();
      return;
    }
    final created = await _apiService.createProduct(product);
    _products = [..._products, created];
    notifyListeners();
  }

  Future<void> editProduct(int id, ProductModel product) async {
    if (_isDemoMode) {
      _products = _products
          .map((p) => p.id == id ? product.copyWith(id: id) : p)
          .toList();
      notifyListeners();
      return;
    }
    final updated = await _apiService.updateProduct(id, product);
    _products = _products.map((p) => p.id == id ? updated : p).toList();
    notifyListeners();
  }

  Future<void> removeProduct(int id) async {
    if (!_isDemoMode) {
      await _apiService.deleteProduct(id);
    }
    _products = _products.where((p) => p.id != id).toList();
    notifyListeners();
  }
}
