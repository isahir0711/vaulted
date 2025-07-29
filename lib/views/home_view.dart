import 'package:flutter/material.dart';
import 'package:vaulted/components/add_password_dialog.dart';
import 'package:vaulted/components/custom_title_bar.dart';
import 'package:vaulted/components/master_password_dialog.dart';
import 'package:vaulted/components/password_detail_view.dart';
import 'package:vaulted/components/password_list.dart';
import 'package:vaulted/enums/account_types.dart';
import 'package:vaulted/models/password.dart';
import 'package:vaulted/services/dbservice.dart';
import 'package:vaulted/services/encryption.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Password> passwords = [];
  Password? selectedPassword;

  @override
  void initState() {
    //here were going to check if the user has a saved master password to encrypt the passwords
    _checkMasterPassword();
    _loadPasswords();
    super.initState();
  }

  void _checkMasterPassword() async {
    //TODO: Disable escape key if master password is not set
    final masterPasswordExists = await Dbservice().masterPasswordExists();
    if (!masterPasswordExists) {
      //disable escape key

      // show a dialog to create the master password
      await showDialog(
        context: context,
        builder: (context) => MasterPasswordDialog(
          onSave: (password) async {
            await Dbservice().storeMasterPassword(password);
          },
        ),
      );
    }
  }

  Future<void> _loadPasswords() async {
    final loadedPasswords = await Dbservice().getPasswords();
    setState(() {
      passwords = loadedPasswords;
    });
  }

  void _selectPassword(Password password) {
    setState(() {
      selectedPassword = password;
    });
  }

  Future<void> _updatePassword(String password, String username, AccountTypes accountType) async {
    if (selectedPassword != null) {
      // Delete the old password
      await Dbservice().deletePassword(selectedPassword!.id!);

      // Create a new encrypted password with the updated values
      Encryption().encryptPassword(password, username, accountType: accountType);

      // Refresh the passwords list
      await _loadPasswords();

      // Clear selection
      setState(() {
        selectedPassword = null;
      });
    }
  }

  Future<void> _addPassword(String password, String username, AccountTypes accountType) async {
    // Encrypt and save the password
    Encryption().encryptPassword(password, username, accountType: accountType);

    // Refresh the passwords list
    await _loadPasswords();
  }

  Future<void> _deletePassword() async {
    if (selectedPassword != null) {
      // Delete the password from database
      await Dbservice().deletePassword(selectedPassword!.id!);

      // Refresh the passwords list
      await _loadPasswords();

      // Clear selection
      setState(() {
        selectedPassword = null;
      });
    }
  }

  void _showAddPasswordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddPasswordDialog(onSave: _addPassword);
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // Custom title bar
          CustomTitleBar(onAddPassword: _showAddPasswordDialog),

          // Main content
          Expanded(
            child: Row(
              children: [
                // Password list
                PasswordList(passwords: passwords, onPasswordSelected: _selectPassword),

                // Password detail view
                Expanded(
                  child: PasswordDetailView(
                    selectedPassword: selectedPassword,
                    onUpdatePassword: _updatePassword,
                    onDeletePassword: _deletePassword,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
