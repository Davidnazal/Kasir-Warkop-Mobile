import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/daily_report_model.dart';
import '../../../data/models/transaction_model.dart';
import '../../../providers/report_provider.dart';

/// Halaman ringkasan omset dan total transaksi harian.
class DailyReportScreen extends StatefulWidget {
  const DailyReportScreen({super.key});

  @override
  State<DailyReportScreen> createState() => _DailyReportScreenState();
}

class _DailyReportScreenState extends State<DailyReportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ReportProvider>().loadDailyReport();
      }
    });
  }

  void _openTransactionHistory(BuildContext context, DailyReportModel? report) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _TransactionHistorySheet(report: report),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reportProvider = context.watch<ReportProvider>();
    final report = reportProvider.report;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Harian'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: reportProvider.loadDailyReport,
          ),
        ],
      ),
      body: reportProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _OmsetSummaryCard(report: report),
                  const SizedBox(height: 12),
                  Card(
                    clipBehavior: Clip.antiAlias,
                    child: ListTile(
                      onTap: () => _openTransactionHistory(context, report),
                      leading: const Icon(
                        Icons.receipt_long,
                        color: AppColors.primary,
                      ),
                      title: const Text('Total Transaksi'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${report?.totalTransactions ?? 0} Order',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.chevron_right,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _OmsetSummaryCard extends StatelessWidget {
  const _OmsetSummaryCard({required this.report});

  final DailyReportModel? report;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Omset Hari Ini',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 6),
          Text(
            CurrencyFormatter.format(report?.totalOmset ?? 0),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (report != null)
            Text(
              'Tanggal: ${report!.date}',
              style: const TextStyle(color: Colors.white70),
            ),
        ],
      ),
    );
  }
}

class _TransactionHistorySheet extends StatelessWidget {
  const _TransactionHistorySheet({required this.report});

  final DailyReportModel? report;

  @override
  Widget build(BuildContext context) {
    final transactions = report?.transactions ?? const [];
    final maxHeight = MediaQuery.sizeOf(context).height * 0.78;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Riwayat Transaksi',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    if (report != null)
                      Text(
                        'Tanggal: ${report!.date} • ${transactions.length} Order',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 12),
            if (transactions.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(
                    'Belum ada transaksi hari ini',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: transactions.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    return _TransactionHistoryCard(
                      transaction: transactions[index],
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TransactionHistoryCard extends StatelessWidget {
  const _TransactionHistoryCard({required this.transaction});

  final TransactionModel transaction;

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '-';
    final hh = dateTime.hour.toString().padLeft(2, '0');
    final mm = dateTime.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.invoiceNumber,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Pukul ${_formatTime(transaction.createdAt)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  transaction.paymentMethod.label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 10),
          if (transaction.details.isEmpty)
            const Text(
              'Detail item tidak tersedia',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            )
          else
            ...transaction.details.map(
              (detail) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${detail.quantity}x ${detail.productName}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(detail.subtotal),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 6),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bayar ${CurrencyFormatter.format(transaction.payAmount)} • Kembali ${CurrencyFormatter.format(transaction.changeAmount)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                CurrencyFormatter.format(transaction.totalPrice),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
