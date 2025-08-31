# 🔧 Solução de Problemas de Conexão

## 🚨 Problema Identificado
```
Connection refused (OS Error: Connection refused, errno = 111), 
address = 192.168.3.43, port = 36346, 
uri=http://192.168.3.43:3000/api/auth/login
```

## ✅ Solução Implementada

### 1. **Servidor Backend Rodando**
- ✅ Servidor iniciado na porta 3000
- ✅ Health check respondendo: `http://192.168.3.43:3000/health`
- ✅ CORS configurado para aceitar conexões do Flutter

### 2. **Script de Inicialização**
```bash
# No diretório backend/
./start_server.sh
```

### 3. **Verificação de Status**
```bash
# Testar se o servidor está respondendo
curl http://192.168.3.43:3000/health
```

## 🔍 Diagnóstico de Problemas

### **Problema 1: Servidor não está rodando**
**Sintomas:**
- `Connection refused`
- `ECONNREFUSED`

**Solução:**
```bash
cd backend
./start_server.sh
```

### **Problema 2: Porta incorreta**
**Sintomas:**
- `Connection refused` em porta diferente de 3000

**Solução:**
- Verificar se o servidor está rodando na porta 3000
- Verificar configuração no Flutter

### **Problema 3: IP incorreto**
**Sintomas:**
- Não consegue conectar ao IP

**Solução:**
```bash
# Verificar IP da máquina
ifconfig | grep "inet " | grep -v 127.0.0.1

# Ou no macOS
ipconfig getifaddr en0
```

### **Problema 4: Firewall bloqueando**
**Sintomas:**
- Conexão recusada mesmo com servidor rodando

**Solução:**
```bash
# Verificar se a porta está aberta
netstat -an | grep 3000

# Ou usar lsof
lsof -i :3000
```

## 🚀 Como Iniciar o Sistema

### **1. Iniciar Backend**
```bash
cd backend
./start_server.sh
```

### **2. Verificar Status**
```bash
curl http://192.168.3.43:3000/health
```

### **3. Iniciar Flutter**
```bash
cd ..
flutter run
```

## 📋 Checklist de Verificação

### **Backend**
- [ ] Node.js instalado
- [ ] Dependências instaladas (`npm install`)
- [ ] Arquivo `.env` configurado
- [ ] Servidor rodando na porta 3000
- [ ] Health check respondendo

### **Rede**
- [ ] IP correto configurado
- [ ] Porta 3000 acessível
- [ ] Firewall permitindo conexões
- [ ] Dispositivo na mesma rede

### **Flutter**
- [ ] URL do backend configurada corretamente
- [ ] App compilado e instalado
- [ ] Permissões de rede concedidas

## 🔧 Configurações Importantes

### **Backend (server.js)**
```javascript
const PORT = process.env.PORT || 3000;
const HOST = process.env.HOST || '0.0.0.0'; // Aceitar conexões externas

app.listen(PORT, HOST, () => {
  console.log(`🌐 Acessível em: http://${HOST}:${PORT}`);
});
```

### **CORS Configurado**
```javascript
const allowedOrigins = [
  'http://localhost:3000',
  'http://192.168.3.43:3000',
  // ... outros IPs
];
```

## 🆘 Comandos de Emergência

### **Reiniciar Servidor**
```bash
# Parar servidor (Ctrl+C)
# Depois reiniciar
cd backend
./start_server.sh
```

### **Verificar Logs**
```bash
# Ver logs do servidor
tail -f backend/server.log
```

### **Testar Conexão**
```bash
# Testar health check
curl http://192.168.3.43:3000/health

# Testar endpoint de auth
curl -X POST http://192.168.3.43:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"teste@teste.com","password":"123456"}'
```

## 📱 Configuração do Flutter

### **URL do Backend**
Verificar se a URL está configurada corretamente no Flutter:
```dart
// Deve apontar para o IP correto
const String baseUrl = 'http://192.168.3.43:3000';
```

### **Permissões Android**
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

## 🎯 Status Atual
- ✅ **Servidor rodando**: `http://192.168.3.43:3000`
- ✅ **Health check OK**: Resposta `{"status":"OK"}`
- ✅ **CORS configurado**: Aceitando conexões do Flutter
- ✅ **Script de inicialização**: `./start_server.sh`

## 🚀 Próximos Passos
1. Reiniciar o app Flutter
2. Tentar fazer login novamente
3. Verificar logs do servidor para debug

**Resultado esperado**: Login funcionando normalmente sem erros de conexão.
