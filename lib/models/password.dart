import 'package:vaulted/enums/account_types.dart';

class Password {
  final int? id;
  final String userNameOrEmail;
  final AccountTypes accountType;
  final String encryptedValue;
  final String iv;

  Password({
    this.id,
    required this.userNameOrEmail,
    required this.encryptedValue,
    required this.iv,
    required this.accountType,
  });

  Map<String, Object?> toMap() {
    final map = <String, Object?>{
      'userNameOrEmail': userNameOrEmail,
      'encryptedValue': encryptedValue,
      'iv': iv,
      'accountType': accountType.name,
    };
    if (id != null) {
      map['id'] = id!;
    }
    return map;
  }
}
