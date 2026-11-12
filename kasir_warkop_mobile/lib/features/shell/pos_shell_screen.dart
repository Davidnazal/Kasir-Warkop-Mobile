import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/responsive_layout.dart';
import '../pos/screens/pos_screen.dart';
import '../products/screens/product_management_screen.dart';
import '../reports/screens/daily_report_screen.dart';

/// Kerangka navigasi utama yang menyesuaikan BottomBar (portrait) dan Rail (landscape).
class PosShellScreen extends StatefulWidget {
  const PosShellScreen({super.key});

  @override
  State<PosShellScreen> createState() => _PosShellScreenState();
}

class _PosShellScreenState extends State<PosShellScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = [
    PosScreen(),
    ProductManagementScreen(),
    DailyReportScreen(),
  ];

  void _onTabSelected(int index) {
    setState(() => _selectedIndex = index);
  }

  Widget _buildPortraitScaffold(Widget currentPage) {
    return Scaffold(
      appBar: _selectedIndex == 0
          ? AppBar(
              title: const Text('Warkop Sukses POS'),
              backgroundColor: AppColors.surface,
            )
          : null,
      body: currentPage,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onTabSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.point_of_sale_outlined),
            selectedIcon: Icon(Icons.point_of_sale),
            label: 'Kasir',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Stok',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Laporan',
          ),
        ],
      ),
    );
  }

  Widget _buildLandscapeScaffold(Widget currentPage) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            NavigationRail(
              backgroundColor: AppColors.slateRail,
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onTabSelected,
              labelType: NavigationRailLabelType.all,
              indicatorColor: AppColors.primary,
              selectedIconTheme: const IconThemeData(color: Colors.white),
              unselectedIconTheme: const IconThemeData(color: Colors.white70),
              selectedLabelTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelTextStyle: const TextStyle(
                color: Colors.white60,
                fontSize: 12,
              ),
              leading: const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.coffee, color: Colors.white),
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.point_of_sale_outlined),
                  selectedIcon: Icon(Icons.point_of_sale),
                  label: Text('POS'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.inventory_2_outlined),
                  selectedIcon: Icon(Icons.inventory_2),
                  label: Text('Stok'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.bar_chart_outlined),
                  selectedIcon: Icon(Icons.bar_chart),
                  label: Text('Laporan'),
                ),
              ],
            ),
            Expanded(child: currentPage),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = _pages[_selectedIndex];
    return ResponsiveLayout(
      portrait: _buildPortraitScaffold(currentPage),
      landscape: _buildLandscapeScaffold(currentPage),
    );
  }
}
