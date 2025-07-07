import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:compra_pronta/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
    testWidgets('Complete client flow test', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify login page is shown
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Compra Pronta'), findsOneWidget);

      // Login as client
      await tester.enterText(
          find.byType(TextFormField).first, 'testecliente@teste.com');
      await tester.enterText(find.byType(TextFormField).last, 'Senha@123');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      // Verify navigation to product list
      expect(find.text('Produtos'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);

      // Verify products are loaded
      expect(find.byType(Card), findsWidgets);

      // Add product to cart
      final firstProductCard = find.byType(Card).first;
      await tester.tap(find.descendant(
        of: firstProductCard,
        matching: find.byIcon(Icons.add_shopping_cart),
      ));
      await tester.pumpAndSettle();

      // Verify product added to cart
      expect(find.text('Produto adicionado ao carrinho!'), findsOneWidget);

      // Navigate to cart
      await tester.tap(find.byIcon(Icons.shopping_cart));
      await tester.pumpAndSettle();

      // Verify cart page
      expect(find.text('Carrinho'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);

      // Navigate back to products
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify back to product list
      expect(find.text('Produtos'), findsOneWidget);

      // Navigate to profile
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();

      // Verify profile page
      expect(find.text('Perfil'), findsOneWidget);
      expect(find.text('Cliente Teste'), findsOneWidget);
      expect(find.text('testecliente@teste.com'), findsOneWidget);

      // Navigate to order history
      await tester.tap(find.text('Histórico de Pedidos'));
      await tester.pumpAndSettle();

      // Verify order history page
      expect(find.text('Histórico de Pedidos'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);

      // Navigate back to profile
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Logout
      await tester.tap(find.text('Sair'));
      await tester.pumpAndSettle();

      // Verify back to login page
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('Complete vendor flow test', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify login page is shown
      expect(find.text('Login'), findsOneWidget);

      // Login as vendor
      await tester.enterText(
          find.byType(TextFormField).first, 'testevendedor@teste.com');
      await tester.enterText(find.byType(TextFormField).last, 'Venda@123');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      // Verify navigation to vendor dashboard
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Vendedor Teste'), findsOneWidget);

      // Navigate to product management
      await tester.tap(find.text('Produtos'));
      await tester.pumpAndSettle();

      // Verify product list page
      expect(find.text('Gerenciar Produtos'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);

      // Add new product
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Verify product form page
      expect(find.text('Adicionar Produto'), findsOneWidget);
      expect(find.byType(TextFormField), findsWidgets);

      // Fill product form
      await tester.enterText(
          find.byType(TextFormField).at(0), 'Novo Produto Teste');
      await tester.enterText(
          find.byType(TextFormField).at(1), 'Descrição do produto teste');
      await tester.enterText(find.byType(TextFormField).at(2), '10.50');
      await tester.enterText(find.byType(TextFormField).at(3), 'alimentos');
      await tester.enterText(find.byType(TextFormField).at(4), '7891234567890');

      // Save product
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      // Verify product saved
      expect(find.text('Produto salvo com sucesso!'), findsOneWidget);

      // Navigate to orders
      await tester.tap(find.text('Pedidos'));
      await tester.pumpAndSettle();

      // Verify order list page
      expect(find.text('Pedidos'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);

      // Navigate to metrics
      await tester.tap(find.text('Métricas'));
      await tester.pumpAndSettle();

      // Verify metrics page
      expect(find.text('Métricas de Vendas'), findsOneWidget);
      expect(find.text('Vendas do Dia'), findsOneWidget);
      expect(find.text('Vendas da Semana'), findsOneWidget);
      expect(find.text('Vendas do Mês'), findsOneWidget);

      // Navigate to settings
      await tester.tap(find.text('Configurações'));
      await tester.pumpAndSettle();

      // Verify settings page
      expect(find.text('Configurações'), findsOneWidget);
      expect(find.text('Vendedor Teste'), findsOneWidget);

      // Logout
      await tester.tap(find.text('Sair'));
      await tester.pumpAndSettle();

      // Verify back to login page
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('Product search and filter test', (WidgetTester tester) async {
      // Start the app and login as client
      app.main();
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byType(TextFormField).first, 'testecliente@teste.com');
      await tester.enterText(find.byType(TextFormField).last, 'Senha@123');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      // Verify product list
      expect(find.text('Produtos'), findsOneWidget);

      // Search for a product
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'arroz');
      await tester.pumpAndSettle();

      // Verify search results
      expect(find.byType(Card), findsWidgets);

      // Clear search
      await tester.enterText(searchField, '');
      await tester.pumpAndSettle();

      // Filter by category
      await tester.tap(find.text('Filtrar'));
      await tester.pumpAndSettle();

      // Select category
      await tester.tap(find.text('alimentos'));
      await tester.pumpAndSettle();

      // Verify filtered results
      expect(find.byType(Card), findsWidgets);

      // Clear filter
      await tester.tap(find.text('Limpar Filtros'));
      await tester.pumpAndSettle();
    });

    testWidgets('Cart operations test', (WidgetTester tester) async {
      // Start the app and login as client
      app.main();
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byType(TextFormField).first, 'testecliente@teste.com');
      await tester.enterText(find.byType(TextFormField).last, 'Senha@123');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      // Add multiple products to cart
      final productCards = find.byType(Card);
      expect(productCards, findsWidgets);

      // Add first product
      await tester.tap(find.descendant(
        of: productCards.first,
        matching: find.byIcon(Icons.add_shopping_cart),
      ));
      await tester.pumpAndSettle();

      // Add second product
      if (productCards.evaluate().length > 1) {
        await tester.tap(find.descendant(
          of: productCards.at(1),
          matching: find.byIcon(Icons.add_shopping_cart),
        ));
        await tester.pumpAndSettle();
      }

      // Navigate to cart
      await tester.tap(find.byIcon(Icons.shopping_cart));
      await tester.pumpAndSettle();

      // Verify cart items
      expect(find.text('Carrinho'), findsOneWidget);
      expect(find.byType(ListTile), findsWidgets);

      // Update quantity
      final quantityButtons = find.byIcon(Icons.add);
      if (quantityButtons.evaluate().isNotEmpty) {
        await tester.tap(quantityButtons.first);
        await tester.pumpAndSettle();
      }

      // Remove item
      final removeButtons = find.byIcon(Icons.delete);
      if (removeButtons.evaluate().isNotEmpty) {
        await tester.tap(removeButtons.first);
        await tester.pumpAndSettle();
      }

      // Clear cart
      await tester.tap(find.text('Limpar Carrinho'));
      await tester.pumpAndSettle();

      // Verify empty cart
      expect(find.text('Carrinho vazio'), findsOneWidget);
    });

    testWidgets('Checkout flow test', (WidgetTester tester) async {
      // Start the app and login as client
      app.main();
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byType(TextFormField).first, 'testecliente@teste.com');
      await tester.enterText(find.byType(TextFormField).last, 'Senha@123');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      // Add product to cart
      final productCard = find.byType(Card).first;
      await tester.tap(find.descendant(
        of: productCard,
        matching: find.byIcon(Icons.add_shopping_cart),
      ));
      await tester.pumpAndSettle();

      // Navigate to cart
      await tester.tap(find.byIcon(Icons.shopping_cart));
      await tester.pumpAndSettle();

      // Proceed to checkout
      await tester.tap(find.text('Finalizar Compra'));
      await tester.pumpAndSettle();

      // Verify checkout page
      expect(find.text('Checkout'), findsOneWidget);
      expect(find.text('Resumo do Pedido'), findsOneWidget);

      // Fill delivery information
      final addressFields = find.byType(TextFormField);
      if (addressFields.evaluate().isNotEmpty) {
        await tester.enterText(addressFields.at(0), 'Rua Teste, 123');
        await tester.enterText(addressFields.at(1), 'Observações de entrega');
      }

      // Select payment method
      await tester.tap(find.text('Cartão de Crédito'));
      await tester.pumpAndSettle();

      // Confirm order
      await tester.tap(find.text('Confirmar Pedido'));
      await tester.pumpAndSettle();

      // Verify order confirmation
      expect(find.text('Pedido Confirmado!'), findsOneWidget);
      expect(find.text('Obrigado pela compra!'), findsOneWidget);
    });

    testWidgets('Error handling test', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Try to login with invalid credentials
      await tester.enterText(
          find.byType(TextFormField).first, 'invalid@email.com');
      await tester.enterText(find.byType(TextFormField).last, 'wrongpassword');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      // Verify error message
      expect(find.text('Email ou senha inválidos'), findsOneWidget);

      // Try to login with empty fields
      await tester.enterText(find.byType(TextFormField).first, '');
      await tester.enterText(find.byType(TextFormField).last, '');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      // Verify validation messages
      expect(find.text('Digite um email válido'), findsOneWidget);
      expect(find.text('Digite sua senha'), findsOneWidget);
    });

    testWidgets('Navigation and back button test', (WidgetTester tester) async {
      // Start the app and login as client
      app.main();
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byType(TextFormField).first, 'testecliente@teste.com');
      await tester.enterText(find.byType(TextFormField).last, 'Senha@123');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      // Navigate to product detail
      final productCard = find.byType(Card).first;
      await tester.tap(productCard);
      await tester.pumpAndSettle();

      // Verify product detail page
      expect(find.text('Detalhes do Produto'), findsOneWidget);

      // Navigate back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify back to product list
      expect(find.text('Produtos'), findsOneWidget);

      // Navigate to cart
      await tester.tap(find.byIcon(Icons.shopping_cart));
      await tester.pumpAndSettle();

      // Navigate back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify back to product list
      expect(find.text('Produtos'), findsOneWidget);
    });
  });
}
