import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vaulted/components/add_password_dialog.dart';
import 'package:vaulted/components/custom_title_bar.dart';
import 'package:vaulted/components/master_password_dialog.dart';
import 'package:vaulted/components/password_detail_view.dart';
import 'package:vaulted/components/password_list.dart';
import 'package:vaulted/services/dbservice.dart';
import 'package:vaulted/viewmodels/main_viewmodel.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    _checkMasterPassword();
    _loadPasswords();
    super.initState();
  }

  void _checkMasterPassword() async {
    final masterPasswordExists = await Dbservice().masterPasswordExists();
    if (!masterPasswordExists) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => MasterPasswordDialog(
          onSave: (password) async {
            await Dbservice().storeMasterPassword(password);
          },
        ),
      );
    }
  }

  Future<void> _loadPasswords() async {
    Provider.of<MainViewModel>(context, listen: false).getPasswords();
  }

  void _showAddPasswordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddPasswordDialog();
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
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Column(
        children: [
          // Custom title bar
          CustomTitleBar(onAddPassword: _showAddPasswordDialog),

          // Main content
          Expanded(
            child: Row(
              children: [
                // Password list
                PasswordList(),

                // Password detail view
                Expanded(child: PasswordDetailView()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
