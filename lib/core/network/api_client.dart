import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../config/app_config.dart';
import '../../features/authentication/data/repositories/token_repository.dart';

part 'api_client.g.dart';

class ApiClient {
  final Dio _dio;

  ApiClient(TokenRepository tokenRepository) : _dio = Dio(BaseOptions(
    baseUrl: AppConfig.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        debugPrint('🌐 [API] Request: ${options.method} ${options.path}');
        
        // Inject JWT Token
        final token = await tokenRepository.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        
        return handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint('✅ [API] Response: ${response.statusCode} from ${response.requestOptions.path}');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        String diagnostic = e.message ?? 'Unknown error';
        
        // Detect browser CORS / Connection Refused
        if (kIsWeb && e.type == DioExceptionType.connectionError) {
          diagnostic = 'Connection Refused/CORS Error. Ensure Spring Boot is running at ${AppConfig.baseUrl} and CORS is enabled.';
        }
        
        debugPrint('❌ [API] Error: $diagnostic');
        return handler.next(e);
      },
    ));
  }

  Dio get dio => _dio;
}

@Riverpod(keepAlive: true)
ApiClient apiClient(ApiClientRef ref) {
  final tokenRepo = ref.watch(tokenRepositoryProvider);
  return ApiClient(tokenRepo);
}
