import 'package:get/get.dart';

class ClienteMainController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void setCurrentIndex(int index) {
    currentIndex.value = index;
  }

  void goToCart() {
    setCurrentIndex(1); // Índice 1 = Carrinho
  }

  void goToProducts() {
    setCurrentIndex(0); // Índice 0 = Produtos
  }

  void goToOrders() {
    setCurrentIndex(2); // Índice 2 = Pedidos
  }

  void goToProfile() {
    setCurrentIndex(3); // Índice 3 = Perfil
  }
}
