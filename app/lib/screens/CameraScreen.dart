import 'dart:io';

import 'package:flutter/material.dart';
//import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:image_picker/image_picker.dart';
import 'package:potholechallenge/services/Auth.dart';
import 'package:potholechallenge/services/database.dart';
import 'package:tflite/tflite.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {

  final AuthService _auth = AuthService();

  String _msg = "";
  String _msg2 = "";
  String _uri = '';
  XFile? _img = null;

  ImagePicker imgPicker = ImagePicker();
  double _imgWidth=0;
  double _imgHeight=0;

  bool _busy = false;

  List? _recognitions = [];

  String _prob = '';
  String _label = '';

  bool _upload = false;

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
    String label = recognitions!=null? recognitions[0]['label']:'';
    double prob = recognitions!=null? recognitions[0]['confidence']:0;
    bool b =(label=='Yes' && prob>=0.7)? true:false;

    setState(() {
      _busy = false;
      _recognitions = recognitions;
      _label = label;
      _prob = (prob*100).toString();
      _upload = b;
      _msg = b?"Pothole Detected with $_prob % Confidence": "No Pothole Detected";
    });
  }

  Future _openCamera() async {
    XFile? picture = await imgPicker.pickImage(source: ImageSource.camera);
    String uri = (picture!=null)?picture.path:'';
    this.setState(() {
      _busy = true;
      _img = picture;
      _uri = uri;
    });
    _predictImage(uri);
  }

  Future getLocation() async{
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();

    return _locationData;

    //Position position = await Geolocator
    //    .getCurrentPosition(desiredAccuracy: LocationAccuracy.best, forceAndroidLocationManager: true);
    //return position;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Camera Screen'),
          actions: <Widget>[
            FlatButton.icon(
              icon:Icon(Icons.person),
              label:Text("Logout"),
              onPressed: () async{
                await _auth.signOut();
              }
              ,)
          ],
        ),
        body:Container(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text(_msg),
                _uri==''?
                Text('No Image'):
                Image.file(File(_uri),height: 400, width: 400, scale: 0.2,),
                RaisedButton(
                  onPressed: _openCamera,
                  child: Text('Capture Image'),
                ),
                RaisedButton(
                  onPressed: () async{
                    String uid = await _auth.getUID();
                    try {
                      LocationData location = await getLocation();
                      setState(() {
                        _msg2 = "Your report has been saved";
                        _upload = false;
                      });
                      return await DatabaseService().addReport(location.latitude, location.longitude, location.accuracy, uid);
                    }
                    catch(e){
                      print('could not upload');
                      print(e);
                    }
                  },
                  child: Text('Submit'),
                ),Text(_msg2),
              ],
            ),
          ),
        )
    );
  }
}