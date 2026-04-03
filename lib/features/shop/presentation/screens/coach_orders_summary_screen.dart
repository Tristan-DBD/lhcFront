import 'package:flutter/material.dart';
import '../../data/services/order_service.dart';
import '../../../../core/utils/message_service.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_empty_state.dart';

class CoachOrdersSummaryScreen extends StatefulWidget {
  const CoachOrdersSummaryScreen({super.key});

  @override
  State<CoachOrdersSummaryScreen> createState() =>
      _CoachOrdersSummaryScreenState();
}

class _CoachOrdersSummaryScreenState extends State<CoachOrdersSummaryScreen> {
  final OrderService _orderService = OrderService();
  List<dynamic> _summary = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSummary();
  }

  Future<void> _fetchSummary() async {
    setState(() => _isLoading = true);
    try {
      final response = await _orderService.getProductionSummary();
      if (response['success'] == true) {
        setState(() {
          final List<dynamic> rawData = response['data'][0]['message'] ?? [];
          _summary = rawData
              .where((item) => item['productName'] != null)
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) MessageService.showError(context, 'Erreur : $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Résumé de Production'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchSummary),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _summary.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _summary.length,
              itemBuilder: (context, index) {
                final item = _summary[index];
                return AppCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      item['productName']?.toString() ?? 'Produit inconnu',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Taille : ${item['size']}'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'x${item['quantity']}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return const AppEmptyState(
      icon: Icons.inventory_2_outlined,
      title: 'Aucune commande à produire',
      message:
          'L\'historique des commandes athlètes est vide ou aucune n\'est en attente de production.',
    );
  }
}
