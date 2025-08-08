import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vaulted/components/text_field.dart';
import 'package:vaulted/enums/account_types.dart';
import 'package:vaulted/viewmodels/main_viewmodel.dart';

class AddPasswordDialog extends StatefulWidget {
  const AddPasswordDialog({super.key});

  @override
  State<AddPasswordDialog> createState() => _AddPasswordDialogState();
}

class _AddPasswordDialogState extends State<AddPasswordDialog> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  AccountTypes _selectedAccountType = AccountTypes.Google;

  void _handleSave() async {
    if (_passwordController.text.isNotEmpty && _usernameController.text.isNotEmpty) {
      Provider.of<MainViewModel>(
        context,
        listen: false,
      ).addnewPassword(_usernameController.text, _passwordController.text, _selectedAccountType);
      Navigator.pop(context);
    }
  }

  Widget defAccountImage() {
    if (_selectedAccountType != AccountTypes.none) {
      return Image(
        image: AssetImage('assets/${_selectedAccountType.name.toLowerCase()}_icon.png'),
        height: 8,
        width: 8,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.error, size: 16, color: Color(0xFF6C757D));
        },
      );
    }
    return Icon(Icons.person, size: 16, color: Color(0xFF6C757D));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Colors.white,
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Add New Password',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF212529)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter the details for your new password entry',
              style: TextStyle(fontSize: 14, color: Color(0xFF6C757D)),
            ),
            const SizedBox(height: 24),

            // Account Type Dropdown
            _buildFormField(
              label: 'Account Type',
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFFE9ECEF)),
                ),
                child: DropdownButtonFormField<AccountTypes>(
                  value: _selectedAccountType,
                  decoration: InputDecoration(
                    prefixIcon: Padding(padding: EdgeInsets.all(8.0), child: defAccountImage()),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  items: AccountTypes.values.map((AccountTypes type) {
                    return DropdownMenuItem<AccountTypes>(
                      value: type,
                      child: Text(type.name, style: const TextStyle(fontSize: 14, color: Color(0xFF212529))),
                    );
                  }).toList(),
                  onChanged: (AccountTypes? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedAccountType = newValue;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Username TextField
            CustomTextField(
              label: 'Username',
              controller: _usernameController,
              isPassword: false,
              icon: Icons.person_outlined,
              hintText: 'email@example.com',
            ),
            const SizedBox(height: 20),

            // Password TextField
            CustomTextField(
              label: 'Password',
              controller: _passwordController,
              isPassword: true,
              icon: Icons.lock_outline,
              hintText: 'Enter your password',
            ),
            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF6C757D),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Color(0xFFE9ECEF)),
                      ),
                    ),
                    child: const Text('Cancel', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007BFF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: const Text('Save', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF495057)),
        ),
        const SizedBox(height: 8),
        child,
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
