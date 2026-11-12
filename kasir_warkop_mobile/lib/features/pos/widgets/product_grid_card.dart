import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/product_thumbnail.dart';
import '../../../data/models/product_model.dart';

/// Kartu menu pada grid katalog kasir beserta indikator stok dan jumlah order.
class ProductGridCard extends StatelessWidget {
  const ProductGridCard({
    super.key,
    required this.product,
    required this.onAdd,
    this.quantityInCart = 0,
  });

  final ProductModel product;
  final int quantityInCart;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = product.stock <= 0;
    final isSelected = quantityInCart > 0;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: isOutOfStock ? null : onAdd,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ProductThumbnail(
                        imagePath: product.resolvedAssetImage,
                        borderRadius: 8,
                        iconSize: 36,
                      ),
                      Positioned(
                        top: 6,
                        left: 6,
                        child: _StockBadge(stock: product.stock),
                      ),
                      if (isSelected)
                        Positioned(
                          top: 6,
                          right: 6,
                          child: _CartQuantityBadge(quantity: quantityInCart),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      CurrencyFormatter.format(product.price),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  _AddButton(isOutOfStock: isOutOfStock),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StockBadge extends StatelessWidget {
  const _StockBadge({required this.stock});

  final int stock;

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = stock <= 0;
    final isLowStock = stock > 0 && stock <= 5;

    final backgroundColor = isOutOfStock
        ? AppColors.dangerSurface
        : isLowStock
        ? AppColors.warningSurface
        : AppColors.successSurface;

    final textColor = isOutOfStock
        ? AppColors.danger
        : isLowStock
        ? AppColors.warning
        : AppColors.success;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isOutOfStock ? 'Habis' : 'Stok: $stock',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

class _CartQuantityBadge extends StatelessWidget {
  const _CartQuantityBadge({required this.quantity});

  final int quantity;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 12,
      backgroundColor: AppColors.primary,
      child: Text(
        '$quantity',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.isOutOfStock});

  final bool isOutOfStock;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isOutOfStock ? AppColors.surfaceVariant : AppColors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.add,
        size: 18,
        color: isOutOfStock ? AppColors.textSecondary : Colors.white,
      ),
    );
  }
}
