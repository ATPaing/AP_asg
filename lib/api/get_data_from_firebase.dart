import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseRetrieveData {
  final CollectionReference _dailyTransRef =
  FirebaseFirestore.instance.collection('transactions');

  Stream<List<dynamic>> streamDailyTransData() {
    return _dailyTransRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }
}
