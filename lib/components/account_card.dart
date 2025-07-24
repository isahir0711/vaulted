import 'package:flutter/material.dart';

class AccountCard extends StatefulWidget {
  final String accountType;
  final VoidCallback? onTap;
  const AccountCard({super.key, required this.accountType, this.onTap});

  @override
  State<AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends State<AccountCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isHovered ? const Color.fromARGB(40, 158, 158, 158) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Column(
                children: [
                  Image(
                    height: 36,
                    width: 36,
                    image: AssetImage('assets/${widget.accountType.toLowerCase()}_icon.png'),
                  ),
                ],
              ),
              SizedBox(width: 16),
              Column(
                children: [
                  Row(children: [Text(widget.accountType)]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
