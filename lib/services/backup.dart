import 'dart:io';

import 'package:path_provider/path_provider.dart';

class BackupService {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    //Documents
    return File('$path/backup.txt');
  }

  Future<File> writeBackUp(String backupJson) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString(backupJson);
  }
}
