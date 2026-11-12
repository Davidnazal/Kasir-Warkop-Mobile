/// Model data produk menu warkop.
class ProductModel {
  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.imageAsset,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int,
      name: json['name'] as String,
      price: (json['price'] as num).toInt(),
      stock: (json['stock'] as num).toInt(),
    );
  }

  /// Urutan prioritas pencocokan kata kunci ke gambar lokal di `assets/images/`.
  static const List<(List<String>, String)> _assetKeywordMap = [
    (['kopi susu', 'aren'], 'assets/images/kopi_susu_aren.jpg'),
    (['indomie', 'mie'], 'assets/images/indomie_telur.jpg'),
    (['roti'], 'assets/images/roti_bakar.jpg'),
    (['teh'], 'assets/images/es_teh_jumbo.jpg'),
    (['pisang'], 'assets/images/pisang_goreng.jpg'),
    (['tubruk', 'kopi'], 'assets/images/kopi_tubruk.jpg'),
    (['cireng'], 'assets/images/cireng_rujak.jpg'),
    (['matcha'], 'assets/images/matcha_latte.jpg'),
  ];

  final int id;
  final String name;
  final int price;
  final int stock;
  final String? imageAsset;

  /// Mengembalikan path aset gambar yang cocok berdasarkan nama produk
  /// agar tetap tampil bergambar di mode demo maupun dari API Laravel.
  String? get resolvedAssetImage {
    if (imageAsset != null) return imageAsset;
    final lower = name.toLowerCase();
    for (final (keywords, assetPath) in _assetKeywordMap) {
      if (keywords.any(lower.contains)) {
        return assetPath;
      }
    }
    return null;
  }

  ProductModel copyWith({
    int? id,
    String? name,
    int? price,
    int? stock,
    String? imageAsset,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      imageAsset: imageAsset ?? this.imageAsset,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'price': price, 'stock': stock};
  }
}
