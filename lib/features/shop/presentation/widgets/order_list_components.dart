import 'package:flutter/material.dart';

class OrderItemRow extends StatelessWidget {
  final Map<String, dynamic> item;

  const OrderItemRow({required this.item, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text('${item['quantity'] ?? 0}x ',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text('${item['product']?['name'] ?? 'Produit'} (${item['size'] ?? 'N/A'})')),
          Text('${(item['price'] ?? 0).toStringAsFixed(2)} €'),
        ],
      ),
    );
  }
}

class OrderTotalRow extends StatelessWidget {
  final double total;
  final Widget? trailing;

  const OrderTotalRow({required this.total, super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: trailing != null ? MainAxisAlignment.spaceBetween : MainAxisAlignment.end,
      children: [
        Text(
          'Total : ${(total).toStringAsFixed(2)} €',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
