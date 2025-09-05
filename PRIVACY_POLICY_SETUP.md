# 📋 Configuração da Política de Privacidade - Google Play Store

## 🚨 Problema Identificado

O Google Play Store está rejeitando o APK porque o app usa a permissão `android.permission.CAMERA` mas não possui uma política de privacidade pública.

## 🔍 Permissões que Requerem Política de Privacidade

Seu app usa os seguintes plugins que automaticamente adicionam a permissão CAMERA:

- `mobile_scanner: ^6.0.10` - Para leitura de códigos de barras/QR
- `barcode_scan2: ^4.2.0` - Scanner de códigos de barras
- `image_picker: ^1.0.7` - Seleção e captura de imagens

## ✅ Solução Implementada

### 1. Arquivos Criados

Criei os arquivos essenciais e configurei o backend:

- **`privacy_policy.md`** - Versão em Markdown para documentação
- **`web/privacy_policy.html`** - Versão web hospedável
- **`backend/public/privacy-policy.html`** - Versão hospedada no backend

### 🌐 URL Pública da Política de Privacidade

**URL OFICIAL:** `https://backend-compra-pronta.onrender.com/privacy-policy`

Esta URL está pronta para ser usada no Google Play Console!

### 2. Configuração no Backend (IMPLEMENTADO)

✅ **Política hospedada no próprio backend do projeto!**

**Arquivos criados/modificados:**
- `backend/public/privacy-policy.html` - Arquivo da política
- `backend/server.js` - Rota `/privacy-policy` adicionada
- `backend/DEPLOY_PRIVACY_POLICY.md` - Guia de deploy

**Status:**
- ✅ Testado localmente: `http://localhost:3000/privacy-policy`
- ⏳ **Pendente:** Deploy no Render para ativar URL pública

### 3. Próximos Passos para Ativar

#### Passo 1: Deploy no Render

```bash
# 1. Fazer commit das mudanças
git add .
git commit -m "feat: adicionar política de privacidade pública"

# 2. Push para repositório (deploy automático)
git push origin main

# 3. Aguardar deploy no Render
# 4. Testar URL pública
curl -I https://backend-compra-pronta.onrender.com/privacy-policy
```

#### Passo 2: Configurar no Google Play Console

1. Acesse o [Google Play Console](https://play.google.com/console)
2. Selecione seu app
3. Vá em **Política do app** > **Política de privacidade**
4. Adicione a URL da sua política de privacidade hospedada
5. Salve as alterações

#### Passo 3: Atualizar Informações de Contato

Edite os arquivos de política de privacidade e substitua:

- `[seu-email@mercax.com]` - Seu email real
- `[seu-telefone]` - Seu telefone real
- `[seu-endereço]` - Seu endereço real

## 📝 Conteúdo da Política

A política criada inclui:

### ✅ Uso da Câmera (Seção Destacada)
- **Leitura de códigos de barras/QR** - Para cadastro de produtos
- **Captura de fotos de produtos** - Para vendedores fotografarem produtos
- **Digitalização de documentos** - Para verificações

### ✅ Outros Pontos Importantes
- Coleta e uso de dados
- Compartilhamento de informações
- Segurança dos dados
- Direitos do usuário (LGPD)
- Retenção de dados
- Informações de contato

## 🔧 Comandos Úteis

### Verificar Permissões no APK
```bash
# Verificar permissões no APK gerado
aapt dump permissions build/app/outputs/flutter-apk/app-release.apk
```

### Gerar APK de Release
```bash
flutter build apk --release
```

### Gerar App Bundle (Recomendado)
```bash
flutter build appbundle --release
```

## 📋 Checklist Final

- [ ] Hospedar política de privacidade em URL pública
- [ ] Atualizar informações de contato nos arquivos
- [ ] Configurar URL no Google Play Console
- [ ] Testar se a URL está acessível
- [ ] Fazer novo upload do APK/AAB

## 🚀 Após Configurar

Depois de hospedar a política e configurar no Google Play Console:

1. Faça um novo build do app
2. Faça upload no Google Play Console
3. O app deve ser aceito sem problemas

## 📞 Suporte

Se precisar de ajuda:

1. Verifique se a URL da política está acessível
2. Confirme que todas as informações de contato estão preenchidas
3. Aguarde algumas horas após configurar no Play Console

---

**Nota:** A política de privacidade é obrigatória para apps que usam permissões sensíveis como CAMERA, LOCATION, MICROPHONE, etc.