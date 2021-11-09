import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snack_distribution_client/globals.dart';
import 'package:snack_distribution_client/homePage.dart';


class LoginPage extends StatefulWidget {

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  TextEditingController txtPhone = new TextEditingController(text: '');
  TextEditingController txtUsername = new TextEditingController(text: '');


  @override
  void initState() {
    getData();
    super.initState();
  }

  Future<void> getData() async
  {
    await Firebase.initializeApp();
    await OneSignal.shared.setRequiresUserPrivacyConsent(true);
    await OneSignal.shared.userProvidedPrivacyConsent();
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    SharedPreferences sp = await SharedPreferences.getInstance();
    if(sp.getString('Phone')!=null)
    {
      setState(() {
        txtPhone.text = sp.getString('Phone')!;
      });
    }
    if(sp.getString('Username')!=null)
    {
      setState(() {
        txtUsername.text = sp.getString('Username')!;
      });
    }
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.pinkAccent,
       child: Center(
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             Container(
               width: MediaQuery.of(context).size.width*0.55,
               child: TextField(
                 controller: txtUsername,
                 decoration: InputDecoration(
                     border: InputBorder.none,
                     label: Text('အမည်'),
                     filled: true,
                     fillColor: Colors.white,
                     prefixIcon: Icon(Icons.person)
                 ),
               ),
             ),
             SizedBox(height: 10,),
             Container(
               width: MediaQuery.of(context).size.width*0.55,
               child: TextField(
                 controller: txtPhone,
                 keyboardType: TextInputType.phone,
                 decoration: InputDecoration(
                     border: InputBorder.none,
                     label: Text('ဖုန်းနံပါတ်'),
                     filled: true,
                     fillColor: Colors.white,
                     prefixIcon: Icon(Icons.phone)
                 ),
               ),
             ),
             SizedBox(height: 10,),
             ElevatedButton.icon(
               icon: Icon(Icons.login),
               label: Text('ဝင်ရောက်မည်'),
               onPressed: () async{
                 if(txtPhone.text=="")
                   {
                     showAlertDialog(context, 'Fill the phone number pls', Text(''), []);
                   }
                 else{
                   SharedPreferences sp = await SharedPreferences.getInstance();
                   sp.setString('Phone', txtPhone.text);
                   sp.setString('Username', txtUsername.text);
                   pushReplacement(context, HomePage());
                 }
               },
             )
           ],
         ),
       ),
      )
    );
  }
}
