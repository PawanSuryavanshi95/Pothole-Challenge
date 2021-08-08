import 'package:flutter/material.dart';
import 'package:potholechallenge/extras/loading.dart';
import 'package:potholechallenge/services/Auth.dart';

class Login extends StatefulWidget {

  final Function? toggle;
  Login({this.toggle});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  final AuthService _auth = AuthService();

  final _formKey = GlobalKey<FormState>();

  String _email = '';
  String _password = '';
  String _error = '';

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Login'),
        actions: <Widget>[
          FlatButton.icon(
            icon:Icon(Icons.person),
            label:Text("Register"),
            onPressed: (){
              widget.toggle!();
            }
            ,)
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: Form(
            key:_formKey,
            child: Column(
              children: <Widget>[
                SizedBox(height: 20.0,),
                TextFormField(
                  validator: (val)=> val!.isEmpty ? "Enter Email" : null,
                  onChanged: (val){
                    setState(() {
                      _email = val;
                    });
                  },
                ),
                SizedBox(height: 20.0,),
                TextFormField(
                  validator: (val)=> val!.length<8 ? "Password should contain atleast 8 characters" : null,
                  obscureText: true,
                  onChanged: (val){
                    setState(() {
                      _password = val;
                    });
                  },
                ),
                SizedBox(height: 20.0,),
                RaisedButton(
                    color:Colors.pink[400],
                    child: Text('Sign In', style: TextStyle(color: Colors.white),),
                    onPressed: () async{
                      if(_formKey.currentState!.validate()){
                        setState(() {
                          loading = true;
                        });
                        dynamic result = await _auth.signInWithEmailAndPassword(_email, _password);
                        if(result==null){
                          setState(() {
                            _error = "Invalid Credentials";
                            loading = false;
                          });
                        }
                      }
                    }),
                SizedBox(height: 12.0,),
                Text(_error, style: TextStyle(color: Colors.red, fontSize: 14.0),)
              ],
            )
        ),
      ),
    );
  }
}