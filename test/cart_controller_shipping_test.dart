import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Shipping Calculation Logic Tests', () {
    // Função auxiliar para simular a lógica de cálculo de frete
    double calculateShipping({
      required double subtotal,
      required double taxaEntrega,
      required double limiteEntregaGratis,
      required double pedidoMinimo,
    }) {
      if (subtotal < pedidoMinimo) {
        return taxaEntrega;
      } else if (subtotal >= limiteEntregaGratis) {
        return 0.0;
      } else {
        return taxaEntrega;
      }
    }

    test('Deve aplicar taxa de entrega quando subtotal menor que pedido mínimo', () {
      // Arrange
      const double subtotal = 30.0;
      const double taxaEntrega = 8.50;
      const double limiteEntregaGratis = 100.0;
      const double pedidoMinimo = 50.0;

      // Act
      final shipping = calculateShipping(
        subtotal: subtotal,
        taxaEntrega: taxaEntrega,
        limiteEntregaGratis: limiteEntregaGratis,
        pedidoMinimo: pedidoMinimo,
      );
      final total = subtotal + shipping;

      // Assert
      expect(shipping, equals(8.50));
      expect(total, equals(38.50));
    });

    test('Deve aplicar taxa de entrega quando subtotal entre pedido mínimo e limite frete grátis', () {
      // Arrange
      const double subtotal = 75.0;
      const double taxaEntrega = 8.50;
      const double limiteEntregaGratis = 100.0;
      const double pedidoMinimo = 50.0;

      // Act
      final shipping = calculateShipping(
        subtotal: subtotal,
        taxaEntrega: taxaEntrega,
        limiteEntregaGratis: limiteEntregaGratis,
        pedidoMinimo: pedidoMinimo,
      );
      final total = subtotal + shipping;

      // Assert
      expect(shipping, equals(8.50));
      expect(total, equals(83.50));
    });

    test('Deve zerar frete quando subtotal atinge limite para frete grátis', () {
      // Arrange
      const double subtotal = 120.0;
      const double taxaEntrega = 8.50;
      const double limiteEntregaGratis = 100.0;
      const double pedidoMinimo = 50.0;

      // Act
      final shipping = calculateShipping(
        subtotal: subtotal,
        taxaEntrega: taxaEntrega,
        limiteEntregaGratis: limiteEntregaGratis,
        pedidoMinimo: pedidoMinimo,
      );
      final total = subtotal + shipping;

      // Assert
      expect(shipping, equals(0.0));
      expect(total, equals(120.0));
    });

    test('Deve zerar frete quando subtotal igual ao limite para frete grátis', () {
      // Arrange
      const double subtotal = 100.0;
      const double taxaEntrega = 8.50;
      const double limiteEntregaGratis = 100.0;
      const double pedidoMinimo = 50.0;

      // Act
      final shipping = calculateShipping(
        subtotal: subtotal,
        taxaEntrega: taxaEntrega,
        limiteEntregaGratis: limiteEntregaGratis,
        pedidoMinimo: pedidoMinimo,
      );
      final total = subtotal + shipping;

      // Assert
      expect(shipping, equals(0.0));
      expect(total, equals(100.0));
    });

    test('Cenário real: pedido de R\$ 45 com mínimo R\$ 50 e frete grátis R\$ 80', () {
      // Arrange - Cenário que estava causando problema
      const double subtotal = 45.0;
      const double taxaEntrega = 5.0;
      const double limiteEntregaGratis = 80.0;
      const double pedidoMinimo = 50.0;

      // Act
      final shipping = calculateShipping(
        subtotal: subtotal,
        taxaEntrega: taxaEntrega,
        limiteEntregaGratis: limiteEntregaGratis,
        pedidoMinimo: pedidoMinimo,
      );
      final total = subtotal + shipping;

      // Assert
      expect(shipping, equals(5.0), reason: 'Deve cobrar frete pois está abaixo do pedido mínimo');
      expect(total, equals(50.0));
    });

    test('Cenário real: pedido de R\$ 60 com mínimo R\$ 50 e frete grátis R\$ 80', () {
      // Arrange
      const double subtotal = 60.0;
      const double taxaEntrega = 5.0;
      const double limiteEntregaGratis = 80.0;
      const double pedidoMinimo = 50.0;

      // Act
      final shipping = calculateShipping(
        subtotal: subtotal,
        taxaEntrega: taxaEntrega,
        limiteEntregaGratis: limiteEntregaGratis,
        pedidoMinimo: pedidoMinimo,
      );
      final total = subtotal + shipping;

      // Assert
      expect(shipping, equals(5.0), reason: 'Deve cobrar frete pois está entre o mínimo e o limite para frete grátis');
      expect(total, equals(65.0));
    });

    test('Cenário real: pedido de R\$ 85 com mínimo R\$ 50 e frete grátis R\$ 80', () {
      // Arrange
      const double subtotal = 85.0;
      const double taxaEntrega = 5.0;
      const double limiteEntregaGratis = 80.0;
      const double pedidoMinimo = 50.0;

      // Act
      final shipping = calculateShipping(
        subtotal: subtotal,
        taxaEntrega: taxaEntrega,
        limiteEntregaGratis: limiteEntregaGratis,
        pedidoMinimo: pedidoMinimo,
      );
      final total = subtotal + shipping;

      // Assert
      expect(shipping, equals(0.0), reason: 'Deve ter frete grátis pois atingiu o limite');
      expect(total, equals(85.0));
    });
  });
}