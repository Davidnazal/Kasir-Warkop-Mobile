import 'product_model.dart';

/// Item keranjang belanja pada sesi kasir aktif.
class CartItemModel {
  CartItemModel({required this.product, this.quantity = 1, this.note});

  final ProductModel product;
  int quantity;
  String? note;

  int get subtotal => product.price * quantity;

  Map<String, dynamic> toTransactionItemJson() {
    return {'product_id': product.id, 'quantity': quantity};
  }
}
