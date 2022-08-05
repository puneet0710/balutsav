import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'firebase.dart';
import 'package:connectivity_plus/connectivity_plus.dart';


final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final CollectionReference _mainCollection = _firestore.collection('volunteer-test');

class Database {
  static String? userId = '5LajePE9ON25EO79bc46';

  static void addItem(Map<String, dynamic>data, String counter) {
    /*DocumentReference documentReferencer =
    _mainCollection.doc(userId).collection('data').doc(counter);*/
    _mainCollection.doc(userId).collection(data["email"]).doc("QWERT").set(data);

    /*documentReferencer
        .set(data)
        .whenComplete(() => print("Item added to the database"))
        .catchError((e) => print(e));*/
    //readItems(data);
  }

  static Future<void> updateItem({
    required String url,
    required String counter,
  }) async {
    DocumentReference documentReferencer =
    _mainCollection.doc(userId).collection('data').doc(counter);

    Map<String, dynamic> data = <String, dynamic>{
      "url": url
    };

    await documentReferencer
        .update(data)
        .whenComplete(() => print("Item updated in the database"))
        .catchError((e) => print(e));
  }

  static Future<List<Map<String, dynamic>>> readItems(String? email,
      List<Map<String, dynamic>> list) async {
      //String email = await Future.value(data["email"]);
    /*DocumentReference documentReferencer = await _mainCollection.doc(
        userId); //.collection("")
    CollectionReference documentReferencer1 = await _mainCollection
        .doc(userId)
        .collection("a.a@a.com")
        .doc("JJVpGixGsqXILfC7zzzQ")
        .parent;*/
    //List<Map<String,dynamic>> list = [];
    //list = [];
    final documentReferencerTest = await _mainCollection.doc(userId).collection(
        email!).doc("QWERT");
    DocumentSnapshot doc = await documentReferencerTest.get();
    final data = doc.data() as Map<String, dynamic>;
    //setState(() {
    list.add({
    "name": data["name"],
    "email": data["email"],
    "phoneNumber": data["phoneNumber"],
    "location": data["location"],
    "details": data["details"],
    "url": data["url"]});
    /*documentReferencerTest.get().then(
          (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        //setState(() {
          list.add({
            "name": data["name"],
            "email": data["email"],
            "phoneNumber": data["phoneNumber"],
            "location": data["location"],
            "details": data["details"],
            "url": data["url"]
          });
      },
      onError: (e) => print("Error getting document: $e"),
    );
*/

    /*Stream <DocumentSnapshot> q= await documentReferencer.snapshots();
    q.forEach((element){
      var data = element.data();
      print("******");
      print(data);
      print("******");
    });*/
    return list;
  }

  static List<Map<String, dynamic>> readItemsSync(Map<String, dynamic>data,
      List<Map<String, dynamic>> list) {
    DocumentReference documentReferencer = _mainCollection.doc(
        userId); //.collection("")
    CollectionReference documentReferencer1 = _mainCollection
        .doc(userId)
        .collection("a.a@a.com")
        .doc("JJVpGixGsqXILfC7zzzQ")
        .parent;
    //List<Map<String,dynamic>> list = [];
    list = [];
    final documentReferencerTest = _mainCollection.doc(userId).collection(
        "a.a@a.com").doc("JJVpGixGsqXILfC7zzzQ");
     documentReferencerTest.get().then(
          (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        //setState(() {
        list.add({
          "name": data["name"],
          "email": data["email"],
          "phoneNumber": data["phoneNumber"],
          "location": data["location"],
          "details": data["details"],
          "url": data["url"]
        });
        //});
        //list.add(data);
        //return list;
        // ...
        //}
      },
      onError: (e) => print("Error getting document: $e"),
    );


    /*Stream <DocumentSnapshot> q= await documentReferencer.snapshots();
    q.forEach((element){
      var data = element.data();
      print("******");
      print(data);
      print("******");
    });*/
    return list;
  }

/*
  void _updateList() async{
    setState(() {
      _counter++;
      list.add({"name":data["name"],"email":data["email"],"phoneNumber":data["phoneNumber"],"location":data["location"],"details":data["details"],"url":data["url"]});
    });
}*/
}
