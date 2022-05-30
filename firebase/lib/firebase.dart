import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final CollectionReference _mainCollection = _firestore.collection('user');

class Database{
  static String? userId = '5LajePE9ON25EO79bc46';
  static void addItem(Map<String,dynamic>data,String counter){
    DocumentReference documentReferencer =
    _mainCollection.doc(userId).collection('data').doc(counter);


    documentReferencer
        .set(data)
        .whenComplete(() => print("Item added to the database"))
        .catchError((e) => print(e));
  }

  static Future<void> updateItem({
    required String url,
    required String counter,
  }) async {
    DocumentReference documentReferencer =
    _mainCollection.doc(userId).collection('data').doc(counter);

    Map<String, dynamic> data = <String, dynamic>{
      "url":url
    };

    await documentReferencer
        .update(data)
        .whenComplete(() => print("Item updated in the database"))
        .catchError((e) => print(e));
  }

  static Future<List<Map<String,dynamic>>>  readItems()async{
    DocumentReference documentReferencer = await _mainCollection.doc(userId).collection('data').doc();

    List<Map<String,dynamic>> list = [];

    Stream <DocumentSnapshot> q= await documentReferencer.snapshots();
    q.forEach((element){
      var data = element.data();
      print("******");
      print(data);
      print("******");
    });

    return list;
  }
}