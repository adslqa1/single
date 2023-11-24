class Tester {
  final int id;
  final String name;
  final String birthday;
  final int gender; // 0: male 1:female
  String? macAddress;

  Tester(obj)
      : id = obj['id'] ?? 0,
        name = obj['name'] ?? '',
        birthday = obj['birthday'] ?? '',
        gender = obj['gender'] ?? 0,
        macAddress = obj['macAddress'];

  Map<String, Object> toSqlMap() {
    return {
      'name': name,
      'birthday': birthday,
      'gender': gender,
      'macAddress': macAddress ?? '',
    };
  }
}
