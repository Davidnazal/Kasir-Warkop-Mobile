import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Menampilkan gambar aset produk dengan fallback ikon kopi bila belum tersedia.
class ProductThumbnail extends StatelessWidget {
  const ProductThumbnail({
    super.key,
    required this.imagePath,
    this.borderRadius = 8,
    this.iconSize = 36,
    this.width,
    this.height,
  });

  final String? imagePath;
  final double borderRadius;
  final double iconSize;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final fallback = Center(
      child: Icon(
        Icons.local_cafe_rounded,
        size: iconSize,
        color: AppColors.textSecondary,
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: width,
        height: height,
        color: AppColors.surfaceVariant,
        child: imagePath != null
            ? Image.asset(
                imagePath!,
                width: width,
                height: height,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => fallback,
              )
            : fallback,
      ),
    );
  }
}
