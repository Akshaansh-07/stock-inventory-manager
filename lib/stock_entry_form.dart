import 'package:flutter/material.dart';
import 'inventory_service.dart';
import 'inventory_screen.dart';

class StockEntryForm extends StatefulWidget {
  const StockEntryForm({super.key});

  @override
  State<StockEntryForm> createState() => _StockEntryFormState();
}

class _StockEntryFormState extends State<StockEntryForm> {
  final _formKey = GlobalKey<FormState>();
  final InventoryService _inventory = InventoryService();

  final TextEditingController _skuController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _reorderController = TextEditingController();

  String? _selectedCategory;
  bool _isSaving = false;

  final List<String> _categories = [
    'Electronics',
    'Stationery',
    'Hardware',
    'Grocery',
  ];

  @override
  void dispose() {
    _skuController.dispose();
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _reorderController.dispose();
    super.dispose();
  }

  String? _validateSku(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter an SKU';
    }

    if (!RegExp(r'^STK-\d{3}$').hasMatch(value.trim())) {
      return 'Use the format STK-101';
    }

    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().length < 3) {
      return 'Enter an item name with at least 3 characters';
    }

    return null;
  }

  String? _validateQuantity(String? value) {
    final quantity = int.tryParse(value ?? '');

    if (quantity == null || quantity < 0) {
      return 'Enter a valid whole number (0 or more)';
    }

    return null;
  }

  String? _validatePrice(String? value) {
    final price = double.tryParse(value ?? '');

    if (price == null || price <= 0) {
      return 'Enter a valid price greater than 0';
    }

    return null;
  }

  String? _validateReorderLevel(String? value) {
    final level = int.tryParse(value ?? '');

    if (level == null || level < 0) {
      return 'Enter a valid reorder level (0 or more)';
    }

    return null;
  }

  Future<void> _saveStockItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _inventory.addStockItem(
        sku: _skuController.text.trim().toUpperCase(),
        itemName: _nameController.text.trim(),
        category: _selectedCategory!,
        quantity: int.parse(_quantityController.text.trim()),
        unitPrice: double.parse(_priceController.text.trim()),
        reorderLevel: int.parse(_reorderController.text.trim()),
      );

      if (!mounted) return;

      _formKey.currentState!.reset();

      _skuController.clear();
      _nameController.clear();
      _quantityController.clear();
      _priceController.clear();
      _reorderController.clear();

      setState(() {
        _selectedCategory = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stock item saved successfully'),
          backgroundColor: Color(0xFF2A9D8F),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to save stock item: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF183B4E),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint ?? 'Enter $label',
            prefixIcon: Icon(icon, color: const Color(0xFF2A9D8F)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Stock Inventory Manager',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'View inventory',
            icon: const Icon(Icons.inventory_2_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const InventoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 650),
              child: Card(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.add_box_outlined,
                          color: Color(0xFF2A9D8F),
                          size: 38,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Add Stock Item',
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF183B4E),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Enter the details of the stock item below.',
                          style: TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 25),

                        _buildField(
                          label: 'SKU',
                          controller: _skuController,
                          validator: _validateSku,
                          icon: Icons.qr_code,
                          hint: 'Example: STK-101',
                        ),
                        const SizedBox(height: 18),

                        _buildField(
                          label: 'Item Name',
                          controller: _nameController,
                          validator: _validateName,
                          icon: Icons.inventory_2_outlined,
                        ),
                        const SizedBox(height: 18),

                        const Text(
                          'Category',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF183B4E),
                          ),
                        ),
                        const SizedBox(height: 8),

                        DropdownButtonFormField<String>(
                          initialValue: _selectedCategory,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(
                              Icons.category_outlined,
                              color: Color(0xFF2A9D8F),
                            ),
                            hintText: 'Select a category',
                          ),
                          items: _categories.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a category';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        _buildField(
                          label: 'Quantity',
                          controller: _quantityController,
                          validator: _validateQuantity,
                          icon: Icons.numbers,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 18),

                        _buildField(
                          label: 'Unit Price (RM)',
                          controller: _priceController,
                          validator: _validatePrice,
                          icon: Icons.payments_outlined,
                          keyboardType:
                          const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          hint: 'Example: 19.90',
                        ),
                        const SizedBox(height: 18),

                        _buildField(
                          label: 'Reorder Level',
                          controller: _reorderController,
                          validator: _validateReorderLevel,
                          icon: Icons.notifications_active_outlined,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 28),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: _isSaving ? null : _saveStockItem,
                            icon: _isSaving
                                ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : const Icon(Icons.save_outlined),
                            label: Text(
                              _isSaving ? 'Saving...' : 'Save Stock Item',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2A9D8F),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}