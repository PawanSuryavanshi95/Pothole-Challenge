import 'package:flutter/material.dart';

import 'package:potholechallenge/screens/Auth/Login.dart';
import 'package:potholechallenge/screens/Auth/Register.dart';

class Auth extends StatefulWidget {
  @override
  _AuthState createState() => _AuthState();
}

class _AuthState extends State<Auth> {

  bool _showSignIn = true;

  void toggle(){
    print('yp');
    setState(() {
      _showSignIn = !_showSignIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(_showSignIn)
      return Login(toggle: toggle);
    else
      return Register(toggle: toggle);
  }
}