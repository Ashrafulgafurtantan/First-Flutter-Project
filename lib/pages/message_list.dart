import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:useallfeatures/home.dart';
import 'package:useallfeatures/models/user.dart';
import 'package:useallfeatures/pages/search.dart';
import 'package:useallfeatures/progress.dart';
import 'package:useallfeatures/widgets/chat_list_view_item.dart';

import '../header.dart';

class MessageList extends StatefulWidget {
  @override
  _MessageListState createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  bool isLoading = true;
  Map likes;

  List<ChatListViewItem>searchResults=[];


  @override
  void initState() {
    super.initState();
    testFunction();
  }


  testFunction()async{
    Stream<DocumentSnapshot>     userSnapshot;
    QuerySnapshot documentSnapshot;
    List<ChatListViewItem>sr=[];

    DocumentSnapshot  snapshot =await  friendRef.document (currentUser.id).get();
    likes = snapshot.data['friends'];
   // print(likes.length);
    likes.forEach((key, value) async{

     // print(currentUser.id);
      //print(key);
   //   if(value==true){
        Test test;
    //    print('hell');

        userSnapshot =await userRef.document(key).snapshots();

       userSnapshot.forEach((doc) async{
      //   print('hell 2');
          test = Test.fromDocument(doc);
        // print(test.name);

       });

        documentSnapshot =await messageRef.document(currentUser.id).collection(key).orderBy('timestamp', descending: false).getDocuments();

        Best best = Best(
            timestamp: documentSnapshot.documents.last.data['timestamp'],
            lastMessage:documentSnapshot.documents.last.data['message'],
            isOwner: ( currentUser.id== documentSnapshot.documents.last.data['senderId']) ? true:false,
        );

    //    print(best.lastMessage);
      //  documentSnapshot.documents.forEach((doc)async {
          ChatListViewItem chatListViewItem = ChatListViewItem(
            name:test.name,
            userId:key  ,
            image: test.image,
            lastMessage: best.lastMessage,

            time: best.timestamp,
            isOwner: best.isOwner,
            hasUnreadMessage: messageList.containsKey(test.name) ,
            newMesssageCount: messageList.containsKey(test.name) ? messageList[test.name] : 0,

          );

          sr.add(chatListViewItem);
          setState(() {
            searchResults=sr;
          });
      // });

    //  }
    });
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      child: Scaffold(
        appBar:  AppBar(
          elevation: 0,
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
          centerTitle: true,
          title: Text(
            'Chats',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
        body: Container(
          child: Container(
            decoration: BoxDecoration(
                color:Color(0xFFFbFbFb),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  topRight: Radius.circular(15.0),
                ),
            ),
            child: ListView(
              children: searchResults
            ),

          ),
        ),
      ),
    );
  }
}


/* if (isLoading == true) {
      return shimmer();
    } else {
      return Container(
        child: Scaffold(
          backgroundColor: Color(0xFF54C5E6),
          appBar: AppBar(
            elevation: 0,
            iconTheme: IconThemeData(
              color: Colors.white,
            ),
            centerTitle: true,
            title: Text(
              'Chats',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
          body: Container(
            child: Container(
              decoration: BoxDecoration(
                  color:Color(0xFFFbFbFb),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15.0),
                    topRight: Radius.circular(15.0),
                  )),
              child: ListView(
                children: <Widget>[
                  ChatListViewItem(
                    hasUnreadMessage: true,
                    lastMessage:
                    "Lorem ipsum dolor sit amet. Sed pharetra ante a blandit ultrices.",
                    name: "Bree Jarvis",
                    newMesssageCount: 8,
                    time: "19:27 PM",
                  ),

                  ChatListViewItem(
                    hasUnreadMessage: false,
                    lastMessage:
                    "Lorem ipsum dolor sit amet. Sed pharetra ante a blandit ultrices.",
                    name: "Carson Sinclair",
                    newMesssageCount: 0,
                    time: "19:27 PM",
                  ),

                ],
              ),
            ),
          ),
        ),
      );
    }*/


class Test{
  // Timestamp timestamp;
  String name;
  String image;
  // String lastMessage;
  Test({this.name,this.image});

  factory Test.fromDocument(DocumentSnapshot doc){
    return Test(
      name:doc['displayname'],
      image: doc['photoUrl'],
    );
  }

}


class Best{
   Timestamp timestamp;

   bool isOwner;
   String lastMessage;
  Best({this.timestamp,this.lastMessage,this.isOwner});

  factory Best.fromDocument(DocumentSnapshot doc){
    return Best(
      timestamp:doc['displayname'],
      lastMessage: doc['photoUrl'],
    );
  }


}