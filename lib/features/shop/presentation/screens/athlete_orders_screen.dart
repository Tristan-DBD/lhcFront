import 'package:flutter/material.dart';
import '../../data/services/order_service.dart';
import '../../../../core/utils/message_service.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../widgets/order_status_badge.dart';
import '../widgets/order_list_components.dart';

class AthleteOrdersScreen extends StatefulWidget {
  const AthleteOrdersScreen({super.key});

  @override
  State<AthleteOrdersScreen> createState() => _AthleteOrdersScreenState();
}

class _AthleteOrdersScreenState extends State<AthleteOrdersScreen> {
  final OrderService _orderService = OrderService();
  List<dynamic> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    try {
      final response = await _orderService.getMyOrders();
      if (response['success'] == true) {
        setState(() {
          final List<dynamic> rawOrders = response['data'][0]['message'] ?? [];

          _orders = rawOrders.where((order) {
            final items = order['items'] as List<dynamic>? ?? [];
            // Ne garder que les items avec un produit valide
            final validItems = items
                .where(
                  (item) =>
                      item['product'] != null &&
                      item['product']['name'] != null,
                )
                .toList();

            if (validItems.isNotEmpty) {
              order['items'] = validItems; // Remplacer par la liste nettoyée
              return true;
            }
            return false; // L'ordre n'a aucun article valide, on l'ignore
          }).toList();

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) MessageService.showError(context, 'Erreur : $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cancelOrder(String orderId) async {
    final confirm = await MessageService.showConfirmationDialog(
      context,
      title: 'Annuler la commande',
      content: 'Êtes-vous sûr de vouloir annuler cette commande ?',
    );

    if (confirm) {
      try {
        final response = await _orderService.cancelOrder(orderId);
        if (response['success'] == true) {
          if (mounted) {
            MessageService.showSuccess(context, 'Commande annulée');
            _fetchOrders();
          }
        }
      } catch (e) {
        if (mounted) MessageService.showError(context, 'Erreur : $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes Commandes')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                final order = _orders[index];
                final String status = order['status'] ?? 'PENDING';
                final bool canCancel = status.toUpperCase() == 'PENDING';

                return AppCard(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Statut:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          OrderStatusBadge(status: status),
                        ],
                      ),
                      const Divider(height: 24),
                      ...(order['items'] as List? ?? []).map((item) {
                        return OrderItemRow(item: item as Map<String, dynamic>);
                      }),
                      const Divider(height: 24),
                      OrderTotalRow(
                        total: (order['total'] ?? 0).toDouble(),
                        trailing: canCancel
                            ? TextButton.icon(
                                onPressed: () => _cancelOrder(order['id']),
                                icon: const Icon(
                                  Icons.cancel_outlined,
                                  size: 18,
                                ),
                                label: const Text('Annuler'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return const AppEmptyState(
      icon: Icons.history,
      title: 'Aucune commande',
      message: 'Vous n\'avez passé aucune commande pour le moment.',
    );
  }
}
