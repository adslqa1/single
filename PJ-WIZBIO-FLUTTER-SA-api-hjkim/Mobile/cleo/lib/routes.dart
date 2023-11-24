import 'package:cleo/cleo_device/view/test_prepare.dart';
import 'package:cleo/screen/auth/reset_password.dart';
import 'package:cleo/screen/auth/signup.dart';
import 'package:cleo/screen/home/delete_account.dart';
import 'package:cleo/screen/report/list.dart';
import 'package:cleo/screen/report/noti_handle.dart';

final routes = {
  NotiHandleScreen.routeName: (context) => const NotiHandleScreen(),
  ResetPasswordScreen.routeName: (context) => const ResetPasswordScreen(),
  SignupScreen.routeName: (context) => const SignupScreen(),
  TestPrepareScreen.routeName: (context) => const TestPrepareScreen(),
  ReportListScreen.routeName: (context) => const ReportListScreen(),
  DeleteAccountScreen.routeName: (context) => const DeleteAccountScreen(),
  // CartridgeProcessScreen.routeName: (context) {
  //   final arg = ModalRoute.of(context)!.settings.arguments;
  //   final initStep =
  //       arg == null ? 0 : (arg as CartridgeProcessScreenArgs).initStep;
  //   return CartridgeProcessScreen(initStep: initStep);
  // },
  // CartridgeFinalScreen.routeName: (context) => const CartridgeFinalScreen(),
  // CartridgeReadScreen.routeName: (context) => const CartridgeReadScreen(),
};
