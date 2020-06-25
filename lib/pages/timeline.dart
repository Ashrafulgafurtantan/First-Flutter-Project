import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:useallfeatures/header.dart';
import 'package:useallfeatures/home.dart';
import 'package:useallfeatures/models/user.dart';
import 'package:useallfeatures/progress.dart';
import 'package:useallfeatures/widgets/createQuestion.dart';
import 'package:useallfeatures/widgets/post.dart';
import 'package:useallfeatures/pages/search.dart';

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  List<Post>postList = [];
  List<String>followingList= [];

  @override
  void initState() {
    super.initState();
    getFollowerList();
    getTimelinePost();

  }
  getFollowerList()async{

    QuerySnapshot snapshot =await followingRef.document(currentUser.id).collection('userFollowing').getDocuments();
    setState(() {
      followingList = snapshot.documents.map((doc) => doc.documentID).toList();

    });


  }
  buildTimeline(){
    if(postList ==null){
      return circularProgress();

    }
    else if(postList.isEmpty)
      return buildUserToFollow();
    else{
      return  ListView(
        children: postList,
      );

    }


  }
  buildUserToFollow(){
    return StreamBuilder(
      stream: userRef.orderBy('timestamp',descending: true).limit(30)
          .snapshots(),
      builder: (context,snapshot){

        if(!snapshot.hasData)
          return circularProgress();

        List<SearchResult>searchResult=[];
        snapshot.data.documents.forEach((doc){
          User user=User.fromDocument(doc);

          final bool isAuth=currentUser.id==user.id;
          final bool isFollowing=followingList.contains(user.id);
          if(isAuth){return;}
          else if(isFollowing){return;}
          else{
            SearchResult userResult=SearchResult(user: user,);
            searchResult.add(userResult);
          }
        });

        return Container(
          color: Theme.of(context).accentColor.withOpacity(.2),
          child: Column(
            children: <Widget>[
              Container(
                padding:EdgeInsets.all(12),
                child:  Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.person_add,
                      color: Theme.of(context).primaryColor,
                      size: 30,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text('user to follow',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 30,
                      ),
                    )
                  ],),
              ),
              Column(children: searchResult,)
            ],

          ),

        );

      },
    );


  }

  getTimelinePost()async{


    QuerySnapshot snapshot = await timelineRef.document(currentUser.id)
        .collection('timelinePosts').orderBy('timestamp',descending: true)
        .getDocuments();
    List<Post> p =snapshot.documents.map((doc)=>Post.fromDocument(doc)).toList();

    setState(() {
      postList=p;
    });


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context,isTimeline: true,title: 'Timeline'),
     // body: RefreshIndicator(child: buildTimeline(), onRefresh: ()=>getTimelinePost(),)
      body:  new Stack(
        children: <Widget>[
          RefreshIndicator(child: buildTimeline(), onRefresh: ()=>getTimelinePost(),),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(

              alignment: Alignment.bottomRight,
              child: RaisedButton.icon(
                elevation: 10,

                splashColor: Colors.white,
                color: Colors.teal[700],
                icon: Icon(Icons.edit,size: 25,
                  color: Colors.white,
                ),
                label: Padding(
                  padding: const EdgeInsets.only(top:15,bottom: 15),
                  child: Text('Ask Community',
                    style: TextStyle(
                      color: Colors.white,
                    fontFamily: 'Signatra',
                    letterSpacing: 2,
                    //  fontWeight: FontWeight.bold,
                      fontSize: 20
                    ),
                  ),
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)
                ),
                onPressed:(){

                  Navigator.push(context, MaterialPageRoute(builder: (context){
                    return CreateQuestion();
                  }));
                },
              ),
            ),
          )
        ],
      ),

    );
  }
}
