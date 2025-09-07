# Guia de Configuração Firebase - MercaX

## 1. Registrar App no Firebase Console

### Passo 1: Acessar Firebase Console
1. Acesse [Firebase Console](https://console.firebase.google.com/)
2. Faça login com sua conta Google
3. Clique em "Criar um projeto" ou selecione um projeto existente

### Passo 2: Adicionar App Android
1. No painel do projeto, clique no ícone do Android
2. Preencha as informações:
   - **Nome do pacote do Android**: `com.company.appname`
   - **Apelido do app (opcional)**: `Meu app Android`
   - **Certificado de assinatura SHA-1 de depuração (opcional)**: `00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00`

### Passo 3: Baixar google-services.json
1. Após registrar o app, baixe o arquivo `google-services.json`
2. Coloque o arquivo em: `android/app/google-services.json`

### Passo 4: Adicionar App iOS (se necessário)
1. Clique no ícone do iOS
2. Preencha as informações:
   - **ID do pacote do iOS**: `com.company.appname`
   - **Apelido do app (opcional)**: `Meu app iOS`
   - **ID da App Store (opcional)**: deixe em branco por enquanto

### Passo 5: Baixar GoogleService-Info.plist
1. Após registrar o app iOS, baixe o arquivo `GoogleService-Info.plist`
2. Coloque o arquivo em: `ios/Runner/GoogleService-Info.plist`

## 2. Configurar Dependências

### Android (android/app/build.gradle)
Adicione no final do arquivo:
```gradle
apply plugin: 'com.google.gms.google-services'
```

### Android (android/build.gradle)
Adicione nas dependências:
```gradle
classpath 'com.google.gms:google-services:4.3.15'
```

### iOS (ios/Runner/Info.plist)
O arquivo `GoogleService-Info.plist` deve estar no diretório `ios/Runner/`

## 3. Ativar Serviços Firebase

### No Firebase Console:
1. **Cloud Messaging**: Vá em "Messaging" e ative o serviço
2. **Authentication** (se necessário): Configure os métodos de login
3. **Firestore** (se necessário): Configure o banco de dados

## 4. Configurar Notificações Push

### Android:
1. No Firebase Console, vá em "Project Settings" > "Cloud Messaging"
2. Na aba "Android apps", adicione o certificado SHA-1 se ainda não foi feito

### iOS:
1. No Firebase Console, vá em "Project Settings" > "Cloud Messaging"
2. Na aba "iOS apps", faça upload do certificado APNs:
   - Desenvolvimento: certificado de desenvolvimento
   - Produção: certificado de produção

## 5. Testar Configuração

### Verificar se os arquivos estão nos locais corretos:
- ✅ `android/app/google-services.json`
- ✅ `ios/Runner/GoogleService-Info.plist`

### Executar o app:
```bash
flutter clean
flutter pub get
flutter build apk --debug  # Para Android
flutter build ios --debug  # Para iOS
```

## 6. Observações Importantes

⚠️ **Certificado SHA-1**: O certificado fornecido (`00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00`) parece ser um placeholder. Para obter o certificado real:

```bash
# Para debug keystore
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# Para release keystore
keytool -list -v -keystore upload-keystore.jks -alias upload -storepass [sua_senha] -keypass [sua_senha]
```

⚠️ **Nome do Pacote**: Certifique-se de que `com.company.appname` corresponde ao `applicationId` em `android/app/build.gradle` e ao `PRODUCT_BUNDLE_IDENTIFIER` no iOS.

⚠️ **Permissões**: Verifique se as permissões necessárias estão configuradas:
- Android: `android/app/src/main/AndroidManifest.xml`
- iOS: `ios/Runner/Info.plist`

## 7. Próximos Passos

Após a configuração:
1. Teste o recebimento de notificações
2. Configure tópicos de notificação se necessário
3. Implemente analytics se desejado
4. Configure regras de segurança do Firestore (se usado)

---

**Nota**: Este guia assume que você já tem um projeto Flutter configurado. Se encontrar problemas, verifique a documentação oficial do Firebase para Flutter.