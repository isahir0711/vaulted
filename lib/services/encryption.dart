import 'package:encrypt/encrypt.dart';
import 'package:vaulted/enums/account_types.dart';
import 'package:vaulted/models/password.dart';
import 'package:vaulted/services/dbservice.dart';

class Encryption {
  void encryptPassword(String password, String userNameOrEmail, {AccountTypes accountType = AccountTypes.none}) async {
    final masterPassword = await Dbservice().getMasterPassword();
    if (masterPassword == null || masterPassword.isEmpty) {
      print("Master password is not set. Cannot encrypt the password.");
      return;
    }
    final key = Key.fromUtf8(masterPassword);
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

  Future<String> decryptPassword(String encryptedPassword, String ivBase64) async {
    final masterPassword = await Dbservice().getMasterPassword();
    if (masterPassword == null || masterPassword.isEmpty) {
      print("Master password is not set. Cannot encrypt the password.");
      return "";
    }
    final key = Key.fromUtf8(masterPassword);
    final iv = IV.fromBase64(ivBase64); // Use the stored IV
    final encrypter = Encrypter(AES(key));

    final encrypted = Encrypted.fromBase64(encryptedPassword);
    final decrypted = encrypter.decrypt(encrypted, iv: iv);

    print('Decrypted password: $decrypted');
    return decrypted;
  }
}
