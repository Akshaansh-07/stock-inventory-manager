import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'inventory_service.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final InventoryService _inventory = InventoryService();

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  late final Stream<QuerySnapshot<Map<String, dynamic>>> _stockStream;

  String _activeSearch = '';
  String _categoryFilter = 'All Categories';
  String _stockFilter = 'All Stock';
  String _quantitySort = 'None';

  final List<String> _categories = [
    'All Categories',
    'Electronics',
    'Stationery',
    'Hardware',
    'Grocery',
  ];

  @override
  void initState() {
    super.initState();
    _stockStream = _inventory.watchStockItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _applySearch() {
    setState(() {
      _activeSearch = _searchController.text.trim().toLowerCase();
    });

    _searchFocus.unfocus();
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _activeSearch = '';
      _categoryFilter = 'All Categories';
      _stockFilter = 'All Stock';
      _quantitySort = 'None';
    });

    _searchFocus.unfocus();
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _filterStock(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> documents,
      ) {
    final filtered = documents.where((document) {
      final data = document.data();

      final sku = (data['sku'] ?? '').toString().toLowerCase();
      final name = (data['itemName'] ?? '').toString().toLowerCase();
      final category = (data['category'] ?? '').toString();

      final quantity = (data['quantity'] as num?)?.toInt() ?? 0;
      final reorderLevel =
          (data['reorderLevel'] as num?)?.toInt() ?? 0;

      // Search by partial SKU or item name.
      final matchesSearch = _activeSearch.isEmpty ||
          sku.contains(_activeSearch) ||
          name.contains(_activeSearch);

      // Category filter.
      final matchesCategory = _categoryFilter == 'All Categories' ||
          category == _categoryFilter;

      // Low-stock filter.
      final matchesStock = _stockFilter == 'All Stock' ||
          (_stockFilter == 'Low Stock' && quantity <= reorderLevel);

      // All selected filters must match.
      return matchesSearch && matchesCategory && matchesStock;
    }).toList();

    if (_quantitySort == 'Ascending') {
      filtered.sort((a, b) {
        final first = (a.data()['quantity'] as num?)?.toInt() ?? 0;
        final second = (b.data()['quantity'] as num?)?.toInt() ?? 0;
        return first.compareTo(second);
      });
    } else if (_quantitySort == 'Descending') {
      filtered.sort((a, b) {
        final first = (a.data()['quantity'] as num?)?.toInt() ?? 0;
        final second = (b.data()['quantity'] as num?)?.toInt() ?? 0;
        return second.compareTo(first);
      });
    }

    return filtered;
  }

  Widget _filterDropdown({
    required String label,
    required String selectedValue,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: selectedValue,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
      items: options.map((option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(
            option,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildSearchBox() {
    return TextField(
      controller: _searchController,
      focusNode: _searchFocus,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => _applySearch(),
      decoration: InputDecoration(
        hintText: 'Search SKU or item name',
        prefixIcon: const Icon(
          Icons.search,
          color: Color(0xFF2A9D8F),
        ),
        suffixIcon: IconButton(
          tooltip: 'Search',
          onPressed: _applySearch,
          icon: const Icon(Icons.arrow_forward),
        ),
      ),
    );
  }

  Widget _buildStockCard(
      QueryDocumentSnapshot<Map<String, dynamic>> document,
      ) {
    final data = document.data();

    final sku = (data['sku'] ?? '').toString();
    final name = (data['itemName'] ?? '').toString();
    final category = (data['category'] ?? '').toString();

    final quantity = (data['quantity'] as num?)?.toInt() ?? 0;
    final reorderLevel =
        (data['reorderLevel'] as num?)?.toInt() ?? 0;

    final price = (data['unitPrice'] as num?)?.toDouble() ?? 0.0;

    final isLowStock = quantity <= reorderLevel;

    return Card(
      margin: const EdgeInsets.only(bottom: 13),
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE5EBED)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5F4F1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    color: Color(0xFF2A9D8F),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: Color(0xFF183B4E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        sku,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isLowStock
                        ? const Color(0xFFFFE9E5)
                        : const Color(0xFFE5F4F1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isLowStock ? 'Low Stock' : 'In Stock',
                    style: TextStyle(
                      color: isLowStock
                          ? const Color(0xFFB54735)
                          : const Color(0xFF237A6D),
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 25),
            Wrap(
              spacing: 20,
              runSpacing: 12,
              children: [
                _detail('Category', category),
                _detail('Quantity', quantity.toString()),
                _detail('Unit Price', 'RM ${price.toStringAsFixed(2)}'),
                _detail('Reorder Level', reorderLevel.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detail(String label, String value) {
    return SizedBox(
      width: 125,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF183B4E),
              fontWeight: FontWeight.w600,
            ),
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
          'Inventory Records',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _stockStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text('Unable to retrieve inventory records.'),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF2A9D8F),
                ),
              );
            }

            final documents = snapshot.data?.docs ?? [];
            final results = _filterStock(documents);

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Find Stock Items',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF183B4E),
                        ),
                      ),
                      const SizedBox(height: 12),

                      _buildSearchBox(),
                      const SizedBox(height: 13),

                      Row(
                        children: [
                          Expanded(
                            child: _filterDropdown(
                              label: 'Category',
                              selectedValue: _categoryFilter,
                              options: _categories,
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() {
                                  _categoryFilter = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _filterDropdown(
                              label: 'Stock Level',
                              selectedValue: _stockFilter,
                              options: const [
                                'All Stock',
                                'Low Stock',
                              ],
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() {
                                  _stockFilter = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: _filterDropdown(
                              label: 'Sort by Quantity',
                              selectedValue: _quantitySort,
                              options: const [
                                'None',
                                'Ascending',
                                'Descending',
                              ],
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() {
                                  _quantitySort = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          OutlinedButton.icon(
                            onPressed: _resetFilters,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Clear Filters'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF183B4E),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Text(
                        '${results.length} inventory item(s) found',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: results.isEmpty
                      ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 55,
                          color: Colors.black26,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No matching stock items found.',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 5, 16, 20),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      return _buildStockCard(results[index]);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}