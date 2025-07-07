# 📑 Documentação Técnica: Supermercado Virtual Flutter (MVVM + GetX)

Este arquivo `.md` reúne TODOS os requisitos, fluxos, arquitetura, regras de negócio e instruções de criação para o seu aplicativo de supermercado virtual. Use-o como input para uma IA de scaffolding ou siga manualmente cada passo.

---

## 1. Visão Geral

- **Tecnologia**: Flutter (Dart)  
- **Arquitetura**: MVVM (Model‑View‑ViewModel)  
- **Gerenciamento de Estado & Rotas**: GetX  
- **Performance**: listas virtualizadas, isolates, caching  
- **Perfis**:  
  - **Único Vendedor** (`istore: true`)  
  - **Múltiplos Clientes** (`istore: false`)  

---

## 2. Estrutura de Pastas

```text
lib/
├── core/
│   ├── constants/         
│   ├── themes/            
│   ├── utils/             
│   ├── services/          
│   ├── repositories/      # Camada de acesso a dados
│   └── bindings/          
│
├── modules/
│   ├── auth/
│   │   ├── pages/
│   │   │   ├── login_page.dart
│   │   │   └── signup_page.dart
│   │   ├── controllers/
│   │   │   └── auth_controller.dart
│   │   └── repositories/
│   │       └── auth_repository.dart
│   │
│   ├── cliente/
│   │   ├── models/
│   │   │   └── product_model.dart
│   │   ├── controllers/
│   │   │   ├── product_list_controller.dart
│   │   │   ├── cart_controller.dart
│   │   │   ├── checkout_controller.dart
│   │   │   └── order_history_controller.dart
│   │   ├── repositories/
│   │   │   ├── product_repository.dart
│   │   │   ├── cart_repository.dart
│   │   │   └── order_repository.dart
│   │   └── pages/
│   │       ├── product_list_page.dart
│   │       ├── product_detail_page.dart
│   │       ├── cart_page.dart
│   │       ├── checkout_page.dart
│   │       └── order_history_page.dart
│   │
│   └── vendedor/
│       ├── models/
│       │   ├── product_model.dart
│       │   ├── order_model.dart
│       │   └── sales_metrics_model.dart
│       ├── controllers/
│       │   ├── vendor_product_list_controller.dart
│       │   ├── vendor_product_form_controller.dart
│       │   ├── vendor_order_list_controller.dart
│       │   ├── vendor_order_detail_controller.dart
│       │   ├── vendor_scan_controller.dart
│       │   └── vendor_metrics_controller.dart
│       ├── repositories/
│       │   ├── vendor_product_repository.dart
│       │   ├── vendor_order_repository.dart
│       │   └── vendor_metrics_repository.dart
│       └── pages/
│           ├── vendor_dashboard_page.dart
│           ├── vendor_product_list_page.dart
│           ├── vendor_product_form_page.dart
│           ├── vendor_order_list_page.dart
│           ├── vendor_order_detail_page.dart
│           ├── vendor_scan_page.dart
│           └── vendor_settings_page.dart
│
├── routes/
│   └── app_pages.dart     
│
└── main.dart              
```

---

## 3. Model de Usuário

```dart
class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final AddressModel address;
  final double latitude;
  final double longitude;
  final bool istore;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.istore = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    phone: json['phone'],
    address: AddressModel.fromJson(json['address']),
    latitude: json['latitude'],
    longitude: json['longitude'],
    istore: json['istore'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'address': address.toJson(),
    'latitude': latitude,
    'longitude': longitude,
    'istore': istore,
  };
}

class AddressModel {
  final String street;
  final String number;
  final String? complement;
  final String neighborhood;
  final String city;
  final String state;
  final String zipCode;

  AddressModel({
    required this.street,
    required this.number,
    this.complement,
    required this.neighborhood,
    required this.city,
    required this.state,
    required this.zipCode,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
    street: json['street'],
    number: json['number'],
    complement: json['complement'],
    neighborhood: json['neighborhood'],
    city: json['city'],
    state: json['state'],
    zipCode: json['zipCode'],
  );

  Map<String, dynamic> toJson() => {
    'street': street,
    'number': number,
    'complement': complement,
    'neighborhood': neighborhood,
    'city': city,
    'state': state,
    'zipCode': zipCode,
  };
}
```

---

## 4. Cadastro & Autenticação

**SignupPage** define automaticamente `istore`:
- `false` → fluxo cliente
- `true` → desbloqueia módulo vendedor

**Campos**: nome, e‑mail, senha + confirmação, telefone, endereço completo, GPS.

**AuthController** persiste em GetStorage e define initial binding.

---

## 5. Fluxos do Cliente

- **Lista virtualizada**, filtro, favoritos
- **Detalhe do produto**, avaliações
- **Carrinho** (quantidade, subtotal, frete estimado)
- **Checkout** (simulação pagamento, grava pedido)
- **Acompanhamento** (status + push)
- **Histórico** (repetir pedido)
- **Perfil** (editar dados, endereços, métodos de pagamento)

---

## 6. Fluxos do Vendedor

- **Dashboard** (vendas, comparativos, alertas de estoque, exportar relatórios)
- **Gestão de produtos** (inclui campo barcode e scanner)
- **Gestão de pedidos** (lista, detalhe, exportar WhatsApp, status)
- **Scanner de embalagem** (leitura de código, lista automática, relatório de embalagem)
- **Configurações da loja** (horário, zonas de entrega, taxa, dados da loja)
- **Métricas & relatórios** programados

---

## 7. Barcode & Scanner

- **ProductModel.barcode** obrigatório
- **BarcodeService** com mobile_scanner
- **VendorScanController** gerencia scannedItems e total
- **Página de scanner** para embalagem e confirmação de pedidos

---

## 8. Mock Users

Para testes de login e fluxos completos, insira estes objetos no seu mock backend ou no cache inicial:

```json
// Cliente de Teste
{
  "id": "user_cliente_001",
  "name": "Cliente Teste",
  "email": "testecliente@teste.com",
  "password": "Senha@123",
  "phone": "+5511999999999",
  "address": {
    "street": "Rua Exemplo",
    "number": "123",
    "complement": "Apto 45",
    "neighborhood": "Bairro Teste",
    "city": "São Paulo",
    "state": "SP",
    "zipCode": "01000-000"
  },
  "latitude": -23.550520,
  "longitude": -46.633308,
  "istore": false
}

// Vendedor de Teste
{
  "id": "user_vendedor_001",
  "name": "Vendedor Teste",
  "email": "testevendedor@teste.com",
  "password": "Venda@123",
  "phone": "+5511988888888",
  "address": {
    "street": "Avenida Loja",
    "number": "456",
    "complement": null,
    "neighborhood": "Centro",
    "city": "São Paulo",
    "state": "SP",
    "zipCode": "01010-000"
  },
  "latitude": -23.551000,
  "longitude": -46.634000,
  "istore": true
}
```

**Credenciais de Acesso:**
- **Cliente**: testecliente@teste.com / Senha@123
- **Vendedor**: testevendedor@teste.com / Venda@123

---

## 9. Instruções para Criar o Projeto (passo a passo)

### 1. Criar o projeto Flutter
```bash
flutter create mercado_app
cd mercado_app
```

### 2. Adicionar dependências (no pubspec.yaml):
```yaml
dependencies:
  flutter:
    sdk: flutter
  get: ^4.6.5
  get_storage: ^2.0.3
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  mobile_scanner: ^2.0.0
  barcode_scan2: ^4.2.0
  flutter_launcher_icons: ^0.10.0
  charts_flutter: ^0.12.0
  # outras conforme necessidade: firebase_messaging, url_launcher, etc.
```

### 3. Configurar Hive / GetStorage
Em main.dart, inicializar:
```dart
await GetStorage.init();
await Hive.initFlutter();
```

### 4. Criar estrutura de pastas
Pelo terminal ou manual:
```bash
mkdir -p lib/{core/{constants,themes,utils,services,bindings},modules/{auth/{pages,controllers},cliente/{models,controllers,pages},vendedor/{models,controllers,pages}},routes}
touch lib/main.dart lib/routes/app_pages.dart
```

### 5. Implementar Bindings
Ex.: AuthBinding injetando AuthController.

### 6. Criar app_pages.dart
Defina rotas e bindings:
```dart
abstract class Routes {
  static const LOGIN = '/login';
  static const SIGNUP = '/signup';
  // ...
}

class AppPages {
  static final pages = [
    GetPage(name: Routes.LOGIN, page: () => LoginPage(), binding: AuthBinding()),
    // demais páginas...
  ];
}
```

### 7. Desenvolver Controllers e Pages
Siga a documentação acima:
- AuthController → login/signup
- ProductListController → lista de produtos
- VendorScanController → scanner
- etc.

### 8. Testar com usuários mockados
Antes de integrar backend real, carregue os JSONs de Mock Users em GetStorage ou serviço simulado.

### 9. Rodar o app
```bash
flutter run
```

### 10. Validações Finais
Verifique navegação, binding de controllers, performance de listas, caching e scanner.

---

## 10. Modelos de Dados Adicionais

### ProductModel
```dart
class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final String barcode;
  final int stock;
  final bool isAvailable;
  final double rating;
  final int reviewCount;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.barcode,
    required this.stock,
    this.isAvailable = true,
    this.rating = 0.0,
    this.reviewCount = 0,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    price: json['price'].toDouble(),
    imageUrl: json['imageUrl'],
    category: json['category'],
    barcode: json['barcode'],
    stock: json['stock'],
    isAvailable: json['isAvailable'] ?? true,
    rating: json['rating']?.toDouble() ?? 0.0,
    reviewCount: json['reviewCount'] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'price': price,
    'imageUrl': imageUrl,
    'category': category,
    'barcode': barcode,
    'stock': stock,
    'isAvailable': isAvailable,
    'rating': rating,
    'reviewCount': reviewCount,
  };
}
```

### OrderModel
```dart
class OrderModel {
  final String id;
  final String userId;
  final List<OrderItemModel> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String status;
  final DateTime createdAt;
  final DateTime? deliveredAt;
  final AddressModel deliveryAddress;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.status,
    required this.createdAt,
    this.deliveredAt,
    required this.deliveryAddress,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
    id: json['id'],
    userId: json['userId'],
    items: (json['items'] as List).map((item) => OrderItemModel.fromJson(item)).toList(),
    subtotal: json['subtotal'].toDouble(),
    deliveryFee: json['deliveryFee'].toDouble(),
    total: json['total'].toDouble(),
    status: json['status'],
    createdAt: DateTime.parse(json['createdAt']),
    deliveredAt: json['deliveredAt'] != null ? DateTime.parse(json['deliveredAt']) : null,
    deliveryAddress: AddressModel.fromJson(json['deliveryAddress']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'items': items.map((item) => item.toJson()).toList(),
    'subtotal': subtotal,
    'deliveryFee': deliveryFee,
    'total': total,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    'deliveredAt': deliveredAt?.toIso8601String(),
    'deliveryAddress': deliveryAddress.toJson(),
  };
}

class OrderItemModel {
  final String productId;
  final String productName;
  final double price;
  final int quantity;

  OrderItemModel({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => OrderItemModel(
    productId: json['productId'],
    productName: json['productName'],
    price: json['price'].toDouble(),
    quantity: json['quantity'],
  );

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'productName': productName,
    'price': price,
    'quantity': quantity,
  };
}
```

---

## 11. Regras de Negócio

### Cliente
- Visualização de produtos com filtros por categoria
- Adição ao carrinho com controle de quantidade
- Cálculo automático de frete baseado na distância
- Histórico de pedidos com possibilidade de repetir
- Sistema de avaliações e comentários

### Vendedor
- Gestão completa de estoque
- Scanner de código de barras para produtos
- Relatórios de vendas e métricas
- Controle de status de pedidos
- Configuração de horários de funcionamento
- Definição de zonas de entrega

### Sistema
- Autenticação segura com persistência local
- Cache de produtos para performance
- Notificações push para status de pedidos
- Backup automático de dados críticos

## 12. Arquitetura e Padrões

### Repository Pattern
**IMPORTANTE**: Toda conexão com banco de dados e acesso a APIs deve ser feita através de repositories.

#### Estrutura do Repository:
```dart
abstract class BaseRepository<T> {
  Future<List<T>> getAll();
  Future<T?> getById(String id);
  Future<T> create(T item);
  Future<T> update(T item);
  Future<bool> delete(String id);
}

class ConcreteRepository implements BaseRepository<Model> {
  // Implementação específica
}
```

#### Benefícios:
- **Separação de Responsabilidades**: Controllers não acessam dados diretamente
- **Testabilidade**: Fácil mock de repositories para testes
- **Flexibilidade**: Troca de fonte de dados sem afetar controllers
- **Reutilização**: Lógica de acesso a dados centralizada
- **Manutenibilidade**: Mudanças na API/banco isoladas

#### Fluxo de Dados:
```
Controller → Repository → API/Database
```

#### Implementação:
- Controllers usam repositories via injeção de dependência
- Repositories encapsulam toda lógica de acesso a dados
- Mock repositories para desenvolvimento/testes
- Repositories reais para produção

---

## 12. Considerações de Performance

- **Listas Virtualizadas**: Uso de ListView.builder para grandes listas
- **Cache de Imagens**: Implementar cache para imagens de produtos
- **Lazy Loading**: Carregamento sob demanda de dados
- **Isolates**: Processamento pesado em background
- **Compressão**: Otimização de imagens e dados

---

## 13. Segurança

- **Validação de Input**: Todos os campos de entrada validados
- **Criptografia**: Senhas hasheadas
- **Sanitização**: Dados limpos antes do processamento
- **Rate Limiting**: Proteção contra spam
- **Logs de Auditoria**: Registro de ações críticas
- **Isolamento de Dados**: 
  - Cada usuário acessa apenas seus próprios dados
  - Repositories filtram dados por usuário autenticado
  - Carrinho, favoritos e histórico isolados por usuário
  - Vendedores não veem dados de clientes e vice-versa
  - Chaves de storage únicas por usuário (ex: `cart_user_001`)

---

## 14. Testes

### Unitários
- Controllers
- Models
- Services

### Widget Tests
- Páginas principais
- Componentes reutilizáveis

### Integration Tests
- Fluxos completos de cliente e vendedor
- Navegação entre telas

---

## 15. Deploy e Distribuição

### Android
- Configurar signing keys
- Otimizar APK/AAB
- Configurar Firebase

### iOS
- Configurar certificados
- Otimizar para App Store
- Configurar Push Notifications

---

## 16. Persistência de Login (Cache e Auto-Login)

### Visão Geral
O aplicativo implementa persistência de login utilizando o GetStorage, garantindo que, após o usuário logar corretamente, seus dados de sessão sejam salvos localmente. Assim, ao reabrir o app, o usuário é autenticado automaticamente e redirecionado para a tela correta (cliente ou vendedor), sem necessidade de novo login manual.

### Como Funciona
- **Salvamento:** Após login ou cadastro bem-sucedido, o usuário é salvo no GetStorage usando a chave `user`.
- **Auto-Login:** Ao iniciar o app, o AuthController carrega o usuário salvo do GetStorage. Se existir, o usuário é considerado autenticado e redirecionado automaticamente para a tela inicial do seu perfil (cliente ou vendedor).
- **Logout:** Remove o usuário do GetStorage e retorna para a tela de login.

### Fluxo de Auto-Login
1. O método `onInit` do `AuthController` executa `_loadUserFromStorage()` ao iniciar.
2. Se encontrar um usuário salvo, define o estado como logado (`isLoggedIn = true`).
3. O widget inicial (`_InitialRouteDecider` em `main.dart`) observa o estado de login:
   - Se logado e for vendedor, redireciona para `/vendor/dashboard`.
   - Se logado e for cliente, redireciona para `/cliente/produtos`.
   - Se não logado, redireciona para `/login`.

### Exemplo de Código
```dart
// Salvando usuário após login
await _authRepository.saveUser(user);

// Carregando usuário salvo
final user = await _authRepository.getCurrentUser();

// Removendo usuário no logout
await _authRepository.logout();
```

### Observações
- O cache utiliza a chave `AppConstants.userKey` (valor: 'user').
- O auto-login é transparente para o usuário e melhora a experiência de uso.
- Para limpar o cache, basta chamar o método de logout.

---

Esta documentação serve como guia completo para implementação do aplicativo de supermercado virtual. Siga cada seção cuidadosamente para garantir uma implementação robusta e escalável. 