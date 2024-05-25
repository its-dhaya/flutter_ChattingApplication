import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chattify/api/apis.dart';
import 'package:chattify/auth/loginscreen.dart';
import 'package:chattify/helper/dialog.dart';
import 'package:chattify/main.dart';
import 'package:chattify/screens/homepage.dart';
import 'package:chattify/widgets/chat_user.dart';
import 'package:chattify/widgets/chat_user_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

class Profilescreen extends StatefulWidget {
  final ChatUserData user;
  const Profilescreen({super.key,required this.user});

  @override
  State<Profilescreen> createState() => _ProfilescreenState();
}

class _ProfilescreenState extends State<Profilescreen> {
  final _formkey = GlobalKey<FormState>();
  String? _image;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( 
       leading: IconButton(onPressed: (){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>Homepage()));
       }, icon: Icon(Icons.arrow_back)),
        title: Text('Profile Screen'),
        actions: [

         
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FloatingActionButton.extended
        (backgroundColor: Colors.tealAccent.shade700,
          onPressed:() async {
            Dialogs.showProgressbar(context);
          await APIs.updateActiveStatus(false);
          await APIs.auth.signOut();
          await GoogleSignIn().signOut();
          Navigator.pop(context);
          Navigator.pop(context);
          APIs.auth = FirebaseAuth.instance;
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>Loginscreen()));

        },
        icon: Icon(Icons.logout),
        label:Text('Logout')
        ),
      ),
      body: Form(
        key: _formkey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(width: mq.width,height: mq.height * .03,),
              
              Stack(
                children: [
                  //local image
                  _image != null ?
                  ClipOval(
                    child: ClipRect(
                    
                    child: Image.file(File(_image!),
                      width: mq.height * .2,
                      height: mq.height * .2,
                      fit: BoxFit.cover,

                         ),
                            ),
                  ):
                  //server image
                  ClipOval(
                    child: ClipRect(
                    
                    child: CachedNetworkImage(
                      width: mq.height * .2,
                      height: mq.height * .2,
                      fit: BoxFit.cover,
                    imageUrl: widget.user.image,
                    // placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => CircleAvatar(child: Icon(Icons.person),)
                         ),
                            ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: MaterialButton(onPressed: (){
                      _showBottomsheet();
                    },
                    elevation: 1,
                    shape: CircleBorder(),
                    color: Colors.white,
                    child: Icon(Icons.edit,color: Colors.tealAccent.shade700,),),
                  )
                ],
              ),
              SizedBox(height: mq.height * .03,),
              Text(widget.user.email,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
              SizedBox(height: mq.height * .03,),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  onSaved: (val)=>APIs.me.name=val ??'',
                  validator: (val)=> val!=null&&val.isNotEmpty ? null :'Required',
                  initialValue: widget.user.name,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person,color: Colors.tealAccent.shade700,),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.tealAccent.shade700
                      ), 
                    ),
                    hintText: "eg.Adam",
                    label: Text('Name',selectionColor: Colors.tealAccent.shade700,)
                  ),
                ),
                
              ),
              SizedBox(height: mq.height *.002,),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  onSaved: (val)=>APIs.me.about=val ??'',
                  validator: (val)=> val!=null&&val.isNotEmpty ? null :'Required',
                    initialValue: widget.user.about,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.info,color: Colors.tealAccent.shade700,),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.tealAccent.shade700
                        ), 
                      ),
                      hintText: "eg.I'm using chattify",
                      label: Text('About',selectionColor: Colors.tealAccent.shade700,)
                    ),
                  ),
              ),
                SizedBox(height: mq.height *.04,),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.tealAccent.shade200,
                  
                    shape: StadiumBorder(),
                    minimumSize: Size(mq.width * .5,mq.height *.06),
                  ),
                  onPressed: (){
                    if(_formkey.currentState!.validate()){
                      _formkey.currentState!.save();
                      log('inside validator');
                      APIs.updateUserInfo().then((value){
                        Dialogs.showSnackbar(
                          context,'Profile updated succesfully'
                        );
                      });

                    }
                  }, 
                  icon: Icon(Icons.edit,size: 20,color: Colors.black,),
                  label: Text('Update',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.black),),)
            ],
          ),
        ),
      )
    );
  }

  void _showBottomsheet(){
    showModalBottomSheet(context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(topLeft: Radius.circular(25),topRight: Radius.circular(25))
    ),

     builder: (_){
      return ListView(
      shrinkWrap: true,
        children: [
          Text('Select Profile picture',textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),
          ),
          SizedBox(height: 8,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(mq.width *.3, mq.height *.10)
                ),
                onPressed: () async{
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                  if(image!=null){
                    log('Image path: ${image.path} -- MimeType:${image.mimeType}');
                    setState(() {
                      _image = image.path;
                    });
                    APIs.updateProfilePicture(File(_image!));
                  }
                  Navigator.pop(context);
                },
                child: Image.asset('assets/addphoto.png'),
              ),

              SizedBox(height: 5,),
                ElevatedButton(
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(mq.width *.3, mq.height *.10)
                ),
                onPressed: () async {
                   final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(source: ImageSource.camera);
                  if(image!=null){
                    log('Image path: ${image.path}');
                    setState(() {
                      _image = image.path;
                    });
                    APIs.updateProfilePicture(File(_image!));
                  }
                  Navigator.pop(context);
                },
                child: Image.asset('assets/addcamera.png'),
              )
            ],
          ),
          
          
        ],
      );
     });
  }
}
