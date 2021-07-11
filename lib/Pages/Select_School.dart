import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:guardian_app/Models/School_model.dart';
import 'file:///C:/Users/Freedom/Downloads/Entacom%20Apps/Principal/entacom_principal/lib/Pages/SplashScreen.dart';
import 'package:guardian_app/UIX/Dialogs.dart';
import "package:sqflite/sqflite.dart";
import 'package:guardian_app/BackEnd/DBHelper.dart';
import 'package:guardian_app/SQL_Models/child_model.dart';
import 'package:guardian_app/SQL_Models/school_model.dart';
import 'package:guardian_app/main.dart';

class School_Select extends StatefulWidget {
  @override
  String _name = '' , _surname = '' , _studentNumber = '';


  String get name => _name;

  set name(String value) {
    _name = value;
  }

  School_Select(this._name, this._surname, this._studentNumber);

  _School_SelectState createState() => _School_SelectState(_name,_surname,_studentNumber);

  get surname => _surname;

  set surname(value) {
    _surname = value;
  }

  get studentNumber => _studentNumber;

  set studentNumber(value) {
    _studentNumber = value;
  }
}

class _School_SelectState extends State<School_Select> {
  String _name = '' , _surname = '' , _studentNumber = '';

  _School_SelectState(this._name, this._surname, this._studentNumber);

  @override
  List<school_model> school_names;
  Dialogs dialog = new Dialogs();



  Widget build(BuildContext context) {
    // TODO: implement build

    if (school_names == null){
      school_names = new List();
      UpdateListView();
    }

    return Scaffold(appBar:
    AppBar(centerTitle: true,
    title: Text('Select School',style: TextStyle(color: Colors.white),),),
    body: ListView.builder(itemCount: school_names.length,itemBuilder: ( context , pos) =>
    new Column(
      children: <Widget>[
        GestureDetector( child: ListTile(leading:
        new CircleAvatar(
          child: Image.network(school_names[pos].school_logo),
          backgroundColor: Colors.transparent,),title: Text(school_names[pos].school_name),),
        onTap: (){
          String schoolName = school_names[pos].school_name;

          ChildInformaiton childInformaiton= new ChildInformaiton(_studentNumber.trim(), _name.trim(),
              _surname.trim(), school_names[pos].school_name.trim());
          dialog.Confirm(context,MyApp.dbHelper, 'Add Child?',
              'Student Number: $_studentNumber\n'
              'Name: $_name \n'
              'Surname: $_surname \n'
              'School: $schoolName', 1 , childInformaiton );

        },),

        Divider(height: 10,)
      ],
    )),);
  }

  UpdateListView(){
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    ref.child('REGISTERED_SCHOOLS').onChildAdded.listen((event){
      var val = event.snapshot.value;
      setState(() {
        school_names.add(school_model(val['SCHOOL_NAME'], val['SCHOOL_LOGO']));
      });

    });

  }
}
