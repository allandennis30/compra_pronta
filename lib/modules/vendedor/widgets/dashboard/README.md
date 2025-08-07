# Dashboard Widgets

Esta pasta contém os widgets componentizados do dashboard do vendedor, seguindo as melhores práticas do Flutter e princípios de UX/UI modernos.

## Estrutura dos Widgets

### `DashboardAppBar`
- AppBar customizado com design moderno
- Gradiente no ícone do dashboard
- Botão de configurações estilizado
- Sombra sutil na parte inferior

### `DashboardBottomNav`
- Bottom navigation customizado
- Indicadores visuais para item ativo
- Animações suaves de transição
- Design clean e moderno

### `RecentOrdersSection`
- Seção completa dos pedidos recentes
- Container com sombra e bordas arredondadas
- Header com ícone e botão "Ver Todos"
- Estado vazio com ilustração

### `OrderCard`
- Card individual para cada pedido
- Avatar com gradiente baseado no status
- Informações organizadas hierarquicamente
- Chip de status com indicador visual
- Animação de tempo relativo

## Características de UX/UI

### Design System
- **Cores**: Paleta consistente com tons de azul e cinza
- **Tipografia**: Hierarquia clara com pesos variados
- **Espaçamento**: Grid de 4px para consistência
- **Bordas**: Radius de 8px, 12px e 16px para diferentes elementos

### Interações
- **Feedback tátil**: InkWell em todos os elementos clicáveis
- **Estados visuais**: Hover, pressed e focused
- **Animações**: Transições suaves entre estados
- **Acessibilidade**: Tooltips e labels semânticos

### Responsividade
- **Layout flexível**: Adapta-se a diferentes tamanhos de tela
- **Densidade de informação**: Otimizada para mobile
- **Touch targets**: Mínimo de 44px para elementos interativos

## Uso

```dart
import '../widgets/dashboard/index.dart';

// No build method
Scaffold(
  appBar: const DashboardAppBar(),
  body: RecentOrdersSection(controller: controller),
  bottomNavigationBar: const DashboardBottomNav(),
)
```

## Benefícios da Componentização

1. **Reutilização**: Widgets podem ser usados em outras telas
2. **Manutenibilidade**: Mudanças centralizadas
3. **Testabilidade**: Cada widget pode ser testado isoladamente
4. **Performance**: Rebuilds otimizados
5. **Consistência**: Design system aplicado uniformemente