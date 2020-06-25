import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:useallfeatures/home.dart';
import 'package:useallfeatures/models/user.dart';
import 'package:useallfeatures/pages/profile.dart';
import 'package:useallfeatures/progress.dart';




class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  Future<QuerySnapshot>searchResultFuture;
  TextEditingController controller;


  handleSearch(String query){
    String s='';
    for(int i=0;i<query.length;i++){
      if(i==0)
        s+=query[i].toUpperCase();
      s+=query[i];
    }
    query=s;
    Future <QuerySnapshot> users=userRef.where('displayname',isGreaterThanOrEqualTo: query).limit(7).getDocuments();

    setState(() {
      searchResultFuture=users;
    });



  }

  noContent(){
    Orientation or=MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          children: <Widget>[
        SvgPicture.asset('assets/images/search.svg',
          height: or==Orientation.landscape ? 150:350
        ),
            Text('Fine Users',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 60,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );

  }
  showContent(){

    return FutureBuilder<QuerySnapshot>(
      future:searchResultFuture ,
      builder: (context,snapshot){
        if(!snapshot.hasData)
          return circularProgress();
        List<SearchResult>searchResults=[];
        snapshot.data.documents.forEach((doc) {
          User user=User.fromDocument(doc);
          SearchResult searchResult=SearchResult(user: user);
          searchResults.add(searchResult);
        });

        return ListView(
          children: searchResults,
        );},
    );

  }
AppBar  buildSearchBar(){
   return AppBar(
     backgroundColor: Colors.white,
     title: TextFormField(
       style: TextStyle(
         fontSize: 20,
         color: Colors.purple,
       ),
       controller: controller,
       autofocus: true,
       decoration: InputDecoration(
           hintText: 'Search here',
           hintStyle: TextStyle(
             fontSize: 20,
             color: Colors.purple,
           ),
           filled: true,
           prefix: Icon(Icons.account_box,size: 28,color: Colors.grey,),
           suffix: IconButton(
             icon: Icon(Icons.clear,size: 28,color: Colors.grey,),
             onPressed: (){
               //  print('cleared');
               controller.clear();
             },
           )
       ),
       onFieldSubmitted: handleSearch,
     ),

   );
  }

  @override
  void initState() {
    // TODO: implement initState
    controller=TextEditingController();
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Theme.of(context).primaryColor.withOpacity(0.6),
      appBar:buildSearchBar(),
      body: searchResultFuture == null ? noContent(): showContent(),
    );
  }
}
class SearchResult extends StatelessWidget {
  User user;
  SearchResult({this.user});


  showProfile(BuildContext context){
    Navigator.push(context, MaterialPageRoute(builder: (context){

      return Profile(profileId: user.id,);
    }));

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.8),
     child: Column(
       children: <Widget>[
         GestureDetector(
           onTap: ()=>showProfile(context),
           child: ListTile(
             leading: CircleAvatar(

               backgroundColor: Colors.grey,
               backgroundImage: CachedNetworkImageProvider(user.photoUrl),
             ),
             title: Text(user.displayname,
               style: TextStyle(
                 color: Colors.white,
                 fontWeight: FontWeight.bold,

               ),),
             subtitle: Text(user.email,
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
