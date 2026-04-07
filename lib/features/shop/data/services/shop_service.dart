import 'dart:io';
import 'dart:typed_data';
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

  Future<Map<String, dynamic>> updateProductImage(String productId, {File? image, Uint8List? bytes, String? filename}) async {
    return _httpClient.upload(
      '/shop/$productId/image',
      image,
      'productImage',
      bytes: bytes,
      filename: filename,
    );
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

  Future<Map<String, dynamic>> createProduct(
    Map<String, dynamic> productData, {
    File? imageFile,
    Uint8List? bytes,
    String? filename,
  }) async {
    if (imageFile != null || bytes != null) {
      return _httpClient.upload(
        '/shop',
        imageFile,
        'productImage',
        bytes: bytes,
        filename: filename,
        body: productData,
        method: 'POST',
      );
    }
    return _httpClient.post('/shop', body: productData);
  }
}
