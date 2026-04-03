import 'package:flutter/material.dart';

class GenericDropdown<T> extends StatefulWidget {
  final List<T> items;
  final String Function(T item) displayString;
  final void Function(T item) onSelected;
  final T? selectedItem;
  final String? hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final Widget Function(T item)? leadingWidget;
  final String? Function(T? value)? validator;

  const GenericDropdown({
    required this.items, required this.displayString, required this.onSelected, super.key,
    this.selectedItem,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.leadingWidget,
    this.validator,
  });

  @override
  State<GenericDropdown<T>> createState() => _GenericDropdownState<T>();
}

class _GenericDropdownState<T> extends State<GenericDropdown<T>> {
  T? _selectedItem;

  @override
  void initState() {
    super.initState();
    // Vérifier si selectedItem est dans la liste des items
    if (widget.selectedItem != null &&
        widget.items.contains(widget.selectedItem)) {
      _selectedItem = widget.selectedItem;
    } else {
      _selectedItem = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: _selectedItem,
      decoration: InputDecoration(
        labelText: widget.labelText ?? 'Sélectionner une option',
        hintText: widget.hintText ?? 'Choisir...',
        prefixIcon: widget.prefixIcon != null
            ? Icon(
                widget.prefixIcon,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      items: widget.items.map((T item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.leadingWidget != null) widget.leadingWidget!(item),
              if (widget.leadingWidget != null) const SizedBox(width: 12),
              Flexible(
                child: Text(
                  widget.displayString(item),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (T? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedItem = newValue;
          });
          widget.onSelected(newValue);
        }
      },
      validator: widget.validator,
    );
  }
}
