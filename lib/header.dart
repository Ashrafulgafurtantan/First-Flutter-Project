import 'package:flutter/material.dart';

AppBar header(BuildContext context,{bool isTimeline=false, String title, bool removeBackButton=false}){
  return AppBar(
    automaticallyImplyLeading:removeBackButton? false : true,
    backgroundColor: Theme.of(context).accentColor,
    title: Center(
      child: Text(title,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.white,
         fontWeight: isTimeline? FontWeight.bold: FontWeight.normal,
            fontSize:isTimeline ? 45: 22,
          fontFamily: isTimeline? 'Signatra' : '',

        ),
      ),
    ),
  );
}