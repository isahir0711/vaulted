import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:vaulted/components/account_card.dart';
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

  List<Password> passwords = [];
  @override
  void initState() {
    _printPasswords();
    super.initState();
  }

  Future<void> _printPasswords() async {
    final loadedPasswords = await Dbservice().getPasswords();
    setState(() {
      passwords = loadedPasswords;
    });
    print('Loaded ${passwords.length} passwords');
    print(passwords);
  }

  Future<void> _decryptPasswordWithId1() async {
    final password = await Dbservice().getPasswordById(6);
    if (password != null) {
      final decryptedPassword = Encryption().decryptPassword(password.encryptedValue, password.iv);
      print('Decrypted password for ID 1: $decryptedPassword');
    } else {
      print('No password found with ID 1');
    }
  }

  @override
  void dispose() {
    _textController.dispose();
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
                            onPressed: () => {print("New password")},
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
                                  return AccountCard();
                                },
                              ),
                      ),
                      Expanded(child: Column(children: [Text("current")])),
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
