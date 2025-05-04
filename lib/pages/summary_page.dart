import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/object_detection_service.dart';

class SummaryPage extends StatefulWidget {
  final Map<String, int> totalCounts;
  final String userName;

  const SummaryPage({Key? key, required this.totalCounts, required this.userName}) : super(key: key);

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  late Map<String, int> totalCounts;
  late String userName;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    totalCounts = widget.totalCounts;
    userName = widget.userName;
  }

  Future<void> _updateStock(BuildContext context) async {
  final firestore = FirebaseFirestore.instance;

  try {
    final snapshot = await firestore.collection('stocks').get();
    final docs = snapshot.docs;

    // 🔥 Burada kullanıcı adını her zaman canlı çekiyoruz
    final user = FirebaseAuth.instance.currentUser;
    final userDoc = await firestore.collection('users').doc(user!.uid).get();
    final freshUserName = userDoc['name'] ?? 'Anonim';

    for (var product in totalCounts.keys) {
      QueryDocumentSnapshot<Map<String, dynamic>>? matchingDoc;

      try {
        matchingDoc = docs.firstWhere(
          (doc) => doc['productName'] == product,
        );
      } catch (e) {
        matchingDoc = null;
      }

      if (matchingDoc != null) {
        final docRef = firestore.collection('stocks').doc(matchingDoc.id);
        final previousQty = matchingDoc['quantity'] ?? 0;
        final newQty = totalCounts[product] ?? 0;
        final change = newQty - previousQty;
        String changeType = 'no_change';
        if (change > 0) {
          changeType = 'increase';
        } else if (change < 0) changeType = 'decrease';

        await docRef.update({
          'quantity': newQty,
          'previousQty': previousQty,
          'change': change,
          'changeType': changeType,
          'updatedAt': DateTime.now().toIso8601String(),
          'userName': freshUserName, // 🔥 Değiştirilen kısım burası
        });
      } else {
        print('Firestore\'da \"$product\" adli urun bulunamadi.');
      }
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Stocks Updated Successfully!'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
          duration: Duration(seconds: 2),
        ),
      );
    }

  } catch (e) {
    print('Failure: $e');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Güncelleme hatası: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}


  void _showUpdatePopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stock Update'),
        content: const Text('Do you want to enhance existing stock records with identified products?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            },
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _updateStock(context);
            },
            child: const Text('Güncelle'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Summary Page',
          style: TextStyle(
            fontFamily: 'Kanit',
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Total Detected Products:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Modern kart tasarımı ile ürün listesi
            ...totalCounts.entries.map((entry) => Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: ListTile(
                leading: const Icon(Icons.shopping_basket, color: Colors.green, size: 28),
                title: Text(
                  entry.key,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green, width: 1),
                  ),
                  child: Text(
                    '${entry.value} pcs',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            )),
            const SizedBox(height: 24),
            Center(
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HomePage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shadowColor: Colors.redAccent,
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _showUpdatePopup(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shadowColor: Colors.greenAccent,
                      ),
                      child: const Text(
                        'Update Stocks',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}