import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class StockPage extends StatelessWidget {
  const StockPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stok Listesi"),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('stocks')
            .orderBy('updatedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final name = data['productName'];
              final quantity = data['quantity'];
              final change = data['change'];
              final changeType = data['changeType'];
              final updatedAt = DateTime.tryParse(data['updatedAt'] ?? '');
              final formattedDate = updatedAt != null
                  ? DateFormat("dd.MM.yyyy HH:mm").format(updatedAt)
                  : 'N/A';

              IconData icon;
              Color color;
              String statusText;

              if (changeType == 'increase') {
                icon = Icons.arrow_upward;
                color = Colors.green;
                statusText = '+$change eklendi';
              } else if (changeType == 'decrease') {
                icon = Icons.arrow_downward;
                color = Colors.red;
                statusText = '-${change.abs()} azaldı';
              } else {
                icon = Icons.remove;
                color = Colors.grey;
                statusText = 'Stok değişmedi';
              }

              final controller =
                  TextEditingController(text: '1'); // varsayılan giriş

              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Icon(icon, color: color),
                  title: Text("$name — $quantity adet",
                      style: const TextStyle(fontSize: 18)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("$statusText\nGüncelleme: $formattedDate"),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              final input =
                                  int.tryParse(controller.text.trim());
                              if (input != null && input > 0) {
                                _updateQuantity(
                                    context, doc.id, quantity - input);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            child: const Icon(Icons.remove),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 60,
                            height: 40,
                            child: TextField(
                              controller: controller,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              final input =
                                  int.tryParse(controller.text.trim());
                              if (input != null && input > 0) {
                                _updateQuantity(
                                    context, doc.id, quantity + input);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green),
                            child: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _updateQuantity(
      BuildContext context, String docId, int newQuantity) async {
    if (newQuantity < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Stok sıfırın altına inemez ❌")),
      );
      return;
    }

    final docRef = FirebaseFirestore.instance.collection('stocks').doc(docId);
    final snapshot = await docRef.get();
    if (!snapshot.exists) return;

    final data = snapshot.data()!;
    final oldQuantity = data['quantity'];
    final difference = newQuantity - oldQuantity;

    String changeType = "no_change";
    if (difference > 0) changeType = "increase";
    else if (difference < 0) changeType = "decrease";

    await docRef.update({
      'quantity': newQuantity,
      'previousQty': oldQuantity,
      'change': difference,
      'changeType': changeType,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }
}

