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
      final password = await EncryptionService().decryptPassword(pass.encryptedValue, pass.iv);
      final temp = PasswordDTO(
        id: pass.id!,
        userNameOrEmail: pass.userNameOrEmail,
        password: password,
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

    //TODO: CHECK IF THE ENCRYPTION RESPONSE WAS SUCCESFULL, if not, do not store in db

    //store the password and the IV into a localdb
    final model = Password(
      userNameOrEmail: usernameEditController.text,
      encryptedValue: encryptedResponse.encryptedPassword,
      iv: encryptedResponse.iV, // Store the IV as base64
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

    final passToDb = Password(
      userNameOrEmail: username,
      encryptedValue: paswordEncryptionResponse.encryptedPassword,
      iv: paswordEncryptionResponse.iV,
      accountType: accountType,
    );
    //TODO: append the new added password to the passwords list
    //TODO: if the action was ok add the password into the list

    int id = await _dbservice.storePassword(passToDb);

    //TODO: fetch the password from the db and then create this DTO
    final addedPassword = PasswordDTO(id: id, userNameOrEmail: username, password: password, accountType: accountType);

    _passwords.add(addedPassword);
    notifyListeners();
  }

  Future<void> deletePassword(int id) async {
    isPasswordSelected = false;
    //TODO: Check if the password exists on the db

    await _dbservice.deletePassword(id);
    //TODO: Result pattern, if the db action is sucessful, continue with the list deletion
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
