import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/product_thumbnail.dart';
import '../../../data/models/product_model.dart';
import '../../../providers/product_provider.dart';

/// Halaman manajemen katalog menu dan stok produk.
class ProductManagementScreen extends StatelessWidget {
  const ProductManagementScreen({super.key});

  Future<void> _showProductForm(
    BuildContext context, {
    ProductModel? existing,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => _ProductFormDialog(existing: existing),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Menu & Stok'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: () => _showProductForm(context),
              icon: const Icon(Icons.add),
              label: const Text('Tambah'),
            ),
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.products.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final product = provider.products[index];
                return _ProductListItem(
                  product: product,
                  onEdit: () => _showProductForm(context, existing: product),
                  onDelete: () => provider.removeProduct(product.id),
                );
              },
            ),
    );
  }
}

class _ProductListItem extends StatelessWidget {
  const _ProductListItem({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  final ProductModel product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: ProductThumbnail(
          imagePath: product.resolvedAssetImage,
          width: 48,
          height: 48,
          borderRadius: 8,
          iconSize: 24,
        ),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${CurrencyFormatter.format(product.price)} • Stok: ${product.stock}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.danger),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductFormDialog extends StatefulWidget {
  const _ProductFormDialog({this.existing});

  final ProductModel? existing;

  @override
  State<_ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<_ProductFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _stockCtrl;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameCtrl = TextEditingController(text: existing?.name ?? '');
    _priceCtrl = TextEditingController(
      text: existing != null ? existing.price.toString() : '',
    );
    _stockCtrl = TextEditingController(
      text: existing != null ? existing.stock.toString() : '',
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  String? _validateNonNegativeInt(String? value, String errorMessage) {
    final parsed = int.tryParse(value ?? '');
    if (parsed == null || parsed < 0) {
      return errorMessage;
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    final provider = context.read<ProductProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final existing = widget.existing;

    final payload = ProductModel(
      id: existing?.id ?? 0,
      name: _nameCtrl.text.trim(),
      price: int.parse(_priceCtrl.text),
      stock: int.parse(_stockCtrl.text),
    );

    try {
      if (existing == null) {
        await provider.addProduct(payload);
      } else {
        await provider.editProduct(existing.id, payload);
      }
      if (mounted) {
        navigator.pop();
      }
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            existing == null
                ? 'Menu berhasil ditambahkan'
                : 'Menu berhasil diperbarui',
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
      }
      messenger.showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit Menu' : 'Tambah Menu'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Nama Menu'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Harga (Rp)'),
              validator: (v) => _validateNonNegativeInt(v, 'Harga tidak valid'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _stockCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Stok'),
              validator: (v) => _validateNonNegativeInt(v, 'Stok tidak valid'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _submit,
          child: Text(_saving ? 'Menyimpan...' : 'Simpan'),
        ),
      ],
    );
  }
}
