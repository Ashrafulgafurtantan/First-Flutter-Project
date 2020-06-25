import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shimmer/shimmer.dart';

Container circularProgress() {
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.only(top: 10),
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.purple),

    ),
  );
}


Container squareCircleSpinKit() {

    return Container(
      color: Colors.deepOrange,
      alignment: Alignment.center,
      padding: EdgeInsets.only(top: 10),
      child: SpinKitSquareCircle(
        color: Colors.yellowAccent,
        size: 50.0,
      ),
    );
}


Container linearProgress() {
  return Container(
    alignment: Alignment.topCenter,
    padding: EdgeInsets.only(bottom: 10),
    child: LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.purple),

    ),
  );
}

Container shimmer(){
  return Container(
    child: Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Shimmer.fromColors(
            baseColor: Color(0xFF54C5E6),
            highlightColor: const Color(0xFFFF8C00),
            child: Text(
              'Welcome',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 40.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text("Please wait...")
        ],
      ),
    ),
  );

}