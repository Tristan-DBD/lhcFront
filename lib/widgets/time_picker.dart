import 'package:flutter/material.dart';
import '../../../../constant/app_colors.dart';

class AppTimePicker extends StatefulWidget {
  final String labelText;
  final String? hintText;
  final TimeOfDay? initialTime;
  final IconData? prefixIcon;
  final TimeOfDay? selectedTime;
  final ValueChanged<TimeOfDay?>? onTimeChanged;
  final String? Function(TimeOfDay?)? validator;

  const AppTimePicker({
    super.key,
    required this.labelText,
    this.hintText,
    this.initialTime,
    this.prefixIcon,
    this.selectedTime,
    this.onTimeChanged,
    this.validator,
  });

  @override
  State<AppTimePicker> createState() => _AppTimePickerState();
}

class _AppTimePickerState extends State<AppTimePicker> {
  late TextEditingController _controller;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.selectedTime ?? widget.initialTime;
    _controller = TextEditingController(
      text: _selectedTime != null 
        ? _formatTime(_selectedTime!)
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
          onTap: _showTimePicker,
          child: AbsorbPointer(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.inputBorder),
                borderRadius: BorderRadius.circular(8.0),
                color: AppColors.inputBackground,
              ),
              child: TextFormField(
                controller: _controller,
                validator: (value) {
                  if (widget.validator != null) {
                    return widget.validator!(_selectedTime);
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: widget.hintText ?? 'Sélectionner une heure',
                  prefixIcon: widget.prefixIcon != null 
                    ? Icon(widget.prefixIcon, color: AppColors.primary)
                    : Icon(Icons.access_time, color: AppColors.primary),
                  suffixIcon: Icon(
                    Icons.arrow_drop_down,
                    color: AppColors.textSecondary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 16.0,
                  ),
                ),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showTimePicker() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.secondary,
              onSurface: AppColors.textPrimary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _controller.text = _formatTime(picked);
      });
      widget.onTimeChanged?.call(picked);
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
