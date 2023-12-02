// trans_cards.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TransCards extends StatefulWidget {
  final List<dynamic>? dailyTransList;

  const TransCards({Key? key, required this.dailyTransList}) : super(key: key);

  @override
  State<TransCards> createState() => _TransCardsState();
}

class _TransCardsState extends State<TransCards> {
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.dailyTransList?.map((item) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xffD9ECFF),
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item['desc'] ?? '',
                          style: const TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff303030),
                          ),
                        ),
                        Text(
                          item['price']?.toString() ?? '',
                          style: const TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff303030),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item['date'] ?? '',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xff303030),
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                // Handle delete action
                                deleteDocumentById(item['id']);
                              },
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                // Handle edit action
                                _showEditDialog(context,item['id']);
                              },
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.green,
                              ),
                            )
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList() ?? [],
    );
  }

  Future<void> deleteDocumentById(String identifier) async {

      // Reference to the collection
      CollectionReference collectionReference = FirebaseFirestore.instance.collection('transactions');

      // Query for the document with the specified identifier
      QuerySnapshot querySnapshot = await collectionReference.where('id', isEqualTo: identifier).get();

      // Check if any documents match the query
      if (querySnapshot.docs.isNotEmpty) {
        // Delete the first matching document (assuming identifier is unique)
        DocumentReference documentReference = querySnapshot.docs.first.reference;
        await documentReference.delete();
      }

  }


  Future<void> updateDocumentById(String identifier, String updatedData) async {
    try {
      // Reference to the collection
      CollectionReference collectionReference = FirebaseFirestore.instance.collection('transactions');

      // Query for the document with the specified identifier
      QuerySnapshot querySnapshot = await collectionReference.where('id', isEqualTo: identifier).get();

      // Check if any documents match the query
      if (querySnapshot.docs.isNotEmpty) {
        // Delete the first matching document (assuming identifier is unique)
        DocumentReference documentReference = querySnapshot.docs.first.reference;
        await documentReference.update({"desc": updatedData});
      } else {
      }
    } catch (e) {
    }
  }

  void _showEditDialog(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // The content of the dialog
        return AlertDialog(
          title: const Text('Edit Description'),
          content: IntrinsicHeight(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: Column(
                children: [
                  // Input field for the description
                  TextField(
                    controller: _descriptionController, // Set the controller
                    decoration: const InputDecoration(labelText: 'New Description'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            // Cancel button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            // Confirm button
            ElevatedButton(
              onPressed: () {
                // Get the value from the text field using the controller
                String newDescription = _descriptionController.text;

                updateDocumentById(docId, newDescription);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }


}
