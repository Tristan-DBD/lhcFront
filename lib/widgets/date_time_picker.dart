import 'package:flutter/material.dart';
import '../../../../constant/app_colors.dart';

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
    super.key,
    required this.labelText,
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
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _showDateTimePicker,
          child: AbsorbPointer(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.inputBorder, width: 1.5),
                borderRadius: BorderRadius.circular(12.0),
                color: AppColors.inputBackground,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: Offset(0, 2),
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
                    margin: EdgeInsets.only(right: 12),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: widget.prefixIcon != null
                        ? Icon(
                            widget.prefixIcon,
                            color: AppColors.primary,
                            size: 20,
                          )
                        : Icon(Icons.event, color: AppColors.primary, size: 20),
                  ),
                  suffixIcon: Container(
                    margin: EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.calendar_month_outlined,
                      color: AppColors.primary.withValues(alpha: 0.7),
                      size: 22,
                    ),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 18.0,
                  ),
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                    fontSize: 15,
                  ),
                ),
                style: const TextStyle(
                  color: AppColors.textPrimary,
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
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.secondary,
              onSurface: AppColors.textPrimary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
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
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.secondary,
              onSurface: AppColors.textPrimary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
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
