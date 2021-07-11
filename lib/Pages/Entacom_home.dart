import 'dart:isolate';

import 'package:guardian_app/Pages/add_QR_screen.dart';
import 'package:guardian_app/Pages/student_screen.dart';
import 'package:flutter/material.dart';
import 'package:guardian_app/main.dart';
import 'add_student_screen.dart';
import 'years_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import 'package:guardian_app/SQL_Models/child_model.dart';
import 'package:guardian_app/SQL_Models/contact_model.dart';
import 'package:guardian_app/SQL_Models/message_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:guardian_app/BackEnd/DBHelper.dart';
import 'package:shared_preferences/shared_preferences.dart';




class EntacomHome extends StatefulWidget{
  @override

  _EntacomHomeState createState() => new _EntacomHomeState() ;

}

class _EntacomHomeState extends State<EntacomHome>

    with SingleTickerProviderStateMixin{

  TabController _tabController;
  SharedPreferences sp ;




  String schoolName, teacherID, subField, subDepartment, subID, studentNumber;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _tabController = new TabController(vsync: this,initialIndex: 1, length: 2);
  }

  @override
  Widget build(BuildContext context) {

    // TODO: implement build
  checkTimer();
    return new Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.cyan,
        child: Icon(Icons.access_alarm, color: Colors.white,),
        onPressed: showCurrentTime,

      ) ,
      appBar: new AppBar(
        centerTitle: true,

        title: new Text('Entacom Guardian',style: TextStyle(fontSize: 20.0 , fontWeight: FontWeight.bold),),
        elevation: 7.0,
        bottom:  new TabBar(
          controller: _tabController,
          indicatorColor: Colors.cyan[600],
          tabs: <Widget>[
            new Tab(icon:  new Icon(Icons.add_circle,color: Colors.white),),
            new Tab(icon: new Icon(Icons.list, color: Colors.white,),),

          ],
        ),
        actions: <Widget>[new Icon(Icons.more_vert)],
      ),

      body: new TabBarView(
        controller: _tabController,
          children: <Widget>[
            new AddStudentScreen(),
            new studentScreen(),

          ],
      ),
    );
  }

  setTimer() {
    DatePicker.showTimePicker(context, showTitleActions: true, showSecondsColumn: false
    ,onConfirm: (time) async{
      sp = await SharedPreferences.getInstance();
      sp.setInt('Hour', time.hour);
      sp.setInt('Minute', time.minute);
    });

  }

  checkTimer()async {
    sp = await SharedPreferences.getInstance();
    if(sp.getInt('Hour') == null){
      Confirm(context, "Prefered Notification Time","Welcome to Entacom Guardian, Before we begin"
          " please set a time that is most convinient for you to receive messages"
          " from your children's teachers (hh/mm/ss)" );
    }
  }

  showCurrentTime() async{
    sp = await SharedPreferences.getInstance();
    String description ;
    if(sp.get('Hour') == null){
      description = 'Timer has not been set yet, would you like to set the timer now?';
    }else{
      description = 'Current time for timer is set to ${sp.getInt('Hour').toString()} : ${sp.getInt('Minute').toString()}'
          ', would you like to change the timer? ';
    }

    Confirm(context, 'Change Notification Timer', description);
  }
  Confirm(BuildContext context, String title, String description,
      ){

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
                child: Text('Set Time',style: TextStyle(color: Colors.black)),
                onPressed: (){

                  Navigator.pop(context);
                  setTimer();
                },
              ),
              FlatButton(
                child: Text('Cancel',style: TextStyle(color: Colors.black)),
                onPressed: (){

                  Navigator.pop(context);
                },
              ),


            ],
          );
        }
    );

  }



}