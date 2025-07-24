import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vaulted/enums/account_types.dart';
import 'package:vaulted/models/password.dart';
import 'package:vaulted/services/encryption.dart';

class PasswordDetailView extends StatefulWidget {
  final Password? selectedPassword;
  final Function(String password, String username, AccountTypes accountType) onUpdatePassword;
  final VoidCallback? onDeletePassword;

  const PasswordDetailView({
    super.key,
    required this.selectedPassword,
    required this.onUpdatePassword,
    this.onDeletePassword,
  });

  @override
  State<PasswordDetailView> createState() => _PasswordDetailViewState();
}

class _PasswordDetailViewState extends State<PasswordDetailView> {
  final TextEditingController _editPasswordController = TextEditingController();
  final TextEditingController _editUsernameController = TextEditingController();
  late AccountTypes selectedAccountType;

  @override
  void initState() {
    super.initState();
    selectedAccountType = AccountTypes.Google;
    _updateControllers();
  }

  @override
  void didUpdateWidget(PasswordDetailView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedPassword != oldWidget.selectedPassword) {
      _updateControllers();
    }
  }

  void _updateControllers() {
    if (widget.selectedPassword != null) {
      selectedAccountType = widget.selectedPassword!.accountType;
      _editUsernameController.text = widget.selectedPassword!.userNameOrEmail;

      // Decrypt the password
      final decryptedPassword = Encryption().decryptPassword(
        widget.selectedPassword!.encryptedValue,
        widget.selectedPassword!.iv,
      );
      _editPasswordController.text = decryptedPassword;
    } else {
      _editPasswordController.clear();
      _editUsernameController.clear();
    }
  }

  void _copyToClipboard() {
    if (_editPasswordController.text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _editPasswordController.text));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password copied to clipboard')));
    }
  }

  void _handleSave() {
    if (_editPasswordController.text.isNotEmpty && _editUsernameController.text.isNotEmpty) {
      widget.onUpdatePassword(_editPasswordController.text, _editUsernameController.text, selectedAccountType);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectedPassword == null) {
      return Center(
        child: Text('Select an account to view details', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and account type
          Row(
            spacing: 12,
            children: [
              Image(
                height: 40,
                width: 40,
                image: AssetImage('assets/${selectedAccountType.name.toLowerCase()}_icon.png'),
              ),
              Text(
                selectedAccountType.name,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[800]),
              ),
            ],
          ),
          const SizedBox(height: 48),

          // Username Field
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.account_circle_outlined, color: Colors.grey, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Username',
                        style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                      TextField(
                        controller: _editUsernameController,
                        style: const TextStyle(fontSize: 14),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'example@example.com',
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Password Field
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline, color: Colors.grey, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Password',
                        style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                      TextField(
                        controller: _editPasswordController,
                        style: const TextStyle(fontSize: 14),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '••••••••••••',
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        obscureText: true,
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: _copyToClipboard,
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFF5865F2)),
                  child: const Text('Copy', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              ElevatedButton(
                onPressed: _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Save Changes'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: widget.onDeletePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _editPasswordController.dispose();
    _editUsernameController.dispose();
    super.dispose();
  }
}
