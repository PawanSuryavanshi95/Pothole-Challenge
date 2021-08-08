import 'package:flutter/material.dart';
import 'package:potholechallenge/extras/loading.dart';
import 'package:potholechallenge/services/Auth.dart';

class Register extends StatefulWidget {

  final Function? toggle;
  Register({this.toggle});
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

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
        title: Text('Register'),
        centerTitle: true,
        actions: <Widget>[
          FlatButton.icon(
            icon:Icon(Icons.person),
            label:Text("Sign In"),
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
                  obscureText: true,
                  validator: (val)=> val!.length<8 ? "Password should contain atleast 8 characters" : null,
                  onChanged: (val){
                    setState(() {
                      _password = val;
                    });
                  },
                ),
                SizedBox(height: 20.0,),
                RaisedButton(
                    color:Colors.pink[400],
                    child: Text('Register', style: TextStyle(color: Colors.white),),
                    onPressed: () async{
                      if(_formKey.currentState!.validate()){
                        setState(() {
                          loading = true;
                        });
                        dynamic result = await _auth.registerWithEmailAndPassword(_email, _password);
                        if(result==null){
                          setState(() {
                            _error = "please supply a valid email";
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