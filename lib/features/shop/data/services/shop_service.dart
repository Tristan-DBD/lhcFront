import 'dart:io';
import '../../../../core/api/http_client.dart';

class ShopService {
  final HttpClient _httpClient = HttpClient();

  Future<Map<String, dynamic>> getProducts() async {
    return _httpClient.get('/shop');
  }

  Future<Map<String, dynamic>> updateStock(int productId, String size, int quantity) async {
    return _httpClient.put('/shop/$productId/stock/$size', body: {
      'quantity': quantity,
    });
  }

  Future<Map<String, dynamic>> addSize(int productId, String size) async {
    return _httpClient.post('/shop/$productId/size', body: {
      'size': size,
    });
  }

  Future<Map<String, dynamic>> updateProductImage(int productId, File image) async {
    return _httpClient.upload('/shop/$productId/image', image, 'productImage');
  }

  Future<Map<String, dynamic>> updatePrice(int productId, double price) async {
    return _httpClient.put('/shop/$productId/price', body: {
      'price': price,
    });
  }

  Future<Map<String, dynamic>> deleteSize(int productId, String size) async {
    return _httpClient.delete('/shop/$productId/stock/$size');
  }

  Future<Map<String, dynamic>> deleteProduct(int productId) async {
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
