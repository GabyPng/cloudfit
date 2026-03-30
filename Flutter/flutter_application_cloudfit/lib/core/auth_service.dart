import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final _client = Supabase.instance.client;

  static User? get currentUser => _client.auth.currentUser;

  static Future<AuthResponse> login(String email, String password) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  static Future<AuthResponse> register(String email, String password) {
    return _client.auth.signUp(email: email, password: password);
  }

  static Future<void> logout() => _client.auth.signOut();

  static String? getIdToken() => _client.auth.currentSession?.accessToken;
}
