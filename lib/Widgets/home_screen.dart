import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_ap_asg/Widgets/trans_cards.dart';
import 'package:finance_ap_asg/api/get_data_from_firebase.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../api/authenticate.dart';
import '../main.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int? totalBalance = 0;

  var taskList = [];

  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    final FirebaseLogout firebaseAuthManager = FirebaseLogout();
    FirebaseRetrieveData firestoreDb = FirebaseRetrieveData();
    return Scaffold(
      body: Container(
        key: _scaffoldKey,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7556F1), Color(0xFF343789)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Container(
          margin: EdgeInsets.only(top: statusBarHeight, left: 10.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'images/logo.png',
                    width: 75,
                    height: 75,
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.exit_to_app,
                      color: Color(0xffD9ECFF),
                    ),
                    iconSize: 40.0,
                    splashRadius: 20.0,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Logout'),
                            content: const Text('Are you sure you want to log out?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await firebaseAuthManager.signOut();
                                  Navigator.popUntil(_scaffoldKey.currentContext!, (route) => route.isFirst);
                                  Navigator.pushReplacement(
                                    _scaffoldKey.currentContext!,
                                    MaterialPageRoute(builder: (context) => const MyHomePage()),
                                  );
                                },
                                child: const Text('Logout'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.only(left: 16.0, top: 10.0, right: 16.0, bottom: 10.0),
                decoration: BoxDecoration(
                  color: const Color(0xffD9ECFF),
                  borderRadius: BorderRadius.circular(5.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                // stream builder for total amount
                child: StreamBuilder<List<dynamic>>(
                  stream: firestoreDb.streamDailyTransData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      List<dynamic>? dailyTransList = snapshot.data;
                      taskList = dailyTransList!;
                      _updateTotalBalance(dailyTransList);
                      return Text(
                        'Total balance: $totalBalance',
                        style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: Color(0xff303030)),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 30),
              Container(
                width: 35.0,
                height: 35.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(
                    color: Colors.grey,
                    width: 2.0,
                  ),
                ),
                child: GestureDetector(
                  onTap: () {
                    // Add your logic here when the button is tapped
                    _showAddTransactionDialog();
                  },
                  child: const Center(
                    child: Icon(
                      Icons.add,
                      color: Colors.blue, // Set the icon color to your preference
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: SingleChildScrollView(
                  child: Center(
                    // stream builder for record card
                    child: StreamBuilder<List<dynamic>>(
                      stream: firestoreDb.streamDailyTransData(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          List<dynamic>? dailyTransList = snapshot.data;
                          return TransCards(
                            dailyTransList: dailyTransList,
                          );
                        }
                      },
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateTotalBalance(List<dynamic>? dailyTransList) async {
    int? tempTotalBalance = 0;

    for (int i = 0; i < dailyTransList!.length; i++) {
      var price = dailyTransList[i]['price'];
      tempTotalBalance = (tempTotalBalance! + (price as int));
    }

    setState(() {
      totalBalance = tempTotalBalance;
    });
  }

  void _showAddTransactionDialog() {
    TextEditingController descController = TextEditingController();
    TextEditingController priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Transaction'),
          content: IntrinsicHeight(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: Column(
                children: [
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Price'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Validate and process the data
                String description = descController.text.trim();
                String priceText = priceController.text.trim();

                if (description.isNotEmpty && priceText.isNotEmpty) {
                  // Convert price to int or double based on your data type
                  int price = int.parse(priceText);

                  // Get the current date
                  String date = DateFormat('yyyy-MM-dd').format(DateTime.now());
                  int id = taskList.length + 1;
                  final data = {
                    "desc": description,
                    "price": price,
                    "date": date,
                    "id": "$id"
                  };
                  var db = FirebaseFirestore.instance;
                  db.collection("transactions").add(data);
                  // Process the data or call a function to add the transaction

                  // Close the dialog
                  Navigator.of(context).pop();
                } else {
                  // Show an error message or handle invalid input
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
