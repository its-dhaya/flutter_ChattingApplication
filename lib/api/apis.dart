import 'dart:developer';
import 'dart:io';
import 'package:chattify/widgets/chat_user_data.dart';
import 'package:chattify/widgets/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Import local notifications

class APIs {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static FirebaseStorage storage = FirebaseStorage.instance;
  static late ChatUserData me;
  static get user => auth.currentUser!;
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static FirebaseMessaging firebasemessage = FirebaseMessaging.instance;

  // Initialize the local notifications
  static Future<void> initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    // Initialize the plugin with the settings
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Function to show a local notification
  static Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'chat_channel', // Channel ID
      'Chat Notifications', // Channel name
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false, // Set to true to show when the notification was triggered
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      title, // Notification title
      body, // Notification body
      platformChannelSpecifics,
    );
  }

  static Future<void> getFirebaseMessagToken() async {
    await firebasemessage.requestPermission();
    await firebasemessage.getToken().then((t) {
      if (t != null) {
        me.pushToken = t;
        log('Pushtoken: $t');
      }
    });
  }

  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  static Future<bool> showuserExists(String email) async {
    final data = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    log('data:${data.docs}');

    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      log('user exists:${data.docs.first.data()}');
      firestore
          .collection('users')
          .doc(user.uid)
          .collection('my_users')
          .doc(data.docs.first.id)
          .set({});
      return true;
    } else {
      return false;
    }
  }

  static Future<void> getselfInfo() async {
    return await firestore
        .collection('users')
        .doc(user.uid)
        .get()
        .then((user) async {
      if (user.exists) {
        me = ChatUserData.fromJson(user.data()!);
        await getFirebaseMessagToken();
        APIs.updateActiveStatus(true);
        log('My data:${user.data()}');
      } else {
        await createUser().then((value) => getselfInfo());
      }
    });
  }

  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chatuser = ChatUserData(
      id: user.uid,
      name: user.displayName.toString(),
      email: user.email.toString(),
      about: "Hey, I'm using chattify!",
      image: user.photoURL.toString(),
      createdAt: time,
      isOnline: false,
      lastActive: time,
      pushToken: '',
    );

    return await firestore.collection('users').doc(user.uid).set(chatuser.toJson());
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyusers() {
    return firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_users')
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllusers(List<String>? usersIds) {
    log('\nUsers id:$usersIds');
    return firestore
        .collection('users')
        .where('id', whereIn: usersIds)
        // .where('id',isNotEqualTo: user.uid)
        .snapshots();
  }

  static Future<void> sendfirstmessage(ChatUserData chatuser, String msg, Type type) async {
    await firestore.collection('users').doc(chatuser.id)
        .collection('my_users')
        .doc(user.uid)
        .set({}).then((value) => sendMessage(chatuser, msg, type));
  }

  static Future<void> updateUserInfo() async {
    return await firestore.collection('users').doc(user.uid).update({
      'name': me.name,
      'about': me.about,
    });
  }

  static Future<void> updateProfilePicture(File file) async {
    final ex = file.path.split('.').last;
    log("Extension:$ex");
    final ref = storage.ref().child('Profile_picture/${user.uid}.$ex');
    await ref.putFile(file, SettableMetadata(contentType: 'image/$ex')).then((p0) {
      log('Data transferred:${p0.bytesTransferred / 1000}kb');
    });
    me.image = await ref.getDownloadURL();
    await firestore.collection('users').doc(user.uid).update({
      'image': me.image
    });
  }

  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode ? '${user.uid}_$id' : '${id}_${user.uid}';

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(ChatUserData user) {
    return firestore.collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  static Future<void> sendMessage(ChatUserData chatuser, String msg, Type type) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final Messages message = Messages(
      msg: msg,
      read: '',
      told: chatuser.id,
      type: type,
      fromid: user.uid,
      sent: time,
    );

    final ref = firestore.collection('chats/${getConversationID(chatuser.id)}/messages/');
    await ref.doc(time).set(message.toJson());

    // Show local notification immediately after sending the message
    await showNotification('New Message from ${me.name}', msg);
  }

  static Future<void> updateMessageStatus(Messages message) async {
    firestore.collection('chats/${getConversationID(message.fromid)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessages(ChatUserData user) {
    return firestore.collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  static Future<void> sendChatImage(ChatUserData chatuser, File file) async {
    final ex = file.path.split('.').last;
    final ref = storage.ref().child('images/${getConversationID(chatuser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ex');
    await ref.putFile(file, SettableMetadata(contentType: 'image/$ex')).then((p0) {
      log('Data transferred:${p0.bytesTransferred / 1000}kb');
    });
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatuser, imageUrl, Type.image);
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(ChatUserData chatuser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatuser.id)
        .snapshots();
  }

  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore
        .collection('users')
        .doc(user.uid)
        .update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken,
    });
  }

  static Future<void> deleteMessage(Messages message) async {
    await firestore
        .collection('chats/${getConversationID(message.told)}/messages/')
        .doc(message.sent)
        .delete();

    if (message.type == Type.image) {
      await storage.refFromURL(message.msg).delete();
    }
  }

  static Future<void> updateMessage(Messages message, String updatedMessage) async {
    await firestore
        .collection('chats/${getConversationID(message.told)}/messages/')
        .doc(message.sent)
        .update({'msg': updatedMessage});
  }
}
