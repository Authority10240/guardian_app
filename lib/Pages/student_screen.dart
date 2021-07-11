
import 'dart:developer';
import 'dart:ui';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:guardian_app/BackEnd/DBHelper.dart';
import 'package:guardian_app/UIX/CustomListView.dart';
import 'package:guardian_app/SQL_Models/child_model.dart';
import 'package:guardian_app/Pages/years_screen.dart';
import 'package:guardian_app/main.dart';
import "package:sqflite/sqflite.dart";
import 'package:shared_preferences/shared_preferences.dart';
import 'package:guardian_app/SQL_Models/child_model.dart';
import 'package:guardian_app/SQL_Models/contact_model.dart';
import 'package:guardian_app/SQL_Models/message_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
class studentScreen extends StatefulWidget{
  @override

  State<StatefulWidget> createState() {
    // TODO: implement createState


    return studentScreenState();
  }
}

class studentScreenState extends State<studentScreen>{
  List <ChildInformaiton> studentList ;
  ChildInformaiton selectedChild = new ChildInformaiton.blank();

  int count = 0;
  SharedPreferences sp ;
  DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
  String schoolName, teacherID, subField, subDepartment, subID, studentNumber;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    if(studentList == null){
      studentList = new List();
      updateListVIew();
    }

  return
    ListView.builder(

        itemCount: count,
        itemBuilder: (BuildContext context, int position){
          return Card(
            color: Colors.white,
            elevation: 7.0,
            child: ListTile(
              trailing: Icon(Icons.email, color: getColor(studentList[position]),),
              onTap: (){
                selectedChild = studentList[position];
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => new yearScreen(selectedChild), )
                );},
              leading: CircleAvatar(
                backgroundColor: Colors.cyan,
                child: Icon(Icons.supervised_user_circle),
              ),

              title: Text(studentList[position].STUDENT_NAME + ' ' + studentList[position].STUDENT_SURNAAME),

              subtitle: Text('Student Number: ' + studentList[position].STUDENT_NUMBER),

            ),
          );
        });

  }

  void _delete (BuildContext context ,ChildInformaiton childInfo) async{

    Confirm(context, MyApp.dbHelper, 'Permanently Delete?', 'By deleting this child you will no longer be able to recieve messages from thie teachers\'.\n Are you sure you want to proceed?' , 1, childInfo);
    updateListVIew();

  }

void updateListVIew(){

    final Future<Database> dbFuture = MyApp.dbHelper.initDB();
    dbFuture.then((database){

      Future<List<ChildInformaiton>> childrenListFuture = MyApp.dbHelper.getChildrenList();
      childrenListFuture.then((childList){
        setState(() {
          this.studentList = childList;
          this.count = childList.length;

          getStudentMessageCount(childList);

        });
      });
      });


}
 Future<Color> getStudentMessageCount(List<ChildInformaiton> chidlist) async{
    for(int i = 0 ; i < chidlist.length ; i++){
      int lengthOfMessages = await MyApp.dbHelper.getChildNewMessageCount(chidlist[i].STUDENT_NUMBER);
      if(lengthOfMessages > 0 ) {
        chidlist[i].badge = Badge(
          child: Text(lengthOfMessages.toString()), badgeColor: Colors.amber,);
      }else{
        chidlist[i].badge = Badge(badgeColor:Colors.white ,);
      }

    }
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
                child: Text('Cancel'),
                onPressed: (){
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text('Confirm'),
                onPressed: (){
                  Navigator.pop(context);
                  switch(pos){
                    case 1:
                      db_helper.deleteChild(childInfo);
                      updateListVIew();
                      break;
                  }
                },
              )
            ],
          );
        }
    );

  }


Color getColor(ChildInformaiton ci){
  Color color = Colors.grey;

  if(ci.NEW_MESSAGE == "Y"){
    color = Colors.amber;
  }

  return color;
}


}