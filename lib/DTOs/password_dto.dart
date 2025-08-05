import 'package:vaulted/enums/account_types.dart';

class PasswordDTO {
  final int id;
  final String userNameOrEmail;
  final String password;
  final AccountTypes accountType;
  PasswordDTO({required this.id, required this.userNameOrEmail, required this.password, required this.accountType});
}

class CreatePasswordDTO {
  final String userNameOrEmail;
  final String encryptedPassword;
  final AccountTypes accountType;

  CreatePasswordDTO({required this.userNameOrEmail, required this.encryptedPassword, required this.accountType});
}
