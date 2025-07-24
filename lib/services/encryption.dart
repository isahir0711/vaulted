import 'package:encrypt/encrypt.dart';
import 'package:vaulted/enums/account_types.dart';
import 'package:vaulted/models/password.dart';
import 'package:vaulted/services/dbservice.dart';

class Encryption {
  static const String _masterKey = "my 32 length key................";

  void encryptPassword(String password, String userNameOrEmail, {AccountTypes accountType = AccountTypes.none}) {
    if (_masterKey.length < 32) {
      print("dude we need a key with 32 min lenght");
      return;
    }

    final key = Key.fromUtf8(_masterKey);
    final iv = IV.fromLength(16);

    final encrypter = Encrypter(AES(key));

    final encrypted = encrypter.encrypt(password, iv: iv);

    //store the password and the IV into a localdb
    final passwordDto = Password(
      userNameOrEmail: userNameOrEmail,
      encryptedValue: encrypted.base64,
      iv: iv.base64, // Store the IV as base64
      accountType: accountType,
    ); // Remove id parameter to let SQLite auto-generate it
    Dbservice().storePassword(passwordDto);
  }

  String decryptPassword(String encryptedPassword, String ivBase64) {
    final key = Key.fromUtf8(_masterKey);
    final iv = IV.fromBase64(ivBase64); // Use the stored IV
    final encrypter = Encrypter(AES(key));

    final encrypted = Encrypted.fromBase64(encryptedPassword);
    final decrypted = encrypter.decrypt(encrypted, iv: iv);

    print('Decrypted password: $decrypted');
    return decrypted;
  }
}
