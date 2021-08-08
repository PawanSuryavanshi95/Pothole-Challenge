import 'package:potholechallenge/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:potholechallenge/services/database.dart';

class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // create user obj based on firebase user
  User_Custom? _mapUser(User? user) {
    return user != null ? User_Custom(uid: user.uid) : null;
  }

  // auth change user stream
  Stream<User_Custom?> get user {
    return _auth.authStateChanges()
        .map(_mapUser);
  }

  Future signInWithEmailAndPassword(String email, String password) async {
    try{
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? firebaseUser = result.user;
      return _mapUser(firebaseUser);
    }
    catch(e){
      print('signin failed');
      print(e);
      return null;
    }
  }

  Future registerWithEmailAndPassword(String email, String password) async {
    try{
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? firebaseUser = result.user;
      return _mapUser(firebaseUser);
    }
    catch(e){
      print('register failed');
      print(e);
      return null;
    }
  }

  Future signOut() async {
    try{
      return await _auth.signOut();
    }
    catch(e){
      print('logout failed');
      print(e);
    }
  }

  Future getUID() async{
    final User? user = await _auth.currentUser;
    final String uid = user!.uid;
    return uid;
  }

}