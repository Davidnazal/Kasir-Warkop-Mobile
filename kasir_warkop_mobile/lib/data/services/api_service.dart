import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../models/cart_item_model.dart';
import '../models/daily_report_model.dart';
import '../models/product_model.dart';
import '../models/transaction_model.dart';

/// Klien HTTP untuk berkomunikasi dengan REST API Laravel.
class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Map<String, String> get _headers => const {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Map<String, dynamic> _decodeBody(
    http.Response response, {
    required int expectedStatus,
    required String fallbackError,
  }) {
    Map<String, dynamic> body = const {};
    if (response.body.isNotEmpty) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        body = decoded;
      }
    }

    if (response.statusCode == expectedStatus) {
      return body;
    }

    final message = body['message'];
    throw Exception(
      message is String && message.isNotEmpty ? message : fallbackError,
    );
  }

  /// Mengambil daftar produk dari `/api/products`.
  Future<List<ProductModel>> fetchProducts() async {
    final response = await _client.get(
      Uri.parse(ApiConstants.products),
      headers: _headers,
    );
    final body = _decodeBody(
      response,
      expectedStatus: 200,
      fallbackError: 'Gagal mengambil data produk',
    );
    final list = body['data'] as List<dynamic>;
    return list
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Menambahkan produk baru ke `/api/products`.
  Future<ProductModel> createProduct(ProductModel product) async {
    final response = await _client.post(
      Uri.parse(ApiConstants.products),
      headers: _headers,
      body: jsonEncode(product.toJson()),
    );
    final body = _decodeBody(
      response,
      expectedStatus: 201,
      fallbackError: 'Gagal menambahkan produk',
    );
    return ProductModel.fromJson(body['data'] as Map<String, dynamic>);
  }

  /// Memperbarui data produk berdasarkan [id].
  Future<ProductModel> updateProduct(int id, ProductModel product) async {
    final response = await _client.put(
      Uri.parse('${ApiConstants.products}/$id'),
      headers: _headers,
      body: jsonEncode(product.toJson()),
    );
    final body = _decodeBody(
      response,
      expectedStatus: 200,
      fallbackError: 'Gagal memperbarui produk',
    );
    return ProductModel.fromJson(body['data'] as Map<String, dynamic>);
  }

  /// Menghapus produk berdasarkan [id].
  Future<void> deleteProduct(int id) async {
    final response = await _client.delete(
      Uri.parse('${ApiConstants.products}/$id'),
      headers: _headers,
    );
    _decodeBody(
      response,
      expectedStatus: 200,
      fallbackError: 'Gagal menghapus produk',
    );
  }

  /// Mengambil daftar transaksi harian dari `/api/transactions`.
  Future<List<TransactionModel>> fetchTransactions({String? date}) async {
    final baseUri = Uri.parse(ApiConstants.transactions);
    final uri = date != null
        ? baseUri.replace(queryParameters: {'date': date})
        : baseUri;
    final response = await _client.get(uri, headers: _headers);
    final body = _decodeBody(
      response,
      expectedStatus: 200,
      fallbackError: 'Gagal mengambil riwayat transaksi',
    );
    final list = body['data'] as List<dynamic>;
    return list
        .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Membuat transaksi baru ke `/api/transactions`.
  Future<TransactionModel> createTransaction({
    required List<CartItemModel> items,
    required int payAmount,
    required PaymentMethod paymentMethod,
  }) async {
    final response = await _client.post(
      Uri.parse(ApiConstants.transactions),
      headers: _headers,
      body: jsonEncode({
        'items': items.map((e) => e.toTransactionItemJson()).toList(),
        'pay_amount': payAmount,
        'payment_method': paymentMethod.apiValue,
      }),
    );
    final body = _decodeBody(
      response,
      expectedStatus: 201,
      fallbackError: 'Transaksi gagal diproses',
    );
    return TransactionModel.fromJson(body['data'] as Map<String, dynamic>);
  }

  /// Mengambil ringkasan laporan harian dari `/api/reports`.
  Future<DailyReportModel> fetchDailyReport() async {
    final response = await _client.get(
      Uri.parse(ApiConstants.reports),
      headers: _headers,
    );
    final body = _decodeBody(
      response,
      expectedStatus: 200,
      fallbackError: 'Gagal mengambil laporan harian',
    );
    return DailyReportModel.fromJson(body);
  }
}
