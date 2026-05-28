import 'package:flutter/material.dart';
import 'package:smart_space/core/services/api_service.dart';

class RecommendationRulesScreen extends StatefulWidget {
  const RecommendationRulesScreen({super.key});

  @override
  State<RecommendationRulesScreen> createState() =>
      _RecommendationRulesScreenState();
}

class _RecommendationRulesScreenState
    extends State<RecommendationRulesScreen> {
  bool isLoading = true;
  List rules = [];

  @override
  void initState() {
    super.initState();
    _loadRules();
  }

  Future<void> _loadRules() async {
    final response = await ApiService.getRecommendationRules();

    if (response["statusCode"] == 200) {
      setState(() {
        rules = response["data"]["rules"];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> _showCreateRuleDialog() async {
    final roomController = TextEditingController();
    final categoryController = TextEditingController();
    final priorityController = TextEditingController(text: "1");

    final shouldCreate = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Create Rule"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: roomController,
                decoration: const InputDecoration(
                  labelText: "Room Type",
                  hintText: "e.g. Kitchen",
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: "Category",
                  hintText: "e.g. storage",
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priorityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Priority",
                  hintText: "1 to 5",
                ),
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
            child: const Text("Create"),
          ),
        ],
      ),
    );

    if (shouldCreate == true) {
      final response = await ApiService.createRecommendationRule(
        roomType: roomController.text.trim(),
        category: categoryController.text.trim(),
        priority: int.tryParse(priorityController.text.trim()) ?? 1,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response["data"]["message"] ?? "Rule created",
          ),
        ),
      );

      _loadRules();
    }
  }

  Future<void> _editRule(Map rule) async {
    final roomController = TextEditingController(
      text: rule["roomType"],
    );

    final categoryController = TextEditingController(
      text: rule["category"],
    );

    final priorityController = TextEditingController(
      text: rule["priority"].toString(),
    );

    bool isActive = rule["isActive"] == true;

    final shouldUpdate = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Edit Rule"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: roomController,
                      decoration: const InputDecoration(
                        labelText: "Room Type",
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: categoryController,
                      decoration: const InputDecoration(
                        labelText: "Category",
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: priorityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Priority",
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      value: isActive,
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Rule Active"),
                      onChanged: (value) {
                        setDialogState(() {
                          isActive = value;
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
      final response =
          await ApiService.updateRecommendationRule(
        ruleId: rule["id"],
        roomType: roomController.text.trim(),
        category: categoryController.text.trim(),
        priority:
            int.tryParse(priorityController.text.trim()) ?? 1,
        isActive: isActive,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response["data"]["message"] ?? "Rule updated",
          ),
        ),
      );

      _loadRules();
    }
  }

  Future<void> _deleteRule(String ruleId) async {
    final response = await ApiService.deleteRecommendationRule(
      ruleId: ruleId,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          response["data"]["message"] ?? "Rule deleted",
        ),
      ),
    );

    _loadRules();
  }

  Future<void> _confirmDeleteRule(String ruleId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Rule"),
        content: const Text(
          "Are you sure you want to delete this rule?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _deleteRule(ruleId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        title: const Text("Recommendation Rules"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                ElevatedButton.icon(
                  onPressed: _showCreateRuleDialog,
                  icon: const Icon(Icons.add),
                  label: const Text("Create Rule"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    padding:
                        const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                if (rules.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Text(
                        "No recommendation rules found",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),

                ...rules.map((rule) {
                  final isActive = rule["isActive"] == true;

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
                          color:
                              Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 48,
                              width: 48,
                              decoration: BoxDecoration(
                                color: Colors.indigo.shade50,
                                borderRadius:
                                    BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.rule,
                                color: Colors.indigo,
                              ),
                            ),

                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    rule["roomType"],
                                    style: const TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Category: ${rule["category"]}",
                                    style: TextStyle(
                                      color:
                                          Colors.grey.shade600,
                                      fontSize: 13,
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
                                color: isActive
                                    ? Colors.green.shade50
                                    : Colors.orange.shade50,
                                borderRadius:
                                    BorderRadius.circular(30),
                              ),
                              child: Text(
                                isActive
                                    ? "Active"
                                    : "Inactive",
                                style: TextStyle(
                                  color: isActive
                                      ? Colors.green.shade700
                                      : Colors.orange.shade700,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius:
                                BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.auto_awesome,
                                color: Colors.indigo,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "Priority ${rule["priority"]} recommendation boost for ${rule["category"]} products.",
                                  style: TextStyle(
                                    color:
                                        Colors.grey.shade700,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  _editRule(rule);
                                },
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  size: 18,
                                ),
                                label: const Text("Edit"),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.indigo,
                                  side: BorderSide(
                                    color:
                                        Colors.indigo.shade100,
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(
                                    vertical: 13,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  _confirmDeleteRule(rule["id"]);
                                },
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 18,
                                ),
                                label: const Text("Delete"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color(0xFFFFF1F1),
                                  foregroundColor:
                                      Colors.red.shade700,
                                  elevation: 0,
                                  padding:
                                      const EdgeInsets.symmetric(
                                    vertical: 13,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(14),
                                  ),
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