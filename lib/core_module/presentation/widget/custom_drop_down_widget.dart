import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatelessWidget {
  final T? selectedValue;
  final List<T>? items;
  final String labelText;
  final ValueChanged<T?> onChanged;
  final String? Function(T?)? validator;

  const CustomDropdown({
    Key? key,
    required this.selectedValue,
    required this.items,
    required this.labelText,
    required this.onChanged,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: selectedValue,
      decoration: InputDecoration(labelText: labelText),
      items: items?.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(item.toString()), // You can customize this based on your object structure.
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }
}
