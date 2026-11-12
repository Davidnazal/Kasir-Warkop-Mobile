import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/transaction_model.dart';
import '../../../providers/pos_provider.dart';
import '../../../providers/product_provider.dart';
import '../../../providers/report_provider.dart';

/// Modal bottom sheet untuk memilih metode pembayaran dan menyelesaikan transaksi.
class CheckoutPaymentModal extends StatefulWidget {
  const CheckoutPaymentModal({super.key});

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const CheckoutPaymentModal(),
    );
  }

  @override
  State<CheckoutPaymentModal> createState() => _CheckoutPaymentModalState();
}

class _CheckoutPaymentModalState extends State<CheckoutPaymentModal> {
  final TextEditingController _payController = TextEditingController();

  @override
  void dispose() {
    _payController.dispose();
    super.dispose();
  }

  Future<void> _submitTransaction(PosProvider pos, int payAmount) async {
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final productProvider = context.read<ProductProvider>();
    final reportProvider = context.read<ReportProvider>();

    try {
      final isDemo = productProvider.isDemoMode;
      final tx = await pos.submitTransaction(
        pos.paymentMethod == PaymentMethod.qris ? pos.subtotal : payAmount,
        isDemoMode: isDemo,
      );
      if (isDemo) {
        reportProvider.recordDemoTransaction(tx);
      } else {
        await productProvider.loadProducts();
        await reportProvider.loadDailyReport();
      }
      nav.pop(true);
      messenger.showSnackBar(
        SnackBar(content: Text('Transaksi ${tx.invoiceNumber} sukses!')),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Gagal: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final pos = context.watch<PosProvider>();
    final total = pos.subtotal;
    final payAmount =
        int.tryParse(_payController.text.replaceAll('.', '')) ?? total;
    final changeAmount = payAmount - total;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Checkout Pembayaran',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          _BillTotalBox(total: total),
          const SizedBox(height: 14),
          SegmentedButton<PaymentMethod>(
            segments: PaymentMethod.values
                .map((m) => ButtonSegment(value: m, label: Text(m.label)))
                .toList(),
            selected: {pos.paymentMethod},
            onSelectionChanged: (set) => pos.setPaymentMethod(set.first),
          ),
          const SizedBox(height: 14),
          if (pos.paymentMethod == PaymentMethod.cash)
            _CashPaymentSection(
              controller: _payController,
              changeAmount: changeAmount,
              onChanged: () => setState(() {}),
            )
          else
            const _QrisPaymentSection(),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: pos.isSubmitting
                ? null
                : () => _submitTransaction(pos, payAmount),
            child: pos.isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Konfirmasi & Proses Transaksi'),
          ),
        ],
      ),
    );
  }
}

class _BillTotalBox extends StatelessWidget {
  const _BillTotalBox({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Total Tagihan'),
          Text(
            CurrencyFormatter.format(total),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CashPaymentSection extends StatelessWidget {
  const _CashPaymentSection({
    required this.controller,
    required this.changeAmount,
    required this.onChanged,
  });

  final TextEditingController controller;
  final int changeAmount;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final isSufficient = changeAmount >= 0;

    return Column(
      children: [
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Uang Diterima (Rp)',
            hintText: 'Masukkan nominal uang tunai',
          ),
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSufficient
                ? AppColors.successSurface
                : AppColors.dangerSurface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Kembalian Kasir'),
              Text(
                CurrencyFormatter.format(isSufficient ? changeAmount : 0),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: isSufficient ? AppColors.success : AppColors.danger,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QrisPaymentSection extends StatelessWidget {
  const _QrisPaymentSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.qr_code_2_rounded,
            size: 110,
            color: AppColors.textPrimary,
          ),
          SizedBox(height: 8),
          Text('Menunggu pelanggan memindai QRIS...'),
        ],
      ),
    );
  }
}
