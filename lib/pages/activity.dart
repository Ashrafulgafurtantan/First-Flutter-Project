import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:useallfeatures/header.dart';
import 'package:useallfeatures/home.dart';
import 'package:useallfeatures/pages/profile.dart';
import 'package:useallfeatures/progress.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:useallfeatures/widgets/post_screen.dart';

class ActivityFeed extends StatefulWidget {

  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {

  showPost(BuildContext context,DocumentSnapshot doc){
    Navigator.push(context, MaterialPageRoute(builder: (context){

      return PostScreen(postId: doc.data['postId'],ownerId: doc.data['postOwnerId'],);
    }));

  }


  showProfile(BuildContext context,DocumentSnapshot doc){
    Navigator.push(context, MaterialPageRoute(builder: (context){

      return Profile(profileId: doc.data['postOwnerId'],);
    }));

  }

 String configureTextPreview(DocumentSnapshot doc){
   String activityItemText;

   if(doc.data['type']=='like'){
      activityItemText = 'Liked your post';
    }
    else if(doc.data['type']=='comment'){
      activityItemText = 'replied: ${doc.data['commentData']}';
    }
    else if(doc.data['type']=='follow'){
      activityItemText = 'is following you';
    }
    return activityItemText;
  }
  Widget configureMediaPreview(DocumentSnapshot doc){
    if(doc.data['type']=='like'|| doc.data['type']=='comment'){
     Widget mediaPreview= GestureDetector(
        onTap: ()=>showPost(context,doc),
        child: Container(
          height: 50,
          width: 50,
          child: AspectRatio(aspectRatio: 16/9,
            child: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: CachedNetworkImageProvider(doc.data['mediaUrl'])
                  )
              ),
            ),
          ),
        ),
      );
      return mediaPreview;

    }
    else{
     return  Text('');
    }
  }

  changeSeenValue(DocumentSnapshot doc,String docId)async{
    await feedRef.document(currentUser.id).collection('feedItems').document(docId).updateData({
      'seen':true,
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepOrange.withOpacity(0.8),
      appBar: header(context,title: 'Activity'),
      body:StreamBuilder<QuerySnapshot>(
        stream:feedRef.document(currentUser.id).collection('feedItems').orderBy('timestamp',descending: true).limit(20).snapshots() ,
        builder: (context,snapshot){
          if(!snapshot.hasData)
            return circularProgress();
          List<Container> searchResults=[];
          snapshot.data.documents.forEach((doc) {
            changeSeenValue(doc,doc.documentID);
            searchResults.add(Container(
              color: Colors.deepOrange.withOpacity(0.5),
              child: Column(
                children: <Widget>[
                  GestureDetector(
                    onTap: ()=>showProfile(context, doc),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey,
                        backgroundImage: CachedNetworkImageProvider(doc.data['userProfileImg']),
                      ),
                      title: GestureDetector(
                        onTap: ()=>showProfile(context, doc),
                        child: RichText(
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white
                            ),
                            children: [
                                TextSpan(text: '${doc.data['username']} ',
                                  style:   TextStyle(
                                    fontWeight: FontWeight.bold
                                  )
                                ),
                              TextSpan(text:configureTextPreview(doc))
                            ],
                          ),
                        ),
                      ),
                      subtitle: Text(DateFormat.jm().format(doc.data['timestamp'].toDate()),
                        style: TextStyle(
                          color: Colors.white
                        ),
                      ),
                      trailing: configureMediaPreview(doc),
                     
                    ),
                  ),
                  Divider(
                    height: 2,
                    color: Colors.white54,
                  ),
                ],
              ),
            ));
          });

          return ListView(
            children: searchResults,
          );
          },
      )
    );
  }
}
/*
List<SearchResult>searchResults=[];
snapshot.data.documents.forEach((doc) {
User user=User.fromDocument(doc);
SearchResult searchResult=SearchResult(user: user);
searchResults.add(searchResult);
});*/
/*

class ActivityResult extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.8),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: (){
              //showProfile(context,profile:user.id);
              print('tap....');
            },
            child: ListTile(
              leading: CircleAvatar(

                backgroundColor: Colors.grey,
                backgroundImage: CachedNetworkImageProvider(doc.data['userProfileImg']),
              ),
              title: Text(doc.data['username'],
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,

                ),),
              subtitle: Text(doc.data['type'],
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Divider(
            height: 2,
            color: Colors.white54,
          ),

        ],
      ),


    );
  }
}
*/
