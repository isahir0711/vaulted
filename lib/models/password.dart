class Password {
  final int? id; // Make id optional for new passwords
  final String encryptedValue;
  final String iv; // Store the IV

  Password({this.id, required this.encryptedValue, required this.iv});

  Map<String, Object?> toMap() {
    final map = <String, Object?>{'encryptedValue': encryptedValue, 'iv': iv};
    if (id != null) {
      map['id'] = id!;
    }
    return map;
  }

  @override
  String toString() {
    return 'Password{id: $id, encryptedValue: $encryptedValue, iv: $iv}';
  }
}
