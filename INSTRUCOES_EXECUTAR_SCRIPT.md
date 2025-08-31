# 📋 Instruções para Executar o Script SQL

## 🚨 Erro Resolvido

O erro `relation "sellers" does not exist` foi corrigido. Agora o script funciona independentemente da existência de outras tabelas.

## 📝 Passos para Executar

### 1. Acesse o Supabase Dashboard
- Vá para https://supabase.com/dashboard
- Faça login na sua conta
- Selecione o projeto: `feljoannoghnpbqhrsuv`

### 2. Abra o SQL Editor
- No menu lateral, clique em "SQL Editor"
- Clique em "New query"

### 3. Execute o Script Principal
Copie e cole o conteúdo do arquivo `backend/database/create_store_settings_table_clean.sql`:

```sql
-- Criação da tabela de configurações da loja
-- Execute este script no SQL Editor do Supabase

-- Criar tabela store_settings (configurações da loja)
CREATE TABLE IF NOT EXISTS store_settings (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  seller_id UUID NOT NULL,
  
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
  
  -- Horário de funcionamento por dia da semana (JSON)
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
  
  -- Constraint única para garantir uma configuração por vendedor
  UNIQUE(seller_id)
);

-- Criar índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_store_settings_seller_id ON store_settings(seller_id);
CREATE INDEX IF NOT EXISTS idx_store_settings_ativo ON store_settings(loja_offline);

-- Criar trigger para atualizar data_atualizacao automaticamente
CREATE TRIGGER update_store_settings_updated_at
    BEFORE UPDATE ON store_settings
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Habilitar RLS (Row Level Security)
ALTER TABLE store_settings ENABLE ROW LEVEL SECURITY;

-- Políticas para permitir que vendedores vejam e editem apenas suas próprias configurações
CREATE POLICY "Sellers can view own store settings" ON store_settings
  FOR SELECT USING (auth.uid()::text = seller_id::text);

CREATE POLICY "Sellers can insert own store settings" ON store_settings
  FOR INSERT WITH CHECK (auth.uid()::text = seller_id::text);

CREATE POLICY "Sellers can update own store settings" ON store_settings
  FOR UPDATE USING (auth.uid()::text = seller_id::text);

CREATE POLICY "Sellers can delete own store settings" ON store_settings
  FOR DELETE USING (auth.uid()::text = seller_id::text);
```

### 4. Execute o Script
- Clique no botão "Run" ou pressione Ctrl+Enter (Cmd+Enter no Mac)
- Aguarde a execução completar

### 5. Verifique a Criação
- Vá para "Table Editor" no menu lateral
- Procure pela tabela `store_settings`
- Verifique se foi criada corretamente

## ✅ Resultado Esperado

Após executar o script, você deve ver:
- ✅ Tabela `store_settings` criada
- ✅ Índices criados
- ✅ Trigger criado
- ✅ Políticas RLS criadas

## 🚀 Próximos Passos

Após criar a tabela:
1. **Inicie o backend**: `cd backend && npm start`
2. **Execute o app Flutter**: `flutter run`
3. **Teste as configurações da loja**

## 🐛 Solução de Problemas

### Erro de Função
Se houver erro com a função `update_updated_at_column`, execute primeiro:

```sql
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.data_atualizacao = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';
```

### Erro de Permissão
Se houver erro de permissão, verifique se você está logado como owner do projeto no Supabase.

## 📞 Suporte

Se ainda houver problemas:
1. Verifique se você está no projeto correto no Supabase
2. Verifique se tem permissões de owner
3. Tente executar as queries uma por vez
