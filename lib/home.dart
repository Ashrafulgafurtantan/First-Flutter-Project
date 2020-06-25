import 'dart:developer';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:useallfeatures/pages/message_list.dart';
import 'package:useallfeatures/pages/timeline.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:useallfeatures/pages/activity.dart';
import 'package:useallfeatures/pages/profile.dart';
import 'package:useallfeatures/pages/search.dart';
import 'package:useallfeatures/pages/upload.dart';
import 'package:useallfeatures/widgets/create_account.dart';

import 'models/user.dart';
GoogleSignIn googleSignIn=GoogleSignIn();
User currentUser;

final userRef=Firestore.instance.collection('users');
final firestorePost=Firestore.instance.collection('posts');
final commentRef=Firestore.instance.collection('comments');
final feedRef=Firestore.instance.collection('feeds');
final followersRef=Firestore.instance.collection('followers');
final followingRef=Firestore.instance.collection('following');
final timelineRef=Firestore.instance.collection('timeline');
final messageRef=Firestore.instance.collection('messages');
final friendRef=Firestore.instance.collection('friends');

final DateTime timestamp=DateTime.now();
Map <String ,int> messageList;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}
class _HomeState extends State<Home> {
  final _scaffoldKey=GlobalKey<ScaffoldState>();
  FirebaseMessaging firebaseMessaging=FirebaseMessaging();
  FirebaseMessaging fc=FirebaseMessaging();

  bool isAuth=false;
  PageController  pageController;
  int pageIndex=0;
  int notificationCount = 0;
  int messageCount=0;
  Map likes;
  @override
  void initState() {
    super.initState();
    pageController=PageController();
    googleSignIn.onCurrentUserChanged.listen((data){
      handleSignIn(data);
    }, onError: (e){
    });

    googleSignIn.signInSilently(suppressErrors: false).then((data){
      handleSignIn(data);
    },onError: (e){
      // print(e.toString());
    });

  }
  getNotifications()async{
    QuerySnapshot snapshot =await  feedRef.document(currentUser.id).collection('feedItems').where('seen',isEqualTo: false).getDocuments() ;
    setState(() {
      notificationCount = snapshot.documents.length;
    });
    print('notification count =$notificationCount');

  }
  unreadMessageCount()async{
    Stream<DocumentSnapshot>     userSnapshot;
    QuerySnapshot documentSnapshot;
    DocumentSnapshot  snapshot =await  friendRef.document (currentUser.id).get();
    likes = snapshot.data['friends'];
    print(likes.length);
    likes.forEach((key, value) async {
      String displayname;
   //   print ( currentUser.id );
      print ( key );
      if (value == true) {
        //   Test test;
        print ( 'hell' );

        userSnapshot = await userRef.document ( key ).snapshots ( );
        userSnapshot.forEach ( (doc) async {
          print ( 'hell 2' );
          displayname = doc['displayname'];
          print ( doc['displayname'] );
        } );

        documentSnapshot = await messageRef.document ( currentUser.id ).collection ( key ).where ('seen', isEqualTo: false ).getDocuments ( );

        messageList.putIfAbsent ( displayname, () => documentSnapshot.documents.length );
      }
      print('new mal');
      print(messageList);
    });

  }


  @override
  void dispose() {
    // TODO: implement initState
    pageController.dispose();
    super.initState ( );
  }

  handleSignIn(GoogleSignInAccount data)async{

    if(data !=null){
      await createUserInFirestore();

      setState(() {
        isAuth=true;
      });
      messageList = Map<String,int>();
  //    await unreadMessageCount();

      await  getNotifications();

      configurePushNotifications();

    }else{
      setState((){
        isAuth=false;
        // print('user is not aunthenticate');
      });
    }
  }

  configurePushNotifications(){
    final GoogleSignInAccount user=googleSignIn.currentUser;
    print('configurePush');
    if(Platform.isIOS)
      getIOsPermission();

    firebaseMessaging.getToken().then((token){
      print('Firebase messaging token :$token\n');
      userRef.document(user.id)
          .updateData({'androidNotificationToken':token});
    });


    firebaseMessaging.configure(
      onResume: (Map<String , dynamic>message)async{
        print('on Message :$message');
      },

      onLaunch: (Map<String , dynamic>message)async{
        print('on Message :$message');
       var notificationData =  message['data'];
        var view = notificationData['view'];
        if(view == 'Profile'){
          Navigator.push(context,MaterialPageRoute(builder: (context){
            return MessageList();
          }));
        }
      },


      onMessage: (Map<String , dynamic>message)async{


        print('on Message :$message');
        final String recipientId=message['data']['recipient'];
        final String body=message['notification']['body'];
        print('recipient id :$recipientId');
       // print('message id :$message');


        if(recipientId==user.id){
          print('recipient id :$recipientId');

          if((body.contains('replied :')) && (body.contains('messaged :'))){

            int repPos = body.indexOf('replied :') ;
            int mesPos = body.indexOf('messaged :') ;

            //  print(repPos);
            //   print(mesPos);
            if(repPos<mesPos){
              setState(() {
                notificationCount++;
              });
            }
            else{
              String   displayname = body.substring(0,mesPos-1);
              print(displayname);
              setState(() {
                if(messageList.containsKey(displayname)){
                  messageList.update(displayname, (value) => value+1);

                }else{
                  messageList.putIfAbsent(displayname, () => 1);

                }
              });
            }

          }else if( body.contains('messaged :')){
            int mesPos = body.indexOf('messaged :') ;
            String   displayname = body.substring(0,mesPos-1);
            print(displayname);
            setState(() {
              if(messageList.containsKey(displayname)){
                messageList.update(displayname, (value) => value+1);

              }else{
                messageList.putIfAbsent(displayname, () => 1);

              }
            });
          }else{
            setState(() {
              notificationCount++;
            });

          }

          print('Notification Shown');

          print('message count ${messageList.length}');
          /*      setState(() {
            notificationCount++;
          });*/
          SnackBar snackBar=SnackBar(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(13.0)),
            ),
            backgroundColor: Colors.deepOrange,
            content: Text(
              body,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Signatra',
                letterSpacing: 2,
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
          _scaffoldKey.currentState.showSnackBar(snackBar);


        }
      },);
  }
  getIOsPermission(){
    firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(alert: true,badge: true,sound: true)
    );
    firebaseMessaging.onIosSettingsRegistered.listen((settings){
      print(('Settings registered: $settings'));
    });

  }


  createUserInFirestore()async{
    final GoogleSignInAccount user=googleSignIn.currentUser;

    DocumentSnapshot doc=await userRef.document(user.id).get();

    if(!doc.exists){
      final userName= await Navigator.push(context,MaterialPageRoute(builder: (context){

        return CreateAccount();

      }));

      userRef.document(user.id).setData({
        'id': user.id,
        'name':userName,
        'photo': user.photoUrl,
        'displayName':user.displayName,
        'email':user.email,
        'bio':'',
        'timestamp':DateTime.now(),

      });

      await followersRef.document(user.id)
          .collection('userFollowers').document(user.id).setData({});
      doc=await userRef.document(user.id).get();
    }
    currentUser=User.fromDocument(doc);
    currentUser.toString();

    DocumentSnapshot friendList=await friendRef.document(currentUser.id).get();
    if(!friendList.exists){
      friendRef.document ( currentUser.id ).setData ( {
        'friends':{},
      });
    }
  }
  SignIn(){
    googleSignIn.signIn();
  }
  SignOut(){
    googleSignIn.signOut();
  }

  onPageChange(int pageIndex){
    setState(() {
      this.pageIndex=pageIndex;

    });
  }
  onTap(int pageIndex){

    pageController.animateToPage(pageIndex,
      duration: Duration(microseconds: 300),
      curve: Curves.easeInOut,

    );
    if(pageIndex==1)
    {
      setState(() {
        notificationCount=0;
      });
    }
  }
  Scaffold onAuthScreen(){
    return Scaffold(
        key: _scaffoldKey,
        body: PageView(
          children: <Widget>[

            Timeline(),
            /*    RaisedButton(onPressed: SignOut,
            child: Text('Logout'),
          ),*/
            ActivityFeed(),
            Upload(currentUser),
            Search(),
            Profile(profileId: currentUser?.id,),
          ],
          controller: pageController,
          onPageChanged: onPageChange,
          physics: NeverScrollableScrollPhysics(),

        ),
        bottomNavigationBar: CupertinoTabBar(
          // backgroundColor: Theme.of(context).accentColor,
          currentIndex: pageIndex,
          onTap: onTap,
          activeColor: Theme.of(context).primaryColor,
          items: [
            BottomNavigationBarItem( icon:Icon(Icons.whatshot), ),
            // BottomNavigationBarItem( icon:Icon(Icons.notifications_active), ),

            BottomNavigationBarItem(
              icon: new Stack(
                children: <Widget>[
                  new Icon(Icons.notifications),
                  notificationCount<1? Container(child: Text(''),):new Positioned(
                    right: 0,
                    child: new Container(
                      padding: EdgeInsets.all(1),
                      decoration: new BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: new Text( notificationCount.toString(),
                        style: new TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                ],
              ),
            ),
            BottomNavigationBarItem( icon:Icon(Icons.camera_alt,size: 35,), ),
            BottomNavigationBarItem( icon:Icon(Icons.search), ),
            BottomNavigationBarItem( icon:Icon(Icons.account_circle), ),



          ],

        )
    );
  }

  onUnAuthScreen(){
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              //   Colors.teal,
              // Colors.purple,
              Theme.of(context).primaryColor,
              Theme.of(context).accentColor,
            ],
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text('Flutter Share',
              style: TextStyle(
                fontSize: 27,
                fontFamily: 'Signatra',
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: (){
                SignIn();

              },
              child: Container(
                height: 60,
                width:260 ,
                decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/google_signin_button.png'),
                      fit: BoxFit.cover,
                    )
                ),
              ),
            )
          ],

        ),
      ),

    );

  }



  @override
  Widget build(BuildContext context) {
    return isAuth ? onAuthScreen() : onUnAuthScreen() ;
    //   return SharedContent().isAuth ? AuthScreen() : onUnAuthScreen() ;
  }
}
