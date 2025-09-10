import 'package:get/get.dart';

class EntregadorMainController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void setCurrentIndex(int index) {
    currentIndex.value = index;
  }

  void goToDeliveries() {
    setCurrentIndex(0); // Índice 0 = Lista de Entregas
  }

  void goToMap() {
    setCurrentIndex(1); // Índice 1 = Mapa de Entregas
  }

  void goToHistory() {
    setCurrentIndex(2); // Índice 2 = Histórico de Entregas
  }

  void goToProfile() {
    setCurrentIndex(3); // Índice 3 = Perfil do Entregador
  }
}