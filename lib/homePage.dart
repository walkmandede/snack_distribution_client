import 'package:cached_network_image_builder/cached_network_image_builder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snack_distribution_client/cartPage.dart';
import 'package:snack_distribution_client/globals.dart';
import 'package:snack_distribution_client/ordersHistory.dart';


class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String selectedCategory = "All";
  Map snackStockMap = {};
  String user = '';
  String phone = '';
  String ItemsCart = '';

  Future<void> initPlatformState() async {
    //Remove this method to stop OneSignal Debugging

    await OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

    await OneSignal.shared.setAppId("a298a2d9-6b9b-4595-8269-2e429a928b14");
// The promptForPushNotificationsWithUserResponse function will show the iOS push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
    await OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {
      print("Accepted permission: $accepted");
    });
    // String externalUserId = 'admin'; // You will supply the external user id to the OneSignal SDK
    // OneSignal.shared.setExternalUserId(externalUserId);
    // await OneSignal.shared.sendTag("status", "admin");
  }


  @override
  void initState() {
    initPlatformState();
    getData();
    super.initState();
  }

  Future<void> getData() async
  {
    await Firebase.initializeApp();
    await getCollectionData('SnackStock', snackStockMap);

    SharedPreferences sp = await SharedPreferences.getInstance();
    setState(() {
      phone = sp.getString('Phone')!;
      user = sp.getString('Username')!;
    });
    if(sp.getString('Cart')!=null)
      {
        setState(() {
          ItemsCart = sp.getString('Cart').toString();
        });
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$user ( '+ phone + ' )'  ),
        actions: [
          ItemsCart==''?Container():IconButton(onPressed: () async{
            SharedPreferences sp = await SharedPreferences.getInstance();
            setState(() {
              ItemsCart = sp.getString('Cart').toString();
            });
            print(sp.getString('Cart'));
            sp.remove('Cart');
            setState(() {
              ItemsCart = '';
            });
            // pushReplacement(context, HomePage());
          }, icon: Icon(Icons.remove_shopping_cart))
        ],
      ),
      drawer: Drawer(
        child: OrdersHistory()
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('SnackStock').snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  Map showItemsMap = {};
                  List allCategories = [];
                  allCategories.add('All');
                  snackStockMap.keys.forEach((element) {
                    if(!allCategories.contains(snackStockMap[element]['Category'])&&snackStockMap[element]['Status']=='Available')
                    {
                        allCategories.add(snackStockMap[element]['Category']);
                    }
                  });
                  snapshot.data?.docs.forEach((element) {
                    if(selectedCategory=='All')
                      {
                        showItemsMap.addEntries(
                            [
                              MapEntry(element.id, element.data())
                            ]
                        );
                      }
                    else if(selectedCategory==snackStockMap[element.id]['Category'])
                      {
                        showItemsMap.addEntries(
                            [
                              MapEntry(element.id, element.data())
                            ]
                        );
                      }
                  });
                  if (!snapshot.hasData) return Center(child: new Text('There is no data available!'));
                  else if(showItemsMap.isEmpty) return new Center(child: new Text('There is no data available!'));
                  return Column(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: allCategories.map((e) {
                            return  GestureDetector(
                              child: chipDesign(e, selectedCategory != e?Colors.grey:Colors.pink, Colors.white),
                              onTap: () {
                                setState(() {
                                  selectedCategory = e;
                                });
                              },
                            );
                          } ).toList(),
                        ),
                      ),
                      SizedBox(height: 10,),
                      Expanded(
                        child: ListView(
                          children: showItemsMap.keys.map((e) =>
                          showItemsMap[e]['Status']=='Deleted'||showItemsMap[e]['Stock']==0?Container():ListTile(
                            leading: Container(
                              margin: EdgeInsets.all(3),
                              width: MediaQuery.of(context).size.width*0.15,
                              height: MediaQuery.of(context).size.width*0.15,
                              child: CachedNetworkImageBuilder(url: showItemsMap[e]['Photo'],
                                builder: (image) {
                                  return Image.file(image);
                                },)
                            ),
                            title: Text(showItemsMap[e]['Name'],style: TextStyle(fontWeight: FontWeight.bold,color: ItemsCart.split('|').contains(e.toString())?Colors.pinkAccent:Colors.black),),
                            subtitle: Text(showItemsMap[e]['Description']),
                            trailing: Text(showItemsMap[e]['Price']+' MMKs',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.pinkAccent),),
                            onTap: () async{
                              SharedPreferences sp = await SharedPreferences.getInstance();
                              var CartItems = sp.getString('Cart');
                              showDialog(context: context, builder: (context) => AlertDialog(
                                title: Column(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width*0.4,
                                      height: MediaQuery.of(context).size.width*0.4,
                                      child: CachedNetworkImageBuilder(url: showItemsMap[e]['Photo'],
                                        builder: (image) {
                                          return Image.file(image);
                                        },),
                                    ),
                                    TextField(
                                      readOnly: true,
                                      controller: new TextEditingController(text: showItemsMap[e]['Name']),
                                      decoration: InputDecoration(
                                          labelText: 'မုန့်နာ',
                                          border: InputBorder.none
                                      ),
                                    ),
                                    TextField(
                                      readOnly: true,
                                      controller: new TextEditingController(text: showItemsMap[e]['Category']),
                                      decoration: InputDecoration(
                                          labelText: 'မုန့်အမျိုးအစား',
                                          border: InputBorder.none
                                      ),
                                    ),
                                    TextField(
                                      readOnly: true,
                                      controller: new TextEditingController(text: showItemsMap[e]['Price']),
                                      decoration: InputDecoration(
                                          labelText: 'စျေးနှုန်း',
                                          border: InputBorder.none
                                      ),
                                    ),
                                    TextField(
                                      readOnly: true,
                                      controller: new TextEditingController(text: showItemsMap[e]['Description']),
                                      decoration: InputDecoration(
                                          labelText: 'အခြား',
                                          border: InputBorder.none
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  CartItems.toString().split('|').contains(e.toString())?Text('စျေးခြင်းထဲတွင်ရှိပြီးသားဖြစ်ပါသည်',style: TextStyle(color: Colors.red),):
                                  TextButton.icon(onPressed: () async{
                                    if(CartItems==null)
                                    {
                                      CartItems = e.toString();
                                      await sp.setString('Cart', CartItems.toString());
                                      setState(() {
                                        ItemsCart = CartItems.toString();
                                      });
                                    }
                                    else{
                                      CartItems = CartItems.toString()+"|"+e.toString();
                                      await sp.setString('Cart', CartItems.toString());
                                      setState(() {
                                        ItemsCart = CartItems.toString();
                                      });
                                    }
                                    pop(context);
                                  }, icon: Icon(Icons.add_shopping_cart), label: Text('စျေးခြင်းထဲ ထည့်မည်')),
                                ],
                              ),);
                            },
                          ),
                          ).toList(),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 10,),
          Container(
            child:
            ItemsCart==''?Container():TextButton.icon(onPressed: () {
              if(ItemsCart!='')
              {
                pushReplacement(context, CartPage());
              }
            }, icon: Icon(Icons.shopping_cart,color:  Colors.pinkAccent,),label: Text('စျေးခြင်းထဲရှိ အရေအတွက် : '+ ItemsCart.split('|').length.toString(),style: TextStyle(color: Colors.pinkAccent),),),
          )
        ],
      ),
    );
  }
}
