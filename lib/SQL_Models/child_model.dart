import 'package:badges/badges.dart';
class ChildInformaiton{


  int id;
  String STUDENT_NUMBER;
  String STUDENT_NAME;
  String STUDENT_SURNAAME;
  String SCHOOL_ID;
  String NEW_MESSAGE;
  Badge _badge;


  Badge get badge => _badge;

  set badge(Badge value) {
    _badge = value;
  }

  ChildInformaiton.blank();

  ChildInformaiton(this.STUDENT_NUMBER,this.STUDENT_NAME,this.STUDENT_SURNAAME,
      this.SCHOOL_ID);

  ChildInformaiton.withId(this.id, this.STUDENT_NUMBER,this.STUDENT_NAME,
      this.STUDENT_SURNAAME,this.SCHOOL_ID);


  //convert from list to map
  Map<String, dynamic> toMap(){
    var map = Map<String, dynamic>();
    if ( id != null ) {
      map['id'] = id;
    }
      map['STUDENT_NUMBER'] = STUDENT_NUMBER;
      map['STUDENT_NAME'] = STUDENT_NAME;
      map['SCHOOL_ID'] = SCHOOL_ID;
      map['STUDENT_SURNAME'] = STUDENT_SURNAAME;
      map['NEW_MESSAGE'] = 'N';


      return map;
  }

  //extract a child object from the Map object
  ChildInformaiton.fromMapObject(Map<String ,dynamic> map){
    this.id = map['id'];
    this.SCHOOL_ID = map['SCHOOL_ID'];
    this.STUDENT_SURNAAME = map['STUDENT_SURNAME'];
    this.STUDENT_NAME = map['STUDENT_NAME'];
    this.STUDENT_NUMBER = map['STUDENT_NUMBER'];
    this.NEW_MESSAGE = map['NEW_MESSAGE'];
  }

  String getSCHOOL_ID(){
    return SCHOOL_ID;}

  setSCHOOL_ID(String value) {
    SCHOOL_ID = value;
  }

  String getSTUDENT_SURNAAME () {
    return STUDENT_SURNAAME;
  }

  setSTUDENT_SURNAAME(String value) {
    STUDENT_SURNAAME = value;
  }

  String getSTUDENT_NAME () {
    return STUDENT_NAME;
  }

  setSTUDENT_NAME(String value) {
    STUDENT_NAME = value;
  }

  String getSTUDENT_NUMBER() {
    return STUDENT_NUMBER;
  }

  setSTUDENT_NUMBER(String value) {
    STUDENT_NUMBER = value;
  }

  int getid() {
    return id;
  }

  setid(int value) {
    id = value;
  }


}