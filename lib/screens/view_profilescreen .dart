import 'package:cached_network_image/cached_network_image.dart';
import 'package:chattify/helper/date_util.dart';
import 'package:chattify/main.dart';
import 'package:chattify/screens/homepage.dart';
import 'package:chattify/widgets/chat_user_data.dart';
import 'package:flutter/material.dart';


class ViewProfilescreen extends StatefulWidget {
  final ChatUserData user;
  const ViewProfilescreen({super.key,required this.user});

  @override
  State<ViewProfilescreen> createState() => _ViewProfilescreenState();
}

class _ViewProfilescreenState extends State<ViewProfilescreen> {



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( 
       leading: IconButton(onPressed: (){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>Homepage()));
       }, icon: Icon(Icons.arrow_back)),
        title: Text(widget.user.name),
),
floatingActionButton: 
Row(
mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Joined on: ',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17),),
                Text(DateUtil.getLastMessageTime(context: context, time: widget.user.createdAt,isshowyear: true),
                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17),)
              ],
            ),
      
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(width: mq.width,height: mq.height * .03,),
            
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
            SizedBox(height: mq.height * .03,),
            Text(widget.user.email,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
            SizedBox(height: mq.height * .03,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('About: ',style: TextStyle(fontWeight: FontWeight.w600,fontSize: 15),),
                Text(widget.user.about,
                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17),)
              ],
            ),


          ],
        ),
      )
    );
  }

}
