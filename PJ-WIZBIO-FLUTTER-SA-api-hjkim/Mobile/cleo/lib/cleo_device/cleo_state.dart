// import 'package:cleo/main.dart';
import 'package:cleo/util/device_mem.dart';
import 'package:flutter/widgets.dart';

import 'cleo_device.dart';
import 'cleo_error.dart';

final stepMsgStateMap = {
  'C,P,0001': (CleoDevice device, String msg) => QrScanState(device, msg),
  'C,P,0002': (CleoDevice device, String msg) =>
      CartridgeInsertState(device, msg),
  'C,P,0003': (CleoDevice device, String msg) =>
      CartridgeTubeOpenState(device, msg),
  'C,P,0004': (CleoDevice device, String msg) =>
      CartridgeSwabOpenState(device, msg),
  'C,P,0005': (CleoDevice device, String msg) =>
      CartridgeSampleGetState(device, msg),
  'C,P,0006': (CleoDevice device, String msg) =>
      CartridgeSampleCloseState(device, msg),
  'C,P,0007': (CleoDevice device, String msg) =>
      CartridgeSampleMixState(device, msg),
  // 'C,P,0008': (CleoDevice device, String msg) =>
  //     CartridgeTubeInsertState(device, msg),
  'C,P,0008': (CleoDevice device, String msg) => CloseCoverState(device, msg),
  'C,P,0009': (CleoDevice device, String msg) => TestProgressState(device, msg),
  'C,P,0010': (CleoDevice device, String msg) => TestProgressState(device, msg),
  'C,P,0011': (CleoDevice device, String msg) => TestCompleteState(device, msg),
};

class CleoState with ChangeNotifier {
  final CleoDevice device;
  String get name => 'CleoState';
  String lastSent = '';
  final String lastMsg;

  CleoState(this.device, this.lastMsg);

  factory CleoState.fromSaved(CleoDevice device, String stateSave) {
    final lastMsg = stateSave;
    return IdleState(device, lastMsg);
  }

  CleoState handleDeviceMsg(String msg) {
    final trimmed = msg.trim();

    final error = tryParseError(trimmed);
    if (error != null) {
      device.updateError(error);
      return this;
    }

    if (trimmed.startsWith('C,P,') && trimmed != 'C,P,F') {
      if (stepMsgStateMap.keys.contains(trimmed)) {
        device.waitPair = false;
        final newState = processStateMsg(trimmed);
        return newState;
      } else {
        final parts = trimmed.split(',');
        final serialNum = parts[3];
        DeviceMem.setDeviceSerial(device.device.id.toString(), serialNum);
        device.serial = serialNum;
        device.waitPair = false;
        device.notifyListeners();

        return this;
      }
    }

    if (trimmed == 'P,P') {
      device.updateError(null);
      return IdleState(device, trimmed);
    }
    if (trimmed == 'C,D') {
      device.updateError(null);
      device.crntTesterId = null;
      device.waitPair = true;
      device.notifyListeners();
      device.device.disconnect();
      return IdleState(device, trimmed);
    }
    if (trimmed == 'C,F') {
      debugPrint('연결 프로토콜 에러?');
      device.sendMsg(lastMsg);
      return this;
    }
    if (trimmed.startsWith('T,E')) {
      device.sendMsg(trimmed);
      device.updateError(CustomError(trimmed));
      return this;
    }

    if (trimmed == 'T,N,C,0000') {
      const response = 'T,P,C,P';
      device.sendMsg(response);
      if (device.error is CartridgeMissingError) {
        device.updateError(null);
      }
      return this;
    }

    debugPrint('WARN :: unhandled msg >>>> $trimmed');
    notifyListeners();
    return this;
  }

  CleoError? tryParseError(String trimmed) {
    // these error is final error that would not be reverted

    if (trimmed == 'C,P,F') {
      return InUseError(trimmed);
    }
    if (trimmed == 'B,F') {
      return StepProtocolError(trimmed);
    }
    if (trimmed == 'E,S,F') {
      return ConditionProtocolError(trimmed);
    }
    if (trimmed == 'P,F') {
      return StopProtocolError(trimmed);
    }
    if (trimmed == 'T,N,F') {
      return StatusProtocolError(trimmed);
    }
    if (trimmed == 'T,N,L,0001,0003') {
      return CoverTimeoutError(trimmed);
    }
    if (trimmed == 'T,N,C,0001,0001') {
      return CartridgeMissingError(trimmed);
    }
    if (trimmed.startsWith('T,N,C,0001')) {
      return CartridgeError(trimmed);
    }
    if (trimmed.startsWith('T,N,H,0001')) {
      return HeatControlError(trimmed);
    }
    if (trimmed.startsWith('T,N,M,0001')) {
      return LightControlError(trimmed);
    }
    if (trimmed.startsWith('T,N,S,0001')) {
      return SolutionStatusError(trimmed);
    }
    if (trimmed.startsWith('T,N,L,0001')) {
      return CoverStatusError(trimmed);
    }
    return null;
  }

  Future cancelTest() {
    return device.sendMsg('P');
  }

  Future disconnectUser() {
    return device.sendMsg('C,D');
  }

  CleoState processStateMsg(String trimmed) {
    final stateMaker = stepMsgStateMap[trimmed];
    if (stateMaker == null) {
      throw 'Not defined State Code';
    }
    return stateMaker(device, trimmed);
  }
}

class IdleState extends CleoState {
  @override
  String get name => 'IdleState';

  IdleState(CleoDevice device, String lastMsg) : super(device, lastMsg);

  @override
  handleDeviceMsg(String msg) {
    final trimmed = msg.trim();

    if (trimmed == 'C') {
      device.waitPair = true;
      notifyListeners();
      return this;
    }

    if (trimmed == 'T,N,0000') {
      return this;
    }

    return super.handleDeviceMsg(msg);
  }

  // pairUser(int userId) {
  //   device.crntTesterId = userId;
  //   lastSent = 'C,P,$userId';
  //   device.updateState(PairingState(device, lastSent));
  //   device.sendMsg(lastSent);
  // }
}

class PairingState extends CleoState {
  @override
  String get name => 'PairingState';

  PairingState(CleoDevice device, String lastMsg) : super(device, lastMsg);

  @override
  handleDeviceMsg(String msg) {
    final trimmed = msg.trim();

    if (trimmed == 'T,N,0000') {
      return IdleState(device, trimmed);
    }

    return super.handleDeviceMsg(msg);
  }
}

// class PairedState extends CleoState {
//   @override
//   String get name => 'PairedState';

//   PairedState(CleoDevice device, String lastMsg) : super(device, lastMsg);

//   @override
//   handleDeviceMsg(String msg) {
//     final trimmed = msg.trim();

//     if (stepMsgStateMap.keys.contains(trimmed)) {
//       return processStateMsg(trimmed);
//     }
//     if (trimmed.startsWith('C,P,')) {
//       return IdleState(device, trimmed);
//     }
//     if (trimmed == 'T,N,0000') {
//       return IdleState(device, trimmed);
//     }

//     return super.handleDeviceMsg(msg);
//   }
// }

class ErrorState extends CleoState {
  @override
  String get name => 'ErrorState';
  final CleoError error;
  ErrorState(CleoDevice device, String lastMsg, this.error)
      : super(device, lastMsg);

  @override
  handleDeviceMsg(String msg) {
    final trimmed = msg.trim();
    debugPrint('msg while error :: $msg');
    return super.handleDeviceMsg(trimmed);
  }
}

class UserSelectState extends CleoState {
  @override
  String get name => 'UserSelectState';

  UserSelectState(CleoDevice device, String lastMsg) : super(device, lastMsg);

  @override
  handleDeviceMsg(String msg) {
    final trimmed = msg.trim();
    if (trimmed == 'C,P') {
      return QrScanState(device, trimmed);
    }
    return super.handleDeviceMsg(msg);
  }

  selectUser(int userId) {
    final lastSent = 'C,N,$userId';
    device.sendMsg(lastSent);
  }
}

class QrScanState extends CleoState {
  @override
  String get name => 'QrScanState';

  QrScanState(CleoDevice device, String lastMsg) : super(device, lastMsg);

  @override
  handleDeviceMsg(String msg) {
    final trimmed = msg.trim();
    if (trimmed == 'E,S,P') {
      // return CartridgeTubeOpenState(device, trimmed);
      return CartridgeInsertState(device, trimmed);

    }
    return super.handleDeviceMsg(msg);
  }

  sendSetting() {
    lastSent =
        'E,P,'
        '${device.crntCartridge!.cycle},' //2
        '${device.crntCartridge!.isoTemperature},'  //3
        '${device.crntCartridge!.current},' //4
        '${device.crntCartridge!.gainDefault},'  //5
        '${device.crntCartridge!.gainSelect},'  //6
        '${device.crntCartridge!.preTestCycle},'  //7
        '${device.crntCartridge!.preTestTime},'  //8
        '${device.crntCartridge!.afterTestCycle},'  //9
        '${device.crntCartridge!.afterTestTime},'  //10
        '${device.crntCartridge!.rtTemperature},'  //11
        '${device.crntCartridge!.rtTime}' //12
        ;
    device.sendMsg(lastSent);
  }

  sendCancel() {
    lastSent = 'P';
    return device.sendMsg(lastSent);
  }
}

class CartridgeInsertState extends CleoState {
  @override
  String get name => 'CartridgeInsertState';
  bool hasCartridge;

  CartridgeInsertState(CleoDevice device, String lastMsg,
      {this.hasCartridge = false})
      : super(device, lastMsg);

  @override
  handleDeviceMsg(String msg) {
    final trimmed = msg.trim();
    if (trimmed == 'T,N,C,0000') {
      hasCartridge = true;
      notifyListeners();
      device.sendMsg('T,P,C,P');
      device.updateState(CloseCoverState(device, ''));
      return CloseCoverState(device, trimmed);
    }
    if (trimmed == 'B,P') {
      // return CartridgeSampleMixState(device, lastMsg);
      return QrScanState(device, lastMsg);
    }

    return super.handleDeviceMsg(msg);
  }

  // goNext() {
  //   device.sendMsg('T,P,C,P');
  //   device.updateState(CloseCoverState(device, ''));
  // }

  goBack() {
    lastSent = 'B';
    return device.sendMsg(lastSent);
  }
}

class CartridgeTubeOpenState extends CleoState {
  @override
  String get name => 'CartridgeTubeOpenState';

  CartridgeTubeOpenState(CleoDevice device, String lastMsg)
      : super(device, lastMsg);

  @override
  handleDeviceMsg(String msg) {
    final trimmed = msg.trim();
    if (trimmed == 'B,P') {
      return QrScanState(device, trimmed);
    }
    if (trimmed == 'T,N,S,P') {
      return CartridgeSwabOpenState(device, trimmed);
    }

    return super.handleDeviceMsg(msg);
  }

  goNext() {
    lastSent = 'T,N,S,0001';
    return device.sendMsg(lastSent);
  }

  goBack() {
    lastSent = 'B';
    return device.sendMsg(lastSent);
  }
}

class CartridgeSwabOpenState extends CleoState {
  @override
  String get name => 'CartridgeSwabOpenState';

  CartridgeSwabOpenState(CleoDevice device, String lastMsg)
      : super(device, lastMsg);

  @override
  handleDeviceMsg(String msg) {
    final trimmed = msg.trim();
    if (trimmed == 'B,P') {
      return CartridgeTubeOpenState(device, trimmed);
    }
    if (trimmed == 'T,N,S,P') {
      return CartridgeSampleGetState(device, trimmed);
    }

    return super.handleDeviceMsg(msg);
  }

  goNext() {
    lastSent = 'T,N,S,0002';
    return device.sendMsg(lastSent);
  }

  goBack() {
    lastSent = 'B';
    return device.sendMsg(lastSent);
  }
}

class CartridgeSampleGetState extends CleoState {
  @override
  String get name => 'CartridgeSampleGetState';

  CartridgeSampleGetState(CleoDevice device, String lastMsg)
      : super(device, lastMsg);

  @override
  handleDeviceMsg(String msg) {
    final trimmed = msg.trim();
    if (trimmed == 'B,P') {
      return CartridgeSwabOpenState(device, trimmed);
    }
    if (trimmed == 'T,N,S,P') {
      return CartridgeSampleCloseState(device, trimmed);
    }

    return super.handleDeviceMsg(msg);
  }

  goNext() {
    lastSent = 'T,N,S,0003';
    return device.sendMsg(lastSent);
  }

  goBack() {
    lastSent = 'B';
    return device.sendMsg(lastSent);
  }
}

class CartridgeSampleCloseState extends CleoState {
  @override
  String get name => 'CartridgeSampleCloseState';

  CartridgeSampleCloseState(CleoDevice device, String lastMsg)
      : super(device, lastMsg);

  @override
  handleDeviceMsg(String msg) {
    final trimmed = msg.trim();
    if (trimmed == 'B,P') {
      return CartridgeSampleGetState(device, trimmed);
    }
    if (trimmed == 'T,N,S,P') {
      return CartridgeSampleMixState(device, trimmed);
    }

    return super.handleDeviceMsg(msg);
  }

  goNext() {
    lastSent = 'T,N,S,0004';
    return device.sendMsg(lastSent);
  }

  goBack() {
    lastSent = 'B';
    return device.sendMsg(lastSent);
  }
}

class CartridgeSampleMixState extends CleoState {
  @override
  String get name => 'CartridgeSampleMixState';

  CartridgeSampleMixState(CleoDevice device, String lastMsg)
      : super(device, lastMsg);

  @override
  handleDeviceMsg(String msg) {
    final trimmed = msg.trim();
    if (trimmed == 'B,P') {
      return CartridgeSampleCloseState(device, trimmed);
    }
    if (trimmed == 'T,N,S,P') {
      return CartridgeInsertState(device, trimmed);
    }

    return super.handleDeviceMsg(msg);
  }

  goNext() {
    lastSent = 'T,N,S,0005';
    return device.sendMsg(lastSent);
  }

  goBack() {
    lastSent = 'B';
    return device.sendMsg(lastSent);
  }
}

// class CartridgeTubeInsertState extends CleoState {
//   @override
//   String get name => 'CartridgeTubeInsertState';

//   CartridgeTubeInsertState(CleoDevice device, String lastMsg)
//       : super(device, lastMsg);

//   @override
//   handleDeviceMsg(String msg) {
//     final trimmed = msg.trim();
//     if (trimmed == 'B,P') {
//       return CartridgeSampleMixState(device, trimmed);
//     }
//     if (trimmed == 'T,N,S,P') {
//       return CloseCoverState(device, trimmed);
//     }

//     return super.handleDeviceMsg(msg);
//   }

//   goNext() {
//     lastSent = 'T,N,S,0006';
//     return device.sendMsg(lastSent);
//   }

//   goBack() {
//     lastSent = 'B';
//     return device.sendMsg(lastSent);
//   }
// }

class CloseCoverState extends CleoState {
  @override
  String get name => 'CloseCoverState';

  CloseCoverState(CleoDevice device, String lastMsg) : super(device, lastMsg);

  @override
  handleDeviceMsg(String msg) {
    final trimmed = msg.trim();
    if (trimmed == 'T,N,L,0000') {
      lastSent = 'T,N,L,P';
      device.sendMsg(lastSent);
      return TestProgressState(device, trimmed);
    }

    if (trimmed == 'B,P') {
      // return CartridgeSampleMixState(device, trimmed);
      return CartridgeInsertState(device, trimmed);
    }
    return super.handleDeviceMsg(msg);
  }

  goBack() {
    lastSent = 'B';
    return device.sendMsg(lastSent);
  }
}

class TestProgressState extends CleoState {
  @override
  String get name => 'TestProgressState';

  TestProgressState(CleoDevice device, String lastMsg) : super(device, lastMsg);

  @override
  handleDeviceMsg(String msg) {
    final trimmed = msg.trim();
    if (trimmed == 'T,N,L,0001,0001') {
      lastSent = 'T,N,L,0001,P';
      device.sendMsg(lastSent);
      return ProgressCoverOpenState(device, trimmed);
    }

    return super.handleDeviceMsg(msg);
  }

  sendCancel() {
    lastSent = 'P';
    return device.sendMsg(lastSent);
  }
}

class ProgressCoverOpenState extends CleoState {
  ProgressCoverOpenState(CleoDevice device, String lastMsg)
      : super(device, lastMsg);

  @override
  String get name => 'ProgressCoverOpen';

  @override
  handleDeviceMsg(String msg) {
    final trimmed = msg.trim().toUpperCase();
    if (trimmed == 'T,N,L,0000') {
      lastSent = 'T,N,L,P';
      device.sendMsg(lastSent);
      return TestProgressState(device, trimmed);
    }

    if (trimmed == 'T,N,L,0001,0001') {
      return this;
    }

    if (trimmed == 'T,N,L,0001,0002') {
      lastSent = 'T,N,L,0001,P';
      device.sendMsg(lastSent);
      device.updateError(CoverTimeoutError(trimmed));
      return this;
    }

    return super.handleDeviceMsg(msg);
  }
}

class TestCompleteState extends CleoState {
  @override
  String get name => 'TestCompleteState';

  TestCompleteState(CleoDevice device, String lastMsg) : super(device, lastMsg);

  @override
  handleDeviceMsg(String msg) {
    final trimmed = msg.trim();
    return super.handleDeviceMsg(trimmed);
  }

  requestSPdata(int cycle) {
    String cycleStr = cycle.toString().padLeft(4, '0');
    return device.sendMsg('S,P,$cycleStr');
  }

  requestSCdata(int cycle) {
    String cycleStr = cycle.toString().padLeft(4, '0');
    return device.sendMsg('S,P,$cycleStr');
  }

  sendFinish() {
    lastSent = 'P';
    return device.sendMsg(lastSent);
  }
}






// // import 'package:cleo/main.dart';
// import 'package:cleo/util/device_mem.dart';
// import 'package:flutter/widgets.dart';

// import 'cleo_device.dart';
// import 'cleo_error.dart';

// final stepMsgStateMap = {
//   'C,P,0001': (CleoDevice device, String msg) => QrScanState(device, msg),
//   'C,P,0002': (CleoDevice device, String msg) =>
//       CartridgeInsertState(device, msg),
//   'C,P,0003': (CleoDevice device, String msg) =>
//       CartridgeTubeOpenState(device, msg),
//   'C,P,0004': (CleoDevice device, String msg) =>
//       CartridgeSwabOpenState(device, msg),
//   'C,P,0005': (CleoDevice device, String msg) =>
//       CartridgeSampleGetState(device, msg),
//   'C,P,0006': (CleoDevice device, String msg) =>
//       CartridgeSampleCloseState(device, msg),
//   'C,P,0007': (CleoDevice device, String msg) =>
//       CartridgeSampleMixState(device, msg),
//   // 'C,P,0008': (CleoDevice device, String msg) =>
//   //     CartridgeTubeInsertState(device, msg),
//   'C,P,0008': (CleoDevice device, String msg) => CloseCoverState(device, msg),
//   'C,P,0009': (CleoDevice device, String msg) => TestProgressState(device, msg),
//   'C,P,0010': (CleoDevice device, String msg) => TestProgressState(device, msg),
//   'C,P,0011': (CleoDevice device, String msg) => TestCompleteState(device, msg),
// };

// class CleoState with ChangeNotifier {
//   final CleoDevice device;
//   String get name => 'CleoState';
//   String lastSent = '';
//   final String lastMsg;

//   CleoState(this.device, this.lastMsg);

//   factory CleoState.fromSaved(CleoDevice device, String stateSave) {
//     final lastMsg = stateSave;
//     return IdleState(device, lastMsg);
//   }

//   CleoState handleDeviceMsg(String msg) {
//     final trimmed = msg.trim();

//     final error = tryParseError(trimmed);
//     if (error != null) {
//       device.updateError(error);
//       return this;
//     }

//     if (trimmed.startsWith('C,P,') && trimmed != 'C,P,F') {
//       if (stepMsgStateMap.keys.contains(trimmed)) {
//         device.waitPair = false;
//         final newState = processStateMsg(trimmed);
//         return newState;
//       } else {
//         final parts = trimmed.split(',');
//         final serialNum = parts[3];
//         DeviceMem.setDeviceSerial(device.device.id.toString(), serialNum);
//         device.serial = serialNum;
//         device.waitPair = false;
//         device.notifyListeners();

//         return this;
//       }
//     }

//     if (trimmed == 'P,P') {
//       device.updateError(null);
//       return IdleState(device, trimmed);
//     }
//     if (trimmed == 'C,D') {
//       device.updateError(null);
//       device.crntTesterId = null;
//       device.waitPair = true;
//       device.notifyListeners();
//       device.device.disconnect();
//       return IdleState(device, trimmed);
//     }
//     if (trimmed == 'C,F') {
//       debugPrint('연결 프로토콜 에러?');
//       device.sendMsg(lastMsg);
//       return this;
//     }
//     if (trimmed.startsWith('T,E')) {
//       device.sendMsg(trimmed);
//       device.updateError(CustomError(trimmed));
//       return this;
//     }

//     if (trimmed == 'T,N,C,0000') {
//       const response = 'T,P,C,P';
//       device.sendMsg(response);
//       if (device.error is CartridgeMissingError) {
//         device.updateError(null);
//       }
//       return this;
//     }

//     debugPrint('WARN :: unhandled msg >>>> $trimmed');
//     notifyListeners();
//     return this;
//   }

//   CleoError? tryParseError(String trimmed) {
//     // these error is final error that would not be reverted

//     if (trimmed == 'C,P,F') {
//       return InUseError(trimmed);
//     }
//     if (trimmed == 'B,F') {
//       return StepProtocolError(trimmed);
//     }
//     if (trimmed == 'E,S,F') {
//       return ConditionProtocolError(trimmed);
//     }
//     if (trimmed == 'P,F') {
//       return StopProtocolError(trimmed);
//     }
//     if (trimmed == 'T,N,F') {
//       return StatusProtocolError(trimmed);
//     }
//     if (trimmed == 'T,N,L,0001,0003') {
//       return CoverTimeoutError(trimmed);
//     }
//     if (trimmed == 'T,N,C,0001,0001') {
//       return CartridgeMissingError(trimmed);
//     }
//     if (trimmed.startsWith('T,N,C,0001')) {
//       return CartridgeError(trimmed);
//     }
//     if (trimmed.startsWith('T,N,H,0001')) {
//       return HeatControlError(trimmed);
//     }
//     if (trimmed.startsWith('T,N,M,0001')) {
//       return LightControlError(trimmed);
//     }
//     if (trimmed.startsWith('T,N,S,0001')) {
//       return SolutionStatusError(trimmed);
//     }
//     if (trimmed.startsWith('T,N,L,0001')) {
//       return CoverStatusError(trimmed);
//     }
//     return null;
//   }

//   Future cancelTest() {
//     return device.sendMsg('P');
//   }

//   Future disconnectUser() {
//     return device.sendMsg('C,D');
//   }

//   CleoState processStateMsg(String trimmed) {
//     final stateMaker = stepMsgStateMap[trimmed];
//     if (stateMaker == null) {
//       throw 'Not defined State Code';
//     }
//     return stateMaker(device, trimmed);
//   }
// }

// class IdleState extends CleoState {
//   @override
//   String get name => 'IdleState';

//   IdleState(CleoDevice device, String lastMsg) : super(device, lastMsg);

//   @override
//   handleDeviceMsg(String msg) {
//     final trimmed = msg.trim();

//     if (trimmed == 'C') {
//       device.waitPair = true;
//       notifyListeners();
//       return this;
//     }

//     if (trimmed == 'T,N,0000') {
//       return this;
//     }

//     return super.handleDeviceMsg(msg);
//   }

//   // pairUser(int userId) {
//   //   device.crntTesterId = userId;
//   //   lastSent = 'C,P,$userId';
//   //   device.updateState(PairingState(device, lastSent));
//   //   device.sendMsg(lastSent);
//   // }
// }

// class PairingState extends CleoState {
//   @override
//   String get name => 'PairingState';

//   PairingState(CleoDevice device, String lastMsg) : super(device, lastMsg);

//   @override
//   handleDeviceMsg(String msg) {
//     final trimmed = msg.trim();

//     if (trimmed == 'T,N,0000') {
//       return IdleState(device, trimmed);
//     }

//     return super.handleDeviceMsg(msg);
//   }
// }

// // class PairedState extends CleoState {
// //   @override
// //   String get name => 'PairedState';

// //   PairedState(CleoDevice device, String lastMsg) : super(device, lastMsg);

// //   @override
// //   handleDeviceMsg(String msg) {
// //     final trimmed = msg.trim();

// //     if (stepMsgStateMap.keys.contains(trimmed)) {
// //       return processStateMsg(trimmed);
// //     }
// //     if (trimmed.startsWith('C,P,')) {
// //       return IdleState(device, trimmed);
// //     }
// //     if (trimmed == 'T,N,0000') {
// //       return IdleState(device, trimmed);
// //     }

// //     return super.handleDeviceMsg(msg);
// //   }
// // }

// class ErrorState extends CleoState {
//   @override
//   String get name => 'ErrorState';
//   final CleoError error;
//   ErrorState(CleoDevice device, String lastMsg, this.error)
//       : super(device, lastMsg);

//   @override
//   handleDeviceMsg(String msg) {
//     final trimmed = msg.trim();
//     debugPrint('msg while error :: $msg');
//     return super.handleDeviceMsg(trimmed);
//   }
// }

// class UserSelectState extends CleoState {
//   @override
//   String get name => 'UserSelectState';

//   UserSelectState(CleoDevice device, String lastMsg) : super(device, lastMsg);

//   @override
//   handleDeviceMsg(String msg) {
//     final trimmed = msg.trim();
//     if (trimmed == 'C,P') {
//       return QrScanState(device, trimmed);
//     }
//     return super.handleDeviceMsg(msg);
//   }

//   selectUser(int userId) {
//     final lastSent = 'C,N,$userId';
//     device.sendMsg(lastSent);
//   }
// }

// class QrScanState extends CleoState {
//   @override
//   String get name => 'QrScanState';
//   bool hasCartridge;

//   QrScanState(CleoDevice device, String lastMsg, {this.hasCartridge = false})
//       : super(device, lastMsg);

//   @override
//   handleDeviceMsg(String msg) {
//     final trimmed = msg.trim();
//     if (trimmed == 'E,S,P') {
//       // return CartridgeTubeOpenState(device, trimmed);
//       // return CartridgeInsertState(device, trimmed);

//     }
//     //cartridge
//     if (trimmed == 'T,N,C,0000') {
//       hasCartridge = true;
//       notifyListeners();
//       device.sendMsg('T,P,C,P');
//       // device.updateState(CloseCoverState(device, ''));
//       // return CloseCoverState(device, trimmed);
//     }
//     if (hasCartridge == false) {
//       if (trimmed == 'B,P') {
//         // return CartridgeSampleMixState(device, lastMsg);
//         return QrScanState(device, lastMsg);
//       }
//     }
//     //lid
//     if (trimmed == 'T,N,L,0000') {
//       lastSent = 'T,N,L,P';
//       device.sendMsg(lastSent);
//       return TestProgressState(device, trimmed);
//     }
//     if (hasCartridge == true) {
//       if (trimmed == 'B,P') {
//         hasCartridge == false;
//         return QrScanState(device, lastMsg);
//       }
//     }

//     return super.handleDeviceMsg(msg);
//   }

//   sendSetting() {
//     lastSent = 'E,P,'
//             '${device.crntCartridge!.cycle},' //2
//             '${device.crntCartridge!.isoTemperature},' //3
//             '${device.crntCartridge!.current},' //4
//             '${device.crntCartridge!.gainDefault},' //5
//             '${device.crntCartridge!.gainSelect},' //6
//             '${device.crntCartridge!.preTestCycle},' //7
//             '${device.crntCartridge!.preTestTime},' //8
//             '${device.crntCartridge!.afterTestCycle},' //9
//             '${device.crntCartridge!.afterTestTime},' //10
//             '${device.crntCartridge!.rtTemperature},' //11
//             '${device.crntCartridge!.rtTime}' //12
//         ;
//     device.sendMsg(lastSent);
//   }

//   sendCancel() {
//     lastSent = 'P';
//     return device.sendMsg(lastSent);
//   }
// }

// class CartridgeInsertState extends CleoState {
//   @override
//   String get name => 'CartridgeInsertState';
//   bool hasCartridge;

//   CartridgeInsertState(CleoDevice device, String lastMsg,
//       {this.hasCartridge = false})
//       : super(device, lastMsg);

//   @override
//   handleDeviceMsg(String msg) {
//     final trimmed = msg.trim();
//     if (trimmed == 'T,N,C,0000') {
//       hasCartridge = true;
//       notifyListeners();
//       device.sendMsg('T,P,C,P');
//       device.updateState(CloseCoverState(device, ''));
//       return CloseCoverState(device, trimmed);
//     }
//     if (trimmed == 'B,P') {
//       // return CartridgeSampleMixState(device, lastMsg);
//       return QrScanState(device, lastMsg);
//     }

//     return super.handleDeviceMsg(msg);
//   }

//   // goNext() {
//   //   device.sendMsg('T,P,C,P');
//   //   device.updateState(CloseCoverState(device, ''));
//   // }

//   goBack() {
//     lastSent = 'B';
//     return device.sendMsg(lastSent);
//   }
// }

// class CartridgeTubeOpenState extends CleoState {
//   @override
//   String get name => 'CartridgeTubeOpenState';

//   CartridgeTubeOpenState(CleoDevice device, String lastMsg)
//       : super(device, lastMsg);

//   @override
//   handleDeviceMsg(String msg) {
//     final trimmed = msg.trim();
//     if (trimmed == 'B,P') {
//       return QrScanState(device, trimmed);
//     }
//     if (trimmed == 'T,N,S,P') {
//       return CartridgeSwabOpenState(device, trimmed);
//     }

//     return super.handleDeviceMsg(msg);
//   }

//   goNext() {
//     lastSent = 'T,N,S,0001';
//     return device.sendMsg(lastSent);
//   }

//   goBack() {
//     lastSent = 'B';
//     return device.sendMsg(lastSent);
//   }
// }

// class CartridgeSwabOpenState extends CleoState {
//   @override
//   String get name => 'CartridgeSwabOpenState';

//   CartridgeSwabOpenState(CleoDevice device, String lastMsg)
//       : super(device, lastMsg);

//   @override
//   handleDeviceMsg(String msg) {
//     final trimmed = msg.trim();
//     if (trimmed == 'B,P') {
//       return CartridgeTubeOpenState(device, trimmed);
//     }
//     if (trimmed == 'T,N,S,P') {
//       return CartridgeSampleGetState(device, trimmed);
//     }

//     return super.handleDeviceMsg(msg);
//   }

//   goNext() {
//     lastSent = 'T,N,S,0002';
//     return device.sendMsg(lastSent);
//   }

//   goBack() {
//     lastSent = 'B';
//     return device.sendMsg(lastSent);
//   }
// }

// class CartridgeSampleGetState extends CleoState {
//   @override
//   String get name => 'CartridgeSampleGetState';

//   CartridgeSampleGetState(CleoDevice device, String lastMsg)
//       : super(device, lastMsg);

//   @override
//   handleDeviceMsg(String msg) {
//     final trimmed = msg.trim();
//     if (trimmed == 'B,P') {
//       return CartridgeSwabOpenState(device, trimmed);
//     }
//     if (trimmed == 'T,N,S,P') {
//       return CartridgeSampleCloseState(device, trimmed);
//     }

//     return super.handleDeviceMsg(msg);
//   }

//   goNext() {
//     lastSent = 'T,N,S,0003';
//     return device.sendMsg(lastSent);
//   }

//   goBack() {
//     lastSent = 'B';
//     return device.sendMsg(lastSent);
//   }
// }

// class CartridgeSampleCloseState extends CleoState {
//   @override
//   String get name => 'CartridgeSampleCloseState';

//   CartridgeSampleCloseState(CleoDevice device, String lastMsg)
//       : super(device, lastMsg);

//   @override
//   handleDeviceMsg(String msg) {
//     final trimmed = msg.trim();
//     if (trimmed == 'B,P') {
//       return CartridgeSampleGetState(device, trimmed);
//     }
//     if (trimmed == 'T,N,S,P') {
//       return CartridgeSampleMixState(device, trimmed);
//     }

//     return super.handleDeviceMsg(msg);
//   }

//   goNext() {
//     lastSent = 'T,N,S,0004';
//     return device.sendMsg(lastSent);
//   }

//   goBack() {
//     lastSent = 'B';
//     return device.sendMsg(lastSent);
//   }
// }

// class CartridgeSampleMixState extends CleoState {
//   @override
//   String get name => 'CartridgeSampleMixState';

//   CartridgeSampleMixState(CleoDevice device, String lastMsg)
//       : super(device, lastMsg);

//   @override
//   handleDeviceMsg(String msg) {
//     final trimmed = msg.trim();
//     if (trimmed == 'B,P') {
//       return CartridgeSampleCloseState(device, trimmed);
//     }
//     if (trimmed == 'T,N,S,P') {
//       return CartridgeInsertState(device, trimmed);
//     }

//     return super.handleDeviceMsg(msg);
//   }

//   goNext() {
//     lastSent = 'T,N,S,0005';
//     return device.sendMsg(lastSent);
//   }

//   goBack() {
//     lastSent = 'B';
//     return device.sendMsg(lastSent);
//   }
// }

// // class CartridgeTubeInsertState extends CleoState {
// //   @override
// //   String get name => 'CartridgeTubeInsertState';

// //   CartridgeTubeInsertState(CleoDevice device, String lastMsg)
// //       : super(device, lastMsg);

// //   @override
// //   handleDeviceMsg(String msg) {
// //     final trimmed = msg.trim();
// //     if (trimmed == 'B,P') {
// //       return CartridgeSampleMixState(device, trimmed);
// //     }
// //     if (trimmed == 'T,N,S,P') {
// //       return CloseCoverState(device, trimmed);
// //     }

// //     return super.handleDeviceMsg(msg);
// //   }

// //   goNext() {
// //     lastSent = 'T,N,S,0006';
// //     return device.sendMsg(lastSent);
// //   }

// //   goBack() {
// //     lastSent = 'B';
// //     return device.sendMsg(lastSent);
// //   }
// // }

// class CloseCoverState extends CleoState {
//   @override
//   String get name => 'CloseCoverState';

//   CloseCoverState(CleoDevice device, String lastMsg) : super(device, lastMsg);

//   @override
//   handleDeviceMsg(String msg) {
//     final trimmed = msg.trim();
//     if (trimmed == 'T,N,L,0000') {
//       lastSent = 'T,N,L,P';
//       device.sendMsg(lastSent);
//       return TestProgressState(device, trimmed);
//     }

//     if (trimmed == 'B,P') {
//       // return CartridgeSampleMixState(device, trimmed);
//       return CartridgeInsertState(device, trimmed);
//     }
//     return super.handleDeviceMsg(msg);
//   }

//   goBack() {
//     lastSent = 'B';
//     return device.sendMsg(lastSent);
//   }
// }

// class TestProgressState extends CleoState {
//   @override
//   String get name => 'TestProgressState';

//   TestProgressState(CleoDevice device, String lastMsg) : super(device, lastMsg);

//   @override
//   handleDeviceMsg(String msg) {
//     final trimmed = msg.trim();
//     if (trimmed == 'T,N,L,0001,0001') {
//       lastSent = 'T,N,L,0001,P';
//       device.sendMsg(lastSent);
//       return ProgressCoverOpenState(device, trimmed);
//     }

//     return super.handleDeviceMsg(msg);
//   }

//   sendCancel() {
//     lastSent = 'P';
//     return device.sendMsg(lastSent);
//   }
// }

// class ProgressCoverOpenState extends CleoState {
//   ProgressCoverOpenState(CleoDevice device, String lastMsg)
//       : super(device, lastMsg);

//   @override
//   String get name => 'ProgressCoverOpen';

//   @override
//   handleDeviceMsg(String msg) {
//     final trimmed = msg.trim().toUpperCase();
//     if (trimmed == 'T,N,L,0000') {
//       lastSent = 'T,N,L,P';
//       device.sendMsg(lastSent);
//       return TestProgressState(device, trimmed);
//     }

//     if (trimmed == 'T,N,L,0001,0001') {
//       return this;
//     }

//     if (trimmed == 'T,N,L,0001,0002') {
//       lastSent = 'T,N,L,0001,P';
//       device.sendMsg(lastSent);
//       device.updateError(CoverTimeoutError(trimmed));
//       return this;
//     }

//     return super.handleDeviceMsg(msg);
//   }
// }

// class TestCompleteState extends CleoState {
//   @override
//   String get name => 'TestCompleteState';

//   TestCompleteState(CleoDevice device, String lastMsg) : super(device, lastMsg);

//   @override
//   handleDeviceMsg(String msg) {
//     final trimmed = msg.trim();
//     return super.handleDeviceMsg(trimmed);
//   }

//   requestSPdata(int cycle) {
//     String cycleStr = cycle.toString().padLeft(4, '0');
//     return device.sendMsg('S,P,$cycleStr');
//   }

//   requestSCdata(int cycle) {
//     String cycleStr = cycle.toString().padLeft(4, '0');
//     return device.sendMsg('S,P,$cycleStr');
//   }

//   sendFinish() {
//     lastSent = 'P';
//     return device.sendMsg(lastSent);
//   }
// }
