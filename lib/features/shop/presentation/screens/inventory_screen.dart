import 'package:flutter/material.dart';
import 'dart:io';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/utils/message_service.dart';
import '../widgets/product_inventory_card.dart';
import '../../data/services/shop_service.dart';
import 'athlete_shop_screen.dart';
import '../../../../core/widgets/app_empty_state.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final ShopService _shopService = ShopService();
  List<dynamic> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() => _isLoading = true);
    try {
      final response = await _shopService.getProducts();
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> dataList = response['data'];
        List<dynamic> products = [];

        if (dataList.isNotEmpty && dataList[0]['message'] is List) {
          products = dataList[0]['message'];
        } else {
          products = dataList;
        }

        setState(() {
          _products = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        MessageService.showError(context, 'Erreur lors du chargement : $e');
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStock(int productId, String size, int newQuantity) async {
    if (newQuantity < 0) return;

    // Optimization: OPTIMISTIC LOCAL UPDATE
    final productIndex = _products.indexWhere((p) => p['id'] == productId);
    if (productIndex == -1) return;

    final product = _products[productIndex];
    final stocks = List<dynamic>.from(product['stocks']);
    final stockIndex = stocks.indexWhere((s) => s['size'] == size);
    if (stockIndex == -1) return;

    final oldQuantity = stocks[stockIndex]['quantity'];

    setState(() {
      stocks[stockIndex]['quantity'] = newQuantity;
      _products[productIndex]['stocks'] = stocks;
    });

    try {
      final response = await _shopService.updateStock(
        productId,
        size,
        newQuantity,
      );
      if (response['success'] != true) {
        setState(() {
          stocks[stockIndex]['quantity'] = oldQuantity;
          _products[productIndex]['stocks'] = stocks;
        });
        if (mounted) {
          MessageService.showError(context, 'Erreur synchronisation API');
        }
      }
    } catch (e) {
      setState(() {
        stocks[stockIndex]['quantity'] = oldQuantity;
        _products[productIndex]['stocks'] = stocks;
      });
      if (mounted) {
        MessageService.showError(context, 'Erreur : $e');
      }
    }
  }

  Future<void> _addSize(int productId, String size) async {
    try {
      final response = await _shopService.addSize(productId, size);
      if (response['success'] == true) {
        // Mise à jour locale immédiate
        final productIndex = _products.indexWhere((p) => p['id'] == productId);
        if (productIndex != -1) {
          final newStock = response['data']?[0]?['message'] ?? response['data'];
          setState(() {
            _products[productIndex]['stocks'] = [
              ..._products[productIndex]['stocks'],
              newStock,
            ];
          });
        }
        if (mounted) {
          MessageService.showSuccess(context, 'Taille ajoutée avec succès');
        }
      } else {
        if (mounted) {
          MessageService.showError(
            context,
            response['data']?[0]?['message'] ?? 'Erreur lors de l\'ajout',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        MessageService.showError(context, 'Erreur : $e');
      }
    }
  }

  Future<void> _updateImage(int productId, File image) async {
    // Show local preview immediately would be ideal, but let's sync first to avoid confusion
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Téléchargement de l\'image en cours...')),
      );
    }

    try {
      final response = await _shopService.updateProductImage(productId, image);
      if (response['success'] == true) {
        final productIndex = _products.indexWhere((p) => p['id'] == productId);
        if (productIndex != -1 && mounted) {
          // On récupère le produit mis à jour ou au moins l'imageUri
          final updatedProduct =
              response['data']?[0]?['message'] ?? response['data'];
          setState(() {
            _products[productIndex]['imageUri'] = updatedProduct['imageUri'];
          });
          MessageService.showSuccess(context, 'Image mise à jour');
        }
      } else {
        if (mounted) {
          MessageService.showError(
            context,
            response['data']?[0]?['message'] ?? 'Erreur lors de l\'upload',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        MessageService.showError(context, 'Erreur upload : $e');
      }
    }
  }

  Future<void> _updatePrice(int productId, double newPrice) async {
    if (newPrice < 0) return;

    // Mise à jour optimiste locale
    final productIndex = _products.indexWhere((p) => p['id'] == productId);
    if (productIndex == -1) return;

    final oldPrice = _products[productIndex]['price'];

    setState(() {
      _products[productIndex]['price'] = newPrice;
    });

    try {
      final response = await _shopService.updatePrice(productId, newPrice);
      if (response['success'] != true) {
        setState(() {
          _products[productIndex]['price'] = oldPrice;
        });
        if (mounted) {
          MessageService.showError(context, 'Erreur synchronisation prix');
        }
      }
    } catch (e) {
      setState(() {
        _products[productIndex]['price'] = oldPrice;
      });
      if (mounted) {
        MessageService.showError(context, 'Erreur : $e');
      }
    }
  }

  Future<void> _deleteSize(int productId, String size) async {
    final confirm = await MessageService.showConfirmationDialog(
      context,
      title: 'Confirmation',
      content: 'Voulez-vous vraiment supprimer la taille $size de ce produit ?',
      confirmText: 'Supprimer',
      confirmColor: Colors.red,
    );

    if (confirm) {
      try {
        final response = await _shopService.deleteSize(productId, size);
        if (response['success'] == true) {
          final productIndex = _products.indexWhere((p) => p['id'] == productId);
          if (productIndex != -1) {
            setState(() {
              final stocks = List<dynamic>.from(_products[productIndex]['stocks']);
              stocks.removeWhere((s) => s['size'] == size);
              _products[productIndex]['stocks'] = stocks;
            });
          }
          if (mounted) {
            MessageService.showSuccess(context, 'Taille supprimée');
          }
        } else {
          if (mounted) {
            MessageService.showError(context, response['data']?[0]?['message'] ?? 'Erreur lors de la suppression');
          }
        }
      } catch (e) {
        if (mounted) {
          MessageService.showError(context, 'Erreur : $e');
        }
      }
    }
  }

  Future<void> _deleteProduct(int productId) async {
    final confirm = await MessageService.showConfirmationDialog(
      context,
      title: 'Confirmation',
      content: 'Voulez-vous vraiment supprimer ce produit ?',
      confirmText: 'Supprimer',
      confirmColor: Colors.red,
    );

    if (confirm) {
      try {
        final response = await _shopService.deleteProduct(productId);
        if (response['success'] == true) {
          setState(() {
            _products.removeWhere((p) => p['id'] == productId);
          });
          if (mounted) {
            MessageService.showSuccess(context, 'Produit supprimé');
          }
        }
      } catch (e) {
        if (mounted) {
          MessageService.showError(context, 'Erreur suppression : $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Inventaire & Stock'),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AthleteShopScreen()),
            ),
            icon: const Icon(Icons.remove_red_eye_outlined),
            tooltip: 'Aperçu Boutique',
          ),
          IconButton(
            onPressed: _fetchProducts,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return ProductInventoryCard(
                  product: product,
                  onStockChanged: (size, quantity) => _updateStock(
                    product['id'],
                    size,
                    quantity,
                  ),
                  onPriceChanged: (newPrice) => _updatePrice(
                    product['id'],
                    newPrice,
                  ),
                  onAddSize: (size) => _addSize(product['id'], size),
                  onDeleteSize: (size) => _deleteSize(product['id'], size),
                  onImageUpdate: (image) => _updateImage(product['id'], image),
                  onDelete: () => _deleteProduct(product['id']),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return AppEmptyState(
      icon: Icons.inventory_2_outlined,
      title: 'Aucun produit en stock',
      message: 'Votre inventaire est vide. Ajoutez des produits pour les rendre disponibles.',
      actionButton: AppButton(
        text: 'Créer un produit',
        onPressed: () => Navigator.pop(context),
      ),
    );
  }
}
