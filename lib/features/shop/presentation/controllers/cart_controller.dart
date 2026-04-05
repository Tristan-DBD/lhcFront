import 'package:flutter/material.dart';

class CartItem {
  final String productId;
  final String productName;
  final String size;
  final double price;
  final String? imageUri;
  int quantity;

  CartItem({
    required this.productId,
    required this.productName,
    required this.size,
    required this.price,
    this.imageUri,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'size': size,
    'quantity': quantity,
  };
}

class CartController extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();

  int get totalItems => _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => _items.values.fold(0, (sum, item) => sum + (item.price * item.quantity));

  int getItemQuantity(String productId, String size) {
    final key = '${productId}_$size';
    return _items[key]?.quantity ?? 0;
  }

  void addItem(String productId, String productName, String size, double price, [String? imageUri]) {
    final key = '${productId}_$size';
    if (_items.containsKey(key)) {
      _items[key]!.quantity += 1;
    } else {
      _items[key] = CartItem(
        productId: productId,
        productName: productName,
        size: size,
        price: price,
        imageUri: imageUri,
      );
    }
    notifyListeners();
  }

  void removeItem(String productId, String size) {
    final key = '${productId}_$size';
    if (_items.containsKey(key)) {
      if (_items[key]!.quantity > 1) {
        _items[key]!.quantity -= 1;
      } else {
        _items.remove(key);
      }
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
