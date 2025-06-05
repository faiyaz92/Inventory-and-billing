import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;

  const StatCard({Key? key, required this.label, required this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
