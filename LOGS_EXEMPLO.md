# 📊 Exemplos de Logs do Sistema

## 🔐 **Login**

### ✅ **Sucesso**
```
ℹ️ INFO: 🔐 Iniciando login - Email: joao@teste.com - Endpoint: https://backend-compra-pronta.onrender.com/api/auth/login
ℹ️ INFO: 📡 Resposta do login recebida - Status: 200 - Tamanho: 456
✅ SUCCESS: ✅ Login realizado com sucesso - UserID: 123 - Tipo: cliente
ℹ️ INFO: 💾 Token JWT salvo no storage
ℹ️ INFO: 💾 Usuário salvo no storage local
```

### ❌ **Credenciais Inválidas**
```
ℹ️ INFO: 🔐 Iniciando login - Email: joao@teste.com - Endpoint: https://backend-compra-pronta.onrender.com/api/auth/login
ℹ️ INFO: 📡 Resposta do login recebida - Status: 401 - Tamanho: 89
⚠️ WARNING: ❌ Login falhou: Credenciais inválidas - Status: 401 - Email: joao@teste.com
```

### 💥 **Erro do Servidor**
```
ℹ️ INFO: 🔐 Iniciando login - Email: joao@teste.com - Endpoint: https://backend-compra-pronta.onrender.com/api/auth/login
ℹ️ INFO: 📡 Resposta do login recebida - Status: 503 - Tamanho: 0
❌ ERROR: 💥 Erro do servidor no login - Status: 503 - Response: 
Error details: 
```

## 📝 **Cadastro (Signup)**

### ✅ **Sucesso**
```
ℹ️ INFO: 📝 Iniciando cadastro - Email: maria@teste.com - Nome: Maria Silva - Tipo: Cliente
ℹ️ INFO: 📡 Resposta do cadastro recebida - Status: 201 - Tamanho: 512
✅ SUCCESS: ✅ Cadastro realizado com sucesso - UserID: 456 - Tipo: cliente
ℹ️ INFO: 💾 Token JWT salvo no storage
ℹ️ INFO: 💾 Usuário salvo no storage local
```

### ⚠️ **Dados Inválidos**
```
ℹ️ INFO: 📝 Iniciando cadastro - Email: maria@teste.com - Nome: Maria Silva - Tipo: Cliente
ℹ️ INFO: 📡 Resposta do cadastro recebida - Status: 400 - Tamanho: 156
⚠️ WARNING: ⚠️ Dados inválidos no cadastro - Status: 400 - Mensagem: Nome deve ter entre 2 e 100 caracteres
```

### ❌ **Email Já Existe**
```
ℹ️ INFO: 📝 Iniciando cadastro - Email: maria@teste.com - Nome: Maria Silva - Tipo: Cliente
ℹ️ INFO: 📡 Resposta do cadastro recebida - Status: 409 - Tamanho: 89
⚠️ WARNING: ❌ Conflito no cadastro - Status: 409 - Email já está em uso
```

## 🔍 **Operações Locais**

### **Buscar Usuário Atual**
```
ℹ️ INFO: 🔍 Buscando usuário atual no storage local
✅ SUCCESS: ✅ Usuário encontrado no storage - ID: 123 - Email: joao@teste.com
```

### **Salvar Usuário**
```
ℹ️ INFO: 💾 Salvando usuário no storage local - ID: 123 - Email: joao@teste.com
✅ SUCCESS: ✅ Usuário salvo com sucesso no storage local
```

### **Logout**
```
ℹ️ INFO: 🚪 Iniciando logout do usuário
ℹ️ INFO: 🗑️ Dados do usuário removidos do storage
✅ SUCCESS: ✅ Logout realizado com sucesso - Token e dados removidos
```

### **Buscar Token**
```
ℹ️ INFO: 🔑 Buscando token JWT no storage
✅ SUCCESS: ✅ Token JWT encontrado no storage
```

## 🚨 **Tratamento de Erros**

### **Erro de Rede**
```
❌ ERROR: 💥 Erro ao fazer login - Email: joao@teste.com
Error details: SocketException: Failed host lookup: 'backend-compra-pronta.onrender.com'
```

### **Timeout**
```
❌ ERROR: 💥 Erro ao fazer cadastro - Email: maria@teste.com
Error details: TimeoutException: Timeout: Servidor demorou para responder
```

### **Erro de Parse**
```
⚠️ WARNING: ⚠️ Erro no login - Status: 500 - Mensagem: Internal Server Error
❌ ERROR: 💥 Erro ao processar resposta do login - Status: 500 - Parse Error: FormatException: Unexpected character
```

## 📱 **Como Visualizar os Logs**

### **Flutter Debug Console**
- Os logs aparecem automaticamente no console do Flutter
- Use `flutter run` para ver logs em tempo real

### **Android Studio / VS Code**
- Abra o console de debug
- Filtre por "INFO", "SUCCESS", "WARNING", "ERROR"

### **Produção**
- Em produção, os logs são desabilitados automaticamente
- Use `kDebugMode` para controlar quando mostrar logs

## 🎯 **Benefícios dos Logs**

1. **Debugging Rápido** - Identifique problemas em segundos
2. **Monitoramento** - Acompanhe todas as interações com o backend
3. **Auditoria** - Rastreie ações dos usuários
4. **Performance** - Monitore tempos de resposta
5. **Segurança** - Detecte tentativas de acesso não autorizado

## 🔧 **Personalização**

### **Níveis de Log**
- `AppLogger.debug()` - Informações detalhadas para desenvolvimento
- `AppLogger.info()` - Informações gerais do sistema
- `AppLogger.warning()` - Avisos que não interrompem o funcionamento
- `AppLogger.error()` - Erros que precisam de atenção
- `AppLogger.success()` - Operações bem-sucedidas

### **Formato dos Logs**
- Emojis para identificação visual rápida
- Timestamps automáticos
- Contexto detalhado (email, status, IDs)
- Stack traces para erros
