import 'package:flutter/material.dart';
import 'package:guardian_app/Models/chat_Model.dart';
class studentYearScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new studentYearScreenState();
  }

}

class studentYearScreenState extends State<studentYearScreen>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ListView.builder(
    itemCount: messageDate.length,
    itemBuilder: (context,i)=> new Column(
      children: <Widget>[
        new Divider(
          height: 10.0,
        ),
        new ListTile(
          leading: new CircleAvatar(
            foregroundColor: Theme.of(context).primaryColor,
            backgroundColor: Theme.of(context).accentColor,
            backgroundImage: new NetworkImage(messageDate[i].avaterURL),

          ),

          title: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Text(messageDate[i].teacher_Name,
                style : new TextStyle(fontWeight: FontWeight.bold),
              ),
              new Text(messageDate[i].dateAndTime,
                style : new TextStyle(color: Colors.grey, fontSize: 14.0),
              ),
              
            ],
          ),
          subtitle: new Container(
            padding: const EdgeInsets.only(top: 5.0),
            child: new Text(messageDate[i].messageContent, style: new TextStyle(color: Colors.grey, fontSize: 14.0),),
          ),
        )
      ],
    ),);
  }

  
}