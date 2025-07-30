import 'package:encrypt/encrypt.dart';
import 'package:vaulted/services/dbservice.dart';

class EncryptionService {
  Future<EncryptionResponse> encryptPassword(String password) async {
    final masterPassword = await Dbservice().getMasterPassword();
    if (masterPassword == null || masterPassword.isEmpty) {
      // print("Master password is not set. Cannot encrypt the password.");
      return EncryptionResponse(encryptedPassword: "", iV: "");
    }
    final key = Key.fromUtf8(masterPassword);
    final iv = IV.fromLength(16);

    final encrypter = Encrypter(AES(key));

    final encrypted = encrypter.encrypt(password, iv: iv);

    return EncryptionResponse(encryptedPassword: encrypted.base64, iV: iv.base64);
  }

  Future<String> decryptPassword(String encryptedPassword, String ivBase64) async {
    final masterPassword = await Dbservice().getMasterPassword();
    if (masterPassword == null || masterPassword.isEmpty) {
      // print("Master password is not set. Cannot encrypt the password.");
      return "";
    }
    final key = Key.fromUtf8(masterPassword);
    final iv = IV.fromBase64(ivBase64); // Use the stored IV
    final encrypter = Encrypter(AES(key));

    final encrypted = Encrypted.fromBase64(encryptedPassword);
    final decrypted = encrypter.decrypt(encrypted, iv: iv);
    return decrypted;
  }
}

class EncryptionResponse {
  final String encryptedPassword;
  final String iV;

  EncryptionResponse({required this.encryptedPassword, required this.iV});
}
