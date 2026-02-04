import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:lhc_front/services/api_service.dart';

class AuthService {
  static login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService().apiUrl}/auth/login'),
        headers: ApiService().headers(),
        body: jsonEncode({'email': email, 'password': password}),
      );

      return jsonDecode(response.body);
    } catch (e) {
      throw e;
    }
  }
}
