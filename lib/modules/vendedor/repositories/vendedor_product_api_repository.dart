import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../repositories/vendedor_product_repository.dart';
import '../../cliente/models/product_model.dart';
import '../../../constants/app_constants.dart';
import '../../../core/utils/logger.dart';
import '../../auth/repositories/auth_repository.dart';

class VendedorProductApiRepository implements VendedorProductRepository {
  final AuthRepository _authRepository;

  VendedorProductApiRepository({required AuthRepository authRepository})
      : _authRepository = authRepository;

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authRepository.getToken();
    return {
      'Content-Type': 'application/json',
      'Cache-Control': 'no-cache, no-store, must-revalidate',
      'Pragma': 'no-cache',
      'Expires': '0',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<List<ProductModel>> getAll() async {
    try {
      AppLogger.info('📋 [API] Buscando produtos do vendedor');
      AppLogger.info('🔗 [API] URL: ${AppConstants.listProductsEndpoint}');

      final headers = await _getHeaders();
      AppLogger.info('🔑 [API] Headers: $headers');

      final response = await http
          .get(
            Uri.parse(AppConstants.listProductsEndpoint),
            headers: headers,
          )
          .timeout(const Duration(seconds: 30));

      AppLogger.info(
          '📡 [API] Resposta recebida - Status: ${response.statusCode}');
      AppLogger.info('📄 [API] Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final productsData = responseData['products'] as List;

        final products =
            productsData.map((json) => ProductModel.fromJson(json)).toList();
        AppLogger.success('✅ [API] Produtos carregados: ${products.length}');
        return products;
      } else if (response.statusCode == 401) {
        AppLogger.warning('❌ [API] Não autorizado - Token inválido');
        throw Exception('Sessão expirada. Faça login novamente.');
      } else if (response.statusCode == 403) {
        AppLogger.warning('❌ [API] Acesso negado - Usuário não é vendedor');
        throw Exception('Apenas vendedores podem acessar produtos.');
      } else {
        final errorData = json.decode(response.body);
        AppLogger.error(
            '❌ [API] Erro ao buscar produtos: ${errorData['message']}');
        throw Exception(errorData['message'] ?? 'Erro ao buscar produtos');
      }
    } catch (e) {
      AppLogger.error('💥 [API] Erro ao buscar produtos', e);
      rethrow;
    }
  }

  @override
  Future<ProductModel?> getById(String id) async {
    try {
      AppLogger.info('🔍 [API] Buscando produto: $id');

      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse('${AppConstants.getProductEndpoint}/$id'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final product = ProductModel.fromJson(responseData['product']);
        AppLogger.success('✅ [API] Produto encontrado: ${product.name}');
        return product;
      } else if (response.statusCode == 404) {
        AppLogger.warning('❌ [API] Produto não encontrado: $id');
        return null;
      } else {
        final errorData = json.decode(response.body);
        AppLogger.error(
            '❌ [API] Erro ao buscar produto: ${errorData['message']}');
        throw Exception(errorData['message'] ?? 'Erro ao buscar produto');
      }
    } catch (e) {
      AppLogger.error('💥 [API] Erro ao buscar produto', e);
      rethrow;
    }
  }

  @override
  Future<ProductModel> create(ProductModel item) async {
    try {
      AppLogger.info('📦 [API] Criando produto: ${item.name}');

      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(AppConstants.createProductEndpoint),
        headers: headers,
        body: json.encode(() {
          final Map<String, dynamic> body = {
            'name': item.name,
            'description': item.description,
            'price': item.price,
            'category': item.category,
            'barcode': item.barcode,
            'stock': item.stock,
            'isSoldByWeight': item.isSoldByWeight,
            'isAvailable': item.isAvailable,
          };
          // Somente enviar pricePerKg quando vendido por peso
          if ((item.isSoldByWeight ?? false) && item.pricePerKg != null) {
            body['pricePerKg'] = item.pricePerKg;
          }
          // Enviar imageUrl apenas se não for vazia
          if ((item.imageUrl ?? '').trim().isNotEmpty) {
            body['imageUrl'] = item.imageUrl;
          }
          return body;
        }()),
      ).timeout(const Duration(seconds: 30));

      AppLogger.info(
          '📡 [API] Resposta recebida - Status: ${response.statusCode}');

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        final createdProduct = ProductModel.fromJson(responseData['product']);
        AppLogger.success(
            '✅ [API] Produto criado com sucesso: ${createdProduct.name}');
        return createdProduct;
      } else if (response.statusCode == 409) {
        final errorData = json.decode(response.body);
        AppLogger.warning(
            '❌ [API] Código de barras duplicado: ${errorData['message']}');
        throw Exception(errorData['message']);
      } else if (response.statusCode == 400) {
        final errorData = json.decode(response.body);
        AppLogger.warning('❌ [API] Dados inválidos: ${errorData['details']}');
        throw Exception(
            'Dados inválidos: ${errorData['details']?.first?['msg'] ?? 'Verifique os campos'}');
      } else if (response.statusCode == 500) {
        final errorData = json.decode(response.body);
        AppLogger.error(
            '❌ [API] Erro interno do servidor: ${errorData['message']}');

        // Verificar se é erro de RLS (Row Level Security)
        if (errorData['code'] == '42501' ||
            (errorData['message'] as String)
                .contains('row-level security policy')) {
          throw Exception(
              'Erro de permissão no servidor. Verifique a configuração do banco de dados.');
        }

        throw Exception(errorData['message'] ?? 'Erro interno do servidor');
      } else if (response.statusCode == 503) {
        // Tratamento específico para erro 503 (Service Unavailable)
        AppLogger.error(
            '❌ [API] Serviço indisponível (503) - Servidor em manutenção ou offline');
        throw Exception(
            'Serviço temporariamente indisponível. Tente novamente em alguns minutos ou entre em contato com o suporte.');
      } else {
        // Verificar se a resposta tem conteúdo antes de tentar fazer decode
        if (response.body.isNotEmpty) {
          try {
            final errorData = json.decode(response.body);
            AppLogger.error(
                '❌ [API] Erro ao criar produto: ${errorData['message']}');
            throw Exception(errorData['message'] ?? 'Erro ao criar produto');
          } catch (decodeError) {
            AppLogger.error(
                '❌ [API] Erro ao decodificar resposta: $decodeError');
            throw Exception('Erro inesperado na resposta do servidor');
          }
        } else {
          AppLogger.error(
              '❌ [API] Resposta vazia do servidor - Status: ${response.statusCode}');
          throw Exception(
              'Servidor retornou resposta vazia. Tente novamente ou entre em contato com o suporte.');
        }
      }
    } catch (e) {
      AppLogger.error('💥 [API] Erro ao criar produto', e);
      rethrow;
    }
  }

  @override
  Future<ProductModel> update(ProductModel item) async {
    try {
      AppLogger.info('🔄 [API] Atualizando produto: ${item.name}');

      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('${AppConstants.updateProductEndpoint}/${item.id}'),
        headers: headers,
        body: json.encode(() {
          final Map<String, dynamic> body = {
            'name': item.name,
            'description': item.description,
            'price': item.price,
            'category': item.category,
            'barcode': item.barcode,
            'stock': item.stock,
            'isSoldByWeight': item.isSoldByWeight,
            'isAvailable': item.isAvailable,
          };
          // Somente enviar pricePerKg quando vendido por peso
          if ((item.isSoldByWeight ?? false) && item.pricePerKg != null) {
            body['pricePerKg'] = item.pricePerKg;
          }
          // Enviar imageUrl apenas se não for vazia
          if ((item.imageUrl ?? '').trim().isNotEmpty) {
            body['imageUrl'] = item.imageUrl;
          }
          return body;
        }()),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final updatedProduct = ProductModel.fromJson(responseData['product']);
        AppLogger.success(
            '✅ [API] Produto atualizado com sucesso: ${updatedProduct.name}');
        return updatedProduct;
      } else if (response.statusCode == 404) {
        AppLogger.warning('❌ [API] Produto não encontrado: ${item.id}');
        throw Exception('Produto não encontrado');
      } else if (response.statusCode == 409) {
        final errorData = json.decode(response.body);
        AppLogger.warning(
            '❌ [API] Código de barras duplicado: ${errorData['message']}');
        throw Exception(errorData['message']);
      } else if (response.statusCode == 400) {
        final errorData = json.decode(response.body);
        AppLogger.warning('❌ [API] Dados inválidos: ${errorData['details']}');
        final String message = errorData['details']?.first?['msg'] ??
            errorData['error'] ??
            'Dados inválidos';
        throw Exception(message);
      } else {
        dynamic errorData;
        try {
          errorData = json.decode(response.body);
        } catch (_) {
          errorData = {'raw': response.body};
        }
        AppLogger.error(
            '❌ [API] Erro ao atualizar produto: status=${response.statusCode} body=${response.body}');
        final String message = errorData['message'] ??
            errorData['error'] ??
            errorData['raw'] ??
            'Erro ao atualizar produto';
        throw Exception(message);
      }
    } catch (e) {
      AppLogger.error('💥 [API] Erro ao atualizar produto', e);
      rethrow;
    }
  }

  @override
  Future<bool> delete(String id) async {
    try {
      AppLogger.info('🗑️ [API] Deletando produto: $id');

      final headers = await _getHeaders();
      final response = await http
          .delete(
            Uri.parse('${AppConstants.deleteProductEndpoint}/$id'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        AppLogger.success('✅ [API] Produto deletado com sucesso: $id');
        return true;
      } else if (response.statusCode == 404) {
        AppLogger.warning('❌ [API] Produto não encontrado: $id');
        return false;
      } else if (response.statusCode == 503) {
        // Tratamento específico para erro 503 (Service Unavailable)
        AppLogger.error(
            '❌ [API] Serviço indisponível (503) - Servidor em manutenção ou offline');
        throw Exception(
            'Serviço temporariamente indisponível. Tente novamente em alguns minutos ou entre em contato com o suporte.');
      } else {
        // Verificar se a resposta tem conteúdo antes de tentar fazer decode
        if (response.body.isNotEmpty) {
          try {
            final errorData = json.decode(response.body);
            AppLogger.error(
                '❌ [API] Erro ao deletar produto: ${errorData['message']}');
            throw Exception(errorData['message'] ?? 'Erro ao deletar produto');
          } catch (decodeError) {
            AppLogger.error(
                '❌ [API] Erro ao decodificar resposta: $decodeError');
            throw Exception('Erro inesperado na resposta do servidor');
          }
        } else {
          AppLogger.error(
              '❌ [API] Resposta vazia do servidor - Status: ${response.statusCode}');
          throw Exception(
              'Servidor retornou resposta vazia. Tente novamente ou entre em contato com o suporte.');
        }
      }
    } catch (e) {
      AppLogger.error('💥 [API] Erro ao deletar produto', e);
      rethrow;
    }
  }

  @override
  Future<List<ProductModel>> search(String query) async {
    try {
      AppLogger.info('🔍 [API] Buscando produtos: $query');

      final allProducts = await getAll();
      return allProducts
          .where((product) =>
              (product.name?.toLowerCase().contains(query.toLowerCase()) ??
                  false) ||
              (product.description
                      ?.toLowerCase()
                      .contains(query.toLowerCase()) ??
                  false))
          .toList();
    } catch (e) {
      AppLogger.error('💥 [API] Erro ao buscar produtos', e);
      rethrow;
    }
  }

  @override
  Future<ProductModel?> getProductByBarcode(String barcode) async {
    try {
      AppLogger.info('🔍 [API] Verificando código de barras: $barcode');

      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse('${AppConstants.checkBarcodeEndpoint}/$barcode'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['available'] == true) {
          AppLogger.info('✅ [API] Código de barras disponível: $barcode');
          return null;
        } else {
          final productData = responseData['product'];
          final product = ProductModel.fromJson(productData);
          AppLogger.warning(
              '❌ [API] Código de barras já existe: ${product.name ?? 'Produto sem nome'}');
          return product;
        }
      } else {
        final errorData = json.decode(response.body);
        AppLogger.error(
            '❌ [API] Erro ao verificar código de barras: ${errorData['message']}');
        throw Exception(
            errorData['message'] ?? 'Erro ao verificar código de barras');
      }
    } catch (e) {
      AppLogger.error('💥 [API] Erro ao verificar código de barras', e);
      rethrow;
    }
  }

  @override
  Future<String> saveProductImage(File imageFile) async {
    try {
      AppLogger.info('📸 [API] Iniciando upload de imagem real');
      AppLogger.info('📸 [API] Endpoint: ${AppConstants.uploadImageEndpoint}');
      AppLogger.info('📸 [API] Arquivo: ${imageFile.path}');

      // Verificar se o arquivo existe
      if (!await imageFile.exists()) {
        AppLogger.error(
            '❌ [API] Arquivo de imagem não encontrado: ${imageFile.path}');
        throw Exception('Arquivo de imagem não encontrado');
      }

      final fileSize = await imageFile.length();
      AppLogger.info('📸 [API] Tamanho do arquivo: $fileSize bytes');

      // Obter token de autenticação
      final headers = await _getHeaders();
      AppLogger.info('📸 [API] Headers preparados: ${headers.keys.join(', ')}');

      // Criar requisição multipart
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(AppConstants.uploadImageEndpoint),
      );

      // Adicionar headers de autorização
      request.headers.addAll(headers);
      AppLogger.info('📸 [API] Headers adicionados à requisição');

      // Adicionar arquivo de imagem
      final stream = http.ByteStream(imageFile.openRead());
      final length = await imageFile.length();
      final filename = imageFile.path.split('/').last;

      AppLogger.info('📸 [API] Preparando arquivo multipart:');
      AppLogger.info('   - Nome: $filename');
      AppLogger.info('   - Tamanho: $length bytes');

      final multipartFile = http.MultipartFile(
        'image',
        stream,
        length,
        filename: filename,
      );
      request.files.add(multipartFile);
      AppLogger.info('📸 [API] Arquivo multipart adicionado à requisição');

      AppLogger.info('📤 [API] Enviando imagem para o servidor...');
      AppLogger.info('📤 [API] URL: ${request.url}');
      AppLogger.info('📤 [API] Método: ${request.method}');
      AppLogger.info('📤 [API] Headers finais: ${request.headers}');

      // Fazer upload
      final response =
          await request.send().timeout(const Duration(seconds: 60));
      final responseData = await response.stream.bytesToString();

      AppLogger.info('📥 [API] Resposta do servidor recebida');
      AppLogger.info('📥 [API] Status: ${response.statusCode}');
      AppLogger.info('📥 [API] Headers da resposta: ${response.headers}');
      AppLogger.info(
          '📥 [API] Tamanho da resposta: ${responseData.length} bytes');

      if (responseData.isNotEmpty) {
        AppLogger.info('📥 [API] Corpo da resposta: $responseData');
      }

      if (response.statusCode == 201) {
        final jsonData = json.decode(responseData);
        final imageUrl = jsonData['imageUrl'] as String;

        AppLogger.success('✅ [API] Imagem enviada com sucesso!');
        AppLogger.info('✅ [API] URL da imagem: $imageUrl');
        AppLogger.info('✅ [API] Resposta completa: ${json.encode(jsonData)}');
        return imageUrl;
      } else {
        // Tratar erros específicos
        String errorMessage;
        try {
          final errorData = json.decode(responseData);
          errorMessage = errorData['message'] ?? 'Erro desconhecido no upload';
          AppLogger.error('❌ [API] Erro detalhado: ${json.encode(errorData)}');
        } catch (e) {
          errorMessage = 'Erro ao processar resposta do servidor';
          AppLogger.error('❌ [API] Erro ao decodificar resposta: $e');
        }

        AppLogger.error(
            '❌ [API] Erro no upload: ${response.statusCode} - $errorMessage');

        // Mensagens de erro amigáveis para o usuário
        if (response.statusCode == 400) {
          if (errorMessage.contains('tamanho')) {
            throw Exception('Imagem muito grande. Máximo permitido: 5MB');
          } else if (errorMessage.contains('tipo')) {
            throw Exception(
                'Tipo de arquivo não suportado. Use JPG, PNG, GIF ou WebP');
          } else {
            throw Exception('Dados inválidos: $errorMessage');
          }
        } else if (response.statusCode == 401) {
          throw Exception('Sessão expirada. Faça login novamente');
        } else if (response.statusCode == 413) {
          throw Exception('Imagem muito grande. Máximo permitido: 5MB');
        } else if (response.statusCode >= 500) {
          throw Exception(
              'Erro no servidor. Tente novamente em alguns minutos');
        } else {
          throw Exception('Erro no upload: $errorMessage');
        }
      }
    } catch (e) {
      AppLogger.error('💥 [API] Erro ao fazer upload da imagem', e);
      AppLogger.error('💥 [API] Tipo de erro: ${e.runtimeType}');
      AppLogger.error('💥 [API] Mensagem: ${e.toString()}');

      // Re-throw com mensagem amigável
      if (e.toString().contains('timeout')) {
        throw Exception('Tempo limite excedido. Verifique sua conexão');
      } else if (e.toString().contains('Connection refused')) {
        throw Exception('Servidor não está acessível. Verifique sua conexão');
      } else {
        rethrow;
      }
    }
  }
}
