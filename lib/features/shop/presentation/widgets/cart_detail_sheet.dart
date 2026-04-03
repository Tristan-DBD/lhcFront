import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/cart_controller.dart';
import '../../data/services/order_service.dart';
import '../../../../core/utils/message_service.dart';
import '../../../../core/storage/supabase_storage.dart';

class CartDetailSheet extends StatefulWidget {
  const CartDetailSheet({super.key});

  @override
  State<CartDetailSheet> createState() => _CartDetailSheetState();
}

class _CartDetailSheetState extends State<CartDetailSheet> {
  bool _isValidating = false;

  Future<void> _handleCheckout(BuildContext context, CartController cart) async {
    if (cart.items.isEmpty) return;

    final confirm = await MessageService.showConfirmationDialog(
      context,
      title: 'Valider ma commande',
      content:
          'Une fois validée, la commande est enregistrée et sera traitée par votre coach. Voulez-vous continuer ?',
    );

    if (confirm) {
      if (mounted) setState(() => _isValidating = true);
      try {
        final orderService = OrderService();
        final response = await orderService.createOrder(
          cart.items.map((item) => item.toJson()).toList(),
        );

        if (response['success'] == true) {
          if (context.mounted) {
            MessageService.showSuccess(context, 'Commande validée avec succès !');
            cart.clear();
            Navigator.pop(context); // Ferme le panier
          }
        } else {
          if (context.mounted) {
            MessageService.showError(
              context,
              response['data']?[0]?['message'] ?? 'Erreur lors de la commande',
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          MessageService.showError(context, 'Erreur : $e');
        }
      } finally {
        if (mounted) setState(() => _isValidating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Consumer<CartController>(
        builder: (context, cart, _) {
          if (cart.items.isEmpty) {
            return const Center(child: Text('Votre panier est vide'));
          }

          return Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(Icons.shopping_cart_outlined, size: 28),
                    const SizedBox(width: 12),
                    const Text(
                      'Mon Panier',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Items List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: cart.items.length,
                  separatorBuilder: (_, __) => const Divider(height: 32),
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return Row(
                      children: [
                        if (item.imageUri != null && item.imageUri!.isNotEmpty)
                          Container(
                            width: 60,
                            height: 60,
                            margin: const EdgeInsets.only(right: 16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Builder(
                              builder: (context) {
                                final url = SupabaseStorageService().getImageUrlSync(item.imageUri!);
                                if (url.isNotEmpty) {
                                  return Image.network(url, fit: BoxFit.cover);
                                }
                                return const Icon(Icons.image_outlined, size: 24, color: Colors.grey);
                              },
                            ),
                            ),
                          )
                        else
                          Container(
                            width: 60,
                            height: 60,
                            margin: const EdgeInsets.only(right: 16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.image_outlined, size: 24, color: Colors.grey),
                          ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.productName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                'Taille : ${item.size}',
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${item.price.toStringAsFixed(2).replaceAll('.', ',')} € / unité',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            _CompactQuantityButton(
                              icon: Icons.remove,
                              onPressed: () => cart.removeItem(item.productId, item.size),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                '${item.quantity}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            _CompactQuantityButton(
                              icon: Icons.add,
                              onPressed: () => cart.addItem(item.productId, item.productName, item.size, item.price),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Summary & Checkout
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total estimé :', style: TextStyle(fontSize: 16)),
                        Text(
                          '${cart.totalPrice.toStringAsFixed(2).replaceAll('.', ',')} €',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isValidating ? null : () => _handleCheckout(context, cart),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        foregroundColor: Colors.white,
                      ),
                      child: _isValidating
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Valider ma commande', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    TextButton(
                      onPressed: () {
                        cart.clear();
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Vider le panier',
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CompactQuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _CompactQuantityButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 18),
        ),
      ),
    );
  }
}
