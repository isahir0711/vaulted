import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.isPassword,
    required this.icon,
    this.hintText,
  });
  final String label;
  final TextEditingController controller;
  final bool? isPassword;
  final IconData icon;
  final String? hintText;

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
              Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
              TextField(
                controller: controller,
                obscureText: isPassword ?? false,
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: hintText,
                  hintStyle: TextStyle(fontSize: 14, color: Color.fromARGB(253, 196, 196, 196)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
