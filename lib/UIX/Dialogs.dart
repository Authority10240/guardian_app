import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:guardian_app/main.dart';
import 'package:guardian_app/BackEnd/DBHelper.dart';
import 'package:guardian_app/SQL_Models/child_model.dart';
import 'package:guardian_app/Pages/Entacom_home.dart';
import 'package:guardian_app/SQL_Models/contact_model.dart';
import 'package:guardian_app/SQL_Models/year_Model.dart';
import 'package:guardian_app/SQL_Models/message_model.dart';
class Dialogs{

  static String text;
  DatabaseReference ref;
  Informattion(BuildContext context, String title, String description) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(description),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok' , style: TextStyle(color: Colors.black)),
                onPressed: (){
                  Navigator.pop(context);
                },
              )
            ],
          );
        }
    );
  }

  Waiting(BuildContext context ,String title, String description){
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(description),
                ],
              ),
            ),
          );
        }
    );
  }

  Input(BuildContext context, String title, String description){

    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(description),
                ],
              ),
            ),
            actions: <Widget>[
              TextField(
                decoration: InputDecoration(
                  hintText: description,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 20.0),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                onChanged: (value) => text = value,
              ),
              FlatButton(
              child: Text('Cancel'),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                color: Colors.cyan,
              onPressed: (){
                text = '';
                Navigator.pop(context);
              },
              ),
              FlatButton(
                child: Text('Confirm'),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                color: Colors.cyan,
                onPressed: (){
                  Navigator.pop(context);
                },
              )
            ],
          );
        }
    );
  }

  Confirm(BuildContext context,DBHelper db_helper, String title, String description,
      int pos,ChildInformaiton childInfo){

    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title,),

            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(description),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Cancel',style: TextStyle(color: Colors.black)),
                onPressed: (){
                  text = '';
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text('Confirm',style: TextStyle(color: Colors.black)),
                onPressed: (){
                  AddChildProcess(context,db_helper,childInfo);

                  Navigator.of(context).popUntil((route)=> route.isFirst);



                },
              )
            ],
          );
        }
    );

  }

  ConfirmSubject(BuildContext context,DBHelper db_helper, String title, String description,
      ChildInformaiton childInfo, ContactInformation continf,){

    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title,),

            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(description),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Cancel',style: TextStyle(color: Colors.black)),
                onPressed: (){
                  text = '';
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text('Confirm',style: TextStyle(color: Colors.black)),
                onPressed: (){
                  AddSubjectProcess(context,db_helper,childInfo,continf);

                  Navigator.of(context).popUntil((route)=> route.isFirst);
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => EntacomHome()));



                },
              )
            ],
          );
        }
    );

  }


  void AddSubjectProcess(BuildContext context , DBHelper dbHelper,
      ChildInformaiton childInfo,ContactInformation contInfo){
    dbHelper.insertContact(childInfo, contInfo);
    try {
      dbHelper.addNewYear(childInfo, contInfo);
    }catch(e){
      //means Year has already been created
    }
    listenToMessages(context, dbHelper, childInfo, contInfo);
    ref = FirebaseDatabase.instance.reference().child(childInfo.getSCHOOL_ID())
    .child('REGISTERED_STUDENTS').child(contInfo.TEACHER_ID)
        .child(new DateTime.now().year.toString()).child(contInfo.COURSE_ID)
        .child(contInfo.SUBJECT_ID).child(contInfo.SET).child(childInfo.getSTUDENT_NUMBER());
    ref.set(childInfo.toMap());


  }


  void AddChildProcess(BuildContext context,DBHelper db_helper , ChildInformaiton childInfo) async {
   // if (!await db_helper.CheckUser(childInfo)) {
      db_helper.addNewStudent(childInfo);

      Informattion(context, 'Student Added', 'Student succesfully Added.');
    /*} else {
      Informattion(
          context, 'Already Added', 'This student has already been Added.');
    }*/
  }

  }

Future listenToMessages(BuildContext context , DBHelper dbHelper,
    ChildInformaiton childInfo,ContactInformation contInfo) async {

  DatabaseReference databaseReference = FirebaseDatabase.instance.reference();

      //start listening to messages from firebase with the struture

  databaseReference.child(childInfo.getSCHOOL_ID()).child("SMESSAGES")
      .child(contInfo.TEACHER_ID).child(DateTime.now().year.toString()).child(contInfo.COURSE_ID)
      .child(contInfo.SUBJECT_ID).child(contInfo.SET).child('GROUPED').onChildAdded.listen((event) {
    var val = event.snapshot.value;
    messageInformation messageinformation = new messageInformation
        .blank();
    //populate with data from firebase;
    messageinformation.ARRIVAL_DATE = val['ARRIVAL_DATE'];
    messageinformation.ATTACHMENT_ID = val['ATTACHMENT_ID'];
    messageinformation.DEVICE_ID = val['DEVICE_ID'];
    messageinformation.EXTENTION = val['sExtentionID'];
    messageinformation.NEW_MESSAGE = val['NEW_MESSAGE'];
    messageinformation.MESSAGE_CONTENT = val['MESSAGE_CONTENT'];
    messageinformation.MESSAGE_HEADING = val['MESSAGE_HEADING'];
    messageinformation.MESSAGE_ID = val['MESSAGE_ID'];
    // messageinformation.MESSAGE_PRIORITY = val['id'];
    messageinformation.SUBJECT_ID = val['SUBJECT_ID'];
    messageinformation.MESSAGE_PRIORITY = val['MESSAGE_PRIORITY'];
    messageinformation.STUDENT_NUMBER = childInfo.STUDENT_NUMBER;
    //insert into database;

    //insert into database;
    MyApp.dbHelper.insertNewMessage(messageinformation);
    // insert the new message flag to all message categories.



  });


}
