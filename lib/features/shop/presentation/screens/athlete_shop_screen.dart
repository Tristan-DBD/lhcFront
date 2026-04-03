import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/utils/message_service.dart';
import '../../../../core/storage/supabase_storage.dart';
import '../controllers/cart_controller.dart';
import '../../data/services/shop_service.dart';
import '../widgets/cart_summary_bar.dart';
import 'athlete_orders_screen.dart';

class AthleteShopScreen extends StatefulWidget {
  const AthleteShopScreen({super.key});

  @override
  State<AthleteShopScreen> createState() => _AthleteShopScreenState();
}

class _AthleteShopScreenState extends State<AthleteShopScreen> {
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
        MessageService.showError(context, 'Erreur chargement : $e');
      }
      setState(() => _isLoading = false);
    }
  }

  void _showProductDetails(Map<String, dynamic> product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductDetailSheet(product: product),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Boutique Athlète'),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AthleteOrdersScreen()),
            ),
            icon: const Icon(Icons.history),
            tooltip: 'Mes commandes',
          ),
          IconButton(
            onPressed: _fetchProducts,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _products.isEmpty
                  ? const Center(child: Text('Aucun produit disponible'))
                  : GridView.builder(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 16,
                        bottom: 120,
                      ),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        return ProductGridCard(
                          product: _products[index],
                          onTap: () => _showProductDetails(_products[index]),
                        );
                      },
                    ),
          const Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: CartSummaryBar(),
          ),
        ],
      ),
    );
  }
}

class ProductGridCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onTap;

  const ProductGridCard({
    required this.product,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final String name = product['name'] ?? 'Inconnu';
    final double price = (product['price'] ?? 0).toDouble();
    final String? imageUri = product['imageUri'];

    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Container
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: imageUri != null
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Builder(
                        builder: (context) {
                          final url = SupabaseStorageService().getImageUrlSync(imageUri);
                          if (url.isNotEmpty) {
                            return Image.network(url, fit: BoxFit.cover);
                          }
                          return const Icon(Icons.image_outlined, size: 32, color: Colors.grey);
                        },
                      ),
                    )
                  : const Icon(Icons.image_outlined, size: 32, color: Colors.grey),
            ),
          ),
          // Info Info
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  '${price.toStringAsFixed(2).replaceAll('.', ',')} €',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProductDetailSheet extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailSheet({required this.product, super.key});

  @override
  State<ProductDetailSheet> createState() => _ProductDetailSheetState();
}

class _ProductDetailSheetState extends State<ProductDetailSheet> {
  String? _selectedSize;
  bool _isAdding = false;

  @override
  Widget build(BuildContext context) {
    final stocks = widget.product['stocks'] as List<dynamic>? ?? [];
    final String name = widget.product['name'] ?? 'Inconnu';
    final double price = (widget.product['price'] ?? 0).toDouble();
    final String? imageUri = widget.product['imageUri'];

    // Stock for selected size
    int currentStock = 0;
    if (_selectedSize != null) {
      final stock = stocks.firstWhere((s) => s['size'] == _selectedSize, orElse: () => null);
      currentStock = stock?['quantity'] ?? 0;
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          // Image & Details
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: imageUri != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Builder(
                            builder: (context) {
                              final url = SupabaseStorageService().getImageUrlSync(imageUri);
                              if (url.isNotEmpty) {
                                return Image.network(url, fit: BoxFit.cover);
                              }
                              return const Icon(Icons.image);
                            },
                          ),
                        )
                      : const Icon(Icons.image),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${price.toStringAsFixed(2).replaceAll('.', ',')} €',
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          
          // Size Selection
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Choisir une taille :',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 45,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: stocks.map((s) {
                final String size = s['size'];
                final isSelected = _selectedSize == size;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ChoiceChip(
                    label: Text(size),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedSize = selected ? size : null);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // Stock Info
          if (_selectedSize != null && currentStock <= 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.orange.shade800),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Produit sur commande. Un délai de production est à prévoir.',
                        style: TextStyle(fontSize: 12, color: Colors.orange, fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 32),

          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Consumer<CartController>(
              builder: (context, cart, _) {
                final quantity = _selectedSize != null 
                    ? cart.getItemQuantity(widget.product['id'], _selectedSize!)
                    : 0;

                return Row(
                  children: [
                    if (quantity > 0)
                      Expanded(
                        child: Row(
                          children: [
                            _QuantityButton(
                              icon: Icons.remove,
                              onPressed: () => cart.removeItem(widget.product['id'], _selectedSize!),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                '$quantity',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            _QuantityButton(
                              icon: Icons.add,
                              onPressed: () => cart.addItem(widget.product['id'], name, _selectedSize!, price, imageUri),
                            ),
                          ],
                        ),
                      ),
                    
                    if (quantity == 0)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _selectedSize == null || _isAdding 
                              ? null 
                              : () async {
                                  setState(() => _isAdding = true);
                                  cart.addItem(widget.product['id'], name, _selectedSize!, price, imageUri);
                                  await Future.delayed(const Duration(milliseconds: 500));
                                  if (mounted) setState(() => _isAdding = false);
                                },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          ),
                          child: _isAdding 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Ajouter au panier'),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _QuantityButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 44,
          height: 44,
          child: Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
    );
  }
}
