import 'package:cleo/provider/auth.dart';
import 'package:cleo/screen/auth/disclaimer.dart';
import 'package:cleo/screen/common/confirm_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:cleo/constants.dart' as cons;
import 'package:provider/provider.dart';

import '../../main.dart';

class SignupScreen extends StatefulWidget {
  static const routeName = '/signUp';
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _emailCtrl;
  late TextEditingController _pwCtrl;
  late TextEditingController _nameCtrl;
  late TextEditingController _confirmPwCtrl;
  late TabController _tabController;
  late ScrollController _scrollController;

  final _formKey = GlobalKey<FormState>();

  bool isConfirm = false;
  bool _visibilityPwd = true;
  bool _visibilityCheckPwd = true;

  @override
  void initState() {
    super.initState();

    _emailCtrl = TextEditingController();
    _pwCtrl = TextEditingController();
    _confirmPwCtrl = TextEditingController();
    _nameCtrl = TextEditingController();
    _tabController = TabController(vsync: this, length: 2);
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    if (Navigator.of(MyApp.naviKey.currentContext!).canPop()) {
      Navigator.of(MyApp.naviKey.currentContext!).pop();
    }
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    _nameCtrl.dispose();
    _tabController.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(
          color: Colors.black, //change your color here
        ),
      ),
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
                            height: constraints.maxHeight * 0.2,
                            child: Stack(
                              children: [
                                Center(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Stack(
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(
                                                right: 10),
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
                              ],
                            )),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: const Text(
                            'Create New Account',
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
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  // border: OutlineInputBorder(),
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
                                },
                              ),
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
                                      value.length < 8) {
                                    return 'more than eight digits. 3 combinations of English, numbers, and special characters.';
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _confirmPwCtrl,
                                obscureText: _visibilityCheckPwd,
                                decoration: InputDecoration(
                                  labelText: 'Confirm Password',
                                  prefixIcon: const Icon(
                                      CupertinoIcons.lock_circle_fill),
                                  suffixIcon: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _visibilityCheckPwd =
                                            !_visibilityCheckPwd;
                                      });
                                    },
                                    child: Icon(
                                      _visibilityCheckPwd
                                          ? Icons.visibility_off_outlined
                                          : Icons.remove_red_eye_outlined,
                                    ),
                                  ),
                                ),
                                validator: (String? value) {
                                  if (value == null ||
                                      value.isEmpty ||
                                      value.length < 8) {
                                    return 'Please enter at least 8 digits';
                                  }

                                  if (value != _pwCtrl.text) {
                                    return 'invalid password';
                                  }

                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _nameCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Your Name',
                                  prefixIcon:
                                      Icon(CupertinoIcons.profile_circled),
                                ),
                                validator: (String? value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Enter a valid name';
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Disclaimer',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(114, 114, 114, 1),
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () async {
                                setState(() {
                                  _tabController.index = 0;
                                });
                                bool isTerm = false;
                                bool isPrivacy = false;
                                final bool isComplete = await showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  routeSettings:
                                      const RouteSettings(name: 'dialog'),
                                  builder: (dialogContext) {
                                    return StatefulBuilder(builder: (
                                      stfContext,
                                      stfSetState,
                                    ) {
                                      return Dialog(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  const Text(
                                                    'Disclaimer',
                                                    style: TextStyle(
                                                      color: Color.fromRGBO(
                                                          114, 114, 114, 1),
                                                    ),
                                                  ),
                                                  InkWell(
                                                    onTap: () =>
                                                        Navigator.of(context)
                                                            .pop(false),
                                                    child: const SizedBox(
                                                      width: 50,
                                                      height: 50,
                                                      child: Align(
                                                        alignment: Alignment
                                                            .centerRight,
                                                        child: Icon(
                                                          CupertinoIcons.clear,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Expanded(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    TabBar(
                                                      controller:
                                                          _tabController,
                                                      labelColor: Colors.black,
                                                      tabs: const [
                                                        Tab(
                                                          text: 'Terms of use',
                                                        ),
                                                        Tab(
                                                          text:
                                                              'Privacy Policy',
                                                        ),
                                                      ],
                                                      onTap: (index) {
                                                        stfSetState(() {
                                                          _scrollController
                                                              .jumpTo(0.0);
                                                        });
                                                      },
                                                    ),
                                                    const SizedBox(height: 16),
                                                    Expanded(
                                                      child: TabBarView(
                                                        physics:
                                                            const NeverScrollableScrollPhysics(),
                                                        controller:
                                                            _tabController,
                                                        children: [
                                                          SingleChildScrollView(
                                                            controller:
                                                                _scrollController,
                                                            child: Disclaimer
                                                                .buildTerms(),
                                                          ),
                                                          SingleChildScrollView(
                                                            controller:
                                                                _scrollController,
                                                            child: Disclaimer
                                                                .privacy(),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                // child: SingleChildScrollView(
                                                //   child: Disclaimer.privacy(),
                                                // ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 6),
                                                child:
                                                    (_tabController.index == 0)
                                                        ? ConfirmButton(
                                                            onPressed: () {
                                                              stfSetState(() {
                                                                if (_scrollController
                                                                        .position
                                                                        .maxScrollExtent <=
                                                                    _scrollController
                                                                        .position
                                                                        .pixels) {
                                                                  _tabController
                                                                      .index = 1;
                                                                  isTerm = true;
                                                                }
                                                                if (isTerm ==
                                                                        false &&
                                                                    isPrivacy ==
                                                                        false) {
                                                                  showDialog(
                                                                      context:
                                                                          stfContext,
                                                                      builder:
                                                                          (stfContext) {
                                                                        return AlertDialog(
                                                                          title: const Text(
                                                                              'Please read the terms of use and privacy policy',
                                                                              style: TextStyle(color: Colors.blueAccent, fontSize: 18)),
                                                                          actions: [
                                                                            TextButton(
                                                                              onPressed: () {
                                                                                Navigator.of(context).pop();
                                                                              },
                                                                              child: const Text(
                                                                                'OK',
                                                                                style: TextStyle(color: Colors.red, fontSize: 14),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        );
                                                                      });
                                                                }
                                                                if (isTerm ==
                                                                        false &&
                                                                    isPrivacy) {
                                                                  showDialog(
                                                                      context:
                                                                          stfContext,
                                                                      builder:
                                                                          (stfContext) {
                                                                        return AlertDialog(
                                                                          title: const Text(
                                                                              'Please read the terms of use',
                                                                              style: TextStyle(color: Colors.blueAccent, fontSize: 18)),
                                                                          actions: [
                                                                            TextButton(
                                                                              onPressed: () {
                                                                                Navigator.of(context).pop();
                                                                              },
                                                                              child: const Text(
                                                                                'OK',
                                                                                style: TextStyle(color: Colors.red, fontSize: 14),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        );
                                                                      });
                                                                }
                                                                if (isTerm &&
                                                                    isPrivacy) {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop(
                                                                          true);
                                                                }
                                                              });
                                                            },
                                                            label: (isPrivacy)
                                                                ? 'Confirm'
                                                                : 'Next',
                                                            width: size.width *
                                                                0.4,
                                                          )
                                                        : ConfirmButton(
                                                            onPressed: () {
                                                              stfSetState(() {
                                                                if (_scrollController
                                                                        .position
                                                                        .maxScrollExtent <=
                                                                    _scrollController
                                                                        .position
                                                                        .pixels) {
                                                                  isPrivacy =
                                                                      true;
                                                                }

                                                                if (isTerm ==
                                                                        false &&
                                                                    isPrivacy ==
                                                                        false) {
                                                                  showDialog(
                                                                      context:
                                                                          stfContext,
                                                                      builder:
                                                                          (stfContext) {
                                                                        return AlertDialog(
                                                                          title: const Text(
                                                                              'Please read the terms of use and privacy policy',
                                                                              style: TextStyle(color: Colors.blueAccent, fontSize: 18)),
                                                                          actions: [
                                                                            TextButton(
                                                                              onPressed: () {
                                                                                Navigator.of(context).pop();
                                                                              },
                                                                              child: const Text(
                                                                                'OK',
                                                                                style: TextStyle(color: Colors.red, fontSize: 14),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        );
                                                                      });
                                                                }
                                                                if (isTerm ==
                                                                        false &&
                                                                    isPrivacy) {
                                                                  showDialog(
                                                                      context:
                                                                          stfContext,
                                                                      builder:
                                                                          (stfContext) {
                                                                        return AlertDialog(
                                                                          title: const Text(
                                                                              'Please read the terms of use',
                                                                              style: TextStyle(color: Colors.blueAccent, fontSize: 18)),
                                                                          actions: [
                                                                            TextButton(
                                                                              onPressed: () {
                                                                                Navigator.of(context).pop();
                                                                              },
                                                                              child: const Text(
                                                                                'OK',
                                                                                style: TextStyle(color: Colors.red, fontSize: 14),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        );
                                                                      });
                                                                }
                                                                if (isTerm &&
                                                                    isPrivacy ==
                                                                        false) {
                                                                  // 스크롤 확인 alert 구현
                                                                  showDialog(
                                                                      context:
                                                                          stfContext,
                                                                      builder:
                                                                          (stfContext) {
                                                                        return AlertDialog(
                                                                          title: const Text(
                                                                              'Please read the privacy policy',
                                                                              style: TextStyle(color: Colors.blueAccent, fontSize: 18)),
                                                                          actions: [
                                                                            TextButton(
                                                                              onPressed: () {
                                                                                Navigator.of(context).pop();
                                                                              },
                                                                              child: const Text(
                                                                                'OK',
                                                                                style: TextStyle(color: Colors.red, fontSize: 14),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        );
                                                                      });
                                                                }
                                                                if (isTerm &&
                                                                    isPrivacy) {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop(
                                                                          true);
                                                                }
                                                              });
                                                            },
                                                            label: 'Confirm',
                                                            width: size.width *
                                                                0.4,
                                                          ),
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    });
                                  },
                                );

                                setState(() {
                                  isConfirm = isComplete;
                                });
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: Colors.grey),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Use and Precautions',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromRGBO(114, 114, 114, 1),
                                      ),
                                    ),
                                    Icon(
                                      Icons.check_circle_outline_outlined,
                                      color:
                                          isConfirm ? cons.primary : cons.grey,
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                        Center(
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 32),
                            child: FlatConfirmButton(
                              label: 'CONFIRM',
                              onPressed: () async {
                                final authProvider = Provider.of<AuthProvider>(
                                    context,
                                    listen: false);
                                if (!_formKey.currentState!.validate()) return;

                                if (!isConfirm) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Please agree to the disclaimer')),
                                  );
                                  return;
                                }

                                showDialog(
                                  context: context,
                                  routeSettings:
                                      const RouteSettings(name: 'dialog'),
                                  useRootNavigator: false,
                                  builder: (context) {
                                    return const CupertinoActivityIndicator(
                                      animating: true,
                                      color: Colors.white,
                                    );
                                  },
                                );

                                Map result = await AuthProvider.signUpWithEmail(
                                  email: _emailCtrl.text.trim(),
                                  password: _pwCtrl.text,
                                  displayName: _nameCtrl.text,
                                );

                                if (result['status'] == false) {
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(result['msg'])),
                                  );

                                  return;
                                }

                                authProvider.setDisplayName(_nameCtrl.text);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(result['msg'])),
                                );

                                Navigator.of(context)
                                    .popUntil((route) => route.isFirst);
                              },
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
