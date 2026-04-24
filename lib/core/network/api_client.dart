import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

class ApiClient {
  static const String _apiKey = 'cclsdjfzdfjahsdfakl;jcnc6969';
  static const bool _debugMode = true; // Set to false in production
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> _buildHeaders() => {
    'Content-Type': 'application/json',
    'x-api-key': _apiKey,
  };

  void _log(String title, dynamic data) {
    if (!_debugMode) return;
    developer.log(
      '═══════════════════════════════════════════════════════',
      name: 'IronLog.API',
    );
    developer.log('$title:', name: 'IronLog.API');
    developer.log(
      data is String ? data : jsonEncode(data),
      name: 'IronLog.API',
    );
    developer.log(
      '═══════════════════════════════════════════════════════',
      name: 'IronLog.API',
    );
  }

  Future<Map<String, dynamic>> post(
    String url,
    Map<String, dynamic> body,
  ) async {
    _log('📤 POST REQUEST', {
      'url': url,
      'headers': _buildHeaders(),
      'body': body,
    });

    final response = await _client.post(
      Uri.parse(url),
      headers: _buildHeaders(),
      body: jsonEncode(body),
    );

    _log('📥 POST RESPONSE', {
      'statusCode': response.statusCode,
      'body': response.body,
    });

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 400) {
      final message = decoded['error']?.toString() ??
          decoded['message']?.toString() ??
          'Request failed';
      _log('❌ API ERROR', {
        'statusCode': response.statusCode,
        'message': message,
        'fullResponse': decoded,
      });
      throw ApiException(
        statusCode: response.statusCode,
        message: message,
      );
    }

    return decoded;
  }

  Future<Map<String, dynamic>> get(String url) async {
    _log('📤 GET REQUEST', {
      'url': url,
      'headers': _buildHeaders(),
    });

    final response = await _client.get(
      Uri.parse(url),
      headers: _buildHeaders(),
    );

    _log('📥 GET RESPONSE', {
      'statusCode': response.statusCode,
      'body': response.body,
    });

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 400) {
      final message = decoded['error']?.toString() ??
          decoded['message']?.toString() ??
          'Request failed';
      _log('❌ API ERROR', {
        'statusCode': response.statusCode,
        'message': message,
        'fullResponse': decoded,
      });
      throw ApiException(
        statusCode: response.statusCode,
        message: message,
      );
    }

    return decoded;
  }

  void dispose() => _client.close();
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
