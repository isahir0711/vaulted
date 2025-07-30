import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vaulted/components/text_field.dart';
import 'package:vaulted/viewmodels/main_viewmodel.dart';

class PasswordDetailView extends StatefulWidget {
  const PasswordDetailView({super.key});

  @override
  State<PasswordDetailView> createState() => _PasswordDetailViewState();
}

class _PasswordDetailViewState extends State<PasswordDetailView> {
  @override
  void initState() {
    super.initState();
  }

  void _handleSave() {
    Provider.of<MainViewModel>(context, listen: false).updatePassword();
  }

  void _deletePassword(int id) {
    Provider.of<MainViewModel>(context, listen: false).deletePassword(id);
  }

  @override
  Widget build(BuildContext context) {
    if (!Provider.of<MainViewModel>(context).isPasswordSelected) {
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
                  Consumer<MainViewModel>(
                    builder: (context, value, child) => Image(
                      width: 48,
                      height: 48,
                      image: AssetImage('assets/${value.selectedPasswordAccountType.name.toLowerCase()}_icon.png'),
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
                        Consumer<MainViewModel>(
                          builder: (context, value, child) => Text(
                            value.selectedPasswordAccountType.name,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF212529)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              Consumer<MainViewModel>(
                builder: (context, value, child) => CustomTextField(
                  isPassword: false,
                  label: "Username",
                  controller: value.usernameEditController,
                  icon: Icons.person_2_outlined,
                ),
              ),

              const SizedBox(height: 20),

              // Password Field
              Consumer<MainViewModel>(
                builder: (context, value, child) => CustomTextField(
                  label: "Password",
                  controller: value.passwordEditController,
                  isPassword: true,
                  icon: Icons.lock_outline,
                ),
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
              Consumer<MainViewModel>(
                builder: (context, value, child) => TextButton(
                  onPressed: () => _deletePassword(value.selectedPasswordId),
                  style: TextButton.styleFrom(overlayColor: Colors.transparent),
                  child: Text("Delete", style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
