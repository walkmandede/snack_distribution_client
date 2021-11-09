import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image_builder/cached_network_image_builder.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snack_distribution_client/globals.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snack_distribution_client/homePage.dart';


class CartPage extends StatefulWidget {

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {

  Map snackStockMap = {};
  var snackImage;
  TextEditingController txtName = new TextEditingController(text: '');
  TextEditingController txtPrice = new TextEditingController(text: '0');
  TextEditingController txtDescription = new TextEditingController(text: '');
  TextEditingController txtQuantity = new TextEditingController(text: '0');
  TextEditingController txtNewCategory = new TextEditingController(text: '');
  Map itemQuantityMap = {};
  String ItemsCart ='';
  int totalPrice = 0;

  @override
  void initState() {
    getData();
    super.initState();
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

  Future<void> getData() async
  {
    await getCollectionData('SnackStock', snackStockMap);
    snackStockMap.keys.forEach((element) {
      setState(() {
        itemQuantityMap.addEntries({
          MapEntry(element, 0)
        });
      });
    });
    SharedPreferences sp = await SharedPreferences.getInstance();
    setState(() {
      ItemsCart = sp.getString('Cart').toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            pushReplacement(context, HomePage());
          },
        ),
        actions: [
          IconButton(onPressed: () async{
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
      body: Container(
        margin: EdgeInsets.all(10),
        child: ItemsCart.toString()==''?Center(
          child: Text('No Items Add to the cart!'),
        ):Column(
          children: [
            Expanded(
              child: ListView(
                children: ItemsCart.split('|').map((e) {
                  return Card(
                    child: Container(
                      margin: EdgeInsets.all(5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width*0.14,height: MediaQuery.of(context).size.width*0.14,
                            child: CachedNetworkImageBuilder(url: snackStockMap[e]['Photo'],
                              builder: (image) {
                                return Image.file(image);
                              },)
                          ),
                          Column(
                            children: [
                              Text(snackStockMap[e]['Name'],style: TextStyle(fontWeight: FontWeight.bold),),
                              Text('Unit Price : '+snackStockMap[e]['Price'].toString()),
                              Text('Total Price : '+(int.parse(snackStockMap[e]['Price'])*itemQuantityMap[e]).toString(),style: TextStyle(color: Colors.pinkAccent,fontWeight: FontWeight.bold),),
                            ],
                          ),
                          Container(
                            child: Row(
                              children: [
                                IconButton(onPressed: () {
                                  if(snackStockMap[e]['Stock']>itemQuantityMap[e])
                                    {
                                      setState(() {
                                        itemQuantityMap[e] = itemQuantityMap[e] + 1;
                                      });
                                      setState(() {
                                        totalPrice = totalPrice + int.parse(snackStockMap[e]['Price']);
                                      });
                                    }
                                }, icon: Icon(Icons.add)),
                                Text(itemQuantityMap[e].toString(),style: TextStyle(color: Colors.pinkAccent,fontWeight: FontWeight.bold),),
                                IconButton(onPressed: () {
                                  if(itemQuantityMap[e]>0)
                                    {
                                      setState(() {
                                        itemQuantityMap[e] = itemQuantityMap[e] - 1;
                                      });
                                      setState(() {
                                        totalPrice = totalPrice - int.parse(snackStockMap[e]['Price']);
                                      });
                                    }
                                  }, icon: Icon(Icons.remove)),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                }).toList(),
              )
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.pink.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Price : ${totalPrice.toString()}',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                    ],
                  ),
                  Divider(color: Colors.white,),
                  TextButton.icon(onPressed: () async {
                    SharedPreferences sp = await SharedPreferences.getInstance();
                    showAlertDialog(context, 'Order Completed', Text('Thanks for your purchasing from us!'), []);
                    itemQuantityMap.keys.forEach((element) async{
                      int remainingStock = snackStockMap[element]['Stock'] - itemQuantityMap[element];
                      await FirebaseFirestore.instance.collection('SnackStock').doc(element).update(
                          {
                            'Stock':remainingStock,
                          }
                      );
                    });
                    await FirebaseFirestore.instance.collection('Orders').doc(DateTime.now().toString()+sp.getString('Username').toString()).set({
                      'Phone': sp.getString('Phone'),
                      'Username': sp.getString('Username'),
                      'DateTime':DateTime.now(),
                      'OrderedItems':itemQuantityMap,
                      'TotalPrice':totalPrice.toString(),
                      'Status':'Pending',
                    });
                    sp.remove('Cart');
                    sendNoti('New Order!', 'New Order!');
                    pushReplacement(context, HomePage());
                  }, icon: Icon(Icons.attach_money,color: Colors.white,),
                      label: Text('Order Now',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),)),

                ],
              )
            ),
          ],
        )
      ),
    );
  }
}
