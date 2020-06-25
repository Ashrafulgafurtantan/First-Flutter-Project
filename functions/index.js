const functions = require('firebase-functions');
const admin=require('firebase-admin');
admin.initializeApp();

exports.onCreateFollower=functions.firestore
    .document('/followers/{userId}/userFollowers/{followerId}')
    .onCreate(async(snapshot,context)=>{
    console.log('Follower Created',snapshot.id);
        const userId=context.params.userId;
        const followerId=context.params.followerId;

        const followedUserPostsRef= admin.firestore().collection('posts')
        .doc(userId).collection('userPosts');
        const timelinePostsRef=admin.firestore().collection('timeline')
        .doc(followerId).collection('timelinePosts');
        const querySnapshot=await followedUserPostsRef.get();
        querySnapshot.forEach(doc =>{
            if(doc.exists){
                const postId=doc.id;
                const postData=doc.data();
                timelinePostsRef.doc(postId).set(postData);
            }
        });
      });


exports.onDeleteFollower=functions.firestore
    .document('/followers/{userId}/userFollowers/{followerId}')
    .onDelete(async(snapshot,context)=>{
    console.log('Follower Created',snapshot.id);
        const userId=context.params.userId;
        const followerId=context.params.followerId;


        const timelinePostsRef=admin.firestore().collection('timeline')
        .doc(followerId).collection('timelinePosts')
        .where('ownerId','==',userId);
        const querySnapshot=await timelinePostsRef.get();
        querySnapshot.forEach(doc =>{
            if(doc.exists){
                doc.ref.delete();
            }
        });
      });
      
exports.onCreatePost = functions.firestore.document('/posts/{userId}/userPosts/{postId}')
  .onCreate(async(snapshot,context)=>{
      console.log('Post Created',snapshot.id);
       const postCreated=snapshot.data();
       const userId=context.params.userId;
       const postId=context.params.postId;


        const followersRef=admin.firestore().collection('followers')
               .doc(userId).collection('userFollowers');
        const querySnapshot=await followersRef.get();


       querySnapshot.forEach((value)=>{
       const followerId = value.id;

      admin.firestore().collection('timeline')
          .doc(followerId).collection('timelinePosts').doc(postId).set(postCreated);
       });
  });


 exports.onUpdatePost = functions.firestore.document('/posts/{userId}/userPosts/{postId}')
 .onUpdate(async(change,context)=>{
     console.log('Post Created',change.after.id);
      const postUpdated=change.after.data();
      const userId=context.params.userId;
      const postId=context.params.postId;


       const followersRef=admin.firestore().collection('followers')
              .doc(userId).collection('userFollowers');
       const querySnapshot=await followersRef.get();

      querySnapshot.forEach((value)=>{
      const followerId = value.id;

     admin.firestore().collection('timeline')
         .doc(followerId).collection('timelinePosts').doc(postId).get().then((doc)=>{
            if(doc.exists)
                doc.ref.update(postUpdated);
         });
      });
 });


exports.onDeletePost = functions.firestore.document('/posts/{userId}/userPosts/{postId}')
  .onDelete(async(snapshot,context)=>{
      console.log('Post Created',snapshot.id);
       const userId=context.params.userId;
       const postId=context.params.postId;

        const followersRef=admin.firestore().collection('followers')
        .doc(userId).collection('userFollowers');
        const querySnapshot=await followersRef.get();


       querySnapshot.forEach((value)=>{
       const followerId = value.id;

      admin.firestore().collection('timeline')
          .doc(followerId).collection('timelinePosts').doc(postId).get().then((doc)=>{
              if(doc.exists)
                doc.ref.delete();
            });
       });
  });


exports.onCreateActivityFeedItem=functions.firestore
 .document('/feeds/{userId}/feedItems/{activityFeedItem}')
 .onCreate(async(snapshot,context)=>{
   console.log('Activity feed item created',snapshot.data());
   const userId=context.params.userId;
   const userRef = admin.firestore().doc(`users/${userId}`);
   const doc = await userRef.get();


 const androidNotificationToken =  doc.data().androidNotificationToken;
 const createdActivityFeedItem=snapshot.data();
  if(androidNotificationToken){
      sendNotification(androidNotificationToken,createdActivityFeedItem);
  }else{
      console.log('no token for users,cant send notification');
  }
  function sendNotification(androidNotificationToken,activityFeedItem){
      let body;

      switch (activityFeedItem.type){
          case "comment":
              body = `${activityFeedItem.username} replied:${activityFeedItem.commentData}`;
              break ;

          case "like":
              body = `${activityFeedItem.username} liked your post`;
              break ;
          case 'follow':
              body = `${activityFeedItem.username} started following you`;
              break ;

          default:
              break;
      }
 //click_action: 'FLUTTER_NOTIFICATION_CLICK'
      const message = {
          notification:{body},
          token : androidNotificationToken,
          data : {recipient : userId}
      };

      admin.messaging().send(message).then(response =>{
      console.log('Successfully send message',response);
      }).catch(error =>{
          console.log('Error sending message',error);
      });

  }
 });



exports.onSendMessage=functions.firestore//ei line e change ashbe
 .document('/messages/{userId}/{activityFeedItem}/{messageId}')
 .onCreate(async(snapshot,context)=>{
   console.log('Message Received',snapshot.data());

const userId=context.params.userId;//sender
   const userRef = admin.firestore().doc(`users/${userId}`);//senderRef
   const doc = await userRef.get();


    const receiverId=context.params.activityFeedItem;//receiver
      const receiverRef = admin.firestore().doc(`users/${receiverId}`);//receiverRef
      const receiverDoc = await receiverRef.get();


 const androidNotificationToken =  receiverDoc.data().androidNotificationToken;//ei line e change ashbe
 const createdActivityFeedItem=snapshot.data();

  if(androidNotificationToken){
      sendNotification(androidNotificationToken,createdActivityFeedItem);
  }else{
      console.log('no token for users,cant send notification');
  }
  function sendNotification(androidNotificationToken,activityFeedItem){
      let body;

      if(activityFeedItem.receiverId==receiverDoc.data().id){
        body = `${doc.data().displayname} messaged : ${activityFeedItem.message}`;


              const message = {
                  notification:{body},
                  token : androidNotificationToken,
                  data : {
                  recipient : receiverId,
                   click_action : 'FLUTTER_NOTIFICATION_CLICK',
                   view :'Profile',
                  }
              };

              admin.messaging().send(message).then(response =>{
              console.log('Successfully send message',response);
              }).catch(error =>{
                  console.log('Error sending message',error);
              });


      }


  }
 });

