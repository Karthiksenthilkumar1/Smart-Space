import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:smart_space/core/services/api_service.dart';

class EditProductScreen extends StatefulWidget {
  final Map product;

  const EditProductScreen({
    super.key,
    required this.product,
  });

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController dimensionsController;
  late TextEditingController categoryController;
  late TextEditingController priceController;
  late TextEditingController imageUrlController;
  String? selectedImagePath;
  bool isSaving = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    final image = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      setState(() {
        selectedImagePath = image.path;
      });
    }
  }
  @override
  void initState() {
    super.initState();

    nameController =
        TextEditingController(text: widget.product["name"]);

    descriptionController =
        TextEditingController(text: widget.product["description"]);

    dimensionsController =
        TextEditingController(text: widget.product["dimensions"]);

    categoryController =
        TextEditingController(text: widget.product["category"]);

    priceController =
        TextEditingController(
      text: widget.product["price"].toString(),
    );

    imageUrlController =
        TextEditingController(text: widget.product["imageUrl"]);
  }

  Future<void> _updateProduct() async {
    setState(() => isSaving = true);

    final response = await ApiService.updateProduct(
      productId: widget.product["id"],
      name: nameController.text.trim(),
      description: descriptionController.text.trim(),
      dimensions: dimensionsController.text.trim(),
      category: categoryController.text.trim(),
      price: double.tryParse(priceController.text.trim()) ?? 0,
      imageUrl: imageUrlController.text.trim(),
      imagePath: selectedImagePath,
    );

    setState(() => isSaving = false);

    if (response["statusCode"] == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Product updated successfully"),
        ),
      );

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response["data"]["message"] ?? "Failed to update product",
          ),
        ),
      );
    }
  }

  Widget _field(
    String label,
    TextEditingController controller,
  ) {
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
        title: const Text("Edit Product"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 180,
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: selectedImagePath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.file(
                        File(selectedImagePath!),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    )
                  : imageUrlController.text.trim().startsWith("http")
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.network(
                            imageUrlController.text.trim(),
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        )
                      : const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image, size: 42, color: Colors.indigo),
                              SizedBox(height: 8),
                              Text("Tap to change product image"),
                            ],
                          ),
                        ),
            ),
          ),
          _field("Product Name", nameController),
          _field("Description", descriptionController),
          _field("Dimensions", dimensionsController),
          _field("Category", categoryController),
          _field("Price", priceController),
          _field("Image URL", imageUrlController),

          const SizedBox(height: 10),

          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: isSaving ? null : _updateProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
              ),
              child: isSaving
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : const Text("UPDATE PRODUCT"),
            ),
          ),
        ],
      ),
    );
  }
}