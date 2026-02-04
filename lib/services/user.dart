import 'dart:convert';

import 'package:lhc_front/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:lhc_front/services/storage.dart';

class UserService {
  static create(userData) async {
    try {
      final user = await http.post(
        Uri.parse('${ApiService().apiUrl}/user'),
        headers: ApiService().headers(token: await StorageService.getToken()),
        body: jsonEncode(userData),
      );
      return jsonDecode(user.body);
    } catch (e) {
      throw e;
    }
  }

  static getAll() async {
    try {
      final users = await http.get(
        Uri.parse('${ApiService().apiUrl}/user'),
        headers: ApiService().headers(token: await StorageService.getToken()),
      );
      return jsonDecode(users.body);
    } catch (e) {
      throw e;
    }
  }
}
