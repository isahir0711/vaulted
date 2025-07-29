import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vaulted/components/text_field.dart';
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

  void _updateControllers() async {
    if (widget.selectedPassword != null) {
      selectedAccountType = widget.selectedPassword!.accountType;
      _editUsernameController.text = widget.selectedPassword!.userNameOrEmail;

      // Decrypt the password
      final decryptedPassword = await Encryption().decryptPassword(
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
      return Container(
        color: const Color(0xFFFAFBFC),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 64, color: Color(0xFFADB5BD)),
              SizedBox(height: 24),
              Text(
                'Select an account to view details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFF6C757D)),
              ),
              SizedBox(height: 8),
              Text(
                'Choose an item from the list to view and edit its details',
                style: TextStyle(fontSize: 14, color: Color(0xFFADB5BD)),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header with icon and account type
          Column(
            children: [
              Row(
                children: [
                  Image(
                    width: 48,
                    height: 48,
                    image: AssetImage('assets/${selectedAccountType.name.toLowerCase()}_icon.png'),
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.account_circle, size: 32, color: Color(0xFF6C757D));
                    },
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedAccountType.name,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF212529)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              CustomTextField(
                isPassword: false,
                label: "Username",
                controller: _editUsernameController,
                icon: Icons.person_2_outlined,
              ),

              const SizedBox(height: 20),

              // Password Field
              CustomTextField(
                label: "Password",
                controller: _editPasswordController,
                isPassword: true,
                icon: Icons.lock_outline,
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Action Buttons
          //TODO: make the text slighly change color on hover
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _handleSave,
                style: TextButton.styleFrom(overlayColor: Colors.transparent),
                child: Text("Save", style: TextStyle(color: Colors.blueAccent)),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: widget.onDeletePassword,
                style: TextButton.styleFrom(overlayColor: Colors.transparent),
                child: Text("Delete", style: TextStyle(color: Colors.red)),
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
