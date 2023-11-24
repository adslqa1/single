import 'package:cleo/cleo_device/cleo_device.dart'; // 2023.10.12_CJH

class ReportStatus {
  static const int pending = 0;
  static const int running = 1;
  static const int complete = 2;
  static const int cancel = 3;
}

class TestReport {
  int? id;
  late final int userId;
  late final String name;
  late final String testType; // ex) COVID-19
  late final String birthday;
  late final int gender;
  late final String macAddress;
  late final String expire;
  late final String lotNum;

  // late final String ctValue;
  String ctValue = '100';
  //ctValue를 시료별로 쓰려면 sql 새로써야 하므로 일단 100 고정, 시료별로 쓰길 원하면 파일 내 ctValue 주석 해제


  String serial = '';
  int? reportStatus; // 0: pending 1:running 2:complete 3:cancel
  String? startAt;
  String? endAt;
  double? result1;
  double? result2;
  double? result3;
  String? rawData1;
  String? rawData2;
  String? rawData3;
  String? rawDataTemp;
  String? fittingData1;
  String? fittingData2;
  String? fittingData3;
  String? fittingDataTemp;
  String? fittingDataCt;
  String? deviceName;
  String? uid;
  int? isSended;

  // int? finalResult; // -1: Negative 0:Invalid 1: Positive

  TestReport({
    required this.userId,
    required this.name,
    required this.testType,
    required this.birthday,
    required this.gender,
    required this.macAddress,
    required this.serial,
    required this.expire,
    required this.lotNum,
    required this.ctValue,
    // required this.uid,
    this.reportStatus = ReportStatus.pending,
  });

  Map<String, Object?> toSqlMap() {
    return {
      'userId': userId,
      'name': name,
      'testType': testType,
      'birthday': birthday,
      'gender': gender,
      'macAddress': macAddress,
      'serial': serial,
      'expire': expire,
      'lotNum': lotNum,
      // 'ctValue': ctValue,
      'reportStatus': reportStatus ?? 0,
      'startAt': startAt,
      'endAt': endAt,
      'result1': result1,
      'result2': result2,
      'result3': result3,
      'rawData1': rawData1,
      'rawData2': rawData2,
      'rawData3': rawData3,
      'rawDataTemp': rawDataTemp,
      'fittingData1': fittingData1,
      'fittingData2': fittingData2,
      'fittingData3': fittingData3,
      'fittingDataTemp': fittingDataTemp,
      'fittingDataCt': fittingDataCt,
      'finalResult': finalResult,
      'deviceName': deviceName,
      'uid': uid,
      'isSended': isSended
    };
  }

  TestReport.fromMap(Map data)
      : userId = data['userId'],
        name = data['name'],
        testType = data['testType'],
        birthday = data['birthday'],
        gender = data['gender'],
        macAddress = data['macAddress'],
        expire = data['expire'],
        lotNum = data['lotNum']
  // ctValue= data['ctValue']
  {
    serial = data['serial'];
    id = data['id'];
    reportStatus = data['reportStatus'];
    startAt = data['startAt'];
    endAt = data['endAt'];
    result1 = data['result1'];
    result2 = data['result2'];
    result3 = data['result3'];
    rawData1 = data['rawData1'];
    rawData2 = data['rawData2'];
    rawData3 = data['rawData3'];
    rawDataTemp = data['rawDataTemp'];
    fittingData1 = data['fittingData1'];
    fittingData2 = data['fittingData2'];
    fittingData3 = data['fittingData3'];
    fittingDataTemp = data['fittingDataTemp'];
    fittingDataCt = data['fittingDataCt'];
    deviceName = data['deviceName'];
    uid = data['uid'];
    isSended = data['isSended'];
    // finalResult = data['finalResult'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'testType': testType,
      'birthday': birthday,
      'gender': gender,
      'macAddress': macAddress,
      'serial': serial,
      'expire': expire,
      'lotNum': lotNum,
      // 'ctValue': ctValue,
      'reportStatus': reportStatus,
      'startAt': startAt,
      'endAt': endAt,
      'result1': result1,
      'result2': result2,
      'result3': result3,
      'rawData1': rawData1,
      'rawData2': rawData2,
      'rawData3': rawData3,
      'rawDataTemp': rawDataTemp,
      'fittingData1': fittingData1,
      'fittingData2': fittingData2,
      'fittingData3': fittingData3,
      'fittingDataTemp': fittingDataTemp,
      'fittingDataCt': fittingDataCt,
      'finalResult': finalResult,
      'deviceName': deviceName,
      'uid': uid,
      'isSended': isSended
    };
  }

  TestReport.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    name = json['name'];
    testType = json['testType'];
    birthday = json['birthday'];
    gender = json['gender'];
    macAddress = json['macAddress'];
    serial = json['serial'];
    expire = json['expire'];
    lotNum = json['lotNum'];
    // ctValue = json['ctValue'];
    reportStatus = json['reportStatus'];
    startAt = json['startAt'];
    endAt = json['endAt'];
    result1 = json['result1'];
    result2 = json['result2'];
    result3 = json['result3'];
    rawData1 = json['rawData1'];
    rawData2 = json['rawData2'];
    rawData3 = json['rawData3'];
    rawDataTemp = json['rawDataTemp'];
    fittingData1 = json['fittingData1'];
    fittingData2 = json['fittingData2'];
    fittingData3 = json['fittingData3'];
    fittingDataTemp = json['fittingDataTemp'];
    fittingDataCt = json['fittingDataCt'];
    deviceName = json['deviceName'];
    uid = json['uid'];
    isSended = json['isSended'];
    // finalResult = json['finalResult'];
  }

  String get jin1 {
    switch (testType) {
      case 'COVID-19':
        return 'ORF';

      case 'COVI-Flu':
        return 'COVID-19';

      case 'Influenza':
        return 'Flu A';

      case 'RSV-MPV':
        return 'RSV';

      case 'CMV':
        return 'CMV A';

      case 'RSV':
        return 'RSV A';

      default:
        return 'Chamber 1';
    }
  }

  String get jin2 {
    switch (testType) {
      case 'COVID-19':
        return 'N';

      case 'COVI-Flu':
        return 'Flu';

      case 'Influenza':
        return 'Flu B';

      case 'RSV-MPV':
        return 'MPV';

      case 'CMV':
        return 'CMV B';

      case 'RSV':
        return 'RSV B';

      default:
        return 'Chamber 2';
    }
  }

  // 2023.10.12_CJH
  int get pd1 {
    // ORF
    // ct 계산 로직
    if (result1 == null || result1! < 1) return -1;
    if (result1! <= CleoDevice.TEST_MIN) return 1;
    // if (device != null &&
    //     device!.crntCartridge != null &&
    //     result1! <=
    //         ((double.parse(device!.crntCartridge!.preTestCycle) *
    //                     double.parse(device!.crntCartridge!.preTestTime)) +
    //                 (double.parse(device!.crntCartridge!.afterTestCycle) *
    //                     double.parse(device!.crntCartridge!.afterTestTime))) /
    //             60) return 1;

    // if (crntCartridge != null && result1! <=
    // ((double.parse(crntCartridge!.preTestCycle) *
    //             double.parse(crntCartridge!.preTestTime)) +
    //         (double.parse(crntCartridge!.afterTestCycle) *
    //             double.parse(crntCartridge!.afterTestTime))) /
    //     60) return 1;

    // if (double.parse(fittingDataCt![0]) == 0) return -1;
    // if (double.parse(fittingDataCt![0]) <= CleoDevice.TEST_MIN) return 1;
    // if (27 < fittingDataCt[0]! && fittingDataCt[0]! <= 29) return 0;
    // pd1
    // if (result1 == null) return -1;
    // if (result1! >= 400) return 1;
    // if (result1! >= 300) return 0;

    return -1;
  } // 0

  // 2023.10.12_CJH
  int get pd2 {
    // N
    // ct 계산 로직
    if (result2 == null || result2! < 1) return -1;
    // if (result2! <= ((double.parse(device.crntCartridge!.preTestCycle) * double.parse(device.crntCartridge!.preTestTime)) +
    // (double.parse(device.crntCartridge!.afterTestCycle) * double.parse(device.crntCartridge!.afterTestTime))) / 60) return 1;

    if (result2! <= CleoDevice.TEST_MIN) return 1;
    // if (27 < result2! && result2! <= 29) return 0;
    // pd2
    // if (result2 == null) return -1;
    // if (result2! >= 400) return 1;
    // if (result2! >= 300) return 0;
    // if (double.parse(fittingDataCt![1]) == 0) return -1;
    // if (double.parse(fittingDataCt![1]) <= 1) return 1;
    // if (29.5 < result2! && result2! <= 30) return 0;
    return -1;
  } // 0

  // 2023.10.12_CJH
  int get pd3 {
    // control
    // ct 계산 로직
    if (result3 == null || result3! < 1) return -1;
    // if (result3! <= ((double.parse(device.crntCartridge!.preTestCycle) * double.parse(device.crntCartridge!.preTestTime)) +
    // (double.parse(device.crntCartridge!.afterTestCycle) * double.parse(device.crntCartridge!.afterTestTime))) / 60) return 1;

    if (result3! <= CleoDevice.TEST_MIN) return 1;
    // if (double.parse(fittingDataCt![2]) == 0) return -1;
    // if (double.parse(fittingDataCt![2]) <= CleoDevice.TEST_MIN) return 1;
    // pd3
    // if (result3 == null) return -1;
    // if (result3! < 400) return -1;
    return 1;
  } // -1

  int get finalResult {
    //pd1 positive = 2
    //pd2 positive = 3
    //pd1,2 positive = 1
    // final positive1
    if (testType == 'Unknown' || testType == 'COVID-19') {
      if (pd1 == 1 && pd2 == 1 && pd3 == 1) return 1;
      if (pd1 == 1 && pd2 == -1 && pd3 == 1) return 1;
      if (pd1 == -1 && pd2 == 1 && pd3 == 1) return 1;
    } else {
      if (pd1 == 1 && pd2 == 1 && pd3 == 1) return 1;
      if (pd1 == 1 && pd2 == -1 && pd3 == 1) return 2;
      if (pd1 == -1 && pd2 == 1 && pd3 == 1) return 3;
    }
    // fianl invalid
    if (pd3 == -1) return 0;

    // final negative
    if (pd1 == -1 && pd2 == -1 && pd3 == 1) return -1;

    return 0;
  }

  String get virusName {
    if (testType == 'COVID-19') return 'SARS-Cov-2 virus';

    if (testType == 'COVI-Flu' && finalResult == 2) return 'SARS-Cov-2 virus';
    if (testType == 'COVI-Flu' && finalResult == 3) return 'Influenza virus';
    if (testType == 'COVI-Flu' && finalResult == 1) return 'SARS-Cov-2 virus, Influenza virus';
    if (testType == 'COVI-Flu' && finalResult == -1) return 'SARS-Cov-2 virus, Influenza virus';
    if (testType == 'COVI-Flu' && finalResult == 0) return 'SARS-Cov-2 virus, Influenza virus';


    if (testType == 'Influenza' && finalResult == 2) return 'Influenza A virus';
    if (testType == 'Influenza' && finalResult == 3) return 'Influenza B virus';
    if (testType == 'Influenza' && finalResult == 1) return 'Influenza A & B virus';
    if (testType == 'Influenza' && finalResult == -1) return 'Influenza virus';
    if (testType == 'Influenza' && finalResult == 0) return 'Influenza virus';

    if (testType == 'RSV-MPV' && finalResult == 2) return jin1;
    if (testType == 'RSV-MPV' && finalResult == 3) return jin2;
    if (testType == 'RSV-MPV' && finalResult == 1) return 'RSV, MPV';
    if (testType == 'RSV-MPV' && finalResult == -1) return 'RSV, MPV';
    if (testType == 'RSV-MPV' && finalResult == -1) return 'RSV, MPV';

    if (testType == 'CMV' && finalResult == 2) return jin1;
    if (testType == 'CMV' && finalResult == 3) return jin2;
    if (testType == 'CMV' && finalResult == 1) return 'CMV A & B virus';
    if (testType == 'CMV' && finalResult == -1) return 'CMV';
    if (testType == 'CMV' && finalResult == 0) return 'CMV';

    if (testType == 'RSV' && finalResult == 2) return 'RSV A virus';
    if (testType == 'RSV' && finalResult == 3) return 'RSV B virus';
    if (testType == 'RSV' && finalResult == 1) return 'RSV A & B virus';
    if (testType == 'RSV' && finalResult == -1) return 'RSV';
    if (testType == 'RSV' && finalResult == 0) return 'RSV';

    return 'Unknown';

    // switch (testType) {
    //   case 'COVID-19':
    //     return 'SARS-CoV-2 virus RNA';

    //   case 'COVI-Flu':
    //     return 'COVID';

    //   case 'Influenza':
    //     return 'Flu A';

    //   case 'RSV-MPV':
    //     return 'ORF';

    //   case 'CMV':
    //     return 'CMV A';

    //   case 'RSV':
    //     return 'RSV A';

    //   default:
    //     return 'Chamber 1';
    // }
  }
}
