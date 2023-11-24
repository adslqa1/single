class CleoError {
  final String msg;

  CleoError(this.msg);

  String get desc => 'Unexpected Cleo Error';
}

class CustomError extends CleoError {
  CustomError(String msg) : super(msg);

  String getCode(String msg) {
    final reg = RegExp(r'(\d+)');
    final code = reg.stringMatch(msg) ?? '-1';
    return code;
  }

  @override
  get desc => 'Error : Code ${getCode(msg)}'; //2023.10.16_CJH
}

class ConnectionProtocolError extends CleoError {
  ConnectionProtocolError(String msg) : super(msg);

  @override
  get desc => 'Connection Error';
}

class InUseError extends CleoError {
  InUseError(String msg) : super(msg);

  @override
  get desc => 'Device already in use';
}

class StepProtocolError extends CleoError {
  StepProtocolError(String msg) : super(msg);

  @override
  get desc => 'Protocol Error';
}

class ConditionProtocolError extends CleoError {
  ConditionProtocolError(String msg) : super(msg);

  @override
  get desc => 'Protocol Error';
}

class StopProtocolError extends CleoError {
  StopProtocolError(String msg) : super(msg);

  @override
  get desc => 'Protocol Error';
}

class StatusProtocolError extends CleoError {
  StatusProtocolError(String msg) : super(msg);

  @override
  get desc => 'Protocol Error';
}

class CoverTimeoutError extends CleoError {
  CoverTimeoutError(String msg) : super(msg);

  @override
  // get desc => '뚜껑 닫음 시간 초과';
  get desc => 'Test failed due to Lid open error';
}

class CartridgeError extends CleoError {
  CartridgeError(String msg) : super(msg);

  @override
  get desc => 'Cartridge insertion Error';
}

class HeatControlError extends CleoError {
  HeatControlError(String msg) : super(msg);

  @override
  get desc => 'Isothermal control Error';
}

class LightControlError extends CleoError {
  LightControlError(String msg) : super(msg);

  @override
  get desc => 'Measurement Error';
}

class SolutionStatusError extends CleoError {
  SolutionStatusError(String msg) : super(msg);

  @override
  get desc => 'Solution status Error';
}

class CoverStatusError extends CleoError {
  CoverStatusError(String msg) : super(msg);

  @override
  get desc => 'Lid Open Error';
}

class CartridgeMissingError extends CleoError {
  CartridgeMissingError(String msg) : super(msg);

  @override
  get desc => 'Cartridge not inserted Error';
}

class ReconnectionFailError extends CleoError {
  ReconnectionFailError(String msg) : super(msg);

  @override
  get desc => 'Reconnection Error';
}

class ProgressCoverOpenError extends CleoError {
  ProgressCoverOpenError(String msg) : super(msg);

  @override
  get desc => 'Lid Open Error';
}
