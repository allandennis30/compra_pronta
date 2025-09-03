# Sistema de Cores Reativas ao Tema

Este sistema permite que todos os componentes reajam automaticamente ao tema do celular (claro/escuro) sem precisar gerenciar cores manualmente.

## Como Usar

### 1. Importar o sistema de cores

```dart
import 'package:flutter/material.dart';
import '../../../core/widgets/theme_aware_widget.dart';
```

### 2. Acessar cores reativas

```dart
@override
Widget build(BuildContext context) {
  final colors = context.colors; // Extensão para facilitar acesso
  
  return Container(
    color: colors.background(context), // Reage ao tema automaticamente
    child: Text(
      'Texto',
      style: TextStyle(
        color: colors.onBackground(context), // Texto que contrasta com o fundo
      ),
    ),
  );
}
```

### 3. Usar widgets temáticos prontos

```dart
// Container que reage ao tema
ThemedContainer(
  padding: EdgeInsets.all(16),
  child: ThemedText('Texto que reage ao tema'),
)

// Botão que reage ao tema
ThemedButton(
  'Clique aqui',
  onPressed: () {},
  type: ButtonType.elevated,
)

// Card que reage ao tema
ThemedCard(
  child: Column(
    children: [
      ThemedIcon(Icons.star, type: IconType.primary),
      ThemedText('Conteúdo do card'),
    ],
  ),
)
```

## Cores Disponíveis

### Cores Base (sempre as mesmas)
- `primary(context)` - Cor primária (verde)
- `secondary(context)` - Cor secundária
- `accent(context)` - Cor de destaque
- `error(context)` - Cor de erro
- `warning(context)` - Cor de aviso
- `success(context)` - Cor de sucesso

### Cores de Fundo (reagem ao tema)
- `background(context)` - Fundo principal
- `surface(context)` - Superfície de cards/containers
- `surfaceVariant(context)` - Variação de superfície

### Cores de Texto (reagem ao tema)
- `onBackground(context)` - Texto sobre fundo principal
- `onSurface(context)` - Texto sobre superfície
- `onSurfaceVariant(context)` - Texto sobre superfície variante

### Cores de Status (reagem ao tema)
- `statusPending(context)` - Status pendente
- `statusConfirmed(context)` - Status confirmado
- `statusPreparing(context)` - Status preparando
- `statusDelivering(context)` - Status entregando
- `statusDelivered(context)` - Status entregue
- `statusCancelled(context)` - Status cancelado

### Cores de Interface (reagem ao tema)
- `border(context)` - Bordas
- `borderFocused(context)` - Bordas focadas
- `borderError(context)` - Bordas de erro
- `iconPrimary(context)` - Ícones primários
- `iconSecondary(context)` - Ícones secundários
- `divider(context)` - Divisores
- `shadow(context)` - Sombras

## Exemplos Práticos

### Antes (cores hardcoded)
```dart
Container(
  color: Colors.white, // Não reage ao tema
  child: Text(
    'Texto',
    style: TextStyle(
      color: Colors.black, // Não reage ao tema
    ),
  ),
)
```

### Depois (cores reativas)
```dart
Container(
  color: context.colors.surface(context), // Reage ao tema
  child: Text(
    'Texto',
    style: TextStyle(
      color: context.colors.onSurface(context), // Reage ao tema
    ),
  ),
)
```

### Usando widgets temáticos
```dart
ThemedContainer(
  child: ThemedText('Texto que sempre contrasta corretamente'),
)
```

## Migração de Componentes

Para migrar um componente existente:

1. **Adicionar import:**
   ```dart
   import '../../../core/widgets/theme_aware_widget.dart';
   ```

2. **Substituir cores hardcoded:**
   ```dart
   // Antes
   color: Colors.white
   
   // Depois
   color: context.colors.surface(context)
   ```

3. **Usar cores de status quando apropriado:**
   ```dart
   // Antes
   color: Colors.green
   
   // Depois
   color: context.colors.statusDelivered(context)
   ```

4. **Considerar usar widgets temáticos:**
   ```dart
   // Antes
   Card(child: Text('Conteúdo'))
   
   // Depois
   ThemedCard(child: ThemedText('Conteúdo'))
   ```

## Benefícios

- ✅ **Reação automática** ao tema do sistema
- ✅ **Consistência visual** em toda a aplicação
- ✅ **Manutenção simplificada** - mudanças centralizadas
- ✅ **Acessibilidade** - contraste automático
- ✅ **UX melhorada** - experiência nativa do sistema

## Configuração

O sistema está configurado no `main.dart` com:
```dart
themeMode: ThemeMode.system, // Reage automaticamente ao tema do sistema
```

Isso significa que o app seguirá automaticamente o tema configurado no celular do usuário.
