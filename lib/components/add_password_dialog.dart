import 'package:flutter/material.dart';
import 'package:vaulted/enums/account_types.dart';

class AddPasswordDialog extends StatefulWidget {
  final Function(String password, String username, AccountTypes accountType) onSave;

  const AddPasswordDialog({super.key, required this.onSave});

  @override
  State<AddPasswordDialog> createState() => _AddPasswordDialogState();
}

class _AddPasswordDialogState extends State<AddPasswordDialog> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  AccountTypes _selectedAccountType = AccountTypes.Google;

  void _handleSave() async {
    if (_passwordController.text.isNotEmpty && _usernameController.text.isNotEmpty) {
      widget.onSave(_passwordController.text, _usernameController.text, _selectedAccountType);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
      backgroundColor: Colors.white,
      title: const Text('Add New Password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Account Type Dropdown
          DropdownButtonFormField<AccountTypes>(
            value: _selectedAccountType,
            decoration: const InputDecoration(labelText: 'Account Type', border: OutlineInputBorder()),
            items: AccountTypes.values.map((AccountTypes type) {
              return DropdownMenuItem<AccountTypes>(value: type, child: Text(type.name));
            }).toList(),
            onChanged: (AccountTypes? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedAccountType = newValue;
                });
              }
            },
          ),
          const SizedBox(height: 16),

          // Username TextField
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.account_circle_outlined),
            ),
          ),
          const SizedBox(height: 16),

          // Password TextField
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.key),
            ),
            obscureText: true,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _handleSave,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
          child: const Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }
}
