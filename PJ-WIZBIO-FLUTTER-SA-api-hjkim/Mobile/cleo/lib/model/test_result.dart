class TestResult {
  int? id; // 결과값 아이디
  final int userId; // 유저 아이디
  final String name;
  final String birthday;
  final int gender;
  final String lotNum;
  final String ctValue;
  final String exp;
  String? disease;
  String? channelA;
  String? channelB;
  String? channelC;
  int? result; // 0: negative 1:positive 2: invalid
  String? createdAt;

  TestResult({
    required this.userId,
    required this.name,
    required this.birthday,
    required this.gender,
    required this.lotNum,
    required this.ctValue,
    required this.exp,
  });

  TestResult.fromMap(Map data)
      : userId = data['userId'],
        name = data['name'],
        birthday = data['birthday'],
        gender = data['gender'],
        lotNum = data['lotNum'],
        ctValue = data['ctValue'],
        exp = data['exp'] {
    id = data['id'];
    disease = data['disease'];
    channelA = data['channelA'];
    channelB = data['channelB'];
    channelC = data['channelC'];
    result = data['result'];
    createdAt = data['createdAt'];
  }
}
