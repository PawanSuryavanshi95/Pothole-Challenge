import 'package:flutter/material.dart';

import 'package:potholechallenge/screens/Auth/Auth.dart';
import 'package:potholechallenge/screens/CameraScreen.dart';
import 'package:potholechallenge/models/user.dart';

import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User_Custom?>(context);
    print(user);

    if(user==null)
      return Auth();
    else
      return CameraScreen();

  }
}