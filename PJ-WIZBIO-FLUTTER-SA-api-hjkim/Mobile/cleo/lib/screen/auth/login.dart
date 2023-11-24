import 'package:cleo/screen/auth/reset_password.dart';
import 'package:cleo/screen/auth/signup.dart';
import 'package:cleo/screen/common/confirm_button.dart';
import 'package:cleo/screen/home/main.dart';
import 'package:cleo/util/storage_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../main.dart';
import '../../provider/auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController _emailCtrl;
  late TextEditingController _pwCtrl;
  late StorageHelper _storageHelper;

  bool _remember = false;
  bool _visibilityPwd = true;

  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();

    _emailCtrl = TextEditingController();
    _pwCtrl = TextEditingController();

    _storageHelper = StorageHelper();
    _storageHelper.init('user').then((value) {
      _storageHelper.getValue('email').then((dynamic email) {
        if (email != null) {
          _emailCtrl.text = email;
        }
      });
      _storageHelper.getValue('remember').then((dynamic remember) {
        if (remember != null) {
          _remember = remember;
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (Navigator.of(MyApp.naviKey.currentContext!).canPop()) {
      Navigator.of(MyApp.naviKey.currentContext!).pop();
    }
    _emailCtrl.dispose();
    _pwCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: constraints.maxHeight * 0.3,
                          child: Center(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(right: 10),
                                      child: Text(
                                        'CLEO',
                                        style: TextStyle(
                                          color: const Color(0xff717071),
                                          fontSize: size.width * 0.12,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Text(
                                        '™',
                                        style: TextStyle(
                                          color: const Color(0xff717071),
                                          fontSize: size.width * 0.04,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'O',
                                  style: TextStyle(
                                    color: const Color(0xff5588F4),
                                    fontSize: size.width * 0.12,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'NE',
                                  style: TextStyle(
                                    color: const Color(0xff717071),
                                    fontSize: size.width * 0.12,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: const Text(
                            'USER LOGIN',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(114, 114, 114, 1),
                            ),
                          ),
                        ),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                  controller: _emailCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                    prefixIcon:
                                        Icon(CupertinoIcons.person_circle_fill),
                                  ),
                                  validator: (String? value) {
                                    value = value?.trim();
                                    String pattern =
                                        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
                                        r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
                                        r"{0,253}[a-zA-Z0-9])?)*$";
                                    RegExp regex = RegExp(pattern);
                                    if (value == null ||
                                        value.isEmpty ||
                                        !regex.hasMatch(value)) {
                                      return 'Enter a valid email address';
                                    } else {
                                      return null;
                                    }
                                  }),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _pwCtrl,
                                obscureText: _visibilityPwd,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(
                                      CupertinoIcons.lock_circle_fill),
                                  suffixIcon: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _visibilityPwd = !_visibilityPwd;
                                      });
                                    },
                                    child: Icon(
                                      _visibilityPwd
                                          ? Icons.visibility_off_outlined
                                          : Icons.remove_red_eye_outlined,
                                    ),
                                  ),
                                ),
                                validator: (String? value) {
                                  if (value == null ||
                                      value.isEmpty ||
                                      value.length < 5) {
                                    return 'Enter a valid password';
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: _remember,
                                  onChanged: (bool? remember) {
                                    setState(() {
                                      _remember = remember!;
                                    });
                                    _storageHelper.setValue(
                                        'remember', remember!);
                                  },
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _remember = !_remember;
                                    });
                                    _storageHelper.setValue(
                                        'remember', !_remember);
                                  },
                                  child: const Text('Remember'),
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.of(context)
                                    .pushNamed(ResetPasswordScreen.routeName);
                              },
                              child: const Text('Forgot Password ?'),
                            ),
                          ],
                        ),
                        Center(
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: FlatConfirmButton(
                              label: 'LOG IN',
                              width: size.width * 0.6,
                              onPressed: () async {
                                if (!_formKey.currentState!.validate()) return;

                                showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    useRootNavigator: false,
                                    builder: (context) {
                                      return const CupertinoActivityIndicator();
                                    });

                                Map result = await AuthProvider.signInWithEmail(
                                  email: _emailCtrl.text.trim(),
                                  password: _pwCtrl.text,
                                );

                                if (!result['status']) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(result['msg']),
                                    ),
                                  );
                                }

                                Navigator.of(context).pop();

                                if (_remember) {
                                  _storageHelper.setValue(
                                      'email', _emailCtrl.text.trim());
                                }
                              },
                            ),
                            // child: ConfirmButton(
                            //   label: 'Login',
                            //   onPressed: () async {
                            //     if (!_formKey.currentState!.validate()) return;

                            //     Map result = await AuthProvider.signInWithEmail(
                            //       email: _emailCtrl.text.trim(),
                            //       password: _pwCtrl.text,
                            //     );

                            //     if (!result['status']) {
                            //       ScaffoldMessenger.of(context).showSnackBar(
                            //         SnackBar(
                            //           content: Text(result['msg']),
                            //         ),
                            //       );
                            //     }
                            //     if (_remember) {
                            //       _storageHelper.setValue(
                            //           'email', _emailCtrl.text.trim());
                            //     }
                            //   },
                            // ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: const Text(
                            'Not USER',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(114, 114, 114, 1),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Center(
                            child: ConfirmButton(
                              width: size.width * 0.525,
                              onPressed: () {
                                Navigator.of(context)
                                    .pushNamed(SignupScreen.routeName);
                              },
                              label: 'CREATE ACCOUNT',
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: const [
                                Center(
                                  child: Text(
                                    '© 2022 Wizbiosolutions Inc. All right reserved.',
                                    style: TextStyle(
                                      color: Color.fromRGBO(114, 114, 114, 0.8),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Text(
                                    'CLEO™ is a trademark of Wizbiosolutions.',
                                    style: TextStyle(
                                      color: Color.fromRGBO(114, 114, 114, 0.8),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
