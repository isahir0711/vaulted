import 'package:flutter/material.dart';

class AccountCard extends StatefulWidget {
  final String accountType;
  final String username;
  final VoidCallback? onTap;
  const AccountCard({super.key, required this.accountType, required this.username, this.onTap});

  @override
  State<AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends State<AccountCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: MouseRegion(
        onEnter: (_) => setState(() => isHovered = true),
        onExit: (_) => setState(() => isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            margin: const EdgeInsets.only(bottom: 1),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isHovered ? const Color(0xFFF8F9FA) : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Image(
                  height: 36,
                  width: 36,
                  image: AssetImage('assets/${widget.accountType.toLowerCase()}_icon.png'),
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.account_circle, size: 24, color: Color(0xFF6C757D));
                  },
                ),
                const SizedBox(width: 12),
                // Account details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.accountType,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF212529)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.username,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF6C757D)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
