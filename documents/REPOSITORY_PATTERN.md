# Repository Pattern - Implementação

## Visão Geral

Este projeto implementa o **Repository Pattern** seguindo os princípios da Clean Architecture. Toda conexão com banco de dados e acesso a APIs é feita através de repositories, garantindo separação de responsabilidades e facilitando testes.

## Estrutura

```
lib/
├── core/
│   └── repositories/
│       ├── base_repository.dart          # Interface base para repositories
│       └── repository_factory.dart       # Factory para criar repositories
│
├── modules/
│   ├── auth/
│   │   └── repositories/
│   │       └── auth_repository.dart      # Repository de autenticação
│   │
│   ├── cliente/
│   │   └── repositories/
│   │       ├── product_repository.dart   # Repository de produtos
│   │       └── cart_repository.dart      # Repository do carrinho
│   │
│   └── vendedor/
│       └── repositories/
│           └── vendor_metrics_repository.dart  # Repository de métricas
```

## Implementação

### 1. Repository Base

```dart
abstract class BaseRepository<T> {
  Future<List<T>> getAll();
  Future<T?> getById(String id);
  Future<T> create(T item);
  Future<T> update(T item);
  Future<bool> delete(String id);
  Future<List<T>> search(String query);
}
```

### 2. Repository Específico

```dart
abstract class ProductRepository extends BaseRepository<ProductModel> {
  Future<List<ProductModel>> getProductsByCategory(String category);
  Future<List<String>> getFavorites();
  Future<void> toggleFavorite(String productId);
  Future<ProductModel?> getProductByBarcode(String barcode);
}
```

### 3. Implementação Mock

```dart
class ProductRepositoryImpl implements ProductRepository {
  @override
  Future<List<ProductModel>> getAll() async {
    // Simular delay de rede
    await Future.delayed(Duration(milliseconds: 500));
    
    return AppConstants.mockProducts
        .map((json) => ProductModel.fromJson(json))
        .toList();
  }
  
  // ... outros métodos
}
```

### 4. Implementação Real (API)

```dart
class ProductApiRepository implements BaseRepository<ProductModel> {
  static const String baseUrl = 'https://api.supermercado.com/v1';
  
  @override
  Future<List<ProductModel>> getAll() async {
    final response = await _httpClient.get(
      Uri.parse('$baseUrl/products'),
      headers: {'Authorization': 'Bearer $apiKey'},
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data.map((json) => ProductModel.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar produtos');
    }
  }
}
```

## Factory Pattern

A `RepositoryFactory` permite trocar facilmente entre implementações mock e reais:

```dart
class RepositoryFactory {
  static const bool _useMockData = true; // Alterar para false para usar APIs reais
  
  static ProductRepository createProductRepository() {
    if (_useMockData) {
      return ProductRepositoryImpl(); // Mock
    } else {
      return ProductApiRepository(); // API real
    }
  }
}
```

## Injeção de Dependência

Os repositories são injetados nos controllers através do GetX:

```dart
class ProductListController extends GetxController {
  final ProductRepository _productRepository = Get.find<ProductRepository>();
  
  void _loadProducts() async {
    final products = await _productRepository.getAll();
    // ...
  }
}
```

## Bindings

Os bindings configuram a injeção de dependência:

```dart
class ClienteBinding extends Bindings {
  @override
  void dependencies() {
    // Repositories usando factory
    Get.lazyPut<ProductRepository>(() => RepositoryFactory.createProductRepository());
    
    // Controllers
    Get.lazyPut<ProductListController>(() => ProductListController());
  }
}
```

## Benefícios

### 1. Separação de Responsabilidades
- Controllers não acessam dados diretamente
- Lógica de acesso a dados centralizada nos repositories

### 2. Testabilidade
- Fácil mock de repositories para testes
- Controllers podem ser testados isoladamente

### 3. Flexibilidade
- Troca de fonte de dados sem afetar controllers
- Suporte a múltiplas fontes (API, banco local, cache)

### 4. Manutenibilidade
- Mudanças na API/banco isoladas nos repositories
- Código mais organizado e legível

### 5. Reutilização
- Repositories podem ser usados por múltiplos controllers
- Lógica de acesso a dados compartilhada

## Fluxo de Dados

```
Controller → Repository → API/Database
     ↓           ↓           ↓
   UI Layer → Business Logic → Data Layer
```

## Configuração de Ambiente

```dart
class Environment {
  static const String current = 'development';
  
  static String get apiBaseUrl {
    switch (current) {
      case 'development':
        return 'https://dev-api.supermercado.com/v1';
      case 'production':
        return 'https://api.supermercado.com/v1';
      default:
        return 'https://dev-api.supermercado.com/v1';
    }
  }
}
```

## Como Usar

### 1. Criar um novo Repository

```dart
abstract class OrderRepository extends BaseRepository<OrderModel> {
  Future<List<OrderModel>> getOrdersByStatus(String status);
  Future<void> updateOrderStatus(String orderId, String status);
}

class OrderRepositoryImpl implements OrderRepository {
  // Implementação
}
```

### 2. Registrar no Factory

```dart
class RepositoryFactory {
  static OrderRepository createOrderRepository() {
    if (_useMockData) {
      return OrderRepositoryImpl();
    } else {
      return OrderApiRepository();
    }
  }
}
```

### 3. Injetar no Controller

```dart
class OrderController extends GetxController {
  final OrderRepository _orderRepository = Get.find<OrderRepository>();
  
  void loadOrders() async {
    final orders = await _orderRepository.getAll();
    // ...
  }
}
```

### 4. Registrar no Binding

```dart
class OrderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderRepository>(() => RepositoryFactory.createOrderRepository());
    Get.lazyPut<OrderController>(() => OrderController());
  }
}
```

## Boas Práticas

1. **Sempre use interfaces**: Defina contracts claros para repositories
2. **Trate erros adequadamente**: Implemente tratamento de erro nos repositories
3. **Use cache quando apropriado**: Implemente cache para melhor performance
4. **Documente APIs**: Documente métodos e parâmetros dos repositories
5. **Teste repositories**: Crie testes unitários para repositories
6. **Use factory pattern**: Facilite troca entre implementações
7. **Configure ambientes**: Separe configurações por ambiente

## Exemplo de Teste

```dart
class MockProductRepository implements ProductRepository {
  @override
  Future<List<ProductModel>> getAll() async {
    return [
      ProductModel(id: '1', name: 'Test Product', price: 10.0),
    ];
  }
}

void main() {
  test('ProductListController should load products', () async {
    final mockRepository = MockProductRepository();
    final controller = ProductListController();
    
    // Test implementation
  });
}
```

## Conclusão

O Repository Pattern implementado neste projeto garante:

- **Arquitetura limpa** e bem estruturada
- **Fácil manutenção** e evolução do código
- **Testabilidade** alta
- **Flexibilidade** para trocar fontes de dados
- **Reutilização** de código

Esta implementação segue as melhores práticas de desenvolvimento Flutter e Clean Architecture. 