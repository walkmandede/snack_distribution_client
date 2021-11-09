import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snack_distribution_client/cartPage.dart';
import 'package:snack_distribution_client/globals.dart';

class OrdersHistory extends StatefulWidget {

  @override
  _OrdersHistoryState createState() => _OrdersHistoryState();
}

class _OrdersHistoryState extends State<OrdersHistory> {

  Map snackStockMap = {};
  Map ordersMap = {};
  Map myOrdersMap = {};
  Map<String,List> myDailyOrdersMap  = {};
  String user = '';

  @override
  void initState() {
    getData();
    super.initState();
  }

  Future<void> getData() async
  {
    await Firebase.initializeApp();
    await getCollectionData('SnackStock', snackStockMap);
    SharedPreferences sp = await SharedPreferences.getInstance();
    setState(() {
      user = sp.getString('Phone')!;
    });
    await getCollectionData('Orders', ordersMap);
    ordersMap.keys.forEach((element) {
      if(ordersMap[element]['Phone']==user)
        {
          setState(() {
            myOrdersMap.addEntries(
                [
                  MapEntry(element, ordersMap[element])
                ]
            );
          });
        }
    });
    myOrdersMap.keys.forEach((element) {
      Timestamp ts = myOrdersMap[element]['DateTime'];
      String myOrderedDate = ts.toDate().toString().substring(0,10);
      List? dailyOrders = [];
      if(myDailyOrdersMap[myOrderedDate]==null)
        {
          dailyOrders.add(element);
        }
      else
        {
          dailyOrders = myDailyOrdersMap[myOrderedDate];
          dailyOrders?.add(element);
        }
      myDailyOrdersMap.addEntries(
        [
          MapEntry(myOrderedDate, dailyOrders!)
        ]
      );
    });
    print(myDailyOrdersMap);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('မှာယူခဲ့ပြီးသော မှတ်တမ်းများ'),
      ),
      body: Container(
        child: ListView(
          children:  myDailyOrdersMap.keys.map((tday)
          {
            return Container(
              margin: EdgeInsets.all(5),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.pinkAccent))
              ),
              child: Column(
                children: myOrdersMap.keys.map((e) {
                  Map itemList = myOrdersMap[e]['OrderedItems'];
                  Timestamp dt = myOrdersMap[e]['DateTime'];
                  return  dt.toDate().toString().substring(0,10)!=tday?Container():ListTile(
                    title: Text(dt.toDate().toString().substring(0,10)),
                    trailing: Text(myOrdersMap[e]['TotalPrice'].toString()+' Ks',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.pink),),
                    subtitle: Column(
                      children: itemList.keys.map((e2) {
                        return itemList[e2].toString()=='0'?Container():Container(
                            margin: EdgeInsets.all(5),
                            child: Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    color: Colors.pink.shade100
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(snackStockMap[e2]['Name'],style: TextStyle(color: Colors.black),),
                                    Text(itemList[e2].toString()+' cpn',style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold),),
                                  ],
                                )
                            )
                        );
                      }).toList(),
                    ),
                  );
                }).toList(),
              ),
            );
          }).toList()
        ),
      ),
    );
  }
}
