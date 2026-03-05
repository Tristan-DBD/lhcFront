import 'package:flutter/material.dart';
import '../../../../core/widgets/app_card.dart';

class PaymentHistoryGrid extends StatefulWidget {
  final Map<String, bool> initialPayments;
  final bool isEditable;
  final Function(String month)? onMonthTap;

  const PaymentHistoryGrid({
    required this.initialPayments,
    super.key,
    this.isEditable = false,
    this.onMonthTap,
  });

  @override
  State<PaymentHistoryGrid> createState() => _PaymentHistoryGridState();
}

class _PaymentHistoryGridState extends State<PaymentHistoryGrid> {
  late Map<String, bool> _payments;

  @override
  void initState() {
    super.initState();
    _payments = Map<String, bool>.from(widget.initialPayments);
  }

  @override
  void didUpdateWidget(covariant PaymentHistoryGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialPayments != oldWidget.initialPayments) {
      setState(() {
        _payments = Map<String, bool>.from(widget.initialPayments);
      });
    }
  }

  static const List<String> months = [
    'jan',
    'feb',
    'mar',
    'apr',
    'may',
    'jun',
    'jul',
    'aug',
    'sep',
    'oct',
    'nov',
    'dec',
  ];

  static const List<String> monthLabels = [
    'J',
    'F',
    'M',
    'A',
    'M',
    'J',
    'J',
    'A',
    'S',
    'O',
    'N',
    'D',
  ];

  void _toggleMonth(String month) {
    setState(() {
      _payments[month] = !(_payments[month] ?? false);
    });
    widget.onMonthTap?.call(month);
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Historique des paiements',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              if (widget.isEditable)
                Text(
                  'Cliquer pour modifier',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            itemCount: 12,
            itemBuilder: (context, index) {
              final monthKey = months[index];
              final isPaid = _payments[monthKey] ?? false;
              return _buildMonthCell(index, isPaid, monthKey);
            },
          ),
          const SizedBox(height: 12),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildMonthCell(int index, bool isPaid, String monthKey) {
    final isCurrentMonth = DateTime.now().month == index + 1;

    Color backgroundColor;
    Color textColor;

    if (isPaid) {
      backgroundColor = const Color(0xFF66BB6A);
      textColor = Colors.white;
    } else {
      backgroundColor = const Color(0xFFEF5350);
      textColor = Colors.white;
    }

    final Widget cellContent = Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: isCurrentMonth
            ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
            : (widget.isEditable
                  ? Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.5),
                    )
                  : null),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(isPaid ? Icons.check : Icons.close, color: textColor, size: 18),
          const SizedBox(height: 1),
          Text(
            monthLabels[index],
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );

    if (widget.isEditable) {
      return GestureDetector(
        onTap: () => _toggleMonth(monthKey),
        child: cellContent,
      );
    }

    return cellContent;
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(const Color(0xFF66BB6A), 'Payé'),
        const SizedBox(width: 24),
        _buildLegendItem(const Color(0xFFEF5350), 'Non payé'),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
