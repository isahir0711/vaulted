import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

import 'package:vaulted/components/text_field.dart';

class MasterPasswordDialog extends StatefulWidget {
  final Function(String password) onSave;

  const MasterPasswordDialog({super.key, required this.onSave});

  @override
  State<MasterPasswordDialog> createState() => _MasterPasswordDialogState();
}

class _MasterPasswordDialogState extends State<MasterPasswordDialog> {
  final TextEditingController _passwordController = TextEditingController();
  final WidgetStatesController _saveController = WidgetStatesController();
  bool _isPasswordValid = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updatePasswordValidity);
  }

  void _updatePasswordValidity() {
    setState(() {
      _isPasswordValid = _passwordController.text.length >= 32;
    });
  }

  //  LOL
  void _generateSecurePassword() {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*()_+-=[]{}|;:,.<>?';
    final Random random = Random.secure();
    final String password = List.generate(32, (index) => chars[random.nextInt(chars.length)]).join();

    setState(() {
      _passwordController.text = password;
    });
  }

  void _copyPassword() async {
    if (_passwordController.text.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: _passwordController.text));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password copied to clipboard'),
            duration: Duration(seconds: 2),
            backgroundColor: Color(0xFF28A745),
          ),
        );
      }
    }
  }

  void _save() async {
    if (_passwordController.text.length < 32) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 32 characters long'),
          duration: Duration(seconds: 2),
          backgroundColor: Color(0xFF28A745),
        ),
      );
      return;
    }

    if (_passwordController.text.isNotEmpty) {
      widget.onSave(_passwordController.text);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      backgroundColor: Colors.white,
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Add the main password for the application',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF212529)),
            ),
            const SizedBox(height: 24),

            // Password TextField
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: "Master Password",
                    controller: _passwordController,
                    isPassword: true,
                    icon: Icons.lock_outline,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  statesController: _saveController,
                  onPressed: _generateSecurePassword,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Generate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF28A745),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    elevation: 0,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _passwordController.text.isNotEmpty ? _copyPassword : null,
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Copy'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C757D),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    elevation: 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isPasswordValid ? _save : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007BFF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
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
    super.dispose();
  }
}
