import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:potholechallenge/screens/Wrapper.dart';
import 'package:potholechallenge/models/user.dart';
import 'package:potholechallenge/services/Auth.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return StreamProvider<User_Custom?>.value(
      initialData: null,
      value: AuthService().user,
      child: MaterialApp(
        home: Wrapper(),
      ),
    );
  }
}

/*
class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yo'),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[ Image(
          image: NetworkImage('https://media.istockphoto.com/photos/pot-hole-picture-id174662203?s=612x612'),
        ),
          Text('Relax Bois')],
      ),
      floatingActionButton: FloatingActionButton(
        child: Text('click'),
        onPressed: () {},
      ),

    );
  }
}



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

class Login extends StatefulWidget {

  final Function? toggle;
  Login({this.toggle});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  String _email = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            child: Column(
              children: <Widget>[
                SizedBox(height: 20.0,),
                TextFormField(
                  onChanged: (val){
                    setState(() {
                      _email = val;
                    });
                  },
                ),
                SizedBox(height: 20.0,),
                TextFormField(
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
                      print(_email);
                      print(_password);
                    }),
              ],
            )
        ),
      ),
    );
  }
}

class Register extends StatefulWidget {

  final Function? toggle;
  Register({this.toggle});
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  final _formKey = GlobalKey<FormState>();

  String _email = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        print(_email);
                        print(_password);
                      }
                    }),
              ],
            )
        ),
      ),
    );
  }
}


class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {

  String _uri = '';
  XFile? _img = null;

  ImagePicker imgPicker = ImagePicker();
  double _imgWidth=0;
  double _imgHeight=0;

  bool _busy = false;

  List? _recognitions = [];

  String _prob = '';
  String _label = '';

  @override
  void initState() {
    super.initState();
    _busy = true;

    loadModel().then((val) {
      setState(() {
        _busy = false;
      });
    });
  }

  loadModel() async {
    Tflite.close();
    String path = "assets/model.tflite";
    try {
      String? res = await Tflite.loadModel(
          model: path,
          labels: "assets/labels.txt",
          numThreads: 1,
          isAsset: true,
          useGpuDelegate: false
      );
      print("loaded");
      print(res);
    } catch(e) {
      print("Failed to load the model");
      print(e);
    }
  }

  _predictImage(String uri) async{
    if(uri=='') return;
    File img = File(uri);

    var recognitions = await Tflite.runModelOnImage(
        path: img.path,   // required
        imageMean: 0.0,   // defaults to 117.0
        imageStd: 255.0,  // defaults to 1.0
        numResults: 2,
        threshold: 0.2,   // defaults to 0.1
        asynch: true      // defaults to true
    );

    FileImage(img).resolve(ImageConfiguration()).addListener(ImageStreamListener((ImageInfo info, bool _){
      _imgWidth = info.image.width.toDouble();
      _imgHeight = info.image.height.toDouble();
    }));

    setState(() {
      _busy = true;
      _recognitions = recognitions;
      _label = recognitions!=null? recognitions[0]['label']:'';
      _prob = recognitions!=null? (recognitions[0]['confidence']*100).toString():'';
    });
  }

  Future _openCamera() async {
    XFile? picture = await imgPicker.pickImage(source: ImageSource.camera);
    String uri = (picture!=null)?picture.path:'';
    this.setState(() {
      _busy = false;
      _img = picture;
    });
    _predictImage(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera Screen'),
      ),
      body:Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Text("Label $_label , Confidence $_prob %"),
              _uri==''?
              Text('No Image'):
              Image.file(File(_uri)),
              RaisedButton(
                onPressed: _openCamera,
                child: Text('Capture Image'),
              ),
            ],
          ),
        ),
      )
    );
  }
}
*/