import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:useallfeatures/header.dart';
import 'package:useallfeatures/home.dart';
import 'package:useallfeatures/models/user.dart';
import 'package:useallfeatures/pages/search.dart';
import 'package:useallfeatures/progress.dart';

class Following extends StatefulWidget {
  final String profileId;
  Following(this.profileId);

  @override
  _FollowingState createState() => _FollowingState();
}

class _FollowingState extends State<Following> {
  List<SearchResult>searchResults=[];


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    testFunction();
    print('following');
    print(widget.profileId);
  }

  testFunction()async{
    Stream<DocumentSnapshot>     documentSnapshot;
    List<SearchResult>sr=[];

    QuerySnapshot snapshot =await  followingRef.document (widget.profileId).collection ('userFollowing').getDocuments();
    snapshot.documents.forEach((doc) async{
      print(doc.documentID);
         documentSnapshot=  userRef.document(doc.documentID).snapshots();
         documentSnapshot.forEach((doc) {
           User user =User.fromDocument(doc);
           SearchResult searchResult=SearchResult(user: user);
           sr.add(searchResult);
           print(user.username);
           setState(() {
             searchResults=sr;
           });

     });

    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: header(context,title: 'Following List',),
        body:searchResults==null? circularProgress():ListView(
          children: searchResults,
        )
    );
  }
}
/*FutureBuilder<QuerySnapshot>(
          future: followingResult,
          builder: (context,snapshot){
            if(!snapshot.hasData)
              return circularProgress();

            List<SearchResult>searchResults=[];
            followingList.forEach((doc) {

            });
            snapshot.data.documents.forEach((doc) {
              print('${doc.documentID} 777');
              User user=User.fromDocument(doc);
              SearchResult searchResult=SearchResult(user: user);
              searchResults.add(searchResult);
            });
            return ListView(
              children:searchResults ,
            );
          },
        )*/