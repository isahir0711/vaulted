import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE9ECEF)),
                ),
                child: DropdownButtonFormField<AccountTypes>(
                  value: _selectedAccountType,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.apps_outlined, color: Color(0xFF6C757D), size: 20),
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
            _buildFormField(
              label: 'Username',
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE9ECEF)),
                ),
                child: TextField(
                  controller: _usernameController,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF212529)),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person_outline, color: Color(0xFF6C757D), size: 20),
                    hintText: 'Enter username or email',
                    hintStyle: TextStyle(color: Color(0xFFADB5BD), fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Password TextField
            _buildFormField(
              label: 'Password',
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE9ECEF)),
                ),
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF212529)),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF6C757D), size: 20),
                    hintText: 'Enter password',
                    hintStyle: TextStyle(color: Color(0xFFADB5BD), fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),
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
