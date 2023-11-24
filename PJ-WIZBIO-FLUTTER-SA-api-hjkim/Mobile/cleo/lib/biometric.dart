import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class Biometric with ChangeNotifier {
  final localAuth = LocalAuthentication();
  bool canCheckBiometrics = false;

  init() async {
    canCheckBiometrics = await localAuth.canCheckBiometrics;
  }

  requestAuth() async {
    return localAuth.authenticate(localizedReason: '데이터 접근을 위해 인증이 필요합니다');
  }
}
