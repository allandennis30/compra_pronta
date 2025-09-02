import 'package:flutter/material.dart';
import '../widgets/client_bottom_nav.dart';
import 'product_list_page.dart';
import 'cart_page.dart';
import 'order_history_page.dart';
import 'profile_page.dart';

class ClienteMainPage extends StatefulWidget {
  const ClienteMainPage({super.key});

  @override
  State<ClienteMainPage> createState() => _ClienteMainPageState();
}

class _ClienteMainPageState extends State<ClienteMainPage> {
  int _currentIndex = 0;

  // Lista de páginas que serão exibidas
  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    // Inicializa as páginas com seus controllers
    _pages.addAll([
      ProductListPage(),
      CartPage(),
      OrderHistoryPage(),
      ProfilePage(),
    ]);
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: ClientBottomNav(
        currentIndex: _currentIndex,
        onTabTapped: _onTabTapped,
      ),
    );
  }
}
