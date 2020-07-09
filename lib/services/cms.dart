import 'package:dovy/general.dart';
import 'package:dovy/models/models.dart';
import 'package:hive/hive.dart';

class AuthService {
  Future<Box<String>> get box async {
    final store = GetIt.I<LocalStorage>().store;
    final box = await store.openBox<String>('auth_box');
    return box;
  }

  Future<AuthResponse> login(String id, String password) async {
    final r = await GetIt.I<CmsService>()
        .externalService
        .http
        .post("/auth/local", data: {
      "identifier": id,
      "password": password,
    });

    final authResponse = AuthResponse.fromJson(r.data);
    (await box).put('jwt', authResponse.jwt);
    GetIt.I<CmsService>().token = authResponse.jwt;
    return authResponse;
  }

  Future<bool> get checkUser async {
    final token = (await box).get('jwt');
    if (token != null) {
      GetIt.I<CmsService>().token = token;
    }
    return token != null;
  }

  Future<String> get token async {
    return (await box).get('jwt');
  }

  Future<void> logout() async {
    GetIt.I<CmsService>().externalService.http.interceptors.clear();
    return (await box).delete('jwt');
  }
}

class CmsService {
  static String baseUrl = 'https://servy-4npeq4oexa-ue.a.run.app';
  Strapi externalService = Strapi.newClient()
    ..initialize(
      base_url: baseUrl,
      token: '',
    );

  Future<Map<String, dynamic>> get configs async {
    final d = await externalService.find('configs');
    final configs = d.fold<Map<String, dynamic>>(
      <String, dynamic>{},
      (previousValue, element) {
        final json = element.data;
        previousValue[json['key']] = json['value'];
        return previousValue;
      },
    );
    return configs;
  }

  set token(String jwt) {
    externalService = Strapi.newClient()
      ..initialize(
        base_url: baseUrl,
        token: jwt ?? '',
      );
  }
}
