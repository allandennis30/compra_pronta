# 📱 Compra Pronta - Versão Cliente (Comprador)

Este documento traz instruções técnicas, arquitetura e boas práticas para o módulo cliente do aplicativo **Compra Pronta**.

---

## 📋 Índice
- [Visão Geral](#visão-geral)
- [Arquitetura](#arquitetura)
- [Instalação e Configuração](#instalação-e-configuração)
- [Funcionalidades](#funcionalidades)
- [Padrões de Desenvolvimento](#padrões-de-desenvolvimento)
- [Testes](#testes)

---

## 🎯 Visão Geral

O módulo **Cliente** do Compra Pronta permite aos usuários finais navegar por produtos, gerenciar carrinho de compras, realizar pedidos e acompanhar histórico de compras.

### Características Principais:
- **Lista virtualizada** de produtos com filtros
- **Sistema de favoritos** integrado
- **Carrinho de compras** com controle de quantidade
- **Checkout** com simulação de pagamento
- **Histórico de pedidos** com possibilidade de repetir
- **Perfil do usuário** com dados editáveis

---

## 🏗️ Arquitetura

### Estrutura de Pastas
```
lib/modules/cliente/
├── models/
│   └── product_model.dart
├── controllers/
│   ├── product_list_controller.dart
│   ├── cart_controller.dart
│   ├── checkout_controller.dart
│   └── order_history_controller.dart
├── repositories/
│   ├── product_repository.dart
│   ├── cart_repository.dart
│   └── order_repository.dart
└── pages/
    ├── product_list_page.dart
    ├── product_detail_page.dart
    ├── cart_page.dart
    ├── checkout_page.dart
    ├── order_history_page.dart
    └── profile_page.dart
```

### Padrão MVVM + GetX
- **Models**: Representam os dados
- **Controllers**: Gerenciam estado e lógica de negócio
- **Views**: Interfaces do usuário
- **Repositories**: Acesso a dados

---

## ⚙️ Instalação e Configuração

### Pré-requisitos
- Flutter SDK 3.5.0+
- Dart 3.0.0+
- Android Studio / VS Code

### Passos de Instalação
1. **Clone o repositório:**
   ```bash
   git clone <url-do-repositorio>
   cd compra_pronta
   ```

2. **Instale as dependências:**
   ```bash
   flutter pub get
   ```

3. **Execute o aplicativo:**
   ```bash
   flutter run
   ```

### Credenciais de Teste
- **Email:** `testecliente@teste.com`
- **Senha:** `Senha@123`

---

## 🚀 Funcionalidades

### 📋 Lista de Produtos
- **Lista virtualizada** para performance
- **Filtros por categoria** em tempo real
- **Busca por nome/descrição**
- **Sistema de favoritos**
- **Adição ao carrinho** com um clique

### 🛒 Carrinho de Compras
- **Controle de quantidade** por item
- **Cálculo automático** de subtotal
- **Estimativa de frete** baseada na localização
- **Persistência local** dos dados

### 💳 Checkout
- **Validação de dados** do usuário
- **Simulação de pagamento**
- **Confirmação de pedido**
- **Geração de comprovante**

### 📊 Histórico de Compras
- **Lista de pedidos** realizados
- **Detalhes completos** de cada pedido
- **Status de entrega** em tempo real
- **Possibilidade de repetir** pedidos

### 👤 Perfil do Usuário
- **Visualização** de dados pessoais
- **Edição** de informações
- **Gerenciamento** de endereços
- **Configurações** da conta

---

## 🔧 Padrões de Desenvolvimento

### Repository Pattern
Toda comunicação com dados é feita através de repositories:

```dart
abstract class ProductRepository extends BaseRepository<ProductModel> {
  Future<List<ProductModel>> getProductsByCategory(String category);
  Future<List<String>> getFavorites();
  Future<void> toggleFavorite(String productId);
  Future<ProductModel?> getProductByBarcode(String barcode);
}
```

### Injeção de Dependência
Controllers recebem repositories via GetX:

```dart
class ProductListController extends GetxController {
  final ProductRepository _productRepository = Get.find<ProductRepository>();
  
  void _loadProducts() async {
    final products = await _productRepository.getAll();
    // ...
  }
}
```

### Bindings
Configuração de dependências:

```dart
class ClienteBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductRepository>(() => RepositoryFactory.createProductRepository());
    Get.lazyPut<ProductListController>(() => ProductListController());
  }
}
```

---

## 🧪 Testes

### Testes Unitários
- **Controllers**: Lógica de negócio
- **Models**: Validação de dados
- **Repositories**: Acesso a dados

### Testes de Widget
- **Páginas principais**: Interface do usuário
- **Componentes**: Reutilizáveis

### Testes de Integração
- **Fluxos completos**: Do login ao checkout
- **Navegação**: Entre telas

---

## 📱 Rotas do Cliente

```dart
abstract class Routes {
  static const clienteProdutos = '/cliente/produtos';
  static const clienteDetalhe = '/cliente/produto';
  static const clienteCarrinho = '/cliente/carrinho';
  static const clienteCheckout = '/cliente/checkout';
  static const clienteHistorico = '/cliente/historico';
  static const clientePerfil = '/cliente/perfil';
}
```

---

## 🔒 Segurança

- **Validação de entrada** em todos os campos
- **Sanitização** de dados antes do processamento
- **Criptografia** de dados sensíveis
- **Logs de auditoria** para ações críticas
- **Isolamento de dados** entre usuários:
  - Cada usuário vê apenas seus próprios dados
  - Carrinho de compras isolado por usuário
  - Histórico de pedidos filtrado por usuário
  - Favoritos separados por usuário
  - Vendedores não acessam dados de clientes
  - Clientes não acessam dados de vendedores

---

## 📈 Performance

- **Listas virtualizadas** para grandes volumes
- **Cache de imagens** para produtos
- **Lazy loading** de dados
- **Compressão** de imagens

---

**Compra Pronta** © 2024 - Módulo Cliente 