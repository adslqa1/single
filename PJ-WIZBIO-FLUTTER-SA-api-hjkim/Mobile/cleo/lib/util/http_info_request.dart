import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cleo/cleo_device/cleo_data.dart';
import 'package:cleo/cleo_device/cleo_device.dart';
import 'package:cleo/util/fittingDataCalc.dart';
// import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../model/test_report.dart';

// 220610 - HyeongJin Kim (SA)
// Description API HttpInfoRequest class 추가
// 220617 - HyeongJin Kim (SA)
// Description API rawdata delivery logic add
class HttpInfoRequest1 {
  final url = Uri.parse('https://wizdx.com/wizbio/api/v1'); // http uri parse
  late List<CleoData> cleoData; // 선언먼저하고 변수 사용 시 init
  late CleoDevice cleoDevice;

  var raw1;
  var raw2;
  var raw3;
  var rawTemp;
  var fitting1;
  var fitting2;
  var fitting3;
  var fittingTemp;
  var fittingCT;
  Future<List<CleoData>> getCleoData() async {
    return cleoData;
  }

  Future<List> getInfoList(TestReport testReport) async {
    // LIS http delivery func
    final dateTime = DateTime.now();
    final date = DateFormat('dd-MM-yyyy').format(dateTime);
    final time = DateFormat('HH:mm:ss').format(dateTime);
    final deviceId = testReport.serial; // 연결된 deviceID get
    final databaseId = deviceId +
        DateFormat('ddMMyyyyHHmmss')
            .format(dateTime); // deviceID + ddMMyyyyHHmmss

    // 기기에서 들어온 month형식이 Uppercase 형태 -> MMM format으로 변경해야 DataFormat 객체에서 Date type으로 인식 (ex. 24.OCT.2022 -> 24.Oct.2022)
    final String lowerExpire = testReport.expire.toLowerCase(); // LowerCase
    final RegExp regExp = RegExp(r'[a-z]');
    final replaceExpire = lowerExpire.replaceAll(
        regExp.stringMatch(lowerExpire).toString(),
        regExp
            .stringMatch(lowerExpire)
            .toString()
            .toUpperCase()); // 첫번째 문자만 UpperCase
    final dateParseExpire =
        DateFormat('dd.MMM.yyyy').parse(replaceExpire); // dateformat으로 parse
    final resultExpire = DateFormat('yyMMdd').format(
        dateParseExpire); // parse한 dateformat format change (ex. 221024)

    final testId = testReport.lotNum +
        date.replaceAll('-', '') +
        time.replaceAll(':', ''); // testID 조합

    int patientAge = int.parse(DateFormat('yyyy').format(dateTime).toString()) -
        int.parse(DateFormat('yyyy')
            .format(DateTime.parse(testReport.birthday))
            .toString()); // bitrthday calc

    final patientGender =
        (testReport.gender == 0) ? 'male' : 'female'; // gender calc
    // toString() 으로 변환시 데이터가 많아지면 중간부분은 '...' 으로 데이터가 생략 되어버리기 때문에 List로 변환후 string buffer를 활용해 데이터를 다시 써서 만들어줘야함
    raw1 = await changeStringScope(cleoData.map((row) => row.ch1).toList());
    raw2 = await changeStringScope(cleoData.map((row) => row.ch2).toList());
    raw3 = await changeStringScope(cleoData.map((row) => row.ch3).toList());
    rawTemp = await changeStringScope(
        cleoData.map((row) => row.celcius).toList()); // 온도 데이터
    // 220704 - HyeongJin Kim (SA)
    // Description fittingData calc logic 추가
    FittingDataCalc calc = FittingDataCalc();
    List<List<int>> sData = List.generate(3, (i) => []);
    List<List<double>> dData = List.generate(4, (i) => []);
    int mode = 1;

    sData[0] = cleoData.map((row) => row.ch1).toList();
    sData[1] = cleoData.map((row) => row.ch2).toList();
    sData[2] = cleoData.map((row) => row.ch3).toList();
    final scData = cleoData.where((row) => row.type == 'C');
    List<List<double>> fittingData = await calc.pcrDataProcess(
        sData, dData, mode, cleoDevice.crntCartridge!.ctValue);
    fitting1 = await changeStringScope(fittingData[0].toList()); // ch1
    fitting2 = await changeStringScope(fittingData[1].toList()); // ch2
    fitting3 = await changeStringScope(fittingData[2].toList()); // ch3
    fittingTemp = await changeStringScope(
        scData.map((row) => row.celcius).toList()); // 온도 데이터
    fittingCT = await changeStringScope(fittingData[3].toList()); // CT 데이터
    // fittingCT = '{28.0,28.0,28.0}';
    List<double> ctList = fittingData[3].toList();

    testReport.result1 = ctList[0];
    testReport.result2 = ctList[1];
    testReport.result3 = ctList[2];
    // /220704 - HyeongJin Kim (SA)

    Map testInfoData = {
      'databaseId': databaseId,
      'DeviceType': 'ONE',
      'DeviceId': deviceId,
      'TestId': testId,
      'TestName': testReport.testType,
      'Tester': testReport.name,
      'TestSlot': '1',
      'ExpireDate': resultExpire,
      'TestDate': date + " " + time,
      'LotNumber': testReport.lotNum,
      'ctValue': testReport.ctValue,
      'CatalogNumber': "",
      'patientResult': testReport.finalResult,
    }; // testInfoData map
    Map slotInfoData = {
      'databaseId': databaseId,
      'patientName': testReport.name,
      'patientAge': patientAge.toString(),
      'patientGender': patientGender,
      'patientResult': (() {
        if (testReport.finalResult == 1) {
          return testReport.testType == 'COVID-19' || testReport.testType == 'Unknown' ? 'Positive' : 'A & B Positive';
        } else if (testReport.finalResult == 2) {
          return 'A Positive';
        } else if (testReport.finalResult == 3) {
          return 'B Positive';
        } else if (testReport.finalResult == -1) {
          return 'Negative';
        } else {
          return 'Invalid';
        }
      })(),
      // 'patientResult': (testReport.finalResult == 1)
      //     ? 'Positive'
      //     : (testReport.finalResult == -1)
      //         ? 'Negative'
      //         : 'Invalid',
      'patientResult1': (testReport.pd1 == 1)
          ? 'Positive'
          : (testReport.pd1 == -1)
              ? 'Negative'
              : 'Invalid',
      'patientResult2': (testReport.pd2 == 1)
          ? 'Positive'
          : (testReport.pd2 == -1)
              ? 'Negative'
              : 'Invalid',
      'patientResult3': (testReport.pd3 == 1)
          ? 'Positive'
          : (testReport.pd3 == -1)
              ? 'Negative'
              : 'Invalid',
    }; // slotInfoData map
    Map slotInfoRawData = {
      'databaseId': databaseId,
      'rawData1': raw1.toString(),
      'rawData2': raw2.toString(),
      'rawData3': raw3.toString(),
      'rawTemp': rawTemp.toString()
    }; // slotInfoRawData map
    Map slotInfoFittingData = {
      'databaseId': databaseId,
      'fittingData1': fitting1.toString(),
      'fittingData2': fitting2.toString(),
      'fittingData3': fitting3.toString(),
      'fittingTemp': fittingTemp.toString(),
      'fittingCT': fittingCT.toString()
    }; // slotInfoFittingData map
    List infoList = [
      testInfoData,
      slotInfoData,
      slotInfoRawData,
      slotInfoFittingData
    ];
    return infoList;
  }

  Future<StringBuffer> changeStringScope(List list) async {
    // string scope '{}' and ',' add func
    var concatenate = StringBuffer();
    for (var i = 0; list.length > i; i++) {
      if (i == 0) {
        concatenate.write('{');
        concatenate.write(list[i].toString() + ',');
      } else if (i == list.length - 1) {
        concatenate.write(list[i].toString());
        concatenate.write('}');
      } else {
        concatenate.write(list[i].toString() + ',');
      }
    }
    return concatenate;
  }

// /220617 - HyeongJin Kim (SA)
  Future postJsonData(data) async {
    final result = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data)); // http delivery code
    if (result != null) {
      if (result.statusCode != 200) {
        throw Exception('Failed to load postJsonData');
      }
    } else {
      throw Exception('Failed to load postJsonData');
    }
    if (kDebugMode) {
      inspect(data);
      print(data);
    }
  }

  // Future<String> getDeviceUniqueId() async { device id 정책 변경으로 주석
  //   // connet deviceId get
  //   String deviceIdentifier = 'unknown';
  //   var deviceInfo = DeviceInfoPlugin();

  //   if (Platform.isAndroid) {
  //     var androidInfo = await deviceInfo.androidInfo;
  //     deviceIdentifier = androidInfo.androidId!;
  //   } else if (Platform.isIOS) {
  //     var iosInfo = await deviceInfo.iosInfo;
  //     deviceIdentifier = iosInfo.identifierForVendor!;
  //   } else if (Platform.isLinux) {
  //     var linuxInfo = await deviceInfo.linuxInfo;
  //     deviceIdentifier = linuxInfo.machineId!;
  //   } else if (kIsWeb) {
  //     var webInfo = await deviceInfo.webBrowserInfo;
  //     deviceIdentifier = webInfo.vendor! +
  //         webInfo.userAgent! +
  //         webInfo.hardwareConcurrency.toString();
  //   }
  //   return deviceIdentifier;
  // }

  // Future<void> setCleoData() async {
  //   // cleoData set
  //   await Future.delayed(const Duration(seconds: 5));
  //   cleoData = await cleoDevice.collectData();
  // }

  Future<void> setCleoDevice(CleoDevice cleoDevice) async {
    // cleoDevice set
    this.cleoDevice = cleoDevice;
  }

// 20220622 - HyeongJin Kim (SA)
// Description cleoData value check logic update
  Future<bool> checkCleoData() async {
    // cleoData check
    bool checkSum = false,
        ch1Check = false,
        ch2Check = false,
        ch3Check = false,
        tempCheck = false;
    int cnt = 0;
    while (!checkSum && cnt <= 4) {
      await Future.delayed(const Duration(seconds: 2));
      cleoData = await cleoDevice.collectData();
      ch1Check = await checkValue(cleoData.map((row) => row.ch1).toList());
      ch2Check = await checkValue(cleoData.map((row) => row.ch2).toList());
      ch3Check = await checkValue(cleoData.map((row) => row.ch3).toList());
      tempCheck = await checkValue(cleoData.map((row) => row.celcius).toList());
      if (ch1Check && ch2Check && ch3Check && tempCheck) {
        checkSum = true;
        await Future.delayed(const Duration(seconds: 5));
        break;
      } else {
        checkSum = false;
      }
      cnt++;
      await Future.delayed(const Duration(seconds: 28));
    }
    return checkSum;
  }

  Future<bool> checkValue(List row) async {
    // value에 0이 존재하면 false 리턴
    for (var element in row) {
      if (element == 0) {
        return false;
      }
    }
    return true;
  }
}
// /220622 - HyeongJin Kim (SA)
// /220610 - HyeongJin Kim (SA)

// import 'dart:convert';

// import 'package:cleo/cleo_device/cleo_data.dart';
// import 'package:cleo/cleo_device/cleo_device.dart';
// import 'package:intl/intl.dart';
// import 'package:http/http.dart' as http;

// import '../model/test_report.dart';

// // 220610 - HyeongJin Kim (SA)
// // Description API HttpInfoRequest class 추가
// // 220617 - HyeongJin Kim (SA)
// // Description API rawdata delivery logic add
class HttpInfoRequest2 {
  // final url = Uri.parse('https://wizdx.com/wizbio/api/v1'); // http uri parse
  late List<CleoData> cleoData; // 선언먼저하고 변수 사용 시 init
  late CleoDevice cleoDevice;

  var raw1;
  var raw2;
  var raw3;
  var rawTemp;
  var fitting1;
  var fitting2;
  var fitting3;
  var fittingTemp;
  var fittingCT;
  Future<List<CleoData>> getCleoData() async {
    return cleoData;
  }

  Future<List> getInfoList(TestReport testReport) async {
    // LIS http delivery func
    final dateTime = DateTime.now();
    final date = DateFormat('dd-MM-yyyy').format(dateTime);
    final time = DateFormat('HH:mm:ss').format(dateTime);
    final deviceId = testReport.serial; // 연결된 deviceID get
    final databaseId = deviceId +
        DateFormat('ddMMyyyyHHmmss')
            .format(dateTime); // deviceID + ddmmyyyyHHmmss

    // 기기에서 들어온 month형식이 Uppercase 형태 -> MMM format으로 변경해야 DataFormat 객체에서 Date type으로 인식 (ex. 24.OCT.2022 -> 24.Oct.2022)
    final String lowerExpire = testReport.expire.toLowerCase(); // LowerCase
    final RegExp regExp = RegExp(r'[a-z]');
    final replaceExpire = lowerExpire.replaceAll(
        regExp.stringMatch(lowerExpire).toString(),
        regExp
            .stringMatch(lowerExpire)
            .toString()
            .toUpperCase()); // 첫번째 문자만 UpperCase
    final dateParseExpire =
        DateFormat('dd.MMM.yyyy').parse(replaceExpire); // dateformat으로 parse
    final resultExpire = DateFormat('yyMMdd').format(
        dateParseExpire); // parse한 dateformat format change (ex. 221024)

    final endAtTime = DateFormat('dd-MM-yyyy HH:mm:ss')
        .format(DateFormat('yy-MM-dd HH:mm:ss').parse(testReport.endAt!));

    final testId = testReport.lotNum +
        date.replaceAll('-', '') +
        time.replaceAll(':', ''); // testID 조합

    int patientAge = int.parse(DateFormat('yyyy').format(dateTime).toString()) -
        int.parse(DateFormat('yyyy')
            .format(DateTime.parse(testReport.birthday))
            .toString()); // bitrthday calc

    // int patientAge = int.parse(testReport.birthday);

    // const patientGender = 'male'; // gender calc
    final patientGender =
        (testReport.gender == 0) ? 'male' : 'female'; // gender calc

    // toString() 으로 변환시 데이터가 많아지면 중간부분은 '...' 으로 데이터가 생략 되어버리기 때문에 List로 변환후 string buffer를 활용해 데이터를 다시 써서 만들어줘야함
    // raw1 = await changeStringScope(cleoData.map((row) => row.ch1).toList());
    // raw2 = await changeStringScope(cleoData.map((row) => row.ch2).toList());
    // raw3 = await changeStringScope(cleoData.map((row) => row.ch3).toList());
// rawTemp = await changeStringScope(
//         cleoData.map((row) => row.celcius).toList()); // 온도 데이터
    raw1 = testReport.rawData1;
    raw2 = testReport.rawData2;
    raw3 = testReport.rawData3;
    rawTemp = testReport.rawDataTemp;

    fitting1 = testReport.fittingData1;
    fitting2 = testReport.fittingData2;
    fitting3 = testReport.fittingData3;
    fittingTemp = testReport.fittingDataTemp;
    fittingCT = testReport.fittingDataCt;

    // 220704 - HyeongJin Kim (SA)
    // Description fittingData calc logic 추가
    // FittingDataCalc calc = FittingDataCalc();
    // List<List<int>> sData = List.generate(3, (i) => []);
    // List<List<double>> dData = List.generate(4, (i) => []);
    // int mode = 1;

    // sData[0] = cleoData.map((row) => row.ch1).toList();
    // sData[1] = cleoData.map((row) => row.ch2).toList();
    // sData[2] = cleoData.map((row) => row.ch3).toList();
    // final scData = cleoData.where((row) => row.type == 'C');
    // List<List<double>> fittigData =
    //     await calc.pcrDataProcess(sData, dData, mode, cleoDevice);
    // fitting1 = await changeStringScope(fittigData[0].toList()); // ch1
    // fitting2 = await changeStringScope(fittigData[1].toList()); // ch2
    // fitting3 = await changeStringScope(fittigData[2].toList()); // ch3
    // fittingTemp = await changeStringScope(
    //     scData.map((row) => row.celcius).toList()); // 온도 데이터
    // fittingCT = await changeStringScope(fittigData[3].toList()); // CT 데이터
    // /220704 - HyeongJin Kim (SA)

    Map testInfoData = {
      'databaseId': databaseId,
      'DeviceType': 'ONE',
      'DeviceId': deviceId,
      'TestId': testId,
      'TestName': testReport.testType,
      'Tester': testReport.name,
      'TestSlot': '1',
      'ExpireDate': resultExpire,
      'TestDate': endAtTime,
      'LotNumber': testReport.lotNum,
      // 'ctValue': testReport.ctValue,
      'CatalogNumber': "",
      'patientResult': testReport.finalResult,
    }; // testInfoData map
    Map slotInfoData = {
      'databaseId': databaseId,
      'patientName': testReport.name,
      'patientAge': patientAge.toString(),
      'patientGender': patientGender,
      'patientResult': (() {
        if (testReport.finalResult == 1) {
          return testReport.testType == 'COVID-19' ||
                  testReport.testType == 'Unknown'
              ? 'Positive'
              : 'A & B Positive';
        } else if (testReport.finalResult == 2) {
          return 'A Positive';
        } else if (testReport.finalResult == 3) {
          return 'B Positive';
        } else if (testReport.finalResult == -1) {
          return 'Negative';
        } else {
          return 'Invalid';
        }
      })(),
      // 'patientResult': (testReport.finalResult == 1)
      //     ? 'Positive'
      //     : (testReport.finalResult == -1)
      //         ? 'Negative'
      //         : 'Invalid',
      'patientResult1': (testReport.pd1 == 1)
          ? 'Positive'
          : (testReport.pd1 == -1)
              ? 'Negative'
              : 'Invalid',
      'patientResult2': (testReport.pd2 == 1)
          ? 'Positive'
          : (testReport.pd2 == -1)
              ? 'Negative'
              : 'Invalid',
      'patientResult3': (testReport.pd3 == 1)
          ? 'Positive'
          : (testReport.pd3 == -1)
              ? 'Negative'
              : 'Invalid',
    }; // slotInfoData map
    Map slotInfoRawData = {
      'databaseId': databaseId,
      'rawData1': raw1.toString(),
      'rawData2': raw2.toString(),
      'rawData3': raw3.toString(),
      'rawTemp': rawTemp.toString()
    }; // slotInfoRawData map
    Map slotInfoFittingData = {
      'databaseId': databaseId,
      'fittingData1': fitting1.toString(),
      'fittingData2': fitting2.toString(),
      'fittingData3': fitting3.toString(),
      'fittingTemp': fittingTemp.toString(),
      'fittingCT': fittingCT.toString()
    }; // slotInfoFittingData map
    List infoList = [
      testInfoData,
      slotInfoData,
      slotInfoRawData,
      slotInfoFittingData
    ];
    return infoList;
  }

  Future<StringBuffer> changeStringScope(List list) async {
    // string scope '{}' and ',' add func
    var concatenate = StringBuffer();
    for (var i = 0; list.length > i; i++) {
      if (i == 0) {
        concatenate.write('{');
        concatenate.write(list[i].toString() + ',');
      } else if (i == list.length - 1) {
        concatenate.write(list[i].toString());
        concatenate.write('}');
      } else {
        concatenate.write(list[i].toString() + ',');
      }
    }
    return concatenate;
  }

// /220617 - HyeongJin Kim (SA)
  Future<String> postJsonData(data, Uri url) async {
    try {
      var result = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(data)); // http delivery code
    } catch (e) {
      return 'error';
    }

    return 'completed';
    // if (result != null) {
    //   if (result.statusCode != 200) {
    //     throw 'Faild to postJsonData';
    //   }
    // } else {
    //   throw 'Faild to postJsonData';
    // }
  }

  // Future<String> getDeviceUniqueId() async { device id 정책 변경으로 주석
  //   // connet deviceId get
  //   String deviceIdentifier = 'unknown';
  //   var deviceInfo = DeviceInfoPlugin();

  //   if (Platform.isAndroid) {
  //     var androidInfo = await deviceInfo.androidInfo;
  //     deviceIdentifier = androidInfo.androidId!;
  //   } else if (Platform.isIOS) {
  //     var iosInfo = await deviceInfo.iosInfo;
  //     deviceIdentifier = iosInfo.identifierForVendor!;
  //   } else if (Platform.isLinux) {
  //     var linuxInfo = await deviceInfo.linuxInfo;
  //     deviceIdentifier = linuxInfo.machineId!;
  //   } else if (kIsWeb) {
  //     var webInfo = await deviceInfo.webBrowserInfo;
  //     deviceIdentifier = webInfo.vendor! +
  //         webInfo.userAgent! +
  //         webInfo.hardwareConcurrency.toString();
  //   }
  //   return deviceIdentifier;
  // }

  // Future<void> setCleoData() async {
  //   // cleoData set
  //   await Future.delayed(const Duration(seconds: 5));
  //   cleoData = await cleoDevice.collectData();
  // }

  Future<void> setCleoDevice(CleoDevice cleoDevice) async {
    // cleoDevice set
    this.cleoDevice = cleoDevice;
  }

// 20220622 - HyeongJin Kim (SA)
// Description cleoData value check logic update
  Future<bool> checkCleoData() async {
    // cleoData check
    bool checkSum = false,
        ch1Check = false,
        ch2Check = false,
        ch3Check = false,
        tempCheck = false;
    int cnt = 0;
    while (!checkSum && cnt <= 4) {
      await Future.delayed(const Duration(seconds: 2));
      cleoData = await cleoDevice.collectData();
      ch1Check = await checkValue(cleoData.map((row) => row.ch1).toList());
      ch2Check = await checkValue(cleoData.map((row) => row.ch2).toList());
      ch3Check = await checkValue(cleoData.map((row) => row.ch3).toList());
      tempCheck = await checkValue(cleoData.map((row) => row.celcius).toList());
      if (ch1Check && ch2Check && ch3Check && tempCheck) {
        checkSum = true;
        await Future.delayed(const Duration(seconds: 5));
        break;
      } else {
        checkSum = false;
      }
      cnt++;
      await Future.delayed(const Duration(seconds: 28));
    }
    return checkSum;
  }

  Future<bool> checkValue(List row) async {
    // value에 0이 존재하면 false 리턴
    for (var element in row) {
      if (element == 0) {
        return false;
      }
    }
    return true;
  }
}
// /220622 - HyeongJin Kim (SA)
// /220610 - HyeongJin Kim (SA)
