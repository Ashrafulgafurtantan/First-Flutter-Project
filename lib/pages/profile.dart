import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:useallfeatures/home.dart';
import 'package:useallfeatures/models/user.dart';
import 'package:useallfeatures/pages/follower.dart';
import 'package:useallfeatures/pages/following.dart';
import 'package:useallfeatures/pages/message_list.dart';
import 'package:useallfeatures/progress.dart';
import 'package:useallfeatures/widgets/edit_pofile.dart';
import 'package:useallfeatures/widgets/message.dart';
import 'package:useallfeatures/widgets/post.dart';
import 'package:useallfeatures/widgets/post_tile.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../header.dart';

class Profile extends StatefulWidget {

  final String profileId;
  Profile({this.profileId});
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  String currentUserId=currentUser?.id;
  bool isLoading = false;
  List<Post>posts=[];
  int postCount = 0;
  String options='grid';
  bool isFollowing = false;
  int followerCount=0;
  int followingCount = 0;
  bool isOwner =false;



  buildCountColumn(String label,int count,BuildContext context){
    return GestureDetector(
      onTap: (){

       if(label!='Posts'){
         Navigator.push(context, MaterialPageRoute(builder: (context){
           if(label =='Follower')
             return Follower(widget.profileId);
           else
             return Following(widget.profileId);
         }));
       }
       else{
         setState(() {
           options='list';
         });
       }


      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(count.toString(),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 4),
            child: Text(label,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          )
        ],
      ),
    );
  }
  Container buildButton(String title,Function fun){

        return Container(
      padding: EdgeInsets.only(top: 2),
      child: FlatButton(
        onPressed: fun,
        child: Container(
          width: isOwner?235:102,
          height: 27,
          alignment: Alignment.center,
          child: Text(title,
            style: TextStyle(
              color: isFollowing ? Colors.black: Colors.white,
             // color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          decoration: BoxDecoration(
            color:isFollowing ? Colors.white:  Colors.teal,
           // color:Colors.blue,
            border: Border.all(color: isFollowing ? Colors.grey: Colors.teal),
           // border: Border.all(color: Colors.blue),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );


  }

  showProfile(BuildContext context){
    Navigator.push(context, MaterialPageRoute(builder: (context){

      return Profile(profileId:widget.profileId);
    }));

  }
  buildProfileButton(){
    if(isOwner)
      return  buildButton('Edit',editProfile);
    else if(!isFollowing)
      return buildButton('Follow',followButton);
    else if(isFollowing)
      return buildButton('UnFollow',unFollowButton);

  }

  followButton()async{
   // print('in follow');
    setState(() {
      isFollowing = true;
    });
    followersRef.document(widget.profileId).collection('userFollowers').document(currentUserId).setData({});
    followingRef.document(currentUserId).collection('userFollowing').document(widget.profileId).setData({});

      feedRef.document(widget.profileId).collection('feedItems').document(currentUserId).setData({
        'type':'follow',
        'username':currentUser.username,
        'userId':currentUserId,
        'userProfileImg':currentUser.photoUrl,
        'timestamp':DateTime.now(),
        'ownerId':widget.profileId,
        'seen' :false,
      });
  }
  unFollowButton(){
   // print('in unfollow');

    setState(() {
      isFollowing = false;
    });
    followersRef.document(widget.profileId).collection('userFollowers').document(currentUserId).get().then((value){
      if(value.exists)
        value.reference.delete();

    });
    followingRef.document(currentUserId).collection('userFollowing').document(widget.profileId).get().then((value){
      if(value.exists)
        value.reference.delete();

    });

    feedRef.document(widget.profileId).collection('feedItems').document(currentUserId).get().then((value){
      if(value.exists)
        value.reference.delete();

    });

  }

  editProfile(){
    Navigator.push(context,MaterialPageRoute(builder: (context){
      return EditProfile();
    }));
  }


  buildProfileHeader(BuildContext context){
    print('profileHeader');
     print(userRef.document(widget.profileId).documentID);
     //final DocumentSnapshot dc = await userRef.document(widget.profileId).get();

     //print(dc.data);

    return FutureBuilder<DocumentSnapshot>(
      future:userRef.document(widget.profileId).get() ,
      builder: (context,snapshot){
        if(!snapshot.hasData)
          return circularProgress();
        User user=User.fromDocument(snapshot.data);
        print('Photo :${user.toString()}');
        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                    backgroundColor: Colors.grey,
                    radius: 30,
                  ),
                  //cachedNetworkImage(user.photoUrl),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            buildCountColumn('Posts',postCount,context),
                            buildCountColumn('Follower',followerCount,context),
                            buildCountColumn('Following',followingCount,context),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildProfileButton(),
                         /*  if(!isOwner)
                             buildMessageButton(),*/

                           isOwner? Text(''):Container(
                             padding: EdgeInsets.only(top: 2),
                             child: FlatButton(
                               onPressed: (){
                             //    print('message button');
                                 Navigator.push(context, MaterialPageRoute(builder: (context)=>Message(profileId: widget.profileId,username:user.displayname)));
                               },
                               child: Container(
                                 width: 102,
                                 height: 27,
                                 alignment: Alignment.center,
                                 child: Text('Message',
                                   style: TextStyle(
                                     color: Colors.white,
                                     // color: Colors.white,
                                     fontWeight: FontWeight.bold,
                                   ),
                                 ),
                                 decoration: BoxDecoration(
                                   color:  Colors.blue,
                                   // color:Colors.blue,
                                   border: Border.all(color: Colors.blue),
                                   // border: Border.all(color: Colors.blue),
                                   borderRadius: BorderRadius.circular(5),
                                 ),
                               ),
                             ),
                           ),
                          ],
                        ),

                      ],
                    ),
                  )
                ],
              ),
              // AboutWidget( user.name,12,true),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top:12),
                child: GestureDetector(

                  onTap: ()=>showProfile(context),
                  child: Text(user.username,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top:4),
                child: GestureDetector(

                  onTap: ()=>showProfile(context),
                  child: Text(user.displayname,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top:2),
                child: GestureDetector(

                  onTap: (){

                    // showProfile(context,profile:user.id);

                  },
                  child: Text(user.bio,
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );

      },
    );

  }
  buildProfilePost(){
    if(isLoading)
      return circularProgress();
    else if(posts.isEmpty){
      Orientation orientation = MediaQuery.of(context).orientation;
      return Container(
        color: Colors.teal.withOpacity(0.6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            SvgPicture.asset('assets/images/no_content.svg',
                height: orientation==Orientation.portrait? 270:100),
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text('No Post',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 40,
                  fontWeight: FontWeight.bold
                ),
              ),
            )
          ],
        ),

      );
    }
    else if(options =='grid'){
      List<GridTile>gridTiles=[];

      for(var post in posts){
        gridTiles.add(GridTile(child:PostTile(post:post )));

      }
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1,
        crossAxisSpacing: 1.5,
        mainAxisSpacing: 1.5,
        physics: NeverScrollableScrollPhysics(),
        children: gridTiles,
        shrinkWrap: true,
      );
    }
    else if(options == 'list'){
      return Column(
        children: posts,
      );

    }


  }
  toggleOptions(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(icon: Icon(Icons.grid_on,color: options=='grid'? Colors.purple:Colors.grey,),

            onPressed: (){

              setState(() {
                options='grid';
              });
            },

        ),

        IconButton(icon: Icon(Icons.format_list_bulleted,color: options=='list'? Colors.purple:Colors.grey,),
            onPressed: (){
              setState(() {
                options='list';
              });
            },

        ),

      ],
    );

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPosts();
    checkIfFollowing();
    getFollower();
    getFollowing();

    isOwner = currentUserId==widget.profileId;

  }
  getFollower()async{
   QuerySnapshot snapshot = await followersRef.document(widget.profileId).collection('userFollowers').getDocuments();
   setState(() {
     followerCount = snapshot.documents.length;

   });

  }
  getFollowing()async{
    QuerySnapshot snapshot = await followingRef.document(widget.profileId).collection('userFollowing').getDocuments();

    setState(() {
      followingCount = snapshot.documents.length;

    });
  }
  checkIfFollowing()async{
   await followingRef.document(currentUserId).collection('userFollowing').document(widget.profileId).get().then((value) {
      if(value.exists)
        {
          setState(() {
            isFollowing=true;
          });
        }
      else{
        setState(() {
          isFollowing=false;
        });

      }

    });    
  }

  getPosts()async{
    setState(() {
      isLoading = true;
    });
    QuerySnapshot doc=await firestorePost.document(widget.profileId).collection('userPosts').orderBy('timestamp',descending: true).getDocuments();

    doc.documents.forEach((doc) {
      Post post = Post.fromDocument(doc);
      posts.add(post);

    });

    setState(() {
      isLoading = false;
      postCount=posts.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

//    appBar: header(context,isTimeline: true,title: 'Profile'),
        appBar: AppBar(
          backgroundColor: Colors.teal,

          title: Center(child: Text('Profile',
          style: TextStyle(
            letterSpacing: 2,
            fontSize: 40,
            fontFamily: 'Signatra',

          ),
          ), ),

          actions: <Widget>[

            currentUserId==widget.profileId ? Padding(
              padding: const EdgeInsets.only(top:12.0),
              child: GestureDetector(
                onTap: (){
                  Navigator.push(context,MaterialPageRoute(builder: (context){
                    return MessageList();

                  }));
                },
                child: new Stack(
                  children: <Widget>[
                    new Icon(FontAwesomeIcons.facebookMessenger,color: Colors.white, size: 27,),
                     messageList.isEmpty ? Container(child: Text(''),):new Positioned(


             //   messageCount<1? Container(child: Text(''),):new Positioned(
                      right: 0,
                      child: new Container(
                        padding: EdgeInsets.all(1),
                        decoration: new BoxDecoration(
                          color: Colors.cyan,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                     //   child: new Text( messageCount.toString(),
                        child: new Text( messageList.isEmpty ? '' :(messageList.length).toString(),

                          style: new TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ) : Container(child: Text(''),),

            SizedBox(
              width: 8,
            )

          ],

        ),

        body: Container(
          child: ListView(
      children: <Widget>[
          buildProfileHeader(context),
          Divider(height: 0,),
          toggleOptions(),
          buildProfilePost(),
      ],
    ),
        )
    );
  }
}
