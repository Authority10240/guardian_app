import 'package:flutter/material.dart';
import 'package:guardian_app/SQL_Models/child_model.dart';
import 'package:guardian_app/SQL_Models/contact_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'Select_Set.dart';


class Teacher_Selector extends StatefulWidget {
  @override
  ChildInformaiton ci ;
  ContactInformation conInf;

  Teacher_Selector(this.ci, this.conInf);

  _Teacher_SelectorState createState() => _Teacher_SelectorState(ci,conInf);
}

class _Teacher_SelectorState extends State<Teacher_Selector> {
  ChildInformaiton ci;
  List<String> Teacher;
  List<String> employee = List();
  ContactInformation contInf ;
  _Teacher_SelectorState(this.ci, this.contInf);
  DatabaseReference ref;



  @override
  Widget build(BuildContext context) {

    // TODO: implement build

    if (Teacher == null){
      Teacher = List();
      UpdateListView();
    }
    return Scaffold(appBar:
    AppBar(centerTitle: true,
      title: Text('Educator',style: TextStyle(color: Colors.white),),),
      body: ListView.builder(itemCount: Teacher.length,itemBuilder: ( context , pos) =>
      new Column(
        children: <Widget>[
          GestureDetector( child: ListTile(leading:
          new CircleAvatar(
            child: Text( pos.toString(),
              style: TextStyle(color: Colors.white),),
            backgroundColor: Colors.cyan,),title: Text(Teacher[pos]),),
            onTap: (){
              String teacher = Teacher[pos];
              contInf.TEACHER_NAME = teacher;
              contInf.TEACHER_ID = employee[pos];

              Navigator.push(context,
                  MaterialPageRoute(
                      builder: (context) =>
                          Set_Selector(ci, contInf)));




            },),

          Divider(height: 10,)
        ],
      )),);
  }

  UpdateListView(){
    ref = FirebaseDatabase.instance.reference();
    ref.child(ci.getSCHOOL_ID()).child(DateTime.now().year.toString())
        .child('GRADE').child(contInf.COURSE_ID).child('SUBJECTS')
        .child(contInf.SUBJECT_ID).child('TEACHER').onChildAdded.listen((event){
      var val = event.snapshot.value;
      String t_name = val['EDUCATOR_DETAILS']['sName'];
      String t_title = val['EDUCATOR_DETAILS']['sTitle'];
      String t_surname = val['EDUCATOR_DETAILS']['sSurname'];
      String t_empID = val['EDUCATOR_DETAILS']['sEmployeeNumber'];

      setState(() {
        Teacher.add(t_title + ' ' + t_name[0] + ' ' + t_surname);
        employee.add(t_empID);
      });

    });

  }
}
