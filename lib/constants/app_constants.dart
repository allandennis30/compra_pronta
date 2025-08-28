class AppConstants {
  // Cores
  static const int primaryColor = 0xFF2E7D32;
  static const int secondaryColor = 0xFF4CAF50;
  static const int accentColor = 0xFF8BC34A;
  static const int backgroundColor = 0xFFF5F5F5;
  static const int errorColor = 0xFFD32F2F;
  static const int warningColor = 0xFFFF9800;
  static const int successColor = 0xFF4CAF50;

  // Textos
  static const String appName = 'Compra Pronta';
  static const String appVersion = '1.0.0';
  
  // Status de pedidos
  static const String statusPending = 'pending';
  static const String statusConfirmed = 'confirmed';
  static const String statusPreparing = 'preparing';
  static const String statusDelivering = 'delivering';
  static const String statusDelivered = 'delivered';
  static const String statusCancelled = 'cancelled';

  // Categorias de produtos
  static const List<String> productCategories = [
    'Frutas e Verduras',
    'Carnes',
    'Laticínios',
    'Pães e Massas',
    'Bebidas',
    'Limpeza',
    'Higiene',
    'Outros'
  ];

  // Taxa de entrega base
  static const double baseDeliveryFee = 5.0;
  static const double deliveryFeePerKm = 1.0;

  // Limites
  static const int maxProductQuantity = 99;
  static const double minOrderValue = 10.0;
  static const int maxDeliveryDistance = 10; // km

  // Storage keys
  static const String userKey = 'user';
  static const String cartKey = 'cart';
  static const String ordersKey = 'orders';
  static const String productsKey = 'products';
  static const String favoritesKey = 'favorites';
  static const String tokenKey = 'auth_token';

  // API Configuration
  static const String baseUrl = 'https://backend-compra-pronta.onrender.com';
  static const String apiVersion = '/api';
  static const String authEndpoint = '/auth';
  
  // Configuração para desenvolvimento local (descomente se necessário)
  // static const String baseUrl = 'http://localhost:3000';
  
  // API Endpoints
  static const String loginEndpoint = '$baseUrl$apiVersion$authEndpoint/login';
  static const String registerEndpoint = '$baseUrl$apiVersion$authEndpoint/register';
  static const String verifyTokenEndpoint = '$baseUrl$apiVersion$authEndpoint/verify';
  static const String refreshTokenEndpoint = '$baseUrl$apiVersion$authEndpoint/refresh';
  static const String profileEndpoint = '$baseUrl$apiVersion$authEndpoint/profile';
  static const String logoutEndpoint = '$baseUrl$apiVersion$authEndpoint/logout';
  static const String usersEndpoint = '$baseUrl$apiVersion$authEndpoint/users';

  // Credenciais de teste para o backend real
  // Cliente: testecliente@teste.com / Senha@123
  // Vendedor: testevendedor@teste.com / Venda@123

  // Mock produtos
  static const List<Map<String, dynamic>> mockProducts = [
    {
      "id": "prod_001",
      "name": "Maçã Fuji",
      "description": "Maçãs frescas e doces, ideais para consumo in natura",
      "price": 8.90,
      "imageUrl": "https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=400",
      "category": "Frutas e Verduras",
      "barcode": "7891234567890",
      "stock": 50,
      "isAvailable": true,
      "rating": 4.5,
      "reviewCount": 12
    },
    {
      "id": "prod_002",
      "name": "Banana Prata",
      "description": "Bananas prata maduras e saborosas",
      "price": 4.50,
      "imageUrl": "https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=400",
      "category": "Frutas e Verduras",
      "barcode": "7891234567891",
      "stock": 30,
      "isAvailable": true,
      "rating": 4.2,
      "reviewCount": 8
    },
    {
      "id": "prod_003",
      "name": "Leite Integral",
      "description": "Leite integral fresco, 1L",
      "price": 6.90,
      "imageUrl": "https://images.unsplash.com/photo-1563636619-e9143da7973b?w=400",
      "category": "Laticínios",
      "barcode": "7891234567892",
      "stock": 25,
      "isAvailable": true,
      "rating": 4.7,
      "reviewCount": 15
    },
    {
      "id": "prod_004",
      "name": "Pão Francês",
      "description": "Pão francês fresco, 500g",
      "price": 3.50,
      "imageUrl": "https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400",
      "category": "Pães e Massas",
      "barcode": "7891234567893",
      "stock": 40,
      "isAvailable": true,
      "rating": 4.3,
      "reviewCount": 20
    },
    {
      "id": "prod_005",
      "name": "Coca-Cola",
      "description": "Refrigerante Coca-Cola, 2L",
      "price": 8.50,
      "imageUrl": "https://images.unsplash.com/photo-1629203851122-3726ecdf080e?w=400",
      "category": "Bebidas",
      "barcode": "7891234567894",
      "stock": 35,
      "isAvailable": true,
      "rating": 4.1,
      "reviewCount": 18
    },
    {
      "id": "prod_006",
      "name": "Detergente Líquido",
      "description": "Detergente líquido para louças, 500ml",
      "price": 5.90,
      "imageUrl": "https://images.unsplash.com/photo-1582735689369-4fe89db7114c?w=400",
      "category": "Limpeza",
      "barcode": "7891234567895",
      "stock": 20,
      "isAvailable": true,
      "rating": 4.4,
      "reviewCount": 10
    }
  ];
}