import 'dart:async';
import 'dart:developer';

import 'package:cleo/util/sql_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../model/tester.dart';

class AuthProvider with ChangeNotifier {
  static FirebaseAuth auth = FirebaseAuth.instance;

  bool isLogin = false;
  String displayName = '';
  String uid = '';

  Tester? currentTester;

  Completer completer = Completer();

  Future<void> init() async {
    if (!completer.isCompleted) {
      completer.complete();
    }

    auth.authStateChanges().listen((User? user) {
      if (user == null) {
        isLogin = false;
        displayName = '';
        uid = '';
        currentTester = null;
        debugPrint('User is currently signed out!');
      } else {
        isLogin = true;
        displayName = user.displayName ?? '';
        uid = user.uid;

        SqlHelper.init(uid).then((value) async {
          List<Map> data = await SqlTester.loadTester();

          if (data.isNotEmpty) {
            setTester(Tester(data[0]));
          }
        });

        debugPrint('User is signed in!');
      }

      notifyListeners();
    });

    await completer.future;
  }

  Future<void> logout() async {
    await auth.signOut();
  }

  static Future<Map> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    Map result = {
      'status': true,
      'msg': 'Sign up is complete',
    };
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      userCredential.user!.updateDisplayName(displayName);

      return result;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        result['msg'] = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        result['msg'] = 'The account already exists for that email.';
      }

      result['status'] = false;

      return result;
    } catch (e) {
      result['status'] = false;
      return result;
    }
  }

  static Future<Map> signInWithEmail({
    required String email,
    required String password,
  }) async {
    Map result = {
      'status': true,
      'msg': '',
    };

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return result;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        result['msg'] = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        result['msg'] = 'Wrong password provided for that user.';
      } else if (e.code == 'network-request-failed') {
        result['msg'] = 'network-request-failed.';
      } else {
        result['msg'] = 'login error';
      }
      result['status'] = false;
      return result;
    }
  }

  void setDisplayName(String? displayName) {
    this.displayName = displayName ?? '';
    notifyListeners();
  }

  void setTester(Tester? tester) {
    currentTester = tester;
    notifyListeners();
  }
}
