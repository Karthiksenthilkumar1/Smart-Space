import 'package:flutter/material.dart';
import 'package:smart_space/core/services/api_service.dart';

class ProductSyncScreen extends StatefulWidget {
  const ProductSyncScreen({super.key});

  @override
  State<ProductSyncScreen> createState() =>
      _ProductSyncScreenState();
}

class _ProductSyncScreenState
    extends State<ProductSyncScreen> {
  bool isLoading = true;

  List syncs = [];
  List vendors = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final syncResponse =
        await ApiService.getProductSyncs();

    final vendorResponse =
        await ApiService.getVendors();

    if (syncResponse["statusCode"] == 200 &&
        vendorResponse["statusCode"] == 200) {
      setState(() {
        syncs = syncResponse["data"]["syncs"];
        vendors = vendorResponse["data"]["vendors"];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> _showSyncDialog() async {
    if (vendors.isEmpty) return;

    String selectedVendorId =
        vendors.first["id"];

    final shouldSync = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Start Product Sync"),
              content: DropdownButtonFormField<String>(
                value: selectedVendorId,
                decoration: const InputDecoration(
                  labelText: "Select Vendor",
                ),
                items: vendors.map((vendor) {
                  return DropdownMenuItem<String>(
                    value: vendor["id"],
                    child: Text(vendor["name"]),
                  );
                }).toList(),
                onChanged: (value) {
                  setDialogState(() {
                    selectedVendorId =
                        value ?? selectedVendorId;
                  });
                },
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(context, false),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.pop(context, true),
                  child: const Text("Sync"),
                ),
              ],
            );
          },
        );
      },
    );

    if (shouldSync == true) {
      final response =
          await ApiService.createProductSync(
        vendorId: selectedVendorId,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response["data"]["message"] ??
                "Sync completed",
          ),
        ),
      );

      _loadData();
    }
  }

  Future<void> _deleteSync(String syncId) async {
    final response =
        await ApiService.deleteProductSync(
      syncId: syncId,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          response["data"]["message"] ??
              "Sync deleted",
        ),
      ),
    );

    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        title: const Text("Product Sync"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        onPressed: _showSyncDialog,
        child: const Icon(Icons.sync),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
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
                    borderRadius:
                        BorderRadius.circular(24),
                  ),
                  child: const Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.sync,
                        color: Colors.white,
                        size: 38,
                      ),
                      SizedBox(height: 15),
                      Text(
                        "Vendor Product Sync",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Sync and refresh products from connected vendors.",
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                const Text(
                  "Sync History",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 18),

                if (syncs.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 60),
                      child: Text(
                        "No sync history found",
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),

                ...syncs.map((sync) {
                  final isCompleted =
                      sync["status"] == "Completed";

                  return Container(
                    margin:
                        const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(22),
                      border: Border.all(
                        color: Colors.grey.shade200,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              Colors.black.withOpacity(0.03),
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
                                color:
                                    Colors.indigo.shade50,
                                borderRadius:
                                    BorderRadius.circular(
                                        16),
                              ),
                              child: Icon(
                                isCompleted
                                    ? Icons.check_circle
                                    : Icons.pending,
                                color: isCompleted
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),

                            const SizedBox(width: 16),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    sync["vendorName"] ??
                                        "",
                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                      fontSize: 17,
                                    ),
                                  ),

                                  const SizedBox(height: 5),

                                  Text(
                                    "${sync["productsSynced"]} products synced",
                                    style: const TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),

                                  const SizedBox(height: 5),

                                  Text(
                                    sync["startedAt"] ??
                                        "",
                                    style: const TextStyle(
                                      color: Colors.indigo,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isCompleted
                                    ? Colors.green.shade50
                                    : Colors.orange.shade50,
                                borderRadius:
                                    BorderRadius.circular(
                                        20),
                              ),
                              child: Text(
                                sync["status"] ?? "",
                                style: TextStyle(
                                  color: isCompleted
                                      ? Colors.green
                                      : Colors.orange,
                                  fontWeight:
                                      FontWeight.bold,
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
                              onPressed: () async {
                                final confirm =
                                    await showDialog<bool>(
                                  context: context,
                                  builder: (context) =>
                                      AlertDialog(
                                    title: const Text(
                                      "Delete Sync",
                                    ),
                                    content: const Text(
                                      "Delete this sync history?",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(
                                          context,
                                          false,
                                        ),
                                        child: const Text(
                                            "Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(
                                          context,
                                          true,
                                        ),
                                        child: const Text(
                                          "Delete",
                                          style: TextStyle(
                                            color:
                                                Colors.red,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  _deleteSync(sync["id"]);
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
    );
  }
}