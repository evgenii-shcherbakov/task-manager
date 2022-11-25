import 'package:injectable/injectable.dart';

import '../dtos/auth.dto.dart';
import '../models/user.dart';
import 'base/base.repository.dart';

@LazySingleton()
class AuthRepository extends BaseRepository {
  AuthRepository(super.httpClient);

  @override
  String get endpoint => 'auth';

  Future<AuthDto> refreshToken() async {
    return AuthDto.fromJSON(await post<Map<String, dynamic>>(path: 'refresh'));
  }

  Future<AuthDto> register(User user) async {
    return AuthDto.fromJSON(
        await post<Map<String, dynamic>>(
            path: 'register',
            body: user.toJson()
        )
    );
  }

  Future<AuthDto> login(String email, String password) async {
    return AuthDto.fromJSON(
        await post<Map<String, dynamic>>(
            path: 'login',
            body: { 'email': email, 'password': password }
        )
    );
  }
}