import 'package:flutter/material.dart';

class AppDateTimePicker extends StatefulWidget {
  final String labelText;
  final String? hintText;
  final DateTime? initialDateTime;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final IconData? prefixIcon;
  final DateTime? selectedDateTime;
  final ValueChanged<DateTime?>? onDateTimeChanged;
  final String? Function(DateTime?)? validator;

  const AppDateTimePicker({
    required this.labelText, super.key,
    this.hintText,
    this.initialDateTime,
    this.firstDate,
    this.lastDate,
    this.prefixIcon,
    this.selectedDateTime,
    this.onDateTimeChanged,
    this.validator,
  });

  @override
  State<AppDateTimePicker> createState() => _AppDateTimePickerState();
}

class _AppDateTimePickerState extends State<AppDateTimePicker> {
  late TextEditingController _controller;
  DateTime? _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _selectedDateTime = widget.selectedDateTime ?? widget.initialDateTime;
    _controller = TextEditingController(
      text: _selectedDateTime != null
          ? _formatDateTime(_selectedDateTime!)
          : '',
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
          onTap: _showDateTimePicker,
          child: AbsorbPointer(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(12.0),
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.shadow.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextFormField(
                controller: _controller,
                validator: (value) {
                  if (widget.validator != null) {
                    return widget.validator!(_selectedDateTime);
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: widget.hintText ?? 'Sélectionner date et heure',
                  prefixIcon: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: widget.prefixIcon != null
                        ? Icon(
                            widget.prefixIcon,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          )
                        : Icon(
                            Icons.event,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                  ),
                  suffixIcon: Container(
                    margin: const EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.calendar_month_outlined,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.7),
                      size: 22,
                    ),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 18.0,
                  ),
                  hintStyle: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    fontSize: 15,
                  ),
                ),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showDateTimePicker() async {
    // D'abord choisir la date
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: widget.firstDate ?? DateTime(1900),
      lastDate: widget.lastDate ?? DateTime(2100),
      locale: const Locale('fr', 'FR'),
      helpText: 'Sélectionner une date',
      cancelText: 'Annuler',
      confirmText: 'Suivant',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Theme.of(context).colorScheme.onPrimary,
              onSurface: Theme.of(context).colorScheme.onSurface,
              surface: Theme.of(context).colorScheme.surface,
            ),
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

    if (selectedDate == null) return;

    // Puis choisir l'heure
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: _selectedDateTime != null
          ? TimeOfDay(
              hour: _selectedDateTime!.hour,
              minute: _selectedDateTime!.minute,
            )
          : TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Theme.of(context).colorScheme.onPrimary,
              onSurface: Theme.of(context).colorScheme.onSurface,
              surface: Theme.of(context).colorScheme.surface,
            ),
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

    if (selectedTime == null) return;

    // Combiner date et heure
    final finalDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    if (finalDateTime != _selectedDateTime) {
      setState(() {
        _selectedDateTime = finalDateTime;
        _controller.text = _formatDateTime(finalDateTime);
      });
      widget.onDateTimeChanged?.call(finalDateTime);
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final date =
        '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
    final time =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return '$date à $time';
  }
}
