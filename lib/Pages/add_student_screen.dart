

import 'package:flutter/material.dart';
import 'package:guardian_app/SQL_Models/child_model.dart';
import 'package:guardian_app/SQL_Models/school_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:guardian_app/BackEnd/DBHelper.dart';
import 'package:guardian_app/UIX/Dialogs.dart';
import "package:sqflite/sqflite.dart";
import 'Select_School.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddStudentScreen extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new AddStudentScreenState();
  }
}

  class AddStudentScreenState extends State<AddStudentScreen>{
  ChildInformaiton childInformaiton;
  List<SchoolInformation> schoolList;
  String studentName = '' , studentSurname = '' , studentNumber = '' , _schoolId ='*Select School';
  SchoolInformation schoolInformation ;
  FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  DatabaseReference databaseReference = FirebaseDatabase.instance.reference();

  int count = 0;
  Dialogs dialog = new Dialogs();
  TextEditingController _textEditingController;
  final formkey=new GlobalKey<FormState>();
  List<String> student = new List<String>();
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    schoolList = List<SchoolInformation>();
    childInformaiton  = new ChildInformaiton.blank();
    _textEditingController = new TextEditingController();

    updateListVIew();
    return Material(
      color: Colors.white,
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          SizedBox(width: 20.0,height: 10.0,),

          Container(
            child: Center(
              child:Text('Add Student:',style: TextStyle(fontSize: 20.0,),),
            )
          ),
          Container(
            height:50,
            width: 50,
            margin: EdgeInsets.only(top: 50.0),
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/add-friend.png'),
                  fit: BoxFit.contain),

              borderRadius: BorderRadius.only
                (
                  bottomLeft: Radius.circular(500.0),
                  bottomRight: Radius.circular(500.0)
              ),
            ),
          ),

          Container(
            width: MediaQuery.of(context).size.width-200,
            child: Center(
              child: Padding(
                  padding: const EdgeInsets.all(28.0),
              child: Center(
              child: Form(
                key: formkey,
                child: Center(
                  child: ListView(
                    shrinkWrap: true,

                    children: <Widget>[
                      _input("Student Number",false,'*Student Number', 'Student Number', 1 ),
                      SizedBox(width: 20.0,height: 10.0,),
                      _input("Name",false,'*Enter Name', 'Name' , 2 ),
                      SizedBox(width: 20.0,height: 10.0,),
                      _input('Surname', false, '*Enter Surname',' Surname' ,3),
                      SizedBox(width: 20.0,height: 10.0),
                      _Button(context,"Next Step"),
                    ],
                  ),
                ),
              ),
              ) ,
              ),
            ),
          )
        ],
      ),
    );
  }



Widget _input(String validation,bool ,String label,String hint , int pos){
  return new TextField(

    decoration: InputDecoration(
      hintText: hint,
      fillColor: Colors.white,
      labelText: label,

      contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 20.0),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0)
      ),
    ),
    obscureText: bool,
   onChanged: (value){
     switch(pos){
       case 1:
         studentNumber = value.trim();
         break;
       case 2:
         studentName = value.trim();
         break;
       case 3:
         studentSurname = value.trim();
         break;
     }

   },
  );
}

Widget _drop_input(String hint, dynamic store)  {
  return new DropdownButtonHideUnderline (
    child: new DropdownButton(
      style: TextStyle(),
      items:  getSchools().map((String value){
        return DropdownMenuItem(
          value: value,
          child: Text(value, style: TextStyle(color: Colors.black),),
        );
      }).toList(),
      value: _schoolId,
      elevation: 7,
      hint: Text(hint),
      iconSize: 40,
      onChanged: (String value){
        this._schoolId = value;
        this.schoolInformation.SCHOOL_NAME = value;
        setState(() {
        });
      },

    ),
  );
}

Widget  _Button(BuildContext context ,String label ){
  return new OutlineButton(
      child: Text(label),

      color: Colors.white,
      onPressed: () {
        if (validateInput()){

          Navigator.push(context, MaterialPageRoute(builder: (context) => new School_Select(studentName,studentSurname,studentNumber)));

        /* childInformaiton= new ChildInformaiton(studentNumber.trim(), studentName.trim(),
              studentSurname.trim(), _schoolId.trim());
          dialog.Confirm(context,dbHelper, 'Add Child',
              'Student Number: $studentNumber\n'
              'Name: $studentName \n'
              'Surname: $studentSurname', 1 , childInformaiton );*/
        }



      });


}

  setValue(String value, dynamic store ){
  store = value;
}
bool validateInput(){
    bool valid = true;
    if(studentName.isEmpty){
        valid = false;
    }else if (studentSurname.isEmpty){
      valid = false;
    }else if(studentNumber.isEmpty){
      valid = false;
    }else if(_schoolId.isEmpty){
     // valid = false;
      _schoolId = 'CAPRICORN  HIGH SCHOOL';
    }
    return valid;
}

  List<String> getSchools (){
      student.clear();
    if (schoolList.length == 0){
      schoolList = new List<SchoolInformation>();
      schoolList.add(new SchoolInformation(0, 'null', '*Select School', 'Null', 'Null','Null', 'Null'));
    }else{
      schoolList.add(new SchoolInformation(0, 'null', '*Select School', 'Null', 'Null','Null', 'Null'));

    }

    for (int i = 0; i< schoolList.length; i++){
      student.add(schoolList[i].SCHOOL_NAME);
    }
    return student;
  }

    void updateListVIew() async {
     /* final Future<Database> dbFuture = dbHelper.initDB();
      dbFuture.then((database) {
        Future<List<SchoolInformation>> childrenListFuture =  dbHelper
        .getSchoolList();
        childrenListFuture.then((childList) {
          setState(() {
            this.schoolList = childList;
            this.count = childList.length;
          });
        });
      });*/
     await listenToSchools();
    }




  Future listenToSchools() async {

    //start listening to messages from firebase with the struture
    SchoolInformation schools = new SchoolInformation.blank();
    schoolList = new List();
    databaseReference.reference().child('REGISTERED_SCHOOLS');
    databaseReference.onChildAdded.listen((event) {
      var val = event.snapshot.value;
      schools.SCHOOL_NAME = val['SCHOOL_NAME'];
     /* schools.SCHOOL_PRINCIPAL = val['SCHOOL_PRINCIPA'];
      schools.SCHOOL_LOCATION = val['SCHOOL_LOCATION'];
      schools.SCHOOL_CONTACTS = val['SCHOOL_CONTACTS'];
      schools.SCHOOL_EMAIL = val['SCHOOL_EMAIL'];*/
      setState(() {
        this.schoolList.add(schools);
        this.student.add(schools.SCHOOL_NAME);
        this.count = schoolList.length;
      });


    });
  }



}

