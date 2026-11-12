import 'package:flutter/material.dart';

/// Memisahkan layout Portrait (HP vertikal) dan Landscape (Tablet / HP horizontal).
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.portrait,
    required this.landscape,
  });

  /// Ambang lebar minimum agar mode split-screen landscape aktif.
  static const double landscapeBreakpoint = 600;

  final Widget portrait;
  final Widget landscape;

  static bool isLandscape(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return size.width >= landscapeBreakpoint && size.width > size.height;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide =
            constraints.maxWidth >= landscapeBreakpoint &&
            constraints.maxWidth > constraints.maxHeight;
        return isWide ? landscape : portrait;
      },
    );
  }
}
