# Como Executar o Script SQL no Supabase

## 📋 Pré-requisitos

- Conta no Supabase criada
- Projeto `feljoannoghnpbqhrsuv` configurado
- Arquivo `backend/database/create_tables.sql` disponível

## 🚀 Passo a Passo

### 1. Acessar o Painel do Supabase

1. Abra seu navegador
2. Acesse: **https://supabase.com/dashboard**
3. Faça login com sua conta

### 2. Selecionar o Projeto

1. Na lista de projetos, clique no projeto: **`feljoannoghnpbqhrsuv`**
2. Aguarde o carregamento do painel do projeto

### 3. Acessar o SQL Editor

1. No menu lateral esquerdo, procure por **"SQL Editor"**
2. Clique em **"SQL Editor"**
3. Você verá uma interface de editor de código SQL

### 4. Copiar o Script SQL

1. Abra o arquivo `backend/database/create_tables.sql` no seu editor de código
2. **Selecione todo o conteúdo** do arquivo (Ctrl+A)
3. **Copie** o conteúdo (Ctrl+C)

**Conteúdo do script:**
```sql
-- Criação da tabela de usuários no Supabase
-- Execute este script no SQL Editor do Supabase

-- Criar tabela users
CREATE TABLE IF NOT EXISTS users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nome VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  senha VARCHAR(255) NOT NULL,
  tipo VARCHAR(50) NOT NULL DEFAULT 'cliente' CHECK (tipo IN ('cliente', 'vendedor')),
  telefone VARCHAR(20),
  cpf VARCHAR(14),
  cnpj VARCHAR(18),
  nome_empresa VARCHAR(255),
  endereco JSONB DEFAULT '{}',
  latitude DECIMAL(10, 8) DEFAULT 0,
  longitude DECIMAL(11, 8) DEFAULT 0,
  ativo BOOLEAN DEFAULT true,
  data_criacao TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  data_atualizacao TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Criar índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_tipo ON users(tipo);
CREATE INDEX IF NOT EXISTS idx_users_ativo ON users(ativo);

-- Criar função para atualizar data_atualizacao automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.data_atualizacao = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Criar trigger para atualizar data_atualizacao
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Inserir usuários de teste
INSERT INTO users (nome, email, senha, tipo, telefone, cnpj, nome_empresa, endereco) VALUES
('João Silva', 'joao@vendedor.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/RK.s5uDfm', 'vendedor', '(11) 99999-9999', '12.345.678/0001-90', 'Supermercado Silva', '{"rua": "Rua das Flores, 123", "bairro": "Centro", "cidade": "São Paulo", "cep": "01000-000", "estado": "SP"}'),
('Maria Santos', 'maria@cliente.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/RK.s5uDfm', 'cliente', '(11) 88888-8888', NULL, NULL, '{"rua": "Av. Paulista, 1000", "bairro": "Bela Vista", "cidade": "São Paulo", "cep": "01310-100", "estado": "SP"}'),
('Carlos Oliveira', 'carlos@vendedor.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/RK.s5uDfm', 'vendedor', '(11) 77777-7777', '98.765.432/0001-10', 'Mercado Oliveira', '{"rua": "Rua Augusta, 456", "bairro": "Consolação", "cidade": "São Paulo", "cep": "01305-000", "estado": "SP"}'),
('Ana Costa', 'ana@cliente.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/RK.s5uDfm', 'cliente', '(11) 66666-6666', NULL, NULL, '{"rua": "Rua Oscar Freire, 789", "bairro": "Jardins", "cidade": "São Paulo", "cep": "01426-001", "estado": "SP"}');

-- Habilitar RLS (Row Level Security) - opcional
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
```

### 5. Colar e Executar o Script

1. No SQL Editor do Supabase, **cole** o script (Ctrl+V)
2. Clique no botão **"Run"** (geralmente um botão verde ou azul)
3. Aguarde a execução do script

### 6. Verificar Resultado

**Se tudo deu certo, você verá:**
- ✅ Mensagem de sucesso
- ✅ Tabela `users` criada
- ✅ Índices criados
- ✅ Função e trigger criados
- ✅ Usuários de teste inseridos

**Se houver erro:**
- ❌ Mensagem de erro em vermelho
- Verifique se copiou o script completo
- Tente executar novamente

### 7. Verificar a Tabela Criada

1. No menu lateral, clique em **"Table Editor"**
2. Você deve ver a tabela **`users`** na lista
3. Clique na tabela `users` para ver os dados
4. Deve haver **4 usuários de teste** inseridos

## 🔍 Verificação Final

### Verificar Estrutura da Tabela
1. Na tabela `users`, clique na aba **"Structure"** ou **"Schema"**
2. Confirme se todos os campos estão presentes:
   - `id` (UUID)
   - `nome` (VARCHAR)
   - `email` (VARCHAR)
   - `senha` (VARCHAR)
   - `tipo` (VARCHAR)
   - `telefone` (VARCHAR)
   - `cpf` (VARCHAR)
   - `cnpj` (VARCHAR)
   - `nome_empresa` (VARCHAR)
   - `endereco` (JSONB)
   - `latitude` (DECIMAL)
   - `longitude` (DECIMAL)
   - `ativo` (BOOLEAN)
   - `data_criacao` (TIMESTAMP)
   - `data_atualizacao` (TIMESTAMP)

### Verificar Usuários de Teste
1. Na aba **"Data"** da tabela `users`
2. Confirme se existem 4 usuários:
   - João Silva (vendedor)
   - Maria Santos (cliente)
   - Carlos Oliveira (vendedor)
   - Ana Costa (cliente)

## 🎯 Próximos Passos

Após executar o script com sucesso:

1. ✅ **Testar o cadastro** no app Flutter
2. ✅ **Verificar se o backend** está funcionando
3. ✅ **Fazer login** com os usuários de teste

### Credenciais de Teste

**Todos os usuários têm a senha:** `senha123`

**Vendedores:**
- `joao@vendedor.com`
- `carlos@vendedor.com`

**Clientes:**
- `maria@cliente.com`
- `ana@cliente.com`

## 🚨 Troubleshooting

### Erro: "permission denied"
**Solução**: Verifique se você tem permissões de administrador no projeto

### Erro: "relation already exists"
**Solução**: A tabela já foi criada. Isso é normal se executar o script novamente

### Erro: "syntax error"
**Solução**: Verifique se copiou o script completo e corretamente

### Não consigo ver a tabela
**Solução**: 
1. Atualize a página (F5)
2. Verifique se está no projeto correto
3. Clique em "Table Editor" novamente

---

**✅ Pronto!** Após executar este script, o cadastro de cliente estará 100% funcional no seu app Compra Pronta.