import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:vaulted/models/password.dart';

class Dbservice {
  Future<Database> OpenDatabase() async {
    // Open the database and store the reference.
    final database = openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'vaulted_database.db'),
      onCreate: (db, version) {
        return db.execute('CREATE TABLE passwords(id INTEGER PRIMARY KEY, encryptedValue TEXT, iv TEXT)');
      },
      version: 2, // Increment version to trigger migration
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Add the IV column to existing tables
          await db.execute('ALTER TABLE passwords ADD COLUMN iv TEXT');
        }
      },
    );

    return database;
  }

  Future<void> storePassword(Password password) async {
    // Get a reference to the database.
    final db = await OpenDatabase();

    // Insert the password into the correct table.
    // The toMap() method will automatically exclude id if it's null
    await db.insert('passwords', password.toMap());
  }

  // A method that retrieves all the passwords from the passwords table.
  Future<List<Password>> getPasswords() async {
    // Get a reference to the database.
    final db = await OpenDatabase();

    // Query the table for all the passwords.
    final List<Map<String, Object?>> passwordMaps = await db.query('passwords');

    // Convert the list of each password's fields into a list of `Password` objects.
    return [
      for (final {'id': id as int, 'encryptedValue': encryptedValue as String, 'iv': iv as String?} in passwordMaps)
        Password(id: id, encryptedValue: encryptedValue, iv: iv ?? ''),
    ];
  }

  // A method that retrieves a password by ID
  Future<Password?> getPasswordById(int id) async {
    // Get a reference to the database.
    final db = await OpenDatabase();

    // Query the table for the password with the specific ID.
    final List<Map<String, Object?>> passwordMaps = await db.query('passwords', where: 'id = ?', whereArgs: [id]);

    if (passwordMaps.isNotEmpty) {
      final passwordMap = passwordMaps.first;
      return Password(
        id: passwordMap['id'] as int,
        encryptedValue: passwordMap['encryptedValue'] as String,
        iv: passwordMap['iv'] as String? ?? '',
      );
    }

    return null; // Return null if no password found with the given ID
  }
}
