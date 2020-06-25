import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:storage_path/storage_path.dart';
import 'package:useallfeatures/pages/upload.dart';
import 'package:useallfeatures/progress.dart';
//import 'package:useallfeatures/widgets/custom_image.dart';
//import 'package:google_fonts/google_fonts.dart';

class CreateQuestion extends StatefulWidget {
  @override
  _CreateQuestionState createState() => _CreateQuestionState();
}

class _CreateQuestionState extends State<CreateQuestion> {
  TextEditingController questionController;
  TextEditingController descriptionController;
  File file;
  List<FileModel> fileModel;
  List<Widget> cardList=new List() ;
  List<GridTile>gridTiles=[];


  fromGalleryHandle()async{
    Navigator.pop(context);
    File f=await ImagePicker.pickImage(source: ImageSource.gallery, maxWidth: 960,maxHeight: 675);
    if(f!=null)
      //  print('file not null');
      setState(() {
        file=f;
      });

  }

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
                onTap: ()=>print('image'),
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

  @override
  void initState() {
    getImagesPath();
    super.initState();
    questionController = TextEditingController();
    descriptionController = TextEditingController();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back,color: Colors.grey,), onPressed: (){
          Navigator.pop(context);
        }),
        backgroundColor: Colors.white,
        title:Text( 'Ask Community',

        style: TextStyle(
          fontFamily: 'Signatra',
          fontSize: 30,
          color: Colors.black
        ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.attach_file,color: Colors.teal,),
            onPressed: ()=>print('attach file'),
          ),
          FlatButton(
            onPressed: ()=>print('send'),
            child: Text('Send',
              style: TextStyle(
                color: Colors.teal,
                fontFamily: 'Signatra',
                fontSize: 30,
              ),
            ),
          )
        ],

      ),
      body: new Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
          file==null ? Container():    Container(
                height: 180,
                width: MediaQuery.of(context).size.width*0.8,
                child: Center(child: AspectRatio(aspectRatio: 16/9,
                  child: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: FileImage(file),
                        )
                    ),
                  ),
                ),),
              ),

              TextField(
                controller: questionController,
                maxLines: 3,
                decoration: new InputDecoration(
                  hintText:'Add a question indicating whats wrong with your crop',


                  labelText: "Question",
                  fillColor: Colors.grey,

                  border: new OutlineInputBorder(

                    borderRadius: new BorderRadius.circular(25.0),
                    borderSide: new BorderSide(
                    ),
                  ),
                ),
                /*       validator: (val) {
              if(val.length==0) {
                return "Email cannot be empty";
              }else{
                return null;
              }
            },*/
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 20,),


              TextField(
                controller: questionController,
                maxLines: 3,
                decoration: new InputDecoration(
                  hintText:'Add a description indicating whats your crop current situation such as leaves,roots,change of color',


                  labelText: "Description of your problem",
                  fillColor: Colors.white,
                  border: new OutlineInputBorder(

                    borderRadius: new BorderRadius.circular(25.0),
                    borderSide: new BorderSide(
                    ),
                  ),
                ),
                /*       validator: (val) {
              if(val.length==0) {
                return "Email cannot be empty";
              }else{
                return null;
              }
            },*/
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          SizedBox.expand(
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

              /*    children: <Widget>[
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
                      Text('Add a image to your post',
                      style: TextStyle(
                        fontFamily: 'Signatra',
                        fontSize: 27,

                      ),
                      ),


                 /*     GestureDetector(
                        child: Text('Image From Gallery',
                          style: TextStyle(
                           // fontFamily: 'Signatra',
                            fontSize: 20,

                          ),
                        ),
                        onTap: fromGalleryHandle,


                      ),*/


                    ],*/
                  ),
                );
              },
            ) ,
          )
        ],
      ),
    );
  }
}
