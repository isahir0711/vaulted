import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.isPassword,
    required this.icon,
  });
  final String label;
  final TextEditingController controller;
  final bool isPassword;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 12,
      children: [
        //Icon column
        Column(children: [Icon(icon)]),
        //Label and input column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label),
              TextField(
                controller: controller,
                obscureText: isPassword,
                decoration: InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(4)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
