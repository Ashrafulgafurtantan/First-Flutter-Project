import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:useallfeatures/header.dart';
import 'package:useallfeatures/home.dart';
import 'package:useallfeatures/models/user.dart';
import 'package:useallfeatures/pages/search.dart';
import 'package:useallfeatures/progress.dart';
class Follower extends StatefulWidget {

  final String profileId;
  Follower(this.profileId);
  @override
  _FollowerState createState() => _FollowerState();
}

class _FollowerState extends State<Follower> {
  List<SearchResult>searchResults=[];


  @override
  void initState() {
    super.initState();
    testFunction();
    print('Follower');
    print(widget.profileId);
  }

  testFunction()async{
    Stream<DocumentSnapshot>     documentSnapshot;
    List<SearchResult>sr=[];

    QuerySnapshot snapshot =await  followersRef.document (widget.profileId).collection ('userFollowers').getDocuments();
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
        appBar: header(context,title: 'Follower List',),
        body:searchResults==null? circularProgress():ListView(
          children: searchResults,
        )
    );
  }
}
