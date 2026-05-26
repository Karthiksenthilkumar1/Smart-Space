import 'package:flutter/material.dart';
import 'package:smart_space/core/services/api_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final dimensionsController = TextEditingController();
  final categoryController = TextEditingController();
  final priceController = TextEditingController();
  final imageUrlController = TextEditingController();

  bool isSaving = false;

  Future<void> _saveProduct() async {
    setState(() => isSaving = true);

    final response = await ApiService.createProduct(
      name: nameController.text.trim(),
      description: descriptionController.text.trim(),
      dimensions: dimensionsController.text.trim(),
      category: categoryController.text.trim(),
      price: double.tryParse(priceController.text.trim()) ?? 0,
      imageUrl: imageUrlController.text.trim(),
    );

    setState(() => isSaving = false);

    if (response["statusCode"] == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product added successfully")),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response["data"]["message"] ?? "Failed to add product",
          ),
        ),
      );
    }
  }

  Widget _field(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        title: const Text("Add Product"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _field("Product Name", nameController),
          _field("Description", descriptionController),
          _field("Dimensions e.g. 110 x 55 x 75 cm", dimensionsController),
          _field("Category e.g. furniture", categoryController),
          _field("Price", priceController),
          _field("Image URL", imageUrlController),

          const SizedBox(height: 10),

          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: isSaving ? null : _saveProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
              ),
              child: isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("ADD PRODUCT"),
            ),
          ),
        ],
      ),
    );
  }
}