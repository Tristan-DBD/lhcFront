import '../../../../core/api/http_client.dart';

class OrderService {
  final HttpClient _httpClient = HttpClient();

  Future<Map<String, dynamic>> createOrder(List<Map<String, dynamic>> items) async {
    return _httpClient.post('/order', body: {
      'items': items,
    });
  }

  Future<Map<String, dynamic>> getMyOrders() async {
    return _httpClient.get('/order/my');
  }

  Future<Map<String, dynamic>> getAllOrders() async {
    return _httpClient.get('/order');
  }

  Future<Map<String, dynamic>> cancelOrder(int orderId) async {
    return _httpClient.delete('/order/$orderId');
  }

  Future<Map<String, dynamic>> getProductionSummary() async {
    return _httpClient.get('/order/summary');
  }

  Future<Map<String, dynamic>> updateOrderStatus(int orderId, String status) async {
    return _httpClient.patch('/order/$orderId/status', body: {'status': status});
  }
}
