# 🚀 Configuração do Servidor Local - Compra Pronta

## ✅ **Status Atual**

O servidor backend está configurado e rodando localmente na porta **3000**.

### **🔧 Configurações Realizadas:**

1. ✅ **Servidor rodando**: `http://localhost:3000`
2. ✅ **App Flutter configurado** para usar servidor local
3. ✅ **Banco de dados Supabase** conectado
4. ✅ **Endpoints funcionando** (login, produtos, etc.)

## 🖥️ **Servidor Local**

### **Status:**
- **URL**: `http://localhost:3000`
- **Health Check**: `http://localhost:3000/health`
- **Status**: ✅ **RODANDO**

### **Endpoints Disponíveis:**

#### **🔐 Autenticação:**
- `POST /api/auth/login` - Login de usuários
- `POST /api/auth/register/client` - Cadastro de cliente
- `POST /api/auth/register/seller` - Cadastro de vendedor
- `GET /api/auth/profile` - Perfil do usuário
- `POST /api/auth/verify` - Verificar token

#### **📦 Produtos:**
- `GET /api/products` - Listar produtos
- `POST /api/products` - Criar produto
- `PUT /api/products/:id` - Atualizar produto
- `DELETE /api/products/:id` - Deletar produto
- `POST /api/products/upload-image` - Upload de imagem

#### **🏥 Health Check:**
- `GET /health` - Status do servidor

## 📱 **App Flutter**

### **Configuração Atual:**
- **Ambiente**: Desenvolvimento Local
- **URL Base**: `http://10.0.2.2:3000` (emulador Android)
- **Status**: ✅ **CONFIGURADO**

### **Como Funciona:**

#### **Emulador Android:**
- **IP**: `10.0.2.2` (mapeia para localhost da máquina host)
- **Porta**: `3000`
- **URL**: `http://10.0.2.2:3000`

#### **iOS Simulator:**
- **IP**: `localhost` ou `127.0.0.1`
- **Porta**: `3000`
- **URL**: `http://localhost:3000`

#### **Dispositivo Real:**
- **IP**: IP da sua máquina na rede local
- **Porta**: `3000`
- **URL**: `http://192.168.1.100:3000` (exemplo)

## 🚀 **Como Usar**

### **1. Iniciar o Servidor:**
```bash
cd backend
npm run dev
```

### **2. Verificar se está funcionando:**
```bash
curl http://localhost:3000/health
```

### **3. Testar login:**
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "teste@teste.com", "senha": "teste123"}'
```

### **4. Rodar o app Flutter:**
```bash
flutter run
```

## 🧪 **Credenciais de Teste**

### **Vendedor:**
- **Email**: `teste@teste.com`
- **Senha**: `teste123`

### **Cliente:**
- **Email**: `cliente@teste.com`
- **Senha**: `teste123`

## 🔧 **Troubleshooting**

### **Problema: App não conecta ao servidor**
1. Verifique se o servidor está rodando: `curl http://localhost:3000/health`
2. Verifique se a porta 3000 não está sendo usada por outro processo
3. Para dispositivo real, use o IP da sua máquina na rede local

### **Problema: Erro de CORS**
- O servidor está configurado para aceitar todas as origens em desenvolvimento
- Verifique se o ALLOWED_ORIGINS está configurado corretamente

### **Problema: Banco de dados não conecta**
- Verifique se as variáveis SUPABASE_URL e SUPABASE_KEY estão no arquivo .env
- O banco está configurado para desenvolvimento

## 📋 **Comandos Úteis**

### **Iniciar servidor:**
```bash
cd backend && npm run dev
```

### **Parar servidor:**
```bash
pkill -f "node server.js"
```

### **Ver logs do servidor:**
```bash
tail -f backend/server.log
```

### **Testar endpoints:**
```bash
# Health check
curl http://localhost:3000/health

# Login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "teste@teste.com", "senha": "teste123"}'

# Listar produtos
curl http://localhost:3000/api/products
```

## 🎯 **Próximos Passos**

1. ✅ Servidor local configurado
2. ✅ App Flutter configurado
3. 🔄 Testar login no app
4. 🔄 Testar criação de produtos
5. 🔄 Testar upload de imagens
6. 🔄 Testar em dispositivo real

---

**Nota**: Para voltar ao servidor de produção, altere em `lib/constants/environment_config.dart`:
```dart
static const Environment _currentEnvironment = Environment.production;
```
