import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../data/models/product_model.dart';
import '../../../providers/pos_provider.dart';
import '../../../providers/product_provider.dart';
import '../widgets/order_cart_panel.dart';
import '../widgets/product_grid_card.dart';

/// Halaman kasir utama yang menampilkan katalog menu dan ringkasan pesanan.
class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ProductProvider>().loadProducts();
      }
    });
  }

  void _openCartBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const SizedBox(
        height: 520,
        child: OrderCartPanel(isBottomSheet: true),
      ),
    );
  }

  Widget _buildCatalogArea(
    BuildContext context, {
    required int crossAxisCount,
  }) {
    final productProvider = context.watch<ProductProvider>();
    final posProvider = context.watch<PosProvider>();
    final query = posProvider.searchQuery.toLowerCase();

    final filteredProducts = productProvider.products
        .where((p) => p.name.toLowerCase().contains(query))
        .toList();

    return Column(
      children: [
        _CatalogSearchBar(
          onSearchChanged: posProvider.setSearchQuery,
          onRefresh: productProvider.loadProducts,
        ),
        if (productProvider.isDemoMode) const _OfflineDemoBanner(),
        Expanded(
          child: _CatalogContent(
            isLoading: productProvider.isLoading,
            errorMessage: productProvider.errorMessage,
            products: filteredProducts,
            crossAxisCount: crossAxisCount,
            posProvider: posProvider,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final pos = context.watch<PosProvider>();

    return ResponsiveLayout(
      portrait: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: pos.totalItems > 0 ? 84 : 0),
            child: _buildCatalogArea(context, crossAxisCount: 2),
          ),
          if (pos.totalItems > 0)
            Positioned(
              left: 16,
              right: 16,
              bottom: 12,
              child: _FloatingCartBar(
                totalItems: pos.totalItems,
                subtotal: pos.subtotal,
                onTap: () => _openCartBottomSheet(context),
              ),
            ),
        ],
      ),
      landscape: Row(
        children: [
          Expanded(
            flex: 65,
            child: _buildCatalogArea(context, crossAxisCount: 4),
          ),
          const SizedBox(width: 340, child: OrderCartPanel()),
        ],
      ),
    );
  }
}

class _CatalogSearchBar extends StatelessWidget {
  const _CatalogSearchBar({
    required this.onSearchChanged,
    required this.onRefresh,
  });

  final ValueChanged<String> onSearchChanged;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Cari menu warkop...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat Ulang Menu',
          ),
        ],
      ),
    );
  }
}

class _OfflineDemoBanner extends StatelessWidget {
  const _OfflineDemoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.warningSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: AppColors.warning),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Mode Preview Offline — Server Laravel belum aktif',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogContent extends StatelessWidget {
  const _CatalogContent({
    required this.isLoading,
    required this.errorMessage,
    required this.products,
    required this.crossAxisCount,
    required this.posProvider,
  });

  final bool isLoading;
  final String? errorMessage;
  final List<ProductModel> products;
  final int crossAxisCount;
  final PosProvider posProvider;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (products.isEmpty) {
      return Center(
        child: Text(
          errorMessage ?? 'Menu kosong atau belum terhubung ke server',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.82,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final cartMatch = posProvider.cart.where(
          (e) => e.product.id == product.id,
        );
        final qty = cartMatch.isEmpty ? 0 : cartMatch.first.quantity;

        return ProductGridCard(
          product: product,
          quantityInCart: qty,
          onAdd: () => posProvider.addToCart(product),
        );
      },
    );
  }
}

class _FloatingCartBar extends StatelessWidget {
  const _FloatingCartBar({
    required this.totalItems,
    required this.subtotal,
    required this.onTap,
  });

  final int totalItems;
  final int subtotal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(16),
      color: AppColors.slateRail,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary,
                child: Text(
                  '$totalItems',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  CurrencyFormatter.format(subtotal),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              const Text(
                'Order / Bayar →',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
