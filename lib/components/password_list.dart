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
      padding: const EdgeInsets.symmetric(horizontal: 12),
      width: 300,
      child: passwords.isEmpty
          ? const Center(child: Text('No passwords found'))
          : ListView.separated(
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemCount: passwords.length,
              itemBuilder: (BuildContext context, int index) {
                return AccountCard(
                  accountType: passwords[index].accountType.name,
                  username: passwords[index].userNameOrEmail,
                  onTap: () => onPasswordSelected(passwords[index]),
                );
              },
            ),
    );
  }
}
