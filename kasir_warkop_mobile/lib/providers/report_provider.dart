import 'package:flutter/foundation.dart';

import '../data/models/daily_report_model.dart';
import '../data/models/transaction_model.dart';
import '../data/services/api_service.dart';

/// Mengelola state laporan omset harian dan riwayat transaksi kasir.
class ReportProvider extends ChangeNotifier {
  ReportProvider({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  final ApiService _apiService;
  final List<TransactionModel> _demoTransactions = [
    TransactionModel(
      id: 1,
      invoiceNumber: 'INV-DEMO-1003',
      totalPrice: 52000,
      payAmount: 60000,
      changeAmount: 8000,
      paymentMethod: PaymentMethod.cash,
      createdAt: DateTime.now().subtract(const Duration(minutes: 18)),
      details: const [
        TransactionDetailModel(
          productId: 1,
          productName: 'Kopi Susu Aren',
          quantity: 2,
          price: 18000,
          subtotal: 36000,
        ),
        TransactionDetailModel(
          productId: 2,
          productName: 'Indomie Special Telur',
          quantity: 1,
          price: 16000,
          subtotal: 16000,
        ),
      ],
    ),
    TransactionModel(
      id: 2,
      invoiceNumber: 'INV-DEMO-1002',
      totalPrice: 28000,
      payAmount: 28000,
      changeAmount: 0,
      paymentMethod: PaymentMethod.qris,
      createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
      details: const [
        TransactionDetailModel(
          productId: 3,
          productName: 'Roti Bakar Coklat Keju',
          quantity: 1,
          price: 20000,
          subtotal: 20000,
        ),
        TransactionDetailModel(
          productId: 4,
          productName: 'Es Teh Manis Jumbo',
          quantity: 1,
          price: 8000,
          subtotal: 8000,
        ),
      ],
    ),
    TransactionModel(
      id: 3,
      invoiceNumber: 'INV-DEMO-1001',
      totalPrice: 37000,
      payAmount: 50000,
      changeAmount: 13000,
      paymentMethod: PaymentMethod.cash,
      createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 20)),
      details: const [
        TransactionDetailModel(
          productId: 8,
          productName: 'Matcha Latte Ice',
          quantity: 1,
          price: 22000,
          subtotal: 22000,
        ),
        TransactionDetailModel(
          productId: 5,
          productName: 'Pisang Goreng Crispy',
          quantity: 1,
          price: 15000,
          subtotal: 15000,
        ),
      ],
    ),
  ];

  DailyReportModel? _report;
  bool _isLoading = false;
  bool _isDemoMode = false;
  String? _errorMessage;

  DailyReportModel? get report => _report;
  bool get isLoading => _isLoading;
  bool get isDemoMode => _isDemoMode;
  String? get errorMessage => _errorMessage;

  DailyReportModel _buildDemoReport() {
    final now = DateTime.now();
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final totalOmset = _demoTransactions.fold(
      0,
      (sum, tx) => sum + tx.totalPrice,
    );

    return DailyReportModel(
      date: today,
      totalOmset: totalOmset,
      totalTransactions: _demoTransactions.length,
      transactions: List.unmodifiable(_demoTransactions),
    );
  }

  /// Mencatat transaksi baru ke daftar laporan saat berjalan di mode demo offline.
  void recordDemoTransaction(TransactionModel transaction) {
    _demoTransactions.insert(0, transaction);
    if (_isDemoMode || _report == null) {
      _report = _buildDemoReport();
      _isDemoMode = true;
      notifyListeners();
    }
  }

  Future<void> loadDailyReport() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      var fetched = await _apiService.fetchDailyReport();
      if (fetched.transactions.isEmpty && fetched.totalTransactions > 0) {
        final transactions = await _apiService.fetchTransactions(
          date: fetched.date,
        );
        fetched = DailyReportModel(
          date: fetched.date,
          totalOmset: fetched.totalOmset,
          totalTransactions: fetched.totalTransactions,
          transactions: transactions,
        );
      }
      _report = fetched;
      _isDemoMode = false;
    } catch (e) {
      // Fallback ke ringkasan demo saat server backend belum berjalan
      _report = _buildDemoReport();
      _isDemoMode = true;
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
