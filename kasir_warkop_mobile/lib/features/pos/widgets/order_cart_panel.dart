import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/cart_item_model.dart';
import '../../../providers/pos_provider.dart';
import 'checkout_payment_modal.dart';

/// Panel keranjang pesanan aktif dengan pengatur kuantitas dan tombol bayar.
class OrderCartPanel extends StatelessWidget {
  const OrderCartPanel({super.key, this.isBottomSheet = false});

  final bool isBottomSheet;

  Future<void> _handlePayPressed(BuildContext context) async {
    final navigator = Navigator.of(context);
    final paid = await CheckoutPaymentModal.show(context);
    if (paid == true && isBottomSheet && navigator.mounted) {
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pos = context.watch<PosProvider>();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(left: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pesanan Aktif (${pos.totalItems})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (pos.cart.isNotEmpty)
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppColors.danger,
                    ),
                    onPressed: pos.clearCart,
                    tooltip: 'Kosongkan Keranjang',
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Expanded(
            child: pos.cart.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada menu dipilih',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: pos.cart.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = pos.cart[index];
                      return _CartItemTile(
                        item: item,
                        onDecrement: () =>
                            pos.updateQuantity(item.product.id, -1),
                        onIncrement: () =>
                            pos.updateQuantity(item.product.id, 1),
                      );
                    },
                  ),
          ),
          _CartSummaryFooter(
            subtotal: pos.subtotal,
            isCartEmpty: pos.cart.isEmpty,
            onPayPressed: () => _handlePayPressed(context),
          ),
        ],
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({
    required this.item,
    required this.onDecrement,
    required this.onIncrement,
  });

  final CartItemModel item;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  CurrencyFormatter.format(item.subtotal),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, size: 20),
            onPressed: onDecrement,
          ),
          Text(
            '${item.quantity}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 20),
            onPressed: onIncrement,
          ),
        ],
      ),
    );
  }
}

class _CartSummaryFooter extends StatelessWidget {
  const _CartSummaryFooter({
    required this.subtotal,
    required this.isCartEmpty,
    required this.onPayPressed,
  });

  final int subtotal;
  final bool isCartEmpty;
  final VoidCallback onPayPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Tagihan',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              Text(
                CurrencyFormatter.format(subtotal),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isCartEmpty ? null : onPayPressed,
              child: const Text('Bayar Sekarang'),
            ),
          ),
        ],
      ),
    );
  }
}
