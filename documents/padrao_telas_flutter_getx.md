# 🧱 Padrão Base para Telas no App (Flutter + GetX + MVVM)

Este documento define como cada tela do aplicativo de supermercado virtual **deve ser estruturada**, **sem uso de widgets como função** e com **componentização**, seguindo a arquitetura recomendada pelo Flutter (MVVM), e utilizando **GetX**.

---

## 📐 Arquitetura Base (MVVM com GetX)

Cada **tela** (página) deve seguir a separação de responsabilidades:

```text
/tela_exemplo/
├── pages/
│   └── tela_exemplo_page.dart         ← Interface da tela (UI)
├── controllers/
│   └── tela_exemplo_controller.dart   ← Lógica da ViewModel
├── bindings/
│   └── tela_exemplo_binding.dart      ← Injeção de dependência
└── widgets/
    ├── componente_a.dart              ← Componentes reutilizáveis
    └── componente_b.dart
🔧 Regras Gerais
✅ OBRIGATÓRIO
Use StatelessWidget ou GetView<Controller>

Toda a lógica deve estar no Controller

Use .obs, Rx<T>, Obx() para reatividade

Crie widgets reutilizáveis na pasta widgets/

Use Get.put() apenas no binding

Sempre crie um Binding por tela

Use LayoutBuilder ou MediaQuery para responsividade

❌ PROIBIDO
❌ Widget buildX() para retornar widgets (substituir por get)

❌ StatefulWidget sem necessidade

❌ setState() – usar apenas reatividade do GetX

❌ Lógica de exibição na view

🧱 Estrutura Base da Página
1. Page (View)
dart
Copiar
Editar
// tela_exemplo_page.dart
class TelaExemploPage extends GetView<TelaExemploController> {
  const TelaExemploPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Título da Tela'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refresh,
          ),
        ],
      ),
      body: _body,
      floatingActionButton: _floatingActionButton,
    );
  }

  Widget get _body => Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.hasError.value) {
          return ErrorWidget(
            message: controller.errorMessage.value,
            onRetry: controller.retry,
          );
        }

        return _content;
      });

  Widget get _content => ResponsiveLayout(
        mobile: _mobileLayout,
        tablet: _tabletLayout,
        desktop: _desktopLayout,
      );

  Widget get _mobileLayout => Column(
        children: [
          HeaderWidget(title: controller.title.value),
          Expanded(
            child: Obx(() => ListView.builder(
                  itemCount: controller.items.length,
                  itemBuilder: (context, index) {
                    return ItemWidget(
                      item: controller.items[index],
                      onTap: controller.onItemTap,
                    );
                  },
                )),
          ),
          FooterWidget(total: controller.total.value),
        ],
      );

  Widget get _tabletLayout => Row(
        children: [
          Expanded(flex: 2, child: _mobileLayout),
          Expanded(
            flex: 1,
            child: SidebarWidget(summary: controller.summary.value),
          ),
        ],
      );

  Widget get _desktopLayout => _tabletLayout;

  Widget? get _floatingActionButton => Obx(() =>
      controller.showFab.value
          ? FloatingActionButton(
              onPressed: controller.onFabPressed,
              child: const Icon(Icons.add),
            )
          : null);
}
2. Controller (ViewModel)
dart
Copiar
Editar
// tela_exemplo_controller.dart
class TelaExemploController extends GetxController {
  final RxList<ItemModel> items = <ItemModel>[].obs;
  final RxString title = ''.obs;
  final RxDouble total = 0.0.obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool showFab = true.obs;
  final Rx<SummaryModel> summary = SummaryModel.empty().obs;

  final TelaExemploRepository _repository;

  TelaExemploController({required TelaExemploRepository repository})
      : _repository = repository;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;
      hasError.value = false;

      final result = await _repository.fetchItems();
      items.assignAll(result);
      _calculateTotal();
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void onItemTap(ItemModel item) {
    Get.toNamed('/item-detail', arguments: item);
  }

  void onFabPressed() {
    Get.toNamed('/add-item');
  }

  void refresh() => loadData();

  void retry() => loadData();

  void _calculateTotal() {
    total.value = items.fold(0.0, (sum, item) => sum + item.price);
  }
}
3. Binding (Injeção de Dependência)
dart
Copiar
Editar
// tela_exemplo_binding.dart
class TelaExemploBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TelaExemploRepository>(
      () => TelaExemploRepositoryImpl(apiService: Get.find<ApiService>()),
    );
    Get.lazyPut<TelaExemploController>(
      () => TelaExemploController(repository: Get.find()),
    );
  }
}
4. Widget Reutilizável
dart
Copiar
Editar
// widgets/item_widget.dart
class ItemWidget extends StatelessWidget {
  final ItemModel item;
  final Function(ItemModel) onTap;

  const ItemWidget({
    Key? key,
    required this.item,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: CircleAvatar(backgroundImage: NetworkImage(item.imageUrl)),
        title: Text(item.name),
        subtitle: Text('R\$ ${item.price.toStringAsFixed(2)}'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => onTap(item),
      ),
    );
  }
}
✅ Checklist de Qualidade de Tela
Item	Obrigatório
Uso de GetView<Controller>	✅
Controller separado	✅
Lógica reativa com Obx()	✅
Sem Widget buildX()	✅
Componentes externos reutilizáveis	✅
Binding configurado	✅

📦 Estrutura Final
text
Copiar
Editar
/lib/modules/tela_exemplo/
├── bindings/
│   └── tela_exemplo_binding.dart
├── controllers/
│   └── tela_exemplo_controller.dart
├── pages/
│   └── tela_exemplo_page.dart
├── widgets/
│   └── item_widget.dart
│   └── header_widget.dart
│   └── footer_widget.dart
│   └── sidebar_widget.dart