import 'dart:io';
import '../../../../core/api/http_client.dart';

class ShopService {
  final HttpClient _httpClient = HttpClient();

  Future<Map<String, dynamic>> getProducts() async {
    return _httpClient.get('/shop');
  }

  Future<Map<String, dynamic>> updateStock(String productId, String size, int quantity) async {
    return _httpClient.put('/shop/$productId/stock/$size', body: {
      'quantity': quantity,
    });
  }

  Future<Map<String, dynamic>> addSize(String productId, String size) async {
    return _httpClient.post('/shop/$productId/size', body: {
      'size': size,
    });
  }

  Future<Map<String, dynamic>> updateProductImage(String productId, File image) async {
    return _httpClient.upload('/shop/$productId/image', image, 'productImage');
  }

  Future<Map<String, dynamic>> updatePrice(String productId, double price) async {
    return _httpClient.put('/shop/$productId/price', body: {
      'price': price,
    });
  }

  Future<Map<String, dynamic>> deleteSize(String productId, String size) async {
    return _httpClient.delete('/shop/$productId/stock/$size');
  }

  Future<Map<String, dynamic>> deleteProduct(String productId) async {
    return _httpClient.delete('/shop/$productId');
  }

  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> productData, File? imageFile) async {
    if (imageFile != null) {
      return _httpClient.upload(
        '/shop',
        imageFile,
        'productImage',
        body: productData,
        method: 'POST',
      );
    }
    return _httpClient.post('/shop', body: productData);
  }
}
