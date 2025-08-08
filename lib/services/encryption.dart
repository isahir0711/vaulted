import 'package:encrypt/encrypt.dart';
import 'package:vaulted/Error/result.dart';
import 'package:vaulted/services/dbservice.dart';

class EncryptionService {
  Future<Result<EncryptionResponse>> encryptPassword(String password) async {
    final masterPassword = await Dbservice().getMasterPassword();
    if (masterPassword == null || masterPassword.isEmpty) {
      return Result.error("Master password is not set");
    }
    final key = Key.fromUtf8(masterPassword);
    final iv = IV.fromLength(16);

    final encrypter = Encrypter(AES(key));

    final encrypted = encrypter.encrypt(password, iv: iv);

    return Result.ok(EncryptionResponse(encryptedPassword: encrypted.base64, iV: iv.base64));
  }

  Future<Result<String>> decryptPassword(String encryptedPassword, String ivBase64) async {
    final masterPassword = await Dbservice().getMasterPassword();
    if (masterPassword == null || masterPassword.isEmpty) {
      return Result.error("Master password not set cannot decrypt");
    }
    final key = Key.fromUtf8(masterPassword);
    final iv = IV.fromBase64(ivBase64); // Use the stored IV
    final encrypter = Encrypter(AES(key));

    final encrypted = Encrypted.fromBase64(encryptedPassword);
    final decrypted = encrypter.decrypt(encrypted, iv: iv);
    return Result.ok(decrypted);
  }
}

class EncryptionResponse {
  final String encryptedPassword;
  final String iV;

  EncryptionResponse({required this.encryptedPassword, required this.iV});
}
