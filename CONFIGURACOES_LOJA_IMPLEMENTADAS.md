# Sistema de Configurações da Loja - Implementação Completa

## 📋 Visão Geral

O sistema de configurações da loja foi completamente implementado, permitindo que vendedores gerenciem todas as informações de sua loja através de uma interface intuitiva no aplicativo Flutter, com persistência completa no backend.

## 🗄️ Estrutura do Banco de Dados

### Tabela: `store_settings`

```sql
CREATE TABLE store_settings (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  seller_id UUID NOT NULL REFERENCES sellers(id) ON DELETE CASCADE,
  
  -- Informações da loja
  nome_loja VARCHAR(255) NOT NULL,
  cnpj_cpf VARCHAR(18) NOT NULL,
  descricao TEXT,
  endereco JSONB DEFAULT '{}',
  telefone VARCHAR(20),
  logo_url TEXT,
  latitude DECIMAL(10, 8) DEFAULT 0,
  longitude DECIMAL(11, 8) DEFAULT 0,
  
  -- Preferências de operação
  horario_inicio TIME DEFAULT '08:00:00',
  horario_fim TIME DEFAULT '18:00:00',
  aceita_fora_horario BOOLEAN DEFAULT false,
  tempo_preparo INTEGER DEFAULT 30,
  mensagem_boas_vindas TEXT,
  horarios_funcionamento JSONB DEFAULT '[]',
  
  -- Política de entrega
  taxa_entrega DECIMAL(10, 2) DEFAULT 0.00,
  raio_entrega DECIMAL(5, 2) DEFAULT 5.0,
  limite_entrega_gratis DECIMAL(10, 2) DEFAULT 100.00,
  
  -- Estado da loja
  loja_offline BOOLEAN DEFAULT false,
  
  -- Timestamps
  data_criacao TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  data_atualizacao TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  UNIQUE(seller_id)
);
```

## 🔧 Backend

### Modelo: `StoreSettings.js`

- **Localização**: `backend/models/StoreSettings.js`
- **Funcionalidades**:
  - Buscar configurações por ID do vendedor
  - Criar/atualizar configurações (upsert)
  - Atualizar campos específicos
  - Buscar lojas ativas
  - Buscar lojas por proximidade geográfica
  - Formatação de dados para frontend

### Rotas: `store_settings.js`

- **Localização**: `backend/routes/store_settings.js`
- **Endpoints**:
  - `GET /api/store-settings` - Buscar configurações do vendedor autenticado
  - `POST /api/store-settings` - Criar/atualizar configurações
  - `PUT /api/store-settings` - Atualizar campos específicos
  - `GET /api/store-settings/public` - Buscar lojas ativas (público)
  - `GET /api/store-settings/:sellerId` - Buscar loja específica (público)

### Integração no Servidor

As rotas foram adicionadas ao `server.js`:
```javascript
app.use('/api/store-settings', storeSettingsRoutes);
```

## 📱 Frontend (Flutter)

### Repositório: `StoreSettingsRepository`

- **Localização**: `lib/repositories/store_settings_repository.dart`
- **Funcionalidades**:
  - Comunicação com API REST
  - Gerenciamento de tokens de autenticação
  - Tratamento de erros
  - Busca de configurações públicas e privadas

### Controller: `VendedorSettingsController`

- **Localização**: `lib/modules/vendedor/controllers/vendor_settings_controller.dart`
- **Funcionalidades**:
  - Carregamento automático de dados ao abrir a página
  - Salvamento completo das configurações
  - Sincronização com servidor
  - Gerenciamento de horários de funcionamento
  - Validação de dados

### Modelo: `HorarioFuncionamento`

- **Localização**: `lib/modules/vendedor/models/horario_funcionamento.dart`
- **Funcionalidades**:
  - Serialização/deserialização JSON
  - Cópia com modificações (copyWith)
  - Validação de horários

### Interface do Usuário

#### Página Principal: `VendorSettingsPage`
- **Localização**: `lib/modules/vendedor/pages/vendor_settings_page.dart`
- **Seções**:
  1. **Perfil da Loja** - Informações básicas
  2. **Preferências de Operação** - Horários e configurações
  3. **Política de Entrega** - Taxas e raio de entrega
  4. **Resumo de Vendas** - Métricas da loja
  5. **Segurança** - Logout e alteração de senha
  6. **Sincronização** - Backup e sincronização

#### Widgets Especializados:
- `PerfilLojaSection` - Campos de informações da loja
- `PreferenciasOperacaoSection` - Horários de funcionamento
- `PoliticaEntregaSection` - Configurações de entrega
- `SincronizacaoLojaSection` - Controles de sincronização

## 🚀 Como Usar

### 1. Configuração do Banco de Dados

Execute o script SQL no Supabase:
```bash
# No SQL Editor do Supabase, execute:
# backend/database/create_store_settings_table.sql
```

Ou use o script automatizado:
```bash
cd backend
node scripts/create_store_settings_table.js
```

### 2. Iniciar o Backend

```bash
cd backend
npm install
npm start
```

### 3. Executar o App Flutter

```bash
flutter pub get
flutter run
```

### 4. Acessar Configurações

1. Faça login como vendedor
2. No dashboard, clique no ícone de configurações
3. Todas as informações serão carregadas automaticamente
4. Edite os campos desejados
5. Clique em "Salvar" (FAB) para persistir as mudanças

## 📊 Funcionalidades Implementadas

### ✅ Informações da Loja
- Nome da loja
- CNPJ/CPF
- Descrição
- Endereço completo
- Telefone
- Logo (URL)
- Localização (latitude/longitude)

### ✅ Preferências de Operação
- Horário de funcionamento por dia da semana
- Aceitar pedidos fora do horário
- Tempo médio de preparo
- Mensagem de boas-vindas
- Interface para configurar horários por dia

### ✅ Política de Entrega
- Taxa de entrega
- Raio de entrega
- Limite para entrega grátis

### ✅ Estado da Loja
- Modo offline/online
- Sincronização com servidor

### ✅ Funcionalidades Avançadas
- Carregamento automático ao abrir a página
- Salvamento completo no backend
- Validação de dados
- Tratamento de erros
- Feedback visual para o usuário
- Sincronização manual

## 🔒 Segurança

- Autenticação obrigatória para vendedores
- Row Level Security (RLS) no Supabase
- Validação de dados no backend
- Tokens JWT para autenticação
- Políticas de acesso por usuário

## 📈 Próximos Passos

1. **Upload de Logo**: Implementar upload de imagem para logo da loja
2. **Geolocalização**: Integrar GPS para captura automática de coordenadas
3. **Notificações**: Alertas quando loja ficar offline
4. **Backup Automático**: Sincronização automática periódica
5. **Relatórios**: Exportação de dados em PDF/CSV
6. **Histórico**: Log de mudanças nas configurações

## 🐛 Solução de Problemas

### Erro ao Carregar Configurações
- Verificar se o vendedor está logado
- Verificar conexão com o backend
- Verificar se a tabela foi criada corretamente

### Erro ao Salvar
- Verificar se todos os campos obrigatórios estão preenchidos
- Verificar conexão com o backend
- Verificar permissões do usuário

### Tabela Não Encontrada
- Executar o script de criação da tabela
- Verificar se o Supabase está configurado corretamente

## 📞 Suporte

Para dúvidas ou problemas:
1. Verificar logs do backend em `backend/server.log`
2. Verificar logs do Flutter no console
3. Verificar se todas as dependências estão instaladas
4. Verificar configuração do Supabase
