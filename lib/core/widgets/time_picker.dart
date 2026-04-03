import 'package:flutter/material.dart';

class AppTimePicker extends StatefulWidget {
  final String labelText;
  final String? hintText;
  final TimeOfDay? initialTime;
  final IconData? prefixIcon;
  final TimeOfDay? selectedTime;
  final ValueChanged<TimeOfDay?>? onTimeChanged;
  final String? Function(TimeOfDay?)? validator;

  const AppTimePicker({
    required this.labelText, super.key,
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
      text: _selectedTime != null ? _formatTime(_selectedTime!) : '',
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
          onTap: _showTimePicker,
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
                    return widget.validator!(_selectedTime);
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: widget.hintText ?? 'Sélectionner une heure',
                  prefixIcon: widget.prefixIcon != null
                      ? Icon(
                          widget.prefixIcon,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : Icon(
                          Icons.access_time,
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

  Future<void> _showTimePicker() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
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
