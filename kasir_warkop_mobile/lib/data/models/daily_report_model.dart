import 'transaction_model.dart';

/// Model ringkasan laporan penjualan harian beserta daftar transaksinya.
class DailyReportModel {
  const DailyReportModel({
    required this.date,
    required this.totalOmset,
    required this.totalTransactions,
    this.transactions = const [],
  });

  factory DailyReportModel.fromJson(Map<String, dynamic> json) {
    final rawTransactions = json['transactions'] as List<dynamic>? ?? const [];

    return DailyReportModel(
      date: json['date'] as String,
      totalOmset: (json['total_omset'] as num).toInt(),
      totalTransactions: (json['total_transactions'] as num).toInt(),
      transactions: rawTransactions
          .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final String date;
  final int totalOmset;
  final int totalTransactions;
  final List<TransactionModel> transactions;
}
