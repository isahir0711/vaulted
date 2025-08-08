import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:vaulted/Error/result.dart';
import 'package:vaulted/enums/account_types.dart';
import 'package:vaulted/models/password.dart';

class Dbservice {
  Future<Database> _openDatabase() async {
    // Open the database and store the reference.
    final database = openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'vaulted_database.db'),
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE passwords(id INTEGER PRIMARY KEY, encryptedValue TEXT,userNameOrEmail TEXT, iv TEXT,accountType TEXT)',
        );
        await db.execute('CREATE TABLE user_config(masterPassword TEXT)');
      },
      version: 2,
    );

    return database;
  }

  Future<int> storePassword(Password password) async {
    // Get a reference to the database.
    final db = await _openDatabase();

    // Insert the password into the correct table.
    // The toMap() method will automatically exclude id if it's null
    int id = await db.insert('passwords', password.toMap());
    return id;
  }

  Future<void> updatePassword(Password password, int id) async {
    final db = await _openDatabase();

    await db.update('passwords', password.toMap(), where: 'id = ?', whereArgs: [id]);
  }

  Future<void> storeMasterPassword(String masterPassword) async {
    // Get a reference to the database.
    final db = await _openDatabase();

    // Insert the master password into the correct table.
    await db.insert('user_config', {
      'id': 1,
      'masterPassword': masterPassword,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<bool> masterPasswordExists() async {
    // Get a reference to the database.
    final db = await _openDatabase();

    // Query the table for the master password.
    final List<Map<String, Object?>> masterPasswordMap = await db.query('user_config');

    //verify if there is a masterPassword stored
    if (masterPasswordMap.isNotEmpty) {
      final masterPassword = masterPasswordMap.first['masterPassword'] as String?;
      return masterPassword != null && masterPassword.isNotEmpty;
    }
    return false;
  }

  Future<String?> getMasterPassword() async {
    // Get a reference to the database.
    final db = await _openDatabase();

    // Query the table for the master password.
    final List<Map<String, Object?>> masterPasswordMap = await db.query('user_config');

    if (masterPasswordMap.isNotEmpty) {
      return masterPasswordMap.first['masterPassword'] as String?;
    }
    return null; // Return null if no master password found
  }

  // A method that retrieves all the passwords from the passwords table.
  Future<List<Password>> getPasswords() async {
    // Get a reference to the database.
    final db = await _openDatabase();

    // Query the table for all the passwords.
    final List<Map<String, Object?>> passwordMaps = await db.query('passwords');

    // Convert the list of each password's fields into a list of `Password` objects.
    return [
      for (final {
            'id': id as int,
            'encryptedValue': encryptedValue as String,
            'iv': iv as String?,
            'accountType': accountType as String?,
            'userNameOrEmail': userNameOrEmail as String?,
          }
          in passwordMaps)
        Password(
          id: id,
          encryptedValue: encryptedValue,
          iv: iv ?? '',
          userNameOrEmail: userNameOrEmail ?? '',
          accountType: _parseAccountType(accountType),
        ),
    ];
  }

  Future<Result<List<Password>>> getAll() async {
    final db = await _openDatabase();

    final List<Map<String, Object?>> passwordMaps = await db.query('passwords');

    if (passwordMaps.isEmpty) {
      return Result.error("empty password list");
    }

    return Result.ok([
      for (final {
            'id': id as int,
            'encryptedValue': encryptedValue as String,
            'iv': iv as String?,
            'accountType': accountType as String?,
            'userNameOrEmail': userNameOrEmail as String?,
          }
          in passwordMaps)
        Password(
          id: id,
          encryptedValue: encryptedValue,
          iv: iv ?? '',
          userNameOrEmail: userNameOrEmail ?? '',
          accountType: _parseAccountType(accountType),
        ),
    ]);
  }

  // A method that retrieves a password by ID
  Future<Result<Password>> getPasswordById(int id) async {
    // Get a reference to the database.
    final db = await _openDatabase();

    // Query the table for the password with the specific ID.
    final List<Map<String, Object?>> passwordMaps = await db.query('passwords', where: 'id = ?', whereArgs: [id]);

    if (passwordMaps.isNotEmpty) {
      final passwordMap = passwordMaps.first;
      final pass = Password(
        id: passwordMap['id'] as int,
        encryptedValue: passwordMap['encryptedValue'] as String,
        userNameOrEmail: passwordMap['userNameOrEmail'] as String,
        iv: passwordMap['iv'] as String? ?? '',
        accountType: _parseAccountType(passwordMap['accountType'] as String?),
      );
      return Result.ok(pass);
    }

    return Result.error("no password found"); // Return null if no password found with the given ID
  }

  Future<void> deleteAll() async {
    // Get a reference to the database.
    final db = await _openDatabase();

    // Remove all passwords from the database.
    await db.delete('passwords');
  }

  Future<bool> deletePassword(int id) async {
    // Get a reference to the database.
    final db = await _openDatabase();

    final exists = await getPasswordById(id);

    if (!exists.isSuccess) {
      return false;
    }
    // Remove the specific password from the database.
    await db.delete('passwords', where: 'id = ?', whereArgs: [id]);
    return true;
  }

  // Helper method to parse account type from string
  AccountTypes _parseAccountType(String? accountTypeString) {
    if (accountTypeString == null) return AccountTypes.none;

    try {
      return AccountTypes.values.firstWhere((type) => type.name == accountTypeString, orElse: () => AccountTypes.none);
    } catch (e) {
      return AccountTypes.none;
    }
  }
}
