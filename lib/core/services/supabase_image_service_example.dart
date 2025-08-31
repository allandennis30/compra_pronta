import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'supabase_image_service.dart';

/// Exemplo de uso do SupabaseImageService
/// Este arquivo demonstra como usar o serviço para gerenciar imagens
class SupabaseImageServiceExample {
  final SupabaseImageService _imageService = SupabaseImageService();

  /// Exemplo: Upload de imagem para um produto
  Future<String> uploadProductImageExample() async {
    try {
      // 1. Selecionar imagem da galeria
      final imageFile = await _imageService.pickImage(ImageSource.gallery);
      if (imageFile == null) {
        throw Exception('Nenhuma imagem selecionada');
      }

      // 2. Fazer upload da imagem
      final userId = 'user123'; // ID do usuário atual
      final imageUrl = await _imageService.uploadImage(imageFile, userId);

      print('✅ Imagem enviada com sucesso: $imageUrl');
      return imageUrl;
    } catch (e) {
      print('❌ Erro ao fazer upload: $e');
      rethrow;
    }
  }

  /// Exemplo: Upload de imagem com remoção automática da anterior (atualização)
  Future<String> uploadImageWithReplacementExample(String oldImageUrl) async {
    try {
      // 1. Selecionar nova imagem
      final newImageFile = await _imageService.pickImage(ImageSource.gallery);
      if (newImageFile == null) {
        throw Exception('Nenhuma nova imagem selecionada');
      }

      // 2. Fazer upload da nova imagem (a anterior será removida automaticamente)
      final userId = 'user123';
      final newImageUrl = await _imageService.uploadImage(newImageFile, userId,
          oldImageUrl: oldImageUrl);

      print('✅ Nova imagem enviada e imagem anterior removida automaticamente');
      print('✅ Nova URL: $newImageUrl');
      return newImageUrl;
    } catch (e) {
      print('❌ Erro ao fazer upload com substituição: $e');
      rethrow;
    }
  }

  /// Exemplo: Atualizar imagem de um produto
  Future<String> updateProductImageExample(String oldImageUrl) async {
    try {
      // 1. Selecionar nova imagem
      final newImageFile = await _imageService.pickImage(ImageSource.camera);
      if (newImageFile == null) {
        throw Exception('Nenhuma nova imagem selecionada');
      }

      // 2. Atualizar imagem (remove a antiga e faz upload da nova)
      final userId = 'user123';
      final newImageUrl =
          await _imageService.updateImage(newImageFile, userId, oldImageUrl);

      print('✅ Imagem atualizada com sucesso: $newImageUrl');
      return newImageUrl;
    } catch (e) {
      print('❌ Erro ao atualizar imagem: $e');
      rethrow;
    }
  }

  /// Exemplo: Remover imagem de um produto
  Future<bool> removeProductImageExample(String imageUrl) async {
    try {
      final success = await _imageService.deleteImage(imageUrl);

      if (success) {
        print('✅ Imagem removida com sucesso');
      } else {
        print('⚠️ Não foi possível remover a imagem');
      }

      return success;
    } catch (e) {
      print('❌ Erro ao remover imagem: $e');
      return false;
    }
  }

  /// Exemplo: Listar imagens de um usuário
  Future<List<String>> listUserImagesExample() async {
    try {
      final userId = 'user123';
      final images = await _imageService.listUserImages(userId);

      print('✅ ${images.length} imagens encontradas:');
      for (final imageUrl in images) {
        print('  - $imageUrl');
      }

      return images;
    } catch (e) {
      print('❌ Erro ao listar imagens: $e');
      return [];
    }
  }

  /// Exemplo: Verificar se uma imagem existe
  Future<void> checkImageExistsExample(String imageUrl) async {
    try {
      final exists = await _imageService.imageExists(imageUrl);

      if (exists) {
        print('✅ Imagem existe: $imageUrl');
      } else {
        print('❌ Imagem não existe: $imageUrl');
      }
    } catch (e) {
      print('❌ Erro ao verificar imagem: $e');
    }
  }

  /// Exemplo: Processo completo de criação de produto com imagem
  Future<void> createProductWithImageExample() async {
    try {
      print('🚀 Iniciando criação de produto com imagem...');

      // 1. Selecionar imagem
      final imageFile = await _imageService.pickImage(ImageSource.gallery);
      if (imageFile == null) {
        print('⚠️ Nenhuma imagem selecionada, criando produto sem imagem');
        return;
      }

      // 2. Comprimir imagem se necessário
      final compressedImage =
          await _imageService.compressImageIfNeeded(imageFile);
      print('📸 Imagem processada: ${compressedImage.path}');

      // 3. Fazer upload da imagem
      final userId = 'user123';
      final imageUrl = await _imageService.uploadImage(compressedImage, userId);
      print('✅ Upload concluído: $imageUrl');

      // 4. Aqui você criaria o produto no banco com a imageUrl
      print('📦 Produto criado com imagem: $imageUrl');

      // 5. Exemplo de como remover a imagem se necessário
      // await _imageService.deleteImage(imageUrl);
    } catch (e) {
      print('💥 Erro no processo: $e');
    }
  }
}

/// Como usar no seu código:
/*
void main() async {
  final example = SupabaseImageServiceExample();
  
  // Upload de imagem
  final imageUrl = await example.uploadProductImageExample();
  
  // Atualizar imagem
  final newImageUrl = await example.updateProductImageExample(imageUrl);
  
  // Listar imagens
  final images = await example.listUserImagesExample();
  
  // Verificar se existe
  await example.checkImageExistsExample(imageUrl);
  
  // Processo completo
  await example.createProductWithImageExample();
}
*/
