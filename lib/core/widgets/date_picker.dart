import 'package:flutter/material.dart';

class AppDatePicker extends StatefulWidget {
  final String labelText;
  final String? hintText;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final IconData? prefixIcon;
  final DateTime? selectedDate;
  final ValueChanged<DateTime?>? onDateChanged;
  final String? Function(DateTime?)? validator;

  const AppDatePicker({
    required this.labelText, super.key,
    this.hintText,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.prefixIcon,
    this.selectedDate,
    this.onDateChanged,
    this.validator,
  });

  @override
  State<AppDatePicker> createState() => _AppDatePickerState();
}

class _AppDatePickerState extends State<AppDatePicker> {
  late TextEditingController _controller;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate ?? widget.initialDate;
    _controller = TextEditingController(
      text: _selectedDate != null ? _formatDate(_selectedDate!) : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.labelText,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _showDatePicker,
          child: AbsorbPointer(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
                borderRadius: BorderRadius.circular(8.0),
                color: Theme.of(context).colorScheme.surface,
              ),
              child: TextFormField(
                controller: _controller,
                validator: (value) {
                  if (widget.validator != null) {
                    return widget.validator!(_selectedDate);
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: widget.hintText ?? 'Sélectionner une date',
                  prefixIcon: widget.prefixIcon != null
                      ? Icon(
                          widget.prefixIcon,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : Icon(
                          Icons.calendar_today,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  suffixIcon: Icon(
                    Icons.arrow_drop_down,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 16.0,
                  ),
                ),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: widget.firstDate ?? DateTime(1900),
      lastDate: widget.lastDate ?? DateTime(2100),
      locale: const Locale('fr', 'FR'),
      helpText: 'Sélectionner une date',
      cancelText: 'Annuler',
      confirmText: 'Valider',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _controller.text = _formatDate(picked);
      });
      widget.onDateChanged?.call(picked);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
