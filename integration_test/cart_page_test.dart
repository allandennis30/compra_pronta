import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:compra_pronta/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Cart Page Integration Tests', () {
    testWidgets('Cart page responsive layout test',
        (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Login as client
      await tester.enterText(
          find.byType(TextFormField).first, 'testecliente@teste.com');
      await tester.enterText(find.byType(TextFormField).last, 'Senha@123');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      // Add product to cart
      final firstProductCard = find.byType(Card).first;
      await tester.tap(find.descendant(
        of: firstProductCard,
        matching: find.byIcon(Icons.add_shopping_cart),
      ));
      await tester.pumpAndSettle();

      // Navigate to cart
      await tester.tap(find.byIcon(Icons.shopping_cart));
      await tester.pumpAndSettle();

      // Verify cart page elements
      expect(find.text('Carrinho'), findsOneWidget);
      expect(find.text('Resumo do Pedido'), findsOneWidget);
      expect(find.text('Finalizar Compra'), findsOneWidget);

      // Verify cart item is displayed
      expect(find.byType(Card), findsWidgets);

      // Test quantity controls
      final addButton = find.byIcon(Icons.add).first;
      final removeButton = find.byIcon(Icons.remove).first;

      // Add quantity
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // Verify no snackbar appears (UX improvement)
      expect(find.text('Produto adicionado ao carrinho!'), findsNothing);

      // Remove quantity
      await tester.tap(removeButton);
      await tester.pumpAndSettle();

      // Verify cart summary updates
      expect(find.text('Subtotal:'), findsOneWidget);
      expect(find.text('Frete:'), findsOneWidget);
      expect(find.text('Total:'), findsOneWidget);
    });

    testWidgets('Cart page empty state test', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Login as client
      await tester.enterText(
          find.byType(TextFormField).first, 'testecliente@teste.com');
      await tester.enterText(find.byType(TextFormField).last, 'Senha@123');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      // Navigate to cart (should be empty)
      await tester.tap(find.byIcon(Icons.shopping_cart));
      await tester.pumpAndSettle();

      // Verify empty state
      expect(find.text('Seu carrinho está vazio'), findsOneWidget);
      expect(find.text('Adicione produtos para continuar'), findsOneWidget);
      expect(find.text('Ver Produtos'), findsOneWidget);

      // Test navigation back to products
      await tester.tap(find.text('Ver Produtos'));
      await tester.pumpAndSettle();

      // Verify back to product list
      expect(find.text('Produtos'), findsOneWidget);
    });

    testWidgets('Cart page clear cart test', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Login as client
      await tester.enterText(
          find.byType(TextFormField).first, 'testecliente@teste.com');
      await tester.enterText(find.byType(TextFormField).last, 'Senha@123');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      // Add product to cart
      final firstProductCard = find.byType(Card).first;
      await tester.tap(find.descendant(
        of: firstProductCard,
        matching: find.byIcon(Icons.add_shopping_cart),
      ));
      await tester.pumpAndSettle();

      // Navigate to cart
      await tester.tap(find.byIcon(Icons.shopping_cart));
      await tester.pumpAndSettle();

      // Verify cart has items
      expect(find.byType(Card), findsWidgets);

      // Clear cart
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      // Verify confirmation dialog
      expect(find.text('Limpar Carrinho'), findsOneWidget);
      expect(find.text('Tem certeza que deseja limpar o carrinho?'),
          findsOneWidget);

      // Confirm clear
      await tester.tap(find.text('Limpar'));
      await tester.pumpAndSettle();

      // Verify cart is empty
      expect(find.text('Seu carrinho está vazio'), findsOneWidget);
    });

    testWidgets('Cart page checkout validation test',
        (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Login as client
      await tester.enterText(
          find.byType(TextFormField).first, 'testecliente@teste.com');
      await tester.enterText(find.byType(TextFormField).last, 'Senha@123');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      // Navigate to cart (empty)
      await tester.tap(find.byIcon(Icons.shopping_cart));
      await tester.pumpAndSettle();

      // Verify checkout button is disabled or shows minimum value message
      final checkoutButton = find.text('Finalizar Compra');
      if (checkoutButton.evaluate().isNotEmpty) {
        // If button exists, it should be disabled or show minimum value message
        expect(find.textContaining('Valor mínimo:'), findsOneWidget);
      }
    });

    testWidgets('Cart page responsive controls test',
        (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Login as client
      await tester.enterText(
          find.byType(TextFormField).first, 'testecliente@teste.com');
      await tester.enterText(find.byType(TextFormField).last, 'Senha@123');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      // Add product to cart
      final firstProductCard = find.byType(Card).first;
      await tester.tap(find.descendant(
        of: firstProductCard,
        matching: find.byIcon(Icons.add_shopping_cart),
      ));
      await tester.pumpAndSettle();

      // Navigate to cart
      await tester.tap(find.byIcon(Icons.shopping_cart));
      await tester.pumpAndSettle();

      // Verify quantity controls are present and functional
      expect(find.byIcon(Icons.add), findsWidgets);
      expect(find.byIcon(Icons.remove), findsWidgets);

      // Test quantity controls functionality
      final addButton = find.byIcon(Icons.add).first;
      final removeButton = find.byIcon(Icons.remove).first;

      // Get initial quantity
      final initialQuantity = find.text('1');
      expect(initialQuantity, findsOneWidget);

      // Add quantity
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // Verify quantity increased
      expect(find.text('2'), findsOneWidget);

      // Remove quantity
      await tester.tap(removeButton);
      await tester.pumpAndSettle();

      // Verify quantity decreased
      expect(find.text('1'), findsOneWidget);
    });
  });
}
