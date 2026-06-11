import 'package:flutter/material.dart';
import 'package:smart_space/core/services/api_service.dart';

class VendorsScreen extends StatefulWidget {
  const VendorsScreen({super.key});

  @override
  State<VendorsScreen> createState() => _VendorsScreenState();
}

class _VendorsScreenState extends State<VendorsScreen> {
  bool isLoading = true;

  List vendors = [];

  @override
  void initState() {
    super.initState();
    _loadVendors();
  }

  Future<void> _loadVendors() async {
    final response = await ApiService.getVendors();

    if (response["statusCode"] == 200) {
      setState(() {
        vendors = response["data"]["vendors"];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> _showAddVendorDialog() async {
    final nameController = TextEditingController();
    final websiteController = TextEditingController();

    String selectedStatus = "Connected";

    final shouldCreate = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Add Vendor"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Vendor Name",
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: websiteController,
                      decoration: const InputDecoration(
                        labelText: "Website",
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: const InputDecoration(
                        labelText: "Status",
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: "Connected",
                          child: Text("Connected"),
                        ),
                        DropdownMenuItem(
                          value: "Pending",
                          child: Text("Pending"),
                        ),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          selectedStatus = value ?? "Connected";
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Add"),
                ),
              ],
            );
          },
        );
      },
    );

    if (shouldCreate == true) {
      final response = await ApiService.createVendor(
        name: nameController.text.trim(),
        status: selectedStatus,
        website: websiteController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response["data"]["message"] ?? "Vendor added",
          ),
        ),
      );

      _loadVendors();
    }
  }

  Future<void> _editVendor(Map vendor) async {
    final nameController = TextEditingController(
      text: vendor["name"],
    );

    final websiteController = TextEditingController(
      text: vendor["website"] ?? "",
    );

    String selectedStatus = vendor["status"] ?? "Connected";

    final shouldUpdate = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Edit Vendor"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Vendor Name",
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: websiteController,
                      decoration: const InputDecoration(
                        labelText: "Website",
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: const InputDecoration(
                        labelText: "Status",
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: "Connected",
                          child: Text("Connected"),
                        ),
                        DropdownMenuItem(
                          value: "Pending",
                          child: Text("Pending"),
                        ),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          selectedStatus = value ?? "Connected";
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Update"),
                ),
              ],
            );
          },
        );
      },
    );

    if (shouldUpdate == true) {
      final response = await ApiService.updateVendor(
        vendorId: vendor["id"],
        name: nameController.text.trim(),
        status: selectedStatus,
        website: websiteController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response["data"]["message"] ?? "Vendor updated",
          ),
        ),
      );

      _loadVendors();
    }
  }

  Future<void> _deleteVendor(String vendorId) async {
    final response = await ApiService.deleteVendor(
      vendorId: vendorId,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          response["data"]["message"] ?? "Vendor deleted",
        ),
      ),
    );

    _loadVendors();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        title: const Text("Vendors"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        onPressed: _showAddVendorDialog,
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: _loadVendors,
        child: isLoading
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 250),
                  Center(child: CircularProgressIndicator()),
                ],
              )
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                children: [
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF4F46E5),
                          Color(0xFF6366F1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.store,
                          color: Colors.white,
                          size: 38,
                        ),
                        SizedBox(height: 15),
                        Text(
                          "Connected Vendors",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Manage ecommerce and furniture vendors.",
                          style: TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  if (vendors.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 60),
                        child: Text(
                          "No vendors available",
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ...vendors.map((vendor) {
                    final isConnected = vendor["status"] == "Connected";

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: Colors.grey.shade200,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                height: 58,
                                width: 58,
                                decoration: BoxDecoration(
                                  color: Colors.indigo.shade50,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.store,
                                  color: Colors.indigo,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      vendor["name"] ?? "",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      "${vendor["productCount"]} products",
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      vendor["website"] ?? "",
                                      style: const TextStyle(
                                        color: Colors.indigo,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isConnected
                                      ? Colors.green.shade50
                                      : Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  vendor["status"] ?? "",
                                  style: TextStyle(
                                    color: isConnected
                                        ? Colors.green
                                        : Colors.orange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              const Spacer(),
                              TextButton.icon(
                                onPressed: () {
                                  _editVendor(vendor);
                                },
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  color: Colors.indigo,
                                ),
                                label: const Text(
                                  "Edit",
                                  style: TextStyle(
                                    color: Colors.indigo,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              TextButton.icon(
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text(
                                        "Delete Vendor",
                                      ),
                                      content: const Text(
                                        "Delete this vendor?",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(
                                            context,
                                            false,
                                          ),
                                          child: const Text("Cancel"),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(
                                            context,
                                            true,
                                          ),
                                          child: const Text(
                                            "Delete",
                                            style: TextStyle(
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    _deleteVendor(
                                      vendor["id"],
                                    );
                                  }
                                },
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                label: const Text(
                                  "Delete",
                                  style: TextStyle(
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
      ),
    );
  }
}
