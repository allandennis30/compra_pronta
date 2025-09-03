# Relatórios de Vendas em PDF

## Funcionalidade Implementada

A funcionalidade de relatórios de vendas em PDF foi implementada na página inicial do vendedor, permitindo:

### Características Principais

1. **Geração de Relatórios por Período**
   - Seleção de períodos pré-definidos (última semana, último mês, últimos 3 meses, etc.)
   - Seleção de período personalizado com data inicial e final
   - Filtragem automática dos pedidos pelo período selecionado

2. **Conteúdo do Relatório**
   - Cabeçalho com nome da loja e período
   - Resumo geral (total de pedidos e receita)
   - Relatórios organizados por mês
   - Detalhamento de cada pedido com:
     - Número sequencial
     - Data do pedido
     - Nome do cliente
     - Lista de itens (quantidade x produto)
     - Valor total do pedido
   - Totalizadores por mês

3. **Funcionalidades de Compartilhamento**
   - **Visualizar**: Abre o PDF dentro do app para visualização
   - **Compartilhar**: Permite compartilhar o PDF com outros apps do dispositivo
   - **Imprimir**: Funcionalidade de impressão integrada

### Localização na Interface

A funcionalidade está localizada na **página inicial do vendedor** (`VendorDashboardPage`), abaixo da seção "Pedidos Recentes", em uma nova seção chamada "Relatórios de Vendas".

### Arquivos Criados/Modificados

#### Novos Arquivos:
- `lib/core/services/pdf_report_service.dart` - Serviço para geração de PDFs
- `lib/modules/vendedor/controllers/sales_report_controller.dart` - Controller para gerenciar relatórios
- `lib/modules/vendedor/widgets/dashboard/sales_report_section.dart` - Widget da interface
- `lib/modules/vendedor/pages/pdf_viewer_page.dart` - Página para visualização de PDFs

#### Arquivos Modificados:
- `pubspec.yaml` - Adicionadas dependências para PDF e compartilhamento
- `lib/modules/vendedor/pages/vendor_dashboard_page.dart` - Integração da nova seção
- `lib/modules/vendedor/repositories/vendor_metrics_repository.dart` - Método para buscar todos os pedidos

### Dependências Adicionadas

```yaml
# Dependências para geração de PDF e relatórios
pdf: ^3.10.7
printing: ^5.12.0
share_plus: ^7.2.2
path_provider: ^2.1.2
intl: ^0.19.0
```

### Como Usar

1. **Acesse a página inicial do vendedor**
2. **Role para baixo** até encontrar a seção "Relatórios de Vendas"
3. **Selecione o período** desejado:
   - Use os botões de período pré-definido, ou
   - Clique nas datas para selecionar um período personalizado
4. **Visualize as estatísticas** do período selecionado
5. **Escolha uma ação**:
   - **Visualizar**: Para ver o relatório dentro do app
   - **Compartilhar**: Para enviar o PDF para outros apps

### Estrutura do PDF

O relatório gerado contém:

1. **Cabeçalho**
   - Título "Relatório de Vendas"
   - Nome da loja
   - Período selecionado
   - Data de geração

2. **Resumo Geral**
   - Total de pedidos no período
   - Receita total do período

3. **Relatórios por Mês**
   - Cada mês com pedidos é apresentado separadamente
   - Cabeçalho do mês com total de pedidos e receita
   - Tabela detalhada com todos os pedidos do mês

4. **Detalhamento dos Pedidos**
   - Número sequencial
   - Data (formato dd/MM)
   - Nome do cliente
   - Lista de itens (ex: "2x Maçã Fuji, 1x Leite Integral")
   - Valor total (formato R$ X,XX)

### Formatação e Estilo

- **Layout**: Formato A4 com margens adequadas
- **Cores**: Esquema de cores profissional (azul para totais, verde para receita)
- **Tipografia**: Hierarquia clara com diferentes tamanhos e pesos de fonte
- **Tabelas**: Bordas e espaçamento adequados para legibilidade
- **Responsividade**: Adapta-se ao conteúdo (mais ou menos pedidos)

### Tratamento de Erros

- Validação de período selecionado
- Verificação de pedidos disponíveis
- Mensagens de erro amigáveis
- Fallbacks para casos de erro na geração

### Performance

- Carregamento assíncrono dos dados
- Indicadores de progresso durante a geração
- Cache dos pedidos carregados
- Otimização para grandes volumes de dados

### Segurança

- Validação de dados antes da geração
- Tratamento seguro de arquivos temporários
- Limpeza automática de arquivos temporários após compartilhamento

## Próximos Passos Sugeridos

1. **Integração com configurações da loja** para personalizar o nome da loja no relatório
2. **Filtros adicionais** (por status do pedido, método de pagamento, etc.)
3. **Gráficos e visualizações** no PDF
4. **Agendamento de relatórios** automáticos
5. **Exportação em outros formatos** (Excel, CSV)
6. **Relatórios comparativos** entre períodos
