import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryService {
  final CollectionReference<Map<String, dynamic>> _collection =
  FirebaseFirestore.instance.collection('stockItems');

  Future<void> addStockItem({
    required String sku,
    required String itemName,
    required String category,
    required int quantity,
    required double unitPrice,
    required int reorderLevel,
  }) async {
    await _collection.add({
      'sku': sku,
      'itemName': itemName,
      'category': category,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'reorderLevel': reorderLevel,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchStockItems() {
    return _collection.snapshots();
  }
}