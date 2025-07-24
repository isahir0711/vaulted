import 'package:flutter/material.dart';
import 'package:vaulted/components/account_card.dart';
import 'package:vaulted/models/password.dart';

class PasswordList extends StatelessWidget {
  final List<Password> passwords;
  final Function(Password) onPasswordSelected;

  const PasswordList({super.key, required this.passwords, required this.onPasswordSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFE9ECEF), width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'All items',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF212529)),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    '${passwords.length}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF6C757D)),
                  ),
                ),
              ],
            ),
          ),
          // Password list
          Expanded(
            child: passwords.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock_outline, size: 48, color: Color(0xFFADB5BD)),
                        SizedBox(height: 16),
                        Text('No passwords found', style: TextStyle(fontSize: 16, color: Color(0xFF6C757D))),
                        SizedBox(height: 8),
                        Text(
                          'Add your first password to get started',
                          style: TextStyle(fontSize: 14, color: Color(0xFFADB5BD)),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: passwords.length,
                    itemBuilder: (BuildContext context, int index) {
                      return AccountCard(
                        accountType: passwords[index].accountType.name,
                        username: passwords[index].userNameOrEmail,
                        onTap: () => onPasswordSelected(passwords[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
