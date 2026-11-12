import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kasir_warkop_mobile/core/utils/currency_formatter.dart';
import 'package:kasir_warkop_mobile/core/widgets/responsive_layout.dart';
import 'package:kasir_warkop_mobile/data/models/daily_report_model.dart';
import 'package:kasir_warkop_mobile/data/models/product_model.dart';
import 'package:kasir_warkop_mobile/data/models/transaction_model.dart';
import 'package:kasir_warkop_mobile/features/pos/widgets/order_cart_panel.dart';
import 'package:kasir_warkop_mobile/features/reports/screens/daily_report_screen.dart';
import 'package:kasir_warkop_mobile/providers/pos_provider.dart';
import 'package:kasir_warkop_mobile/providers/product_provider.dart';
import 'package:kasir_warkop_mobile/providers/report_provider.dart';
import 'package:provider/provider.dart';

class _DemoProductProvider extends ProductProvider {
  @override
  bool get isDemoMode => true;
}

void main() {
  test('CurrencyFormatter formats IDR correctly', () {
    expect(CurrencyFormatter.format(18000), 'Rp 18.000');
    expect(CurrencyFormatter.format(0), 'Rp 0');
  });

  test('ProductModel resolves matching local asset paths', () {
    const coffee = ProductModel(
      id: 1,
      name: 'Kopi Susu Aren',
      price: 18000,
      stock: 10,
    );
    const unknown = ProductModel(id: 2, name: 'Kerupuk', price: 2000, stock: 5);

    expect(coffee.resolvedAssetImage, 'assets/images/kopi_susu_aren.jpg');
    expect(unknown.resolvedAssetImage, isNull);
  });

  test('PosProvider respects stock limit and calculates subtotal', () {
    final pos = PosProvider();
    const product = ProductModel(
      id: 1,
      name: 'Es Teh Manis Jumbo',
      price: 8000,
      stock: 2,
    );

    pos.addToCart(product);
    pos.addToCart(product);
    pos.addToCart(product);

    expect(pos.totalItems, 2);
    expect(pos.subtotal, 16000);

    pos.updateQuantity(product.id, -2);
    expect(pos.cart, isEmpty);
  });

  test('DailyReportModel parses nested transactions and ordered details', () {
    final model = DailyReportModel.fromJson({
      'date': '2026-11-12',
      'total_omset': 36000,
      'total_transactions': 1,
      'transactions': [
        {
          'id': 10,
          'invoice_number': 'INV-100',
          'total_price': 36000,
          'pay_amount': 50000,
          'change_amount': 14000,
          'payment_method': 'cash',
          'details': [
            {
              'id': 1,
              'product_id': 1,
              'quantity': 2,
              'price': 18000,
              'subtotal': 36000,
              'product': {'id': 1, 'name': 'Kopi Susu Aren'},
            },
          ],
        },
      ],
    });

    expect(model.transactions, hasLength(1));
    expect(model.transactions.first.invoiceNumber, 'INV-100');
    expect(
      model.transactions.first.details.first.productName,
      'Kopi Susu Aren',
    );
    expect(model.transactions.first.details.first.quantity, 2);
  });

  testWidgets(
    'DailyReportScreen opens ordered items sheet when Total Transaksi is tapped',
    (WidgetTester tester) async {
      final reportProvider = ReportProvider();
      reportProvider.recordDemoTransaction(
        const TransactionModel(
          invoiceNumber: 'INV-TEST-01',
          totalPrice: 18000,
          payAmount: 20000,
          changeAmount: 2000,
          paymentMethod: PaymentMethod.cash,
          details: [
            TransactionDetailModel(
              productId: 1,
              productName: 'Kopi Susu Aren',
              quantity: 1,
              price: 18000,
              subtotal: 18000,
            ),
          ],
        ),
      );

      await tester.pumpWidget(
        ChangeNotifierProvider<ReportProvider>.value(
          value: reportProvider,
          child: const MaterialApp(home: DailyReportScreen()),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Total Transaksi'));
      await tester.pumpAndSettle();

      expect(find.text('Riwayat Transaksi'), findsOneWidget);
      expect(find.text('INV-TEST-01'), findsOneWidget);
      expect(find.text('1x Kopi Susu Aren'), findsOneWidget);
    },
  );

  testWidgets(
    'OrderCartPanel bottom sheet closes automatically after checkout succeeds',
    (WidgetTester tester) async {
      final posProvider = PosProvider();
      posProvider.addToCart(
        const ProductModel(
          id: 1,
          name: 'Kopi Susu Aren',
          price: 18000,
          stock: 10,
        ),
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ProductProvider>(
              create: (_) => _DemoProductProvider(),
            ),
            ChangeNotifierProvider<PosProvider>.value(value: posProvider),
            ChangeNotifierProvider<ReportProvider>(
              create: (_) => ReportProvider(),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => Center(
                  child: ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => const SizedBox(
                          height: 520,
                          child: OrderCartPanel(isBottomSheet: true),
                        ),
                      );
                    },
                    child: const Text('Buka Keranjang'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Buka Keranjang'));
      await tester.pumpAndSettle();
      expect(find.text('Bayar Sekarang'), findsOneWidget);

      await tester.tap(find.text('Bayar Sekarang'));
      await tester.pumpAndSettle();
      expect(find.text('Konfirmasi & Proses Transaksi'), findsOneWidget);

      await tester.tap(find.text('Konfirmasi & Proses Transaksi'));
      await tester.pumpAndSettle();

      expect(find.text('Konfirmasi & Proses Transaksi'), findsNothing);
      expect(find.text('Belum ada menu dipilih'), findsNothing);
      expect(find.text('Buka Keranjang'), findsOneWidget);
    },
  );

  testWidgets('ResponsiveLayout switches between portrait and landscape', (
    WidgetTester tester,
  ) async {
    const widget = MaterialApp(
      home: ResponsiveLayout(
        portrait: Text('PORTRAIT_VIEW'),
        landscape: Text('LANDSCAPE_VIEW'),
      ),
    );

    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(widget);
    expect(find.text('PORTRAIT_VIEW'), findsOneWidget);
    expect(find.text('LANDSCAPE_VIEW'), findsNothing);

    await tester.binding.setSurfaceSize(const Size(1024, 768));
    await tester.pumpWidget(widget);
    expect(find.text('LANDSCAPE_VIEW'), findsOneWidget);
    expect(find.text('PORTRAIT_VIEW'), findsNothing);

    await tester.binding.setSurfaceSize(null);
  });
}
