import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import '../../core/utils/logger.dart';

/// Serviço para gerenciar imagens diretamente com o Supabase Storage
class SupabaseImageService {
  static const String _bucketName = 'product-images';
  static const String _baseUrl = 'https://feljoannoghnpbqhrsuv.supabase.co';
  static const String _storageUrl = '$_baseUrl/storage/v1';
  static const String _anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZlbGpvYW5ub2dobnBicWhyc3V2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ2MjY3ODUsImV4cCI6MjA3MDIwMjc4NX0.uIrk_RMpPaaR2EXSU2YZ-nHvj2Ez5_Wl-3sETF9Tupg';

  // Chave service_role para operações administrativas (deleção)
  static const String _serviceRoleKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZlbGpvYW5ub2dobnBicWhyc3V2Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NDYyNjc4NSwiZXhwIjoyMDcwMjAyNzg1fQ.aHaBE-oyRxAqzYryqvuluwOpReWx5PWtGsaC4FRt6ac';

  /// Headers padrão para requisições ao Supabase
  Map<String, String> get _headers => {
        'apikey': _anonKey,
        'Authorization': 'Bearer $_anonKey',
        'Content-Type': 'application/json',
      };

  /// Upload de imagem para o Supabase Storage
  /// Retorna a URL pública da imagem
  /// Se oldImageUrl for fornecido, remove a imagem antiga automaticamente
  Future<String> uploadImage(File imageFile, String userId,
      {String? oldImageUrl}) async {
    try {
      AppLogger.info('📸 [SUPABASE] Iniciando upload de imagem...');
      AppLogger.info('📸 [SUPABASE] Arquivo: ${imageFile.path}');
      AppLogger.info('📸 [SUPABASE] Usuário: $userId');

      // Verificar se é uma atualização de imagem
      if (oldImageUrl != null && oldImageUrl.isNotEmpty) {
        AppLogger.info('🔄 [SUPABASE] Detectado: Atualização de imagem');
        AppLogger.info(
            '🗑️ [SUPABASE] Imagem anterior será removida: $oldImageUrl');
      } else {
        AppLogger.info('🆕 [SUPABASE] Detectado: Nova imagem');
      }

      // 1. Comprimir imagem se necessário
      final compressedFile = await compressImageIfNeeded(imageFile);

      // 2. Ler o arquivo comprimido como bytes
      final bytes = await compressedFile.readAsBytes();
      AppLogger.info('📸 [SUPABASE] Tamanho final: ${bytes.length} bytes');

      // 2. Gerar nome único para o arquivo
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final randomSuffix = _generateRandomString(6);
      final extension = imageFile.path.split('.').last;
      final fileName = '$timestamp-$randomSuffix.$extension';

      // 3. Caminho no bucket: products/userId/filename
      final filePath = 'products/$userId/$fileName';
      AppLogger.info('📸 [SUPABASE] Caminho: $filePath');

      // 4. Fazer upload via API REST do Supabase
      final uploadUrl = '$_storageUrl/object/$_bucketName/$filePath';
      AppLogger.info('📸 [SUPABASE] URL de upload: $uploadUrl');

      final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      request.headers.addAll(_headers);
      request.headers.remove('Content-Type'); // Remover para multipart

      // Adicionar o arquivo com MIME type correto
      final mimeTypeString = _getMimeType(extension);
      final mimeType = MediaType.parse(mimeTypeString);
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: fileName,
          contentType: mimeType,
        ),
      );

      // 5. Executar upload
      AppLogger.info('📸 [SUPABASE] Executando upload...');
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      AppLogger.info('📸 [SUPABASE] Resposta: ${response.statusCode}');
      AppLogger.info('📸 [SUPABASE] Body: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // 6. Gerar URL pública
        final publicUrl = '$_storageUrl/object/public/$_bucketName/$filePath';
        AppLogger.success('✅ [SUPABASE] Upload concluído: $publicUrl');

        // 7. Se for uma atualização, remover a imagem antiga
        if (oldImageUrl != null && oldImageUrl.isNotEmpty) {
          try {
            AppLogger.info('🗑️ [SUPABASE] Removendo imagem anterior...');
            final deleteSuccess = await deleteImage(oldImageUrl);
            if (deleteSuccess) {
              AppLogger.success(
                  '✅ [SUPABASE] Imagem anterior removida com sucesso');
            } else {
              AppLogger.warning(
                  '⚠️ [SUPABASE] Não foi possível remover a imagem anterior');
            }
          } catch (e) {
            AppLogger.error('💥 [SUPABASE] Erro ao remover imagem anterior', e);
            // Não falhar o processo por erro na deleção da imagem antiga
          }
        }

        return publicUrl;
      } else {
        throw Exception(
            'Erro no upload: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      AppLogger.error('💥 [SUPABASE] Erro no upload de imagem', e);
      rethrow;
    }
  }

  /// Remover imagem do Supabase Storage
  Future<bool> deleteImage(String imageUrl) async {
    try {
      AppLogger.info('🗑️ [SUPABASE] Removendo imagem: $imageUrl');

      // Extrair o caminho do arquivo da URL
      final filePath = _extractFilePathFromUrl(imageUrl);
      if (filePath == null) {
        throw Exception('URL de imagem inválida');
      }

      AppLogger.info('🗑️ [SUPABASE] Caminho do arquivo: $filePath');

      // URL para remoção
      final deleteUrl = '$_storageUrl/object/$_bucketName/$filePath';
      AppLogger.info('🗑️ [SUPABASE] URL de remoção: $deleteUrl');

      // Headers específicos para deleção usando service_role
      final deleteHeaders = {
        'apikey': _serviceRoleKey,
        'Authorization': 'Bearer $_serviceRoleKey',
      };

      // Fazer requisição DELETE com service_role
      final response = await http.delete(
        Uri.parse(deleteUrl),
        headers: deleteHeaders,
      );

      AppLogger.info('🗑️ [SUPABASE] Resposta: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        AppLogger.success('✅ [SUPABASE] Imagem removida com sucesso');
        return true;
      } else {
        AppLogger.warning(
            '⚠️ [SUPABASE] Erro ao remover imagem: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      AppLogger.error('💥 [SUPABASE] Erro ao remover imagem', e);
      return false;
    }
  }

  /// Atualizar imagem (remove a antiga e faz upload da nova)
  Future<String> updateImage(
      File newImage, String userId, String? oldImageUrl) async {
    try {
      AppLogger.info('🔄 [SUPABASE] Atualizando imagem...');

      // Usar o método uploadImage que agora detecta automaticamente se é uma atualização
      final newImageUrl =
          await uploadImage(newImage, userId, oldImageUrl: oldImageUrl);

      AppLogger.success('✅ [SUPABASE] Imagem atualizada com sucesso');
      return newImageUrl;
    } catch (e) {
      AppLogger.error('💥 [SUPABASE] Erro ao atualizar imagem', e);
      rethrow;
    }
  }

  /// Listar imagens de um usuário
  Future<List<String>> listUserImages(String userId) async {
    try {
      AppLogger.info('📋 [SUPABASE] Listando imagens do usuário: $userId');

      final listUrl =
          '$_storageUrl/object/list/$_bucketName?prefix=products/$userId/';
      AppLogger.info('📋 [SUPABASE] URL de listagem: $listUrl');

      final response = await http.get(
        Uri.parse(listUrl),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final files = data['data'] as List<dynamic>;

        final imageUrls = files.map((file) {
          final fileName = file['name'] as String;
          return '$_storageUrl/object/public/$_bucketName/$fileName';
        }).toList();

        AppLogger.success(
            '✅ [SUPABASE] ${imageUrls.length} imagens encontradas');
        return imageUrls;
      } else {
        AppLogger.warning(
            '⚠️ [SUPABASE] Erro ao listar imagens: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      AppLogger.error('💥 [SUPABASE] Erro ao listar imagens', e);
      return [];
    }
  }

  /// Verificar se uma imagem existe
  Future<bool> imageExists(String imageUrl) async {
    try {
      final filePath = _extractFilePathFromUrl(imageUrl);
      if (filePath == null) return false;

      final infoUrl = '$_storageUrl/object/info/$_bucketName/$filePath';

      final response = await http.get(
        Uri.parse(infoUrl),
        headers: _headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Gerar string aleatória
  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    final buffer = StringBuffer();

    for (int i = 0; i < length; i++) {
      buffer.write(chars[random % chars.length]);
    }

    return buffer.toString();
  }

  /// Obter MIME type baseado na extensão
  String _getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'svg':
        return 'image/svg+xml';
      case 'bmp':
        return 'image/bmp';
      default:
        return 'image/jpeg';
    }
  }

  /// Extrair caminho do arquivo da URL
  String? _extractFilePathFromUrl(String imageUrl) {
    try {
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;

      AppLogger.info('🔍 [SUPABASE] Debug - pathSegments: $pathSegments');

      // Procurar por 'object' na URL
      final objectIndex = pathSegments.indexOf('object');
      if (objectIndex != -1 && objectIndex + 3 < pathSegments.length) {
        // Pular 'object', 'public' e 'bucket' (product-images)
        // Estrutura: /storage/v1/object/public/product-images/products/userId/filename
        final startIndex = objectIndex + 3;
        final extractedPath = pathSegments.sublist(startIndex).join('/');

        AppLogger.info('🔍 [SUPABASE] Debug - objectIndex: $objectIndex');
        AppLogger.info('🔍 [SUPABASE] Debug - startIndex: $startIndex');
        AppLogger.info('🔍 [SUPABASE] Debug - extractedPath: $extractedPath');

        return extractedPath;
      }

      AppLogger.warning(
          '⚠️ [SUPABASE] Não foi possível extrair caminho da URL: $imageUrl');
      return null;
    } catch (e) {
      AppLogger.error('💥 [SUPABASE] Erro ao extrair caminho da URL', e);
      return null;
    }
  }

  /// Selecionar imagem da galeria ou câmera
  Future<File?> pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);

        // Comprimir automaticamente para 200KB
        final compressedFile = await compressImageIfNeeded(file);

        AppLogger.info('📸 [SUPABASE] Imagem selecionada e comprimida');
        return compressedFile;
      }
      return null;
    } catch (e) {
      AppLogger.error('💥 [SUPABASE] Erro ao selecionar imagem', e);
      return null;
    }
  }

  /// Comprimir imagem para 200KB ou menos
  Future<File> compressImageIfNeeded(File imageFile) async {
    try {
      final fileSize = await imageFile.length();
      const targetSize = 200 * 1024; // 200KB

      AppLogger.info(
          '📸 [SUPABASE] Tamanho original: ${(fileSize / 1024).toStringAsFixed(1)}KB');

      if (fileSize <= targetSize) {
        AppLogger.info(
            '📸 [SUPABASE] Imagem já está no tamanho ideal (≤200KB)');
        return imageFile;
      }

      AppLogger.info('📸 [SUPABASE] Iniciando compressão para 200KB...');

      // Ler a imagem
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        AppLogger.error('💥 [SUPABASE] Não foi possível decodificar a imagem');
        return imageFile;
      }

      // Calcular nova resolução mantendo proporção
      final aspectRatio = image.width / image.height;
      int newWidth = image.width;
      int newHeight = image.height;

      // Redimensionar se a imagem for muito grande
      if (image.width > 1200 || image.height > 1200) {
        if (aspectRatio > 1) {
          newWidth = 1200;
          newHeight = (1200 / aspectRatio).round();
        } else {
          newHeight = 1200;
          newWidth = (1200 * aspectRatio).round();
        }
      }

      // Redimensionar a imagem
      var resizedImage = img.copyResize(
        image,
        width: newWidth,
        height: newHeight,
        interpolation: img.Interpolation.linear,
      );

      AppLogger.info(
          '📸 [SUPABASE] Imagem redimensionada: ${newWidth}x$newHeight');

      // Comprimir com qualidade progressiva
      int quality = 85;
      List<int> compressedBytes = [];

      do {
        compressedBytes = img.encodeJpg(resizedImage, quality: quality);
        AppLogger.info(
            '📸 [SUPABASE] Tentativa com qualidade $quality%: ${(compressedBytes.length / 1024).toStringAsFixed(1)}KB');

        if (compressedBytes.length <= targetSize) {
          break;
        }

        quality -= 10;
        if (quality < 10) {
          // Se ainda não conseguiu, reduzir mais a resolução
          newWidth = (newWidth * 0.8).round();
          newHeight = (newHeight * 0.8).round();
          resizedImage = img.copyResize(
            image,
            width: newWidth,
            height: newHeight,
            interpolation: img.Interpolation.linear,
          );
          quality = 85;
          AppLogger.info(
              '📸 [SUPABASE] Reduzindo resolução para: ${newWidth}x$newHeight');
        }
      } while (compressedBytes.length > targetSize &&
          (newWidth > 300 || newHeight > 300));

      // Criar arquivo temporário com a imagem comprimida
      final tempDir = Directory.systemTemp;
      final tempFile = File(
          '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(compressedBytes);

      final finalSize = await tempFile.length();
      AppLogger.success(
          '✅ [SUPABASE] Compressão concluída: ${(finalSize / 1024).toStringAsFixed(1)}KB (${((fileSize - finalSize) / fileSize * 100).toStringAsFixed(1)}% de redução)');

      return tempFile;
    } catch (e) {
      AppLogger.error('💥 [SUPABASE] Erro ao comprimir imagem', e);
      return imageFile;
    }
  }
}
