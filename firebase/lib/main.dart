
import 'dart:async';

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



void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Baal Utsav'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final refDataInstance = FirebaseDatabase.instance.reference().child('users');
  String _location ='';
  String _details='';
  String _name='';
  String _email='';
  String _phoneNumber='';
  String userId = '5LajePE9ON25EO79bc46';
  String _url = '';
  UploadTask? task;
  File? file;
  String fileName = 'No File Selected';
  var data ={ "name" : '',"email":'',"phoneNumber":"","location":"","details":"","url":""};
  List<Map<String,dynamic>> list = [];
  List<Map<String,File?>> file_list = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  ConnectivityResult? _connectivityResult;
  late StreamSubscription _connectivitySubscription;
  bool? _isConnectionSuccessful;

  @override
  initState() {
    super.initState();

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
        ConnectivityResult result
        ) async{
      print('Current connectivity status: $result');
      if(result == ConnectivityResult.mobile||result == ConnectivityResult.wifi){
        for(var i=0;i<file_list.length;i++){
          var keys= file_list[i].keys;
          Iterable<File?> temp = file_list[i].values;


          final fileName = basename(temp.first!.path);
          final destination = 'files/$fileName';
          var urlDownload = '';
          final File file1 = await File(temp.first!.path);
          task = uploadFile1(destination, file1);
          setState(() {});

          if (task == null) urlDownload = '';

          final snapshot = await task!.whenComplete(() {print("pending image added");});
          //urlDownload = await snapshot.ref.getDownloadURL();
          //Database.updateItem(url: urlDownload, counter: keys.first);
        }
        file_list = [];
      }
      setState(() {
        _connectivityResult = result;
      });
    });
  }

  @override
  dispose() {
    super.dispose();

    _connectivitySubscription.cancel();
  }

  Future<void> _checkConnectivityState() async {
    final ConnectivityResult result = await Connectivity().checkConnectivity();

    if (result == ConnectivityResult.wifi) {
      print('Connected to a Wi-Fi network');
    } else if (result == ConnectivityResult.mobile) {
      print('Connected to a mobile network');
    } else {
      print('Not connected to any network');
    }

    setState(() {
      _connectivityResult = result;
    });
  }


  Widget _buildName() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Name'),
      maxLength: 10,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Name is Required';
        }

        return null;
      },
      onSaved: (value) {
        _name = value!;
        data["name"]=value;
      },
    );
  }

  Widget _buildLocation() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Location'),
      maxLength: 10,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Location is Required';
        }

        return null;
      },
      onSaved: (value) {
        _location = value!;
        data["location"]=value;
      },
    );
  }

  Widget _buildDetails() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Details'),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Details is Required';
        }

        return null;
      },
      onSaved: (value) {
        _details = value!;
        data["details"]=value;
      },
    );
  }

  Widget _buildEmail() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Email'),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Email is Required';
        }

        if (!RegExp(
            r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
            .hasMatch(value)) {
          return 'Please enter a valid email Address';
        }

        return null;
      },
      onSaved: (value) {
        _email = value!;
        data["email"]=value;
      },
    );
  }



  Widget _buildPhoneNumber() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Phone number'),
      keyboardType: TextInputType.phone,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Phone number is Required';
        }

        return null;
      },
      onSaved: (value) {
        _phoneNumber = value!;
        data["phoneNumber"] = value;
      },
    );
  }


  Future selectFile()async{
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    FilePickerStatus.done;

    if (result == null) return;
    final path = result.files.single.path!;
    WidgetsBinding.instance?.addPostFrameCallback((_) => setState(()=>{file = File(path)}));
  }
  static UploadTask? uploadFile1(String destination, File file) {
    try {
      final ref = FirebaseStorage.instance.ref(destination);

      return ref.putFile(file);
    } on FirebaseException catch (e) {
      return null;
    }
  }
  uploadFile()async{
    if (file == null) return ;
    _checkConnectivityState();
    final fileName = basename(file!.path);
    final destination = 'files/$fileName';
    if(_connectivityResult == ConnectivityResult.none){
      file_list.add({'$_counter': file});
      print(file_list);
      return destination;
    }

    task = uploadFile1(destination, file!);
    setState(() {});

    if (task == null) return '';

    final snapshot = await task!.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();

    return destination;
  }
  _openPopupForSearch(context,text) {
    fileName = file != null ? basename(file!.path) : 'No File Selected';
    //_checkConnectivityState();
    Alert(
      context: context,
      title: "Enter Email to search the records",
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _connectivityResult.toString(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            //_buildName(),
            _buildEmail(),
            //_buildPhoneNumber(),
            //_buildLocation(),
            //_buildDetails(),
            const SizedBox(height: 100),
            /*DialogButton(child: const Text(
              "Select File",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ), onPressed: selectFile),
            Text(
              text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),*/
            DialogButton(
              child: const Text(
                "Submit",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: () async {
                if (!_formKey.currentState!.validate()) {
                  return;
                }
                _formKey.currentState!.save();
                _url = await uploadFile();
                data["url"] = _url;
                // final CollectionReference _ref = _firestore.collection('user');
                // DocumentReference documentRef = _ref.doc(userId).collection('data').doc();
                // await documentRef.set(data).whenComplete(() => print("Added")).catchError((e)=>print(e));
                //Database.addItem(data,_counter.toString());
                list=[];
                await Database.readItems(data["email"],list);
                //var asStream = refDataInstance.push().child('volunteer-details').set(data).asStream();

                Navigator.pop(context);
                setState(() {
                  _counter++;
                  //list.add({"name":data["name"],"email":data["email"],"phoneNumber":data["phoneNumber"],"location":data["location"],"details":data["details"],"url":data["url"]});
                });
                //_updateListRead();
                //Send to API
              },
            ),
          ],
        ),
      ),
    ).show();
  }
  _openPopup(context,text) {
    fileName = file != null ? basename(file!.path) : 'No File Selected';
    _checkConnectivityState();
    Alert(
      context: context,
      title: "Enter Details",
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _connectivityResult.toString(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            _buildName(),
            _buildEmail(),
            _buildPhoneNumber(),
            _buildLocation(),
            _buildDetails(),
            const SizedBox(height: 100),
            DialogButton(child: const Text(
              "Select File",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ), onPressed: selectFile),
            Text(
              text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            DialogButton(
              child: const Text(
                "Submit",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: () async {
                if (!_formKey.currentState!.validate()) {
                  return;
                }
                _formKey.currentState!.save();
                _url = await uploadFile();
                data["url"] = _url;
                _updateList();
                // final CollectionReference _ref = _firestore.collection('user');
                // DocumentReference documentRef = _ref.doc(userId).collection('data').doc();
                // await documentRef.set(data).whenComplete(() => print("Added")).catchError((e)=>print(e));
                Database.addItem(data,_counter.toString());


                //var asStream = refDataInstance.push().child('volunteer-details').set(data).asStream();

                Navigator.pop(context);
                //Send to API
              },
            ),
          ],
        ),
      ),
    ).show();
  }
  int _counter = 0;

  void _updateList() async{
    setState(() {
      _counter++;
      list.add({"name":data["name"],"email":data["email"],"phoneNumber":data["phoneNumber"],"location":data["location"],"details":data["details"],"url":data["url"]});
    });


    // final destination = 'files/$fileName';
    //
    // task = uploadBytes(destination, data);
    // setState(() {});
    //
    // if (task == null) return ;
    //
    // final snapshot = await task!.whenComplete(() {});
    // final urlDownload = await snapshot.ref.getDownloadURL();
    // print(urlDownload);
    //print(list);
  }

  @override
  Widget build(BuildContext context) {
    final text =  file != null ? basename(file!.path) : 'No File Selected';
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const <DataColumn>[
            DataColumn(
              label: Text(
                'Name',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            DataColumn(
              label: Text(
                'Email',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            DataColumn(
              label: Text(
                'Phone Number',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            DataColumn(
              label: Text(
                'Location',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            DataColumn(
              label: Text(
                'Details',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            DataColumn(
              label: Text(
                'Download',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          ],
          rows: list.map((e) => DataRow(cells: [
            DataCell(Text(e["name"].toString())),
            DataCell(Text(e["email"].toString())),
            DataCell(Text(e["phoneNumber"].toString())),
            DataCell(Text(e["location"].toString())),
            DataCell(Text(e["details"].toString())),
            DataCell( TextButton(
              child: Text('Download', style: TextStyle(fontSize: 20.0),),
              onPressed: () async{
                final ref = FirebaseStorage.instance.ref(e["url"]);
                final imageUrl = await ref.getDownloadURL();
                launchUrlString(imageUrl);
              },
            ),  )
          ])).toList(),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            left: 300,
            bottom: 20,
            child: FloatingActionButton(
              tooltip: 'Increment',
              onPressed: ()=>_openPopup(context,text),
              child: const Icon(Icons.add),
            )
          ),
          Positioned(
              left: 30,
              bottom: 20,
              child: FloatingActionButton(
                tooltip: 'Search',
                onPressed: ()=>_openPopupForSearch(context,text),
                child: const Icon(Icons.search),
              )
          ),
        ]
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

