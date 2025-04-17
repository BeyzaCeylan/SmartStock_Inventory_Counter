import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ImportPage extends StatelessWidget {
  const ImportPage({super.key});

  Future<void> importProductsFromJson(BuildContext context) async {
    final String jsonString = await rootBundle.loadString('assets/products.json');
    final List<dynamic> products = jsonDecode(jsonString);

    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? "Anonim";

    for (var product in products) {
      await FirebaseFirestore.instance.collection('stocks').add({
        'productName': product['productName'],
        'quantity': product['quantity'],
        'previousQty': product['quantity'],
        'change': 0,
        'changeType': 'no_change',
        'userName': userName,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Ürünler başarıyla yüklendi')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ürün Yükleyici'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () => importProductsFromJson(context),
          icon: const Icon(Icons.cloud_upload),
          label: const Text("Ürünleri JSON'dan Yükle"),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            backgroundColor: Colors.orange,
            textStyle: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
