# 🚀 Executar Script de Produtos no Supabase

## 📋 Passo a Passo

### 1. Acessar o Supabase
1. Abra o navegador e acesse: https://supabase.com/dashboard
2. Faça login na sua conta
3. Selecione o projeto: `feljoannoghnpbqhrsuv`

### 2. Abrir SQL Editor
1. No menu lateral esquerdo, clique em **SQL Editor**
2. Clique em **New query** para criar uma nova consulta

### 3. Executar o Script
1. Copie todo o conteúdo do arquivo: `backend/database/execute_products_table.sql`
2. Cole no SQL Editor do Supabase
3. Clique em **Run** para executar o script

### 4. Verificar Resultado
Após executar, você deve ver:
- ✅ Tabela `products` criada
- ✅ Índices criados
- ✅ Políticas RLS configuradas
- ✅ Trigger de `updated_at` criado

## 🔍 Verificar se Funcionou

### Verificar Tabela
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

## 🐛 Solução de Problemas

### Erro: "relation already exists"
- A tabela já existe, isso é normal
- O script usa `CREATE TABLE IF NOT EXISTS`

### Erro: "permission denied"
- Verifique se você tem permissões de administrador no projeto
- Entre em contato com o administrador do projeto

### Erro: "function already exists"
- A função já existe, isso é normal
- O script usa `CREATE OR REPLACE FUNCTION`

## ✅ Checklist

- [ ] Acessei o Supabase Dashboard
- [ ] Selecionei o projeto correto
- [ ] Abri o SQL Editor
- [ ] Executei o script completo
- [ ] Verifiquei se a tabela foi criada
- [ ] Verifiquei se as políticas RLS foram criadas
- [ ] Reiniciei o backend
- [ ] Testei o cadastro de produtos

## 📞 Suporte

Se encontrar problemas:
1. Verifique se está no projeto correto
2. Verifique se tem permissões de administrador
3. Tente executar o script novamente
4. Entre em contato com o suporte

## 🎯 Próximos Passos

Após executar o script:
1. Reinicie o backend: `cd backend && npm start`
2. Teste o cadastro de produtos no app
3. Verifique se os produtos aparecem na lista
4. Teste a edição de produtos

**O cadastro de produtos estará 100% funcional! 🎉**

