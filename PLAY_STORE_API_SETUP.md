# Configuração da Play Store API para Verificação de Atualizações

Este documento explica como configurar e usar a integração com a Play Store API para verificar atualizações do app automaticamente.

## 📋 Visão Geral

O sistema implementado oferece duas abordagens para verificar atualizações:

1. **Web Scraping da Play Store** (Método 1) - Implementado e funcional
2. **API Oficial do Google Play Console** (Método 2) - Requer configuração adicional

## 🚀 Método 1: Web Scraping (Recomendado para início)

### Características:
- ✅ **Funciona imediatamente** - Não requer configuração adicional
- ✅ **Simples de implementar** - Já está configurado e pronto para uso
- ⚠️ **Menos confiável** - Google pode mudar a estrutura da página
- ⚠️ **Rate limiting** - Pode ser bloqueado em caso de muitas requisições

### Como usar:
1. O método já está ativo por padrão
2. Configure o `packageName` em `PlayStoreConfig`:
   ```dart
   static const String packageName = 'com.seu.app'; // Substitua pelo seu package name
   ```
3. O app verificará automaticamente na inicialização

### Configuração do Package Name:
1. Abra `android/app/build.gradle`
2. Encontre a linha `applicationId "com.example.app"`
3. Use o mesmo valor em `PlayStoreConfig.packageName`

## 🔧 Método 2: API Oficial (Recomendado para produção)

### Vantagens:
- ✅ **Oficialmente suportado** pelo Google
- ✅ **Mais confiável** e estável
- ✅ **Informações detalhadas** (notas de versão, prioridade de atualização)
- ✅ **Rate limiting controlado**

### Configuração Passo a Passo:

#### 1. Google Cloud Console
1. Acesse [Google Cloud Console](https://console.cloud.google.com/)
2. Crie um novo projeto ou selecione um existente
3. Ative a **Google Play Android Publisher API**:
   - Vá para "APIs & Services" > "Library"
   - Procure por "Google Play Android Publisher API"
   - Clique em "Enable"

#### 2. Service Account
1. Vá para "APIs & Services" > "Credentials"
2. Clique em "Create Credentials" > "Service Account"
3. Preencha os dados:
   - **Name**: `play-store-api-service`
   - **Description**: `Service account for Play Store API access`
4. Clique em "Create and Continue"
5. Adicione a role: **"Service Account User"**
6. Clique em "Done"

#### 3. Chave JSON
1. Na lista de Service Accounts, clique no que você criou
2. Vá para a aba "Keys"
3. Clique em "Add Key" > "Create new key"
4. Selecione "JSON" e clique em "Create"
5. **Salve o arquivo JSON com segurança** - você precisará dele no backend

#### 4. Google Play Console
1. Acesse [Google Play Console](https://play.google.com/console/)
2. Selecione seu app
3. Vá para "Setup" > "API access"
4. Clique em "Link a Google Cloud project"
5. Selecione o projeto criado no passo 1
6. Na seção "Service accounts", encontre o service account criado
7. Clique em "Grant access"
8. Selecione as permissões:
   - **"View app information and download bulk reports"**
   - **"View financial data, orders, and cancellation survey responses"**
9. Clique em "Invite user"

#### 5. Backend API
Crie um endpoint em seu backend que consulte a Play Store API:

```javascript
// Exemplo em Node.js
const { google } = require('googleapis');

app.get('/app/version/:packageName', async (req, res) => {
  try {
    const auth = new google.auth.GoogleAuth({
      keyFile: 'path/to/service-account-key.json',
      scopes: ['https://www.googleapis.com/auth/androidpublisher'],
    });
    
    const androidpublisher = google.androidpublisher({
      version: 'v3',
      auth: auth,
    });
    
    const result = await androidpublisher.edits.apks.list({
      packageName: req.params.packageName,
      editId: 'your-edit-id',
    });
    
    // Processa resultado e retorna versão mais recente
    res.json({
      version: latestVersion,
      versionCode: latestVersionCode,
      releaseNotes: releaseNotes
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
```

#### 6. Configuração no App
1. Edite `lib/core/services/play_store_config.dart`:
   ```dart
   static const String apiBaseUrl = 'https://sua-api.com';
   static const String apiToken = ''; // Se necessário
   ```

2. Descomente a linha no `AppUpdateService`:
   ```dart
   // Método 2: Usar sua própria API que consulta a Play Console API
   await _fetchVersionFromAPI(); // Descomente esta linha
   ```

## 🔄 Como Funciona

### Fluxo de Verificação:
1. **Inicialização**: App carrega versão atual usando `package_info_plus`
2. **Verificação**: Consulta Play Store (método 1) ou sua API (método 2)
3. **Comparação**: Compara versões usando semântica `major.minor.patch`
4. **Popup**: Exibe dialog de atualização se nova versão disponível
5. **Redirecionamento**: Leva usuário para Play Store ao clicar "Atualizar"

### Cache Inteligente:
- Verificações são cacheadas por 1 hora
- Evita requisições desnecessárias
- Configurável em `PlayStoreConfig.cacheTimeoutHours`

### Logs Detalhados:
- Todos os passos são logados usando `AppLogger`
- Facilita debugging e monitoramento
- Inclui informações sobre qual método foi usado

## 🧪 Testando

### Teste Forçado:
```dart
// Para forçar exibição do popup (apenas para testes)
final updateController = Get.find<UpdateController>();
await updateController.forceUpdateCheck();
```

### Verificação Manual:
```dart
// Para verificar sem mostrar popup
final updateService = Get.find<AppUpdateService>();
final hasUpdate = await updateService.checkForUpdates();
print('Tem atualização: $hasUpdate');
```

## 🔒 Segurança

### Boas Práticas:
- ❌ **NUNCA** commite tokens ou chaves no código
- ✅ Use variáveis de ambiente no backend
- ✅ Use Firebase Remote Config para configurações sensíveis
- ✅ Implemente rate limiting no seu backend
- ✅ Monitore logs para detectar abusos

### Configuração Segura:
```dart
// ❌ ERRADO - token no código
static const String apiToken = 'sk_live_abc123';

// ✅ CORRETO - token vazio, configurado no backend
static const String apiToken = '';
```

## 🚨 Troubleshooting

### Problemas Comuns:

1. **"Não foi possível extrair versão da Play Store"**
   - Verifique se o `packageName` está correto
   - Confirme se o app está publicado na Play Store
   - Google pode ter mudado a estrutura da página

2. **"API não configurada"**
   - Configure `apiBaseUrl` em `PlayStoreConfig`
   - Implemente o endpoint no seu backend
   - Verifique se o service account tem permissões

3. **Rate Limiting**
   - Aumente o `cacheTimeoutHours`
   - Implemente backoff exponencial
   - Use o Método 2 (API oficial)

4. **Permissões negadas**
   - Verifique configuração do service account
   - Confirme permissões no Google Play Console
   - Regenere as chaves se necessário

## 📈 Monitoramento

### Métricas Importantes:
- Taxa de sucesso das verificações
- Tempo de resposta das requisições
- Frequência de atualizações disponíveis
- Taxa de conversão (usuários que atualizam)

### Logs para Monitorar:
```
📱 [UPDATE] Versão atual do app: 1.0.0
🔍 [UPDATE] Verificando atualizações...
📋 [UPDATE] Versão encontrada na Play Store: 1.0.1
✅ [UPDATE] Atualização disponível: 1.0.0 -> 1.0.1
```

## 🔄 Próximos Passos

1. **Teste o Método 1** com seu app publicado
2. **Configure o Método 2** para produção
3. **Implemente analytics** para monitorar uso
4. **Configure notificações** para atualizações críticas
5. **Adicione testes automatizados** para verificação de atualizações

---

**Nota**: Este sistema segue as boas práticas do Flutter e GetX, mantendo separação de responsabilidades e facilidade de manutenção.