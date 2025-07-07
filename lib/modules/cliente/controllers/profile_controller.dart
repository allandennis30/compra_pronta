import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../core/models/user_model.dart';

class ProfileController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final Rx<UserModel?> user = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    user.value = _authController.currentUser;
  }

  void logout() async {
    await _authController.logout();
  }
}
