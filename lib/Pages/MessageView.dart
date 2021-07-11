
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:guardian_app/SQL_Models/child_model.dart';
import 'package:guardian_app/SQL_Models/contact_model.dart';
import 'package:guardian_app/BackEnd/DBHelper.dart';
import 'package:guardian_app/SQL_Models/message_model.dart';
import 'package:guardian_app/SQL_Models/year_Model.dart';
import 'package:guardian_app/main.dart';
import "package:sqflite/sqflite.dart";
import 'package:firebase_database/firebase_database.dart';
import 'package:guardian_app/Pages/Subject_List.dart';

class MessageView  extends StatefulWidget {
  @override
  MessageView_State createState() => MessageView_State(this.ci, this.continfo, this.yi);
  MessageView(this.ci,this.continfo, this.yi);
  ChildInformaiton ci;
  YearInformation yi;
  ContactInformation continfo;


}

class MessageView_State extends State<MessageView> {
  YearInformation yi;
  ChildInformaiton ci;
  ContactInformation contInfo;

  MessageView_State(this.ci, this.contInfo, this.yi);
  List<messageInformation> messageList;



  @override

  Widget build(BuildContext context) {

    if(messageList == null){
      messageList = List();

      UpdateListView();
    }
    return Scaffold(
      appBar: AppBar(centerTitle: true,
        leading: FlatButton(onPressed: (){
          updateSubjectNewMessage();
          Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) =>
                  Subject_List(ci,yi)) );
        },
        child: Icon(Icons.arrow_back, color: Colors.white,),),
        title: Text(
          contInfo.SUBJECT_ID + ' Messages',style: TextStyle(color: Colors.white),),),
      body:WillPopScope(
        onWillPop: (){
          updateSubjectNewMessage();
          return Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) =>
                  Subject_List(ci,yi)) );
        },
        child: ListView.builder(itemCount: messageList.length,itemBuilder: (context, pos) =>
        new Card(color: getMessageColor(messageList[pos]),child: ListTile(title: Text(messageList[pos].MESSAGE_CONTENT), subtitle: Text(messageList[pos].ARRIVAL_DATE),)),
        ),
      )  );
  }

  UpdateListView(){
    final Future<Database> dbFuture = MyApp.dbHelper.initDB();
    dbFuture.then((database) {
      Future<List<messageInformation>> messageListFuture = MyApp.dbHelper
          .getMessageList(contInfo,yi,ci);
      messageListFuture.then((messages) {
        setState(() {
          this.messageList = messages;


        });
      });
    });

  }
  getMessageColor(messageInformation msginfo){
    Color color = Colors.white70;

    if(msginfo.NEW_MESSAGE == 'Y'){
      color = Colors.cyan;
    }

    return color;
  }

   listenToMessages() async {
    DBHelper dbaccess = new DBHelper();

    String schoolName, teacherID, subField, subDepartment, subID, studentNumber;

    // get information from the student table
    List<ChildInformaiton> childInfo = await dbaccess.getChildrenList();
    //loop through all the information to get individual studet details
    for (int i = 0; i < childInfo.length; i++) {
      // get the subject for each individual unique students
      List<ContactInformation> contactInfo = await dbaccess.getContactList
        (childInfo[i].STUDENT_NUMBER);
      //loop through all the each subject of each student.
      for (int j = 0; j < contactInfo.length; j++) {
        //gether the required information from the relevant tables


        schoolName = childInfo[i].SCHOOL_ID;
        teacherID = contactInfo[j].TEACHER_ID;
        subField = contactInfo[j].COURSE_ID;
        subDepartment = contactInfo[j].DEPARTMENT_ID;
        subID = contactInfo[j].SUBJECT_ID;
        studentNumber = childInfo[i].STUDENT_NUMBER;

        DatabaseReference ref = FirebaseDatabase.instance.reference();
        DatabaseReference childReference = FirebaseDatabase.instance.reference();
        //start listening to messages from firebase with the struture

        ref.child(schoolName).child("SMESSAGES")
            .child(teacherID).child(contactInfo[j].SCHOLAR_YEAR).child(subField)
            .child(contactInfo[j].SUBJECT_ID).child(contactInfo[j].SET).child('GROUPED').onChildAdded.listen((event) {
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
          messageinformation.STUDENT_NUMBER = childInfo[i].STUDENT_NUMBER;
          //insert into database;
          dbaccess.insertNewMessage(messageinformation);

          UpdateListView();
        });

        childReference.child(schoolName).child("SMESSAGES")
            .child(teacherID).child(contactInfo[j].SCHOLAR_YEAR).child(subField)
            .child(contactInfo[j].SUBJECT_ID).child(contactInfo[j].SET).child(studentNumber).onChildAdded.listen((event) {
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
          messageinformation.STUDENT_NUMBER = childInfo[i].STUDENT_NUMBER;
          //insert into database;

          //insert into database;
          MyApp.dbHelper.insertNewMessage(messageinformation);
          // insert the new message flag to all message categories.



        });
      }
    }
  }

 updateSubjectNewMessage(){
MyApp.dbHelper.updateNewMessage(contInfo, yi, ci);
MyApp.dbHelper.updateNewMessageSubjectTable(ci.getSTUDENT_NUMBER(), contInfo.SUBJECT_ID, 'N');
 }


}
