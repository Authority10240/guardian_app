

import 'package:flutter/material.dart';
import 'package:guardian_app/SQL_Models/contact_model.dart';
import 'package:guardian_app/UIX/Dialogs.dart';
import 'dart:async';
import 'package:qrcode_reader/qrcode_reader.dart';
import 'package:flutter/services.dart';
//import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/scheduler.dart';
import 'package:guardian_app/BackEnd/DBHelper.dart';
import 'package:guardian_app/SQL_Models/child_model.dart';
import "package:sqflite/sqflite.dart";
import 'Grade_Selector.dart';
import 'package:guardian_app/Pages/Entacom_home.dart';

import 'package:guardian_app/BackEnd/aes_encryption_helper.dart';

class QRCodeAddScreen extends StatefulWidget {
  ChildInformaiton _ci;

  QRCodeAddScreen(this._ci);

  @override
  State<StatefulWidget> createState() {

    // TODO: implement createState
    return new QRState(_ci);
  }
}

  class QRState extends State<QRCodeAddScreen> {
    List <ChildInformaiton> studentList ;
    DBHelper dbHelper = DBHelper();
    int count = 0;
    String result = 'Select Subject Adding Method',child= '*Select Student';
    ChildInformaiton ci;
    QRState(this.ci);
    Dialogs dialogs = Dialogs();
    List<String> qrString = List();
    Future _scanQR() async {
      updateListVIew();
      try {
        String qrResult = await QRCodeReader().scan();
        //result = await AESCrypt().decryptString(qrResult);
        result = qrResult;
        if (qrResult == null) {

        } else{
          setState(() {
            ContactInformation contInfo = ContactInformation.blank();
            qrString = qrResult.split(':');
            contInfo.TEACHER_NAME = qrString[0] +' '+ qrString[1] + ' ' + qrString[2];
            contInfo.TEACHER_ID = qrString[3];
            contInfo.SUBJECT_ID = qrString[5];
            contInfo.COURSE_ID = qrString[6];
            contInfo.SET = qrString[7];
            dialogs.ConfirmSubject(context, dbHelper, 'Add Subject', 'Add:'
                '\nGrade ' + '\'${contInfo.COURSE_ID}\''
                '\nSubject ' + '\'${contInfo.SUBJECT_ID}\''
                '\nSet + ' '\'${contInfo.SET}\''
                '\nTo:'
                '\n \'${ci.getSTUDENT_NAME() + ' ' + ci.getSTUDENT_SURNAAME()}', ci, contInfo);
          });
      }
      } on PlatformException catch (e) {

      } on FormatException catch (e) {
        setState(() {
          result = 'No QR code scanned';
        });
      } catch (e) {
        setState(() {
          result = 'Unknown Error $e.';
        });
      }
    }

    @override
    Widget build(BuildContext context) {
      // TODO: implement build
      return Scaffold(
        appBar: AppBar(title: Text('Add Subject'),
        centerTitle: true,
        leading: FlatButton(onPressed: (){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => EntacomHome()));
        },
        child: Icon(Icons.arrow_back, color: Colors.white,),),),

        body: WillPopScope(
          onWillPop: (){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => EntacomHome()));
          },
          child: ListView(
            children: <Widget>[

              SizedBox(height: MediaQuery.of(context).size.height/3,),

              RaisedButton(
                child: Text('Via Selection'),
                color: Colors.cyan,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(new Radius.circular(10.0))),
                elevation: 7.0,
                onPressed: (){

                  Navigator.push(context,
                      MaterialPageRoute(
                          builder: (context) =>
                              Grade_Selector(ci)));
                },


              ),

              RaisedButton(
                child: Text('Via Quick Response Code'),
                color: Colors.cyan,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(new Radius.circular(10.0))),
                elevation: 7.0,
                onPressed: (){
                  _scanQR();
                },


              ),
              SizedBox(height: 30,),
              Icon(Icons.add_to_photos,color: Colors.cyan,size: 150,)

            ],
          )
          ,
        )
      );
    }

    Confirm(BuildContext context, DBHelper db_helper, String title,
        String description,
        int pos, ChildInformaiton childInfo) {
      return showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              
              title: Text(title,),
              elevation: 7.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(description),
                    _drop_input('Child Name.'),
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('Cancel', style: TextStyle(color: Colors.black)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text('Confirm',style: TextStyle(color: Colors.black)),
                  onPressed: () {
                    decryptQRCode();
                    Navigator.pop(context);
                  },
                )
              ],
            );
          }
      );
    }

    Widget _drop_input(String hint) {
      return new DropdownButtonHideUnderline(
        child: new DropdownButton(
          style: TextStyle(color: Colors.black),

          items:getNames().map((String value){
            return DropdownMenuItem(
                child: Text(value),
                value: value,
                key: Key(value));
          }).toList(),
            value: child,
          elevation: 7,
          hint: Text(hint),
          iconSize: 40,
          onChanged: (value) {
            setState(() {
              child = value;
              getStudent(value);
            });
          },
        ),
      );
    }

    prepareContact(String QRresult) {

    }

    void updateListVIew() {
      final Future<Database> dbFuture = dbHelper.initDB();
      dbFuture.then((database) {
        Future<List<ChildInformaiton>> childrenListFuture = dbHelper
            .getChildrenList();
        childrenListFuture.then((childList) {
          setState(() {
            this.studentList = childList;
            this.count = childList.length;
          });
        });
      });
    }

    List<String> getNames (){
      List<String> student = new List<String>();
      if (studentList.length == 0){
        studentList = new List<ChildInformaiton>();
      }else{
        studentList.add(ChildInformaiton('', 'No Student', '', ''));
      }
      for (int i = 0; i< studentList.length; i++){
        student.add(studentList[i].STUDENT_NAME );
      }
      return student;
    }

    void getStudent(String name){
      for( int i = 0 ; i < studentList.length; i++){
        if (studentList[i].STUDENT_NAME == name){
          this.ci = studentList[i];
        }
      }
    }

    decryptQRCode(){

    }


      }





