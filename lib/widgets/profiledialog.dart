import 'package:cached_network_image/cached_network_image.dart';
import 'package:chattify/main.dart';
import 'package:chattify/widgets/chat_user_data.dart';
import 'package:flutter/material.dart';

class Profiledialog extends StatelessWidget {
  const Profiledialog({super.key,required this.user});

final ChatUserData user;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.white.withOpacity(.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      content: SizedBox(width: mq.width *.8,height: mq.height *.40,
      child: Stack(children: [

        Positioned(
          top: mq.height *.075,
          left: mq.width *.1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(mq.height * .1),
                child: CachedNetworkImage(
                  width: mq.width * .6,
                  fit: BoxFit.cover,
                imageUrl: user.image,
                // placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => CircleAvatar(child: Icon(Icons.person),)
                     ),
                        ),
        ),
        Positioned(
          left: mq.width *.04,
          top: mq.height *.02,
          width: mq.width *.55,
          child: Text(user.name,style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20),)),

      Positioned(
          right: 8,
          top: 6,
          child: MaterialButton(
            onPressed: (){},
            minWidth: 0,
            padding: EdgeInsets.all(0),
            shape: CircleBorder(),
            child: Icon(Icons.info_outline_rounded,color: Colors.blue,size: 30,),
),
        )
      ],),),
    );
  }
}