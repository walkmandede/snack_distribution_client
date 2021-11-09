library my_prj.globals;
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

Color c1 = Color(0xff204051);
Color c2 = Color(0xff3b6978);
Color c3 = Color(0xff84a9ac);
Color c4 = Color(0xffcae8d5);
Color colorAppBar = Colors.indigo;
Color colorBG = Color(0xfff5f6f8);
Color colorTextFieldBG = Color(0xffffffff);
Color colorTextFieldHint = Color(0xffcdd0d2);


void showAlertDialog(BuildContext ct,String title,Widget content,List<Widget> action)
{
  showDialog(
      context: ct,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: content,
        actions: action,
      )
  );
}

void showHero(BuildContext ct,String url)
{
  showDialog(
      context: ct,
      builder: (context) => AlertDialog(
        title: Image.network( url,
        ),
      )
  );
}


Future<String> uploadImageCloud(var imageFile,DateTime date) async {
  var Rand1 = new Random().nextInt(999);
  var Rand2 = new Random().nextInt(999);
  var Rand3 = new Random().nextInt(999);
  var fullImageName = '$Rand1$Rand2$Rand3.jpg';
  final Reference refImg = FirebaseStorage.instance.ref().child(
      DateTime.fromMillisecondsSinceEpoch(date.millisecondsSinceEpoch)
          .toString()
          .substring(0, 10) +
          '/' +
          fullImageName);
  UploadTask uploadTask = refImg.putFile(imageFile);
  var dowurl = await (await uploadTask.whenComplete(() => null)).ref.getDownloadURL();
  return dowurl;
}

Future<PlatformFile?> galleryOpen() async {
  FilePickerResult? img = await FilePicker.platform.pickFiles(type: FileType.image,);
    return img?.files.first;

}


Widget chipDesign(String label, Color color,Color textColor) => Container(
  child: Chip(
    label: Text(
      label,style: TextStyle(color: textColor),
    ),
    backgroundColor: color,
    elevation: 4,
    shadowColor: Colors.grey[50],
    padding: EdgeInsets.all(4),
  ),
  margin: EdgeInsets.only(left: 12, right: 12, top: 2, bottom: 2),

);

void push(BuildContext context,var to)
{
  Navigator.of(context,rootNavigator: true).push(MaterialPageRoute(builder: (context) => to,));
}

void pushReplacement(BuildContext context,var to)
{
  Navigator.of(context,rootNavigator: true).pushReplacement(MaterialPageRoute(builder: (context) => to,));
}

void pop(BuildContext context)
{
  Navigator.of(context,rootNavigator: true).pop();
}

void showSnack(BuildContext context,String text)
{
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text),duration: Duration(seconds: 2),));
}

Future<void> getCollectionData(String collectionName,Map mapName) async
{
  QuerySnapshot teamDs = await FirebaseFirestore.instance.collection(collectionName).get();
  teamDs.docs.forEach((element) {
    mapName.addEntries(
        [
          MapEntry(element.id, element.data())
        ]
    );
  });
}

Future<void> sendNoti(String _context,String _heading) async {
  final status = await OneSignal.shared.getDeviceState();
  String pid = status!.userId.toString();
  var notification = OSCreateNotification(
      playerIds: [pid],
      content: _context,
      heading: _heading,
      androidSmallIcon: 'https://firebasestorage.googleapis.com/v0/b/htdemployee.appspot.com/o/appImages%2Fgb_1.png?alt=media&token=9a9d0728-1679-4268-a478-7930de6347ca',
      iosAttachments: {"id1": 'https://firebasestorage.googleapis.com/v0/b/htdemployee.appspot.com/o/appImages%2Fgb_1.png?alt=media&token=9a9d0728-1679-4268-a478-7930de6347ca'},
      buttons: [
      ]);
  await OneSignal.shared.postNotification(notification);
}

void getStreamBuilder()
{
  StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance.collection('books').snapshots(),
    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
      if (!snapshot.hasData) return new Text('Loading...');
      return new ListView(
        children: snapshot.data!.docs.map((DocumentSnapshot document) {
          return new ListTile(
            title: new Text(document['title']),
            subtitle: new Text(document['author']),
          );
        }).toList(),
      );
    },
  );
}





