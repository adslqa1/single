class CartridgeInfo {
  final String expDate;
  final String lotNum;
  final String testType;
  final String refNo;
  final String ctValue;

  final String cycle; //50,30sec reference
  final String isoTemperature; //61
  final String current; //12
  final String gainDefault; //2
  final String gainSelect; //2
  final String preTestCycle; //30,SP
  final String preTestTime; //10,SP
  final String afterTestCycle; //40,SC
  final String afterTestTime; //30,SC
  final String rtTemperature; //50
  final String rtTime; //300

  CartridgeInfo(
      this.testType,
      this.lotNum,
      this.expDate,
      this.refNo,
      this.ctValue,

      this.cycle,
      this.isoTemperature,
      this.current,
      this. gainDefault,
      this. gainSelect,
      this.preTestCycle,
      this.preTestTime,
      this.afterTestCycle,
      this.afterTestTime,
      this.rtTemperature,
      this.rtTime
      );

  CartridgeInfo.fromJson(json)
      : testType = json['testType'],
        lotNum = json['lotNum'],
        expDate = json['expDate'],
        refNo = json['refNo'],
        ctValue = json['ctValue'],

        cycle = json['cycle'],
        isoTemperature = json['isoTemperature'],
        current = json['current'],
        gainDefault = json['gainDefault'],
        gainSelect= json['gainSelect'],
        preTestCycle = json['preTestCycle'],
        preTestTime = json['preTestTime'],
        afterTestCycle = json['afterTestCycle'],
        afterTestTime = json['afterTestTime'],
        rtTemperature = json['rtTemperature'],
        rtTime = json['rtTime']
        ;

  Map<String, String> toJson() {
    return {
      'expDate': expDate,
      'lotNum': lotNum,
      'testType': testType,
      'refNo': refNo,
      'ctValue': ctValue,

      'cycle': cycle,
      'isoTemperature': isoTemperature,
      'current': current,
      'gainDefault': gainDefault,
      'gainSelect': gainSelect,
      'preTestCycle': preTestCycle,
      'preTestTime': preTestTime,
      'afterTestCycle': afterTestCycle,
      'afterTestTime': afterTestTime,
      'rtTemperature': rtTemperature,
      'rtTime': rtTime
    };
  }
}
