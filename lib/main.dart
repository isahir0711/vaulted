import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:vaulted/components/account_card.dart';
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
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _editPasswordController = TextEditingController();

  List<Password> passwords = [];
  Password? selectedPassword;
  AccountTypes selectedAccountType = AccountTypes.Google;
  @override
  void initState() {
    _printPasswords();
    super.initState();
  }

  void _selectPassword(Password password) {
    setState(() {
      selectedPassword = password;
      selectedAccountType = password.accountType;
      // Decrypt and set the password for editing
      final decryptedPassword = Encryption().decryptPassword(password.encryptedValue, password.iv);
      _editPasswordController.text = decryptedPassword;
    });
  }

  Future<void> _printPasswords() async {
    final loadedPasswords = await Dbservice().getPasswords();
    setState(() {
      passwords = loadedPasswords;
    });
    print('Loaded ${passwords.length} passwords');
    print(passwords);
  }

  Future<void> _updatePassword() async {
    if (selectedPassword != null && _editPasswordController.text.isNotEmpty) {
      // Delete the old password
      await Dbservice().deletePassword(selectedPassword!.id!);

      // Create a new encrypted password with the updated values
      Encryption().encryptPassword(_editPasswordController.text, accountType: selectedAccountType);

      // Refresh the passwords list
      await _printPasswords();

      // Clear selection
      setState(() {
        selectedPassword = null;
        _editPasswordController.clear();
      });
    }
  }

  void _copyToClipboard() {
    if (_editPasswordController.text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _editPasswordController.text));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password copied to clipboard')));
    }
  }

  Future<void> _showAddPasswordDialog() async {
    final TextEditingController passwordController = TextEditingController();
    AccountTypes selectedAccountType = AccountTypes.Google;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add New Password'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<AccountTypes>(
                    value: selectedAccountType,
                    decoration: const InputDecoration(labelText: 'Account Type', border: OutlineInputBorder()),
                    items: AccountTypes.values.map((AccountTypes type) {
                      return DropdownMenuItem<AccountTypes>(value: type, child: Text(type.name));
                    }).toList(),
                    onChanged: (AccountTypes? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedAccountType = newValue;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (passwordController.text.isNotEmpty) {
                      // Encrypt and save the password
                      Encryption().encryptPassword(passwordController.text, accountType: selectedAccountType);

                      // Refresh the passwords list
                      await _printPasswords();

                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _editPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Custom title bar
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                // boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: Row(
                children: [
                  // App icon and title
                  Expanded(
                    child: DragToMoveArea(
                      child: Row(
                        children: [
                          ElevatedButton(
                            onPressed: () => _showAddPasswordDialog(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              shape: const CircleBorder(),
                            ),
                            child: Icon(Icons.add, color: Colors.white),
                          ),
                          //Add Text field to search through the passwords
                          // Icon(Icons.security, size: 20, color: Theme.of(context).colorScheme.primary),
                          // const SizedBox(width: 8),
                          // Text(
                          //   widget.title,
                          //   style: TextStyle(
                          //     fontSize: 14,
                          //     fontWeight: FontWeight.w500,
                          //     color: Theme.of(context).colorScheme.onPrimaryContainer,
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                  // Window controls
                  Row(
                    children: [
                      WindowButton(icon: Icons.minimize, onPressed: () => windowManager.minimize()),
                      WindowButton(
                        icon: Icons.crop_square,
                        onPressed: () async {
                          if (await windowManager.isMaximized()) {
                            windowManager.unmaximize();
                          } else {
                            windowManager.maximize();
                          }
                        },
                      ),
                      WindowButton(icon: Icons.close, onPressed: () => windowManager.close(), isClose: true),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Main content
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        width: 300,
                        child: passwords.isEmpty
                            ? const Center(child: Text('No passwords found'))
                            : ListView.separated(
                                separatorBuilder: (context, index) => SizedBox(height: 8),
                                itemCount: passwords.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return AccountCard(
                                    accountType: passwords[index].accountType.name,
                                    onTap: () => _selectPassword(passwords[index]),
                                  );
                                },
                              ),
                      ),
                      Expanded(
                        child: selectedPassword == null
                            ? Center(
                                child: Text(
                                  'Select an account to view details',
                                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Account Details',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    const SizedBox(height: 24),

                                    // Account Type Selector
                                    Text(
                                      'Account Type',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    DropdownButtonFormField<AccountTypes>(
                                      value: selectedAccountType,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      ),
                                      items: AccountTypes.values.map((AccountTypes type) {
                                        return DropdownMenuItem<AccountTypes>(value: type, child: Text(type.name));
                                      }).toList(),
                                      onChanged: (AccountTypes? newValue) {
                                        if (newValue != null) {
                                          setState(() {
                                            selectedAccountType = newValue;
                                          });
                                        }
                                      },
                                    ),
                                    const SizedBox(height: 24),

                                    // Password Field
                                    Text(
                                      'Password',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: _editPasswordController,
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            ),
                                            obscureText: true,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          onPressed: _copyToClipboard,
                                          icon: const Icon(Icons.copy),
                                          tooltip: 'Copy to clipboard',
                                          style: IconButton.styleFrom(
                                            backgroundColor: Colors.grey[200],
                                            padding: const EdgeInsets.all(12),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),

                                    // Save Button
                                    ElevatedButton(
                                      onPressed: _updatePassword,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blueAccent,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      ),
                                      child: const Text('Save Changes'),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ],
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

class WindowButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isClose;

  const WindowButton({super.key, required this.icon, required this.onPressed, this.isClose = false});

  @override
  State<WindowButton> createState() => _WindowButtonState();
}

class _WindowButtonState extends State<WindowButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          width: 46,
          height: 40,
          decoration: BoxDecoration(
            color: isHovered ? (widget.isClose ? Colors.red : Colors.grey.withOpacity(0.2)) : Colors.transparent,
          ),
          child: Icon(
            widget.icon,
            size: 16,
            color: isHovered && widget.isClose ? Colors.white : Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}
