import 'package:flutter/material.dart';
import '../../data/services/order_service.dart';
import '../../../../core/utils/message_service.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../widgets/order_status_badge.dart';
import '../widgets/order_list_components.dart';

class CoachAllOrdersScreen extends StatefulWidget {
  const CoachAllOrdersScreen({super.key});

  @override
  State<CoachAllOrdersScreen> createState() => _CoachAllOrdersScreenState();
}

class _CoachAllOrdersScreenState extends State<CoachAllOrdersScreen> {
  final OrderService _orderService = OrderService();
  List<dynamic> _orders = [];
  bool _isLoading = true;
  String _selectedFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    try {
      final response = await _orderService.getAllOrders();
      if (response['success'] == true) {
        setState(() {
          final List<dynamic> rawOrders = response['data'][0]['message'] ?? [];

          _orders = rawOrders.where((order) {
            final items = order['items'] as List<dynamic>? ?? [];
            final validItems = items
                .where(
                  (item) =>
                      item['product'] != null &&
                      item['product']['name'] != null,
                )
                .toList();
            if (validItems.isNotEmpty) {
              order['items'] = validItems;
              return true;
            }
            return false;
          }).toList();

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) MessageService.showError(context, 'Erreur : $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(int orderId, String newStatus) async {
    final oldOrders = List.from(_orders);

    // Optimistic UI Update
    setState(() {
      final orderIndex = _orders.indexWhere((o) => o['id'] == orderId);
      if (orderIndex != -1) {
        _orders[orderIndex]['status'] = newStatus;
      }
    });

    try {
      final response = await _orderService.updateOrderStatus(
        orderId,
        newStatus,
      );
      if (response['success'] == true) {
        if (mounted) {
          MessageService.showSuccess(context, 'Statut mis à jour !');
        }
      } else {
        // Rollback
        setState(() {
          _orders = oldOrders;
        });
        if (mounted) {
          MessageService.showError(
            context,
            response['data']?[0]?['message'] ?? 'Erreur lors de la mise à jour',
          );
        }
      }
    } catch (e) {
      // Rollback
      setState(() {
        _orders = oldOrders;
      });
      if (mounted) {
        MessageService.showError(context, 'Erreur : $e');
      }
    }
  }

  void _showStatusDialog(Map<String, dynamic> order) {
    final currentStatus = order['status'] ?? 'PENDING';
    final statuses = ['PENDING', 'PROCESSING', 'COMPLETED', 'CANCELLED'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Modifier l\'état (Commande #${order['id']})'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: statuses.map((status) {
              final isCurrent = status == currentStatus;
              return ListTile(
                title: Text(OrderStatusBadge.getLabel(status)),
                leading: Icon(
                  Icons.circle,
                  color: OrderStatusBadge.getColor(status),
                  size: 16,
                ),
                trailing: isCurrent
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  if (!isCurrent) {
                    _updateStatus(order['id'], status);
                  }
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Toutes les commandes'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchOrders),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      _buildFilterChip('Toutes', 'ALL'),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        OrderStatusBadge.getLabel('PENDING'),
                        'PENDING',
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        OrderStatusBadge.getLabel('PROCESSING'),
                        'PROCESSING',
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        OrderStatusBadge.getLabel('COMPLETED'),
                        'COMPLETED',
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        OrderStatusBadge.getLabel('CANCELLED'),
                        'CANCELLED',
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _orders.isEmpty
                      ? _buildEmptyState()
                      : Builder(
                          builder: (context) {
                            final filteredOrders = _selectedFilter == 'ALL'
                                ? _orders
                                : _orders
                                      .where(
                                        (o) =>
                                            (o['status'] ?? 'PENDING') ==
                                            _selectedFilter,
                                      )
                                      .toList();

                            if (filteredOrders.isEmpty) {
                              return const Center(
                                child: Text(
                                  'Aucune commande avec ce statut.',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              );
                            }

                            return ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredOrders.length,
                              itemBuilder: (context, index) {
                                final order = filteredOrders[index];
                                final String status =
                                    order['status'] ?? 'PENDING';
                                final String userName =
                                    order['user']?['name'] ?? 'Athlète inconnu';
                                final String userSurname =
                                    order['user']?['surname'] ?? '';

                                return AppCard(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Commande #${order['id']}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '$userName $userSurname',
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                              ),
                                            ],
                                          ),
                                          OrderStatusBadge(
                                            status: status,
                                            editable: true,
                                            onTap: () =>
                                                _showStatusDialog(order),
                                          ),
                                        ],
                                      ),
                                      const Divider(height: 24),
                                      ...(order['items'] as List).map((item) {
                                        return OrderItemRow(
                                          item: item as Map<String, dynamic>,
                                        );
                                      }),
                                      const Divider(height: 24),
                                      OrderTotalRow(
                                        total: (order['total'] ?? 0).toDouble(),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterChip(String label, String filterValue) {
    final bool isSelected = _selectedFilter == filterValue;
    Color chipColor;
    if (filterValue != 'ALL') {
      chipColor = OrderStatusBadge.getColor(filterValue);
    } else {
      chipColor = Colors.deepPurple;
    }

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : chipColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedColor: chipColor,
      checkmarkColor: Colors.white,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = filterValue;
        });
      },
      backgroundColor: chipColor.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? Colors.transparent : chipColor,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const AppEmptyState(
      icon: Icons.receipt_long_outlined,
      title: 'Aucune commande',
      message: 'La liste des commandes passées par les athlètes est vide.',
    );
  }
}
