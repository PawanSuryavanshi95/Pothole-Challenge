import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService{

  final String? uid;
  DatabaseService({ this.uid });

  final CollectionReference data = FirebaseFirestore.instance.collection('pothole');

  Future addReport(double? latitude, double? longitude, double? accuracy, String uid) async {
    Map<String, dynamic> report = {'latitude':latitude, 'longitude':longitude, 'accuracy':accuracy, 'uid':uid};
    return await data.add(report);
  }


}