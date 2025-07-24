import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:vaulted/components/add_password_dialog.dart';
import 'package:vaulted/components/custom_title_bar.dart';
import 'package:vaulted/components/password_detail_view.dart';
import 'package:vaulted/components/password_list.dart';
import 'package:vaulted/enums/account_types.dart';
import 'package:vaulted/models/password.dart';
import 'package:vaulted/services/dbservice.dart';
import 'package:vaulted/services/encryption.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize window manager
  await windowManager.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  WindowOptions windowOptions = const WindowOptions(
    size: Size(900, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vaulted',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.white)),
      home: const MyHomePage(title: 'Vaulted'),
      debugShowCheckedModeBanner: false,
    );
  }
}

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
    _loadPasswords();
    super.initState();
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
      backgroundColor: Colors.white,
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
                  child: PasswordDetailView(selectedPassword: selectedPassword, onUpdatePassword: _updatePassword),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
