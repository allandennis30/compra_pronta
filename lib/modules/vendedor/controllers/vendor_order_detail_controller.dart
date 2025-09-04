import 'vendedor_order_detail_controller.dart';

/// Compatibilidade: alguns pontos do app ainda referenciam
/// VendorOrderDetailController. Mantemos um alias/subclasse
/// para evitar falhas em tempo de execução.
class VendorOrderDetailController extends VendedorOrderDetailController {}
