import 'dart:collection';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:vaulted/DTOs/password_dto.dart';
import 'package:vaulted/enums/account_types.dart';
import 'package:vaulted/models/password.dart';
import 'package:vaulted/services/dbservice.dart';
import 'package:vaulted/services/encryption.dart';

class MainViewModel extends ChangeNotifier {
  final Dbservice _dbservice = Dbservice();
  final EncryptionService _encryptionService = EncryptionService();
  final List<PasswordDTO> _passwords = [];
  AccountTypes selectedPasswordAccountType = AccountTypes.Amazon;
  int selectedPasswordId = 0;
  bool isPasswordSelected = false;
  String selectedPassword = "";
  UnmodifiableListView<PasswordDTO> get passwords => UnmodifiableListView(_passwords);

  final TextEditingController passwordEditController = TextEditingController();
  final TextEditingController usernameEditController = TextEditingController();

  Future<void> getPasswords() async {
    final loadedPasswords = await _dbservice.getPasswords();

    for (var pass in loadedPasswords) {
      final passwordResponse = await EncryptionService().decryptPassword(pass.encryptedValue, pass.iv);

      if (!passwordResponse.isSuccess) {
        print("Loggin issue with the decryption ${passwordResponse.errorMessage}");
        return;
      }

      final temp = PasswordDTO(
        id: pass.id!,
        userNameOrEmail: pass.userNameOrEmail,
        password: passwordResponse.value!,
        accountType: pass.accountType,
      );
      _passwords.add(temp);
    }
    notifyListeners();
  }

  Future<void> updatePassword() async {
    //use the textediting controllers text values;
    final passwordToEncrypt = passwordEditController.text;
    final encryptedResponse = await _encryptionService.encryptPassword(passwordToEncrypt);

    if (!encryptedResponse.isSuccess) {
      print("Main_ViewModel updatePassword() ${encryptedResponse.errorMessage}");
      return;
    }

    //store the password and the IV into a localdb
    final model = Password(
      userNameOrEmail: usernameEditController.text,
      encryptedValue: encryptedResponse.value!.encryptedPassword,
      iv: encryptedResponse.value!.iV, // Store the IV as base64
      accountType: selectedPasswordAccountType,
    );
    await _dbservice.updatePassword(model, selectedPasswordId);

    final index = _passwords.indexWhere((item) => item.id == selectedPasswordId);
    if (index != -1) {
      _passwords[index] = PasswordDTO(
        id: selectedPasswordId,
        userNameOrEmail: usernameEditController.text,
        password: passwordEditController.text,
        accountType: selectedPasswordAccountType,
      );
    }
    notifyListeners();
  }

  void addnewPassword(String username, String password, AccountTypes accountType) async {
    final paswordEncryptionResponse = await EncryptionService().encryptPassword(password);

    if (!paswordEncryptionResponse.isSuccess) {
      print("main_viewmodel addnewPassword() ${paswordEncryptionResponse.errorMessage}");
      return;
    }

    final passToDb = Password(
      userNameOrEmail: username,
      encryptedValue: paswordEncryptionResponse.value!.encryptedPassword,
      iv: paswordEncryptionResponse.value!.iV,
      accountType: accountType,
    );

    int id = await _dbservice.storePassword(passToDb);

    final roundtripRes = await _dbservice.getPasswordById(id);

    if (!roundtripRes.isSuccess) {
      print("Error addnewPAssword() ${roundtripRes.errorMessage}");
      return;
    }

    final decryptRountripRes = await EncryptionService().decryptPassword(
      roundtripRes.value!.encryptedValue,
      roundtripRes.value!.iv,
    );

    if (!decryptRountripRes.isSuccess) {
      print("Error decrypting addnewPassword() ${decryptRountripRes.errorMessage}");
      return;
    }

    final addedPassword = PasswordDTO(
      id: roundtripRes.value!.id!,
      userNameOrEmail: roundtripRes.value!.userNameOrEmail,
      password: decryptRountripRes.value!,
      accountType: roundtripRes.value!.accountType,
    );

    print(addedPassword.toString());

    _passwords.add(addedPassword);
    notifyListeners();
  }

  Future<void> deletePassword(int id) async {
    isPasswordSelected = false;
    var deleteRes = await _dbservice.deletePassword(id);
    if (!deleteRes) {
      return;
    }
    _passwords.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void passwordSelection(PasswordDTO selected) {
    isPasswordSelected = true;
    passwordEditController.text = selected.password;
    usernameEditController.text = selected.userNameOrEmail;
    selectedPasswordId = selected.id;
    selectedPasswordAccountType = selected.accountType;
    selectedPassword = selected.password;
    notifyListeners();
  }

  Future<void> copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: selectedPassword));
  }
}
