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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon and account type
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    child: Image(
                      image: AssetImage('assets/${selectedAccountType.name.toLowerCase()}_icon.png'),
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.account_circle, size: 32, color: Color(0xFF6C757D));
                      },
                    ),
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
                        const SizedBox(height: 4),
                        Text(
                          widget.selectedPassword!.userNameOrEmail,
                          style: const TextStyle(fontSize: 14, color: Color(0xFF6C757D)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Username Field
              _buildFormField(
                label: 'Username',
                icon: Icons.person_outline,
                controller: _editUsernameController,
                hintText: 'Enter username or email',
              ),
              const SizedBox(height: 20),

              // Password Field
              _buildPasswordField(),
              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
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
                      child: const Text('Save Changes', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: widget.onDeletePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFDC3545),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Color(0xFFDC3545)),
                      ),
                      elevation: 0,
                    ),
                    child: const Text('Delete', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF495057)),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE9ECEF)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            style: const TextStyle(fontSize: 14, color: Color(0xFF212529)),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: const Color(0xFF6C757D), size: 20),
              hintText: hintText,
              hintStyle: const TextStyle(color: Color(0xFFADB5BD), fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF495057)),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE9ECEF)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _editPasswordController,
                  obscureText: true,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF212529)),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF6C757D), size: 20),
                    hintText: '••••••••••••',
                    hintStyle: TextStyle(color: Color(0xFFADB5BD), fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 4),
                child: TextButton.icon(
                  onPressed: _copyToClipboard,
                  icon: const Icon(Icons.copy, size: 16, color: Color(0xFF007BFF)),
                  label: const Text(
                    'Copy',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF007BFF)),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _editPasswordController.dispose();
    _editUsernameController.dispose();
    super.dispose();
  }
}
