import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import '../../constants/app_constants.dart';
import '../../core/utils/logger.dart';

/// Serviço para gerenciar imagens diretamente com o Supabase Storage
class SupabaseImageService {
  static const String _bucketName = 'product-images';
  static const String _baseUrl = 'https://feljoannoghnpbqhrsuv.supabase.co';
  static const String _storageUrl = '$_baseUrl/storage/v1';
  static const String _anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZlbGpvYW5ub2dobnBicWhyc3V2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ2MjY3ODUsImV4cCI6MjA3MDIwMjc4NX0.uIrk_RMpPaaR2EXSU2YZ-nHvj2Ez5_Wl-3sETF9Tupg';

  /// Headers padrão para requisições ao Supabase
  Map<String, String> get _headers => {
        'apikey': _anonKey,
        'Authorization': 'Bearer $_anonKey',
        'Content-Type': 'application/json',
      };

  /// Upload de imagem para o Supabase Storage
  /// Retorna a URL pública da imagem
  Future<String> uploadImage(File imageFile, String userId) async {
    try {
      AppLogger.info('📸 [SUPABASE] Iniciando upload de imagem...');
      AppLogger.info('📸 [SUPABASE] Arquivo: ${imageFile.path}');
      AppLogger.info('📸 [SUPABASE] Usuário: $userId');

      // 1. Ler o arquivo como bytes
      final bytes = await imageFile.readAsBytes();
      AppLogger.info('📸 [SUPABASE] Tamanho: ${bytes.length} bytes');

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

      // Fazer requisição DELETE
      final response = await http.delete(
        Uri.parse(deleteUrl),
        headers: _headers,
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

      // 1. Remover imagem antiga se existir
      if (oldImageUrl != null && oldImageUrl.isNotEmpty) {
        AppLogger.info('🗑️ [SUPABASE] Removendo imagem antiga...');
        await deleteImage(oldImageUrl);
      }

      // 2. Fazer upload da nova imagem
      AppLogger.info('📸 [SUPABASE] Fazendo upload da nova imagem...');
      final newImageUrl = await uploadImage(newImage, userId);

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

      // Procurar por 'object' e 'public' na URL
      final objectIndex = pathSegments.indexOf('object');
      if (objectIndex != -1 && objectIndex + 2 < pathSegments.length) {
        // Pular 'object' e 'public' ou 'bucket'
        final startIndex = objectIndex + 2;
        return pathSegments.sublist(startIndex).join('/');
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Selecionar imagem da galeria ou câmera
  Future<File?> pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      AppLogger.error('💥 [SUPABASE] Erro ao selecionar imagem', e);
      return null;
    }
  }

  /// Comprimir imagem se necessário
  Future<File> compressImageIfNeeded(File imageFile) async {
    try {
      final fileSize = await imageFile.length();
      final maxSize = 2 * 1024 * 1024; // 2MB

      if (fileSize <= maxSize) {
        AppLogger.info('📸 [SUPABASE] Imagem não precisa de compressão');
        return imageFile;
      }

      AppLogger.info('📸 [SUPABASE] Comprimindo imagem...');

      // Para simplicidade, retornamos o arquivo original
      // Em produção, você pode implementar compressão real
      AppLogger.warning(
          '⚠️ [SUPABASE] Compressão não implementada, usando arquivo original');
      return imageFile;
    } catch (e) {
      AppLogger.error('💥 [SUPABASE] Erro ao comprimir imagem', e);
      return imageFile;
    }
  }
}
