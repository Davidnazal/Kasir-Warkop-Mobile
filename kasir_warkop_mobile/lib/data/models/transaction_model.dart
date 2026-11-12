/// Metode pembayaran yang didukung pada proses checkout.
enum PaymentMethod {
  cash('cash', 'Tunai / Cash'),
  qris('qris', 'QRIS Dinamis');

  const PaymentMethod(this.apiValue, this.label);

  final String apiValue;
  final String label;
}

/// Rincian item produk yang dipesan dalam sebuah transaksi.
class TransactionDetailModel {
  const TransactionDetailModel({
    this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.subtotal,
  });

  factory TransactionDetailModel.fromJson(Map<String, dynamic> json) {
    final productJson = json['product'] as Map<String, dynamic>?;
    final productId = (json['product_id'] as num).toInt();
    return TransactionDetailModel(
      id: json['id'] as int?,
      productId: productId,
      productName: (productJson?['name'] as String?) ?? 'Produk #$productId',
      quantity: (json['quantity'] as num).toInt(),
      price: (json['price'] as num).toInt(),
      subtotal: (json['subtotal'] as num).toInt(),
    );
  }

  final int? id;
  final int productId;
  final String productName;
  final int quantity;
  final int price;
  final int subtotal;
}

/// Model hasil transaksi penjualan beserta daftar item yang dipesan.
class TransactionModel {
  const TransactionModel({
    this.id,
    required this.invoiceNumber,
    required this.totalPrice,
    required this.payAmount,
    required this.changeAmount,
    required this.paymentMethod,
    this.createdAt,
    this.details = const [],
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final methodStr = (json['payment_method'] ?? 'cash') as String;
    final rawDetails = json['details'] as List<dynamic>? ?? const [];

    return TransactionModel(
      id: json['id'] as int?,
      invoiceNumber: json['invoice_number'] as String,
      totalPrice: (json['total_price'] as num).toInt(),
      payAmount: (json['pay_amount'] as num).toInt(),
      changeAmount: (json['change_amount'] as num).toInt(),
      paymentMethod: methodStr == 'qris'
          ? PaymentMethod.qris
          : PaymentMethod.cash,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)?.toLocal()
          : null,
      details: rawDetails
          .map(
            (e) => TransactionDetailModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  final int? id;
  final String invoiceNumber;
  final int totalPrice;
  final int payAmount;
  final int changeAmount;
  final PaymentMethod paymentMethod;
  final DateTime? createdAt;
  final List<TransactionDetailModel> details;
}
