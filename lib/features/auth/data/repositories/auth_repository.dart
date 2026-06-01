import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';
import '../models/register_request.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<SignUpResponse> signup(SignUpRequest request) async {
    final response = await _apiClient.post(Endpoints.signup, request.toJson());
    return SignUpResponse.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<SignUpResponse> register(SignUpRequest request) async {
    return signup(request);
  }

  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    return _apiClient.post(Endpoints.login, {
      'identifier': identifier,
      'password': password,
    });
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otpCode,
  }) async {
    return _apiClient.post(Endpoints.verifyOtp, {
      'email': email,
      'otpCode': otpCode,
    });
  }

  Future<Map<String, dynamic>> resendOtp({
    required String email,
  }) async {
    return _apiClient.post(Endpoints.resendOtp, {
      'email': email,
    });
  }
}
