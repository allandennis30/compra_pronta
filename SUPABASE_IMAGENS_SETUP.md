# 📸 Sistema de Imagens com Supabase - Compra Pronta

## ✅ **Status Atual**

O sistema de gerenciamento de imagens foi implementado e integrado com o Supabase Storage. Agora você pode:

1. ✅ **Upload de imagens** diretamente para o Supabase
2. ✅ **Remoção de imagens** do bucket
3. ✅ **Atualização de imagens** (remove antiga, adiciona nova)
4. ✅ **Integração com produtos** (URL da imagem salva no banco)
5. ✅ **Carregamento automático** de imagens ao exibir produtos

## 🏗️ **Arquitetura Implementada**

### **1. SupabaseImageService**
- **Localização**: `lib/core/services/supabase_image_service.dart`
- **Responsabilidade**: Gerenciar todas as operações de imagem com o Supabase
- **Funcionalidades**: Upload, remoção, atualização, listagem, verificação

### **2. VendedorProductSupabaseRepository**
- **Localização**: `lib/modules/vendedor/repositories/vendedor_product_supabase_repository.dart`
- **Responsabilidade**: Integrar produtos com o serviço de imagens
- **Funcionalidades**: CRUD de produtos + gerenciamento de imagens

### **3. Integração com Controllers**
- **Localização**: `lib/modules/vendedor/controllers/vendor_product_form_controller.dart`
- **Responsabilidade**: Usar o serviço de imagens no formulário de produtos
- **Funcionalidades**: Upload automático ao criar/editar produtos

## 🚀 **Como Funciona**

### **Fluxo de Criação de Produto com Imagem:**

1. **Usuário seleciona imagem** no formulário
2. **Controller detecta nova imagem** e chama o serviço
3. **SupabaseImageService faz upload** para o bucket `product-images`
4. **URL pública é retornada** e salva no produto
5. **Produto é criado** no banco com a `imageUrl`
6. **Ao carregar produtos**, as imagens são exibidas automaticamente

### **Estrutura de Arquivos no Supabase:**

```
product-images/
├── products/
│   ├── userId1/
│   │   ├── 1234567890-abc123.jpg
│   │   └── 1234567891-def456.png
│   └── userId2/
│       └── 1234567892-ghi789.webp
```

## 📱 **Como Usar no App**

### **1. Upload de Imagem Simples:**

```dart
import 'package:compra_pronta/core/services/supabase_image_service.dart';

final imageService = SupabaseImageService();

// Selecionar e fazer upload
final imageFile = await imageService.pickImage(ImageSource.gallery);
if (imageFile != null) {
  final imageUrl = await imageService.uploadImage(imageFile, userId);
  print('Imagem enviada: $imageUrl');
}
```

### **2. Criar Produto com Imagem:**

```dart
// No controller do formulário
if (productImage.value != null) {
  final imageUrl = await supabaseRepo.uploadProductImage(productImage.value!);
  
  final product = ProductModel(
    name: 'Nome do Produto',
    imageUrl: imageUrl, // URL da imagem salva aqui
    // ... outros campos
  );
  
  await repository.create(product);
}
```

### **3. Atualizar Imagem de Produto:**

```dart
final newImageUrl = await supabaseRepo.updateProductImage(
  newImageFile, 
  oldImageUrl
);
```

### **4. Remover Imagem:**

```dart
final success = await supabaseRepo.removeProductImage(imageUrl);
if (success) {
  print('Imagem removida com sucesso');
}
```

## 🔧 **Configuração do Supabase**

### **Bucket Necessário:**
- **Nome**: `product-images`
- **Tipo**: Público
- **Tamanho máximo**: 5MB por arquivo
- **Tipos permitidos**: JPEG, PNG, GIF, WebP, SVG, BMP

### **Políticas RLS (Row Level Security):**
- ✅ Vendedores podem fazer upload
- ✅ Vendedores podem atualizar suas imagens
- ✅ Vendedores podem deletar suas imagens
- ✅ Todos podem visualizar imagens (produtos públicos)

## 📋 **Endpoints da API**

### **Upload de Imagem:**
```http
POST /api/products/upload-image
Authorization: Bearer <token>
Content-Type: multipart/form-data

Body: image=<arquivo>
```

### **Resposta:**
```json
{
  "message": "Imagem enviada com sucesso",
  "imageUrl": "https://...supabase.co/storage/v1/object/public/product-images/products/userId/filename.jpg",
  "fileName": "1234567890-abc123.jpg",
  "filePath": "products/userId/filename.jpg",
  "size": 245760
}
```

## 🧪 **Testando o Sistema**

### **1. Teste de Upload:**
```bash
# No VS Code com extensão REST Client
backend/test_upload.http
```

### **2. Teste no App Flutter:**
1. Faça login como vendedor
2. Vá para "Meus Produtos"
3. Clique em "Adicionar Produto"
4. Selecione uma imagem
5. Preencha os dados e salve
6. Verifique se a imagem aparece na lista

### **3. Verificar no Supabase:**
1. Acesse o Dashboard do Supabase
2. Vá para Storage > product-images
3. Verifique se a imagem foi criada na pasta correta

## 🔍 **Troubleshooting**

### **Problema: Upload falha**
1. Verifique se o bucket `product-images` existe
2. Verifique as políticas RLS
3. Verifique se o usuário está autenticado
4. Verifique o tamanho da imagem (máximo 5MB)

### **Problema: Imagem não aparece**
1. Verifique se a `imageUrl` foi salva no produto
2. Verifique se a URL é acessível publicamente
3. Verifique se o bucket é público
4. Verifique as políticas de visualização

### **Problema: Erro de CORS**
1. Verifique se o bucket está configurado corretamente
2. Verifique se as políticas RLS permitem acesso
3. Verifique se a URL está correta

## 📊 **Monitoramento**

### **Logs Disponíveis:**
- ✅ Upload de imagens
- ✅ Remoção de imagens
- ✅ Atualização de imagens
- ✅ Erros de upload
- ✅ Tamanhos de arquivo
- ✅ URLs geradas

### **Métricas:**
- Número de imagens por usuário
- Tamanho total de armazenamento
- Taxa de sucesso de upload
- Tempo médio de upload

## 🎯 **Próximos Passos**

1. ✅ Sistema de imagens implementado
2. ✅ Integração com produtos funcionando
3. 🔄 Testar em dispositivos reais
4. 🔄 Implementar cache de imagens
5. 🔄 Adicionar compressão automática
6. 🔄 Implementar redimensionamento
7. 🔄 Adicionar filtros de imagem

## 💡 **Dicas de Uso**

### **Para Vendedores:**
- Use imagens de boa qualidade (máximo 5MB)
- Formato recomendado: JPEG ou PNG
- Dimensões recomendadas: 800x600 ou 1024x768
- Sempre teste o upload antes de criar o produto

### **Para Desenvolvedores:**
- O serviço é thread-safe
- Sempre trate erros de upload
- Implemente retry para falhas de rede
- Use cache para melhorar performance

---

**Nota**: Este sistema substitui o upload via backend, permitindo upload direto para o Supabase e melhor performance.
