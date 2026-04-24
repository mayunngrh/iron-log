import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';
import '../models/register_request.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<SignUpResponse> signup(SignUpRequest request) async {
    final response = await _apiClient.post(Endpoints.signup, request.toJson());
    return SignUpResponse.fromJson(response);
  }

  Future<SignUpResponse> register(SignUpRequest request) async {
    return signup(request);
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    return _apiClient.post(Endpoints.login, {
      'email': email,
      'password': password,
    });
  }
}
