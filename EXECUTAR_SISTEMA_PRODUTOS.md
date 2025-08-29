# 🚀 Executar Sistema de Produtos Completo

## 📋 Passo a Passo

### 1. Acessar o Supabase
1. Abra o navegador e acesse: https://supabase.com/dashboard
2. Faça login na sua conta
3. Selecione o projeto: `feljoannoghnpbqhrsuv`

### 2. Executar Script Principal
1. No menu lateral esquerdo, clique em **SQL Editor**
2. Clique em **New query** para criar uma nova consulta
3. Copie todo o conteúdo do arquivo: `backend/database/create_products_system.sql`
4. Cole no SQL Editor do Supabase
5. Clique em **Run** para executar o script

### 3. Executar Script de Produtos de Teste (Opcional)
1. Crie uma nova query no SQL Editor
2. Copie todo o conteúdo do arquivo: `backend/database/add_test_products.sql`
3. Cole no SQL Editor do Supabase
4. Clique em **Run** para executar o script

### 4. Verificar Resultado
Após executar os scripts, você deve ver:
- ✅ Tabela `products` criada
- ✅ Coluna `products_ids` adicionada na tabela `users`
- ✅ Índices criados
- ✅ Políticas RLS configuradas
- ✅ Triggers criados
- ✅ Funções criadas
- ✅ Produtos de teste inseridos (se executou o segundo script)

## 🔍 Verificar se Funcionou

### Verificar Tabela de Produtos
```sql
SELECT 
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'products' 
ORDER BY ordinal_position;
```

### Verificar Coluna na Tabela Users
```sql
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'users' 
AND column_name = 'products_ids';
```

### Verificar Políticas RLS
```sql
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'products';
```

### Verificar Produtos de Teste
```sql
SELECT 
    p.id,
    p.name,
    p.category,
    p.price,
    p.stock,
    p.is_available,
    u.nome as seller_name
FROM products p
JOIN users u ON p.seller_id = u.id
ORDER BY p.created_at DESC;
```

### Verificar IDs no Usuário
```sql
SELECT 
    u.id,
    u.nome,
    u.products_ids,
    array_length(u.products_ids, 1) as total_products
FROM users u
WHERE is_seller = true;
```

## 🔧 Como Funciona

### Sistema Duplo:
1. **Tabela `products`**: Armazena todos os dados dos produtos
2. **Coluna `products_ids` na tabela `users`**: Rastreia quais produtos cada vendedor criou

### Triggers Automáticos:
- ✅ Quando um produto é criado → ID é adicionado ao usuário automaticamente
- ✅ Quando um produto é deletado → ID é removido do usuário automaticamente

### Segurança:
- ✅ Vendedores só veem seus próprios produtos
- ✅ Clientes veem apenas produtos disponíveis
- ✅ Código de barras único por vendedor

## 🐛 Solução de Problemas

### Erro: "relation already exists"
- A tabela já existe, isso é normal
- O script usa `CREATE TABLE IF NOT EXISTS`

### Erro: "column already exists"
- A coluna já existe, isso é normal
- O script usa `ADD COLUMN IF NOT EXISTS`

### Erro: "function already exists"
- A função já existe, isso é normal
- O script usa `CREATE OR REPLACE FUNCTION`

### Erro: "trigger already exists"
- O trigger já existe, isso é normal
- O script usa `CREATE TRIGGER` sem `IF NOT EXISTS`

## ✅ Checklist

- [ ] Acessei o Supabase Dashboard
- [ ] Selecionei o projeto correto
- [ ] Executei o script `create_products_system.sql`
- [ ] Verifiquei se a tabela `products` foi criada
- [ ] Verifiquei se a coluna `products_ids` foi adicionada
- [ ] Verifiquei se as políticas RLS foram criadas
- [ ] Executei o script `add_test_products.sql` (opcional)
- [ ] Verifiquei se os produtos de teste foram inseridos
- [ ] Reiniciei o backend
- [ ] Testei o cadastro de produtos no app

## 🎯 Próximos Passos

Após executar os scripts:
1. Reinicie o backend: `cd backend && npm start`
2. Teste o cadastro de produtos no app
3. Verifique se os produtos aparecem na lista
4. Teste a edição de produtos
5. Teste a exclusão de produtos

## 📞 Suporte

Se encontrar problemas:
1. Verifique se está no projeto correto
2. Verifique se tem permissões de administrador
3. Tente executar os scripts novamente
4. Verifique os logs do backend
5. Entre em contato com o suporte

**O sistema de produtos estará 100% funcional! 🎉**
