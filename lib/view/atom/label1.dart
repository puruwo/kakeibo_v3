import 'package:flutter/material.dart';

class Label1Widget extends StatelessWidget {
  const Label1Widget({required this.label, super.key});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
    padding: const EdgeInsets.all(8),
    alignment: Alignment.center,
    child: Text(
      label,
      style: const TextStyle(fontWeight: FontWeight.bold),
    ),
  );;
  }
}