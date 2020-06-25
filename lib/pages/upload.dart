import 'dart:io';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:useallfeatures/home.dart';
import 'package:useallfeatures/models/user.dart';
import 'package:useallfeatures/progress.dart';
import 'package:uuid/uuid.dart';
import 'package:storage_path/storage_path.dart';



import 'dart:async';
import 'package:flutter/services.dart';
import 'package:storage_path/storage_path.dart';

final StorageReference storageReference=FirebaseStorage.instance.ref();

class Upload extends StatefulWidget {

  User currentUser;
  Upload(this.currentUser);

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> with AutomaticKeepAliveClientMixin
<Upload>{
  File file;
  bool fileNull =true;
  bool isUploadScreen = false;
  bool isUploading =false;
  String postId=Uuid().v4();
  TextEditingController captionController;
  TextEditingController locationController;
  List<GridTile>gridTiles=[];





  getImagesPath() async {
    List<GridTile>tiles=[];


    String imagespath = "";
    List<Widget> cList=new List() ;

    try {
      imagespath = await StoragePath.imagesPath;
      var response = jsonDecode(imagespath);
      //  print(response);
      //  print(imagespath);

      var imageList = response as List;

      List<FileModel> list = imageList.map<FileModel>((json) => FileModel.fromJson(json)).toList();

      list.forEach((element)async {
        print(element.toString());
        if(element.folder =='WhatsApp Images'){


          for(int i=0;i<element.files.length && i<10;i++){
            //  print('ImageName:${element.files[i]}');
            File f = await File(element.files[i]);
            if(f.exists() != null){

              tiles.add(GridTile(child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(child:Image.file(f) ,
                  onTap: (){
                  setState(() {
                    file = f;
                    fileNull = false;

                  });

                  },
                ),
              ),));

            }
            else{
              print('no image');
            }
          }

          setState(() {
            //cardList = cList;
            gridTiles = tiles;
          });
        }
      });

    } on PlatformException {
      imagespath = 'Failed to get path';
    }
  }



  fromGalleryHandle()async{
    Navigator.pop(context);
    File f=await ImagePicker.pickImage(source: ImageSource.gallery, maxWidth: 960,maxHeight: 675);
    if(f!=null)
    //  print('file not null');
    setState(() {
      file=f;
    });
  }
  fromCameraHandle()async{
    Navigator.pop(context);
    File f=await ImagePicker.pickImage(source: ImageSource.camera, maxWidth: 960,maxHeight: 675);
    setState(() {
      file=f;
    });
  }

  selectImage(parentContext){
    return showDialog(context: parentContext,
    builder: (context){
      return SimpleDialog(
        title: Text('Create Post'),
        children: <Widget>[
          SimpleDialogOption(child: Text('Photo from Camera'),onPressed: fromCameraHandle,),
          SimpleDialogOption(child: Text('Photo from Gallery'),
          onPressed: fromGalleryHandle,
          ),
          SimpleDialogOption(child: Text('Cancel'),
          onPressed: ()=>Navigator.pop(context),
          ),

        ],
      );

    },
    );

  }

  Container buildSplashScreen(){
    Orientation orientation=MediaQuery.of(context).orientation;
    return Container(
      color: Theme.of(context).accentColor.withOpacity(0.6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[

          SvgPicture.asset('assets/images/upload.svg',
            height: orientation==Orientation.portrait? 270:100),
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: RaisedButton(
              child: Text('Upload',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 22,
              ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              color: Colors.deepOrange,
              onPressed: (){
               // selectImage(context);
                setState(() {
                  isUploadScreen = true;
                });
              },
            ),
          )
        ],
      ),

    );
  }
  compressedImage()async{
    final tempDir=await getTemporaryDirectory();
    final path= tempDir.path;
    //print( 'image path ${ file.path}' );
  //  final p = '/storage/emulated/0/Android/data/ashraf.useallfeatures/files/Pictures/';

    Im.Image imgFile=Im.decodeImage(file.readAsBytesSync());

    final compressedImgFile=File('$path/img_$postId.jpg')..writeAsBytesSync(Im.encodeJpg(imgFile,quality: 93));

    setState(() {
      file=compressedImgFile;
    });


  }
  uploadImgInFireStore(String mediaUrl,String description,String location){
    firestorePost.document(widget.currentUser.id).collection('userPosts').document(postId).setData({

      'postId':postId,
      'ownerId':widget.currentUser.id,
      'username': widget.currentUser.username,
      'mediaUrl':mediaUrl,
      'description':description,
      'location':location,
      'timestamp':DateTime.now(),
      'likes':{},
    });
  }

   Future<String> uploadImage(imgFile)async{

   StorageUploadTask storageUploadTask =await storageReference.child('post_$postId.jpg').putFile(imgFile);

   StorageTaskSnapshot storageTaskSnapshot  =await storageUploadTask.onComplete;

  String downUrl=await storageTaskSnapshot.ref.getDownloadURL();
  return downUrl;
  }

  @override
  Scaffold uploadingScreen(){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        leading: IconButton(icon: Icon(Icons.arrow_back,color: Colors.black,), onPressed: (){
          setState(() {
           // file=null;
            isUploadScreen =false;
          });
        }),
        title: Text('Caption Post',
        style: TextStyle(
          color: Colors.black,
        ),
        ),
        actions: <Widget>[
          FlatButton(

            onPressed: isUploading ? null : () async {
              String mediaUrl = 'https://firebasestorage.googleapis.com/v0/b/features-explained.appspot.com/o/hd.jpg?alt=media&token=6791cb4d-ccb9-475b-918e-d5653d76d0af';
            setState(() {
              isUploading=true;
            });

              if(file!=null){
                await compressedImage();
                mediaUrl=  await uploadImage(file);
              }

            uploadImgInFireStore(mediaUrl,locationController.text,captionController.text);
            captionController.clear();
            setState(() {
              file=null;
              isUploading=false;

              isUploadScreen = false;
              postId=Uuid().v4();
              fileNull = true;
            });
            locationController.clear();
          } ,
          child: Text('Post',
          style: TextStyle(
            color: Colors.blueAccent,
            fontWeight: FontWeight.bold,
           fontFamily: 'Pacifico',
            fontSize: 20,
          ),
          ))
        ],
      ),

      body: Stack(
        children: <Widget>[
          ListView(

            children: <Widget>[
              isUploading ? linearProgress() :Text(''),
              fileNull?  Container(): Container(
                height: 230,
                width: MediaQuery.of(context).size.width*0.8,
                child: Center(child: AspectRatio(aspectRatio: 16/9,
                  child:new Stack(
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: FileImage(file),
                            )
                        ),
                      ),

                      Container(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          splashColor: Colors.transparent,
                          icon: Icon(FontAwesomeIcons.trash,size: 20,),
                          color: Colors.white,
                          onPressed: (){
                            setState(() {
                              fileNull = true;
                              file = null;
                            });
                          },
                        ),
                      ),

                    ],
                  ),
                ),),
              ),
              Padding(
                padding: EdgeInsets.only(top: 7,),
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(widget.currentUser.photoUrl),
                  backgroundColor: Colors.grey,

                ),
                title: Container(
                  height: 120,
                  child: TextField(
                    controller: captionController,

                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Write a Caption',
                      border: InputBorder.none,

                    ),
                  ),
                ),
              ),
              Divider(
                height: 5,
              ),
              ListTile(
                leading: Icon(Icons.pin_drop,
                  color: Colors.deepOrange,
                  size: 35,
                ),
                title: Container(
                  width: 250,
                  child: TextField(
                    controller: locationController,
                    decoration: InputDecoration(
                        hintText: 'Where the photo taken',
                        border: InputBorder.none
                    ),
                  ),
                ),
              ),
              Container(
                height: 100,
                width: 200,
                alignment: Alignment.center,
                child: RaisedButton.icon(
                  color: Colors.blueAccent,
                  icon: Icon(Icons.my_location,
                    color: Colors.white,
                  ),
                  label: Text('Use Current location',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)
                  ),
                  onPressed: ()async{


                    final Position position=await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
                    List<Placemark>placemarks=await Geolocator().placemarkFromCoordinates(position.latitude, position.longitude);
                    Placemark placemark=placemarks[0];
                    String formattedAddress='${placemark.locality},${placemark.country}';

                    setState(() {
                      locationController.text=formattedAddress;
                    });
                  },
                ),
              ),

            ],
          ),
          !fileNull?   Container() : SizedBox.expand(
                child:DraggableScrollableSheet(
                  initialChildSize: 0.25,
                  minChildSize: 0.12,
                  maxChildSize: .8,
                  builder: (BuildContext c, ScrollController scrollController ){
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,

                        // color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20)
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            blurRadius: 10,
                          )
                        ],

                      ),
                      child: gridTiles==null? circularProgress(): ListView(
                        controller: scrollController,
                        children: <Widget>[
                          Center(
                            child: Container(
                              height: 8,
                              width: 50,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),

                          SizedBox(height: 20,),
                          Center(
                            child: Text('Add a image to your post',
                              style: TextStyle(
                                fontFamily: 'Signatra',
                                fontSize: 27,

                              ),
                            ),
                          ),
                          SizedBox(height: 10,),
                          GridView.count(
                            crossAxisCount: 3,
                            childAspectRatio: 1,
                            crossAxisSpacing: 1.5,
                            mainAxisSpacing: 1.5,
                            physics: NeverScrollableScrollPhysics(),
                            children: gridTiles,
                            shrinkWrap: true,
                          ),
                        ],
                      ),
                    );
                  },
                ) ,
              ),

        ],
      ),
    );
  }
  String imagePath = "";
  @override
  void initState() {
    super.initState ( );
    locationController = TextEditingController();
    captionController = TextEditingController();
    getImagesPath();
  }

  bool get wantKeepAlive =>true;


  Widget build(BuildContext context) {

    super.build(context);
   // return file==null ? buildSplashScreen() :uploadingScreen() ;
    return isUploadScreen ? uploadingScreen():buildSplashScreen();
  }
}

class FileModel {
  List<String> files;
  String folder;

  FileModel({this.files, this.folder});

  FileModel.fromJson(Map<String, dynamic> json) {
    files = json['files'].cast<String>();
    folder = json['folderName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['files'] = this.files;
    data['folderName'] = this.folder;
    return data;
  }

  @override
  String toString() {
    return 'FileModel{ folder: $folder}';
  }

}