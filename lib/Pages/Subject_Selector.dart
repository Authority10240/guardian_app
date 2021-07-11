import 'package:flutter/material.dart';
import 'package:guardian_app/SQL_Models/child_model.dart';
import 'package:guardian_app/SQL_Models/contact_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'Teacher_Selector.dart';

class Subject_Selector extends StatefulWidget {
  @override
  ChildInformaiton ci ;
  ContactInformation conInf;

  Subject_Selector(this.ci, this.conInf);

  _Subject_SelectorState createState() => _Subject_SelectorState(ci,conInf);
}

class _Subject_SelectorState extends State<Subject_Selector> {
  ChildInformaiton ci;
  List<String> Subject ;
  ContactInformation contInf ;
  _Subject_SelectorState(this.ci, this.contInf);
  DatabaseReference ref;



  @override
  Widget build(BuildContext context) {

    // TODO: implement build

    if (Subject == null){
      Subject = List();
      UpdateListView();
    }
    return Scaffold(appBar:
    AppBar(centerTitle: true,
      title: Text('Subject',style: TextStyle(color: Colors.white),),),
      body: ListView.builder(itemCount: Subject.length,itemBuilder: ( context , pos) =>
      new Column(
        children: <Widget>[
          GestureDetector( child: ListTile(leading:
          new CircleAvatar(
            child: Text( Subject[pos][0],
              style: TextStyle(color: Colors.white),),
            backgroundColor: Colors.cyan,),title: Text(Subject[pos]),),
            onTap: (){
              String subject = Subject[pos];
              contInf.SUBJECT_ID = subject;
              Navigator.push(context,
                  MaterialPageRoute(
                      builder: (context) =>
                          Teacher_Selector(ci,contInf)));




            },),

          Divider(height: 10,)
        ],
      )),);
  }

  UpdateListView(){
    ref = FirebaseDatabase.instance.reference();
    ref.child(ci.getSCHOOL_ID()).child(DateTime.now().year.toString())
        .child('GRADE').child(contInf.COURSE_ID).child('SUBJECTS').onChildAdded.listen((event){
      var val = event.snapshot.value;
      setState(() {
        Subject.add(event.snapshot.key);
      });

    });

  }
}
