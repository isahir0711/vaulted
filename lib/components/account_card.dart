import 'package:flutter/material.dart';

class AccountCard extends StatefulWidget {
  // final String accounType;
  const AccountCard({super.key});

  @override
  State<AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends State<AccountCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isHovered ? const Color.fromARGB(40, 158, 158, 158) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Column(children: [Image(height: 36, width: 36, image: AssetImage('assets/google_icon.png'))]),
            SizedBox(width: 16),
            Column(
              children: [
                Row(children: [Text("Account Type")]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ListTile(
//                                     title: Text('Password ${passwords[index].id}'),
//                                     subtitle: Text(passwords[index].encryptedValue),
//                                     onTap: () async {
//                                       if (passwords[index].iv.isNotEmpty) {
//                                         final decrypted = Encryption().decryptPassword(
//                                           passwords[index].encryptedValue,
//                                           passwords[index].iv,
//                                         );
//                                         print('Decrypted: $decrypted');
//                                       }
//                                     },
//                                   );
