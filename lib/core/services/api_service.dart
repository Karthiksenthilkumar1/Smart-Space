import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String emulatorUrl = "http://10.0.2.2:8000";

  static const String localNetworkUrl =
      "http://172.30.4.83:8000";

  static String baseUrl = localNetworkUrl;
  static String? authToken;

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/api/auth/login");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      authToken = data["token"];
    }

    return {
      "statusCode": response.statusCode,
      "data": data,
    };
  }

  static Future<void> saveFcmToken(
    String fcmToken,
  ) async {
    final url =
        Uri.parse(
      "$baseUrl/api/auth/fcm-token",
    );

    await http.put(
      url,
      headers: {
        "Content-Type":
            "application/json",
        "Authorization":
            "Bearer $authToken",
      },
      body: jsonEncode({
        "fcmToken": fcmToken,
      }),
    );
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final url = Uri.parse("$baseUrl/api/auth/register");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
        "role": role,
      }),
    );

    final data = jsonDecode(response.body);

    return {
      "statusCode": response.statusCode,
      "data": data,
    };
  }

  static Future<Map<String, dynamic>> saveScan({
    required double width,
    required double height,
    required double depth,
    required double area,
    required String roomType,
    String? imagePath,
  }) async {
    final url = Uri.parse("$baseUrl/api/scans");

    final request = http.MultipartRequest("POST", url);

    request.headers["Authorization"] =
        "Bearer $authToken";

    request.fields["width"] =
        width.toString();

    request.fields["height"] =
        height.toString();

    request.fields["depth"] =
        depth.toString();

    request.fields["area"] =
        area.toString();

    request.fields["roomType"] =
        roomType;

    if (imagePath != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          "image",
          imagePath,
        ),
      );
    }

    final streamedResponse =
        await request.send();

    final response =
        await http.Response.fromStream(
      streamedResponse,
    );

    final data =
        jsonDecode(response.body);

    return {
      "statusCode":
          response.statusCode,
      "data": data,
    };
  }

  static Future<Map<String, dynamic>> getMyScans() async {
    final url = Uri.parse("$baseUrl/api/scans/my-scans");

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $authToken",
      },
    );

    final data = jsonDecode(response.body);

    return {
      "statusCode": response.statusCode,
      "data": data,
    };
  }

  static Future<Map<String, dynamic>> getMyVideos() async {
  final url = Uri.parse("$baseUrl/api/video-scans/my-videos");

  final response = await http.get(
    url,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $authToken",
    },
  );

  final data = jsonDecode(response.body);

  return {
    "statusCode": response.statusCode,
    "data": data,
  };
}

  static Future<Map<String, dynamic>> saveProduct({
    required String productId,
  }) async {
    final url = Uri.parse("$baseUrl/api/saved-products");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $authToken",
      },
      body: jsonEncode({
        "productId": productId,
      }),
    );

    final data = jsonDecode(response.body);

    return {
      "statusCode": response.statusCode,
      "data": data,
    };
  }

  static Future<Map<String, dynamic>> getSavedProducts() async {
    final url = Uri.parse("$baseUrl/api/saved-products");

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $authToken",
      },
    );

    final data = jsonDecode(response.body);

    return {
      "statusCode": response.statusCode,
      "data": data,
    };
  }

  static Future<Map<String, dynamic>> removeSavedProduct({
    required String savedProductId,
  }) async {
    final url = Uri.parse("$baseUrl/api/saved-products/$savedProductId");

    final response = await http.delete(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $authToken",
      },
    );

    final data = jsonDecode(response.body);

    return {
      "statusCode": response.statusCode,
      "data": data,
    };
  }

  static Future<Map<String, dynamic>> analyzeMeasurement({
    String? imagePath,
    double? referenceWidth,
  }) async {
    final url = Uri.parse("$baseUrl/api/measurements/analyze");

    final request = http.MultipartRequest("POST", url);

    request.headers["Authorization"] = "Bearer $authToken";

    if (referenceWidth != null) {
      request.fields["referenceWidth"] = referenceWidth.toString();
    }

    if (imagePath != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          "image",
          imagePath,
        ),
      );
    }

    final streamedResponse = await request.send();

    final response = await http.Response.fromStream(streamedResponse);

    final data = jsonDecode(response.body);

    return {
      "statusCode": response.statusCode,
      "data": data,
    };
  }

  static Future<Map<String, dynamic>> getRecommendations({
    required double width,
    required double height,
    required double depth,
    required double area,
    required String roomType,
  }) async {
    final encodedRoomType = Uri.encodeComponent(roomType);

    final url = Uri.parse(
      "$baseUrl/api/recommendations?width=$width&height=$height&depth=$depth&area=$area&roomType=$encodedRoomType",
    );

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $authToken",
      },
    );

    final data = jsonDecode(response.body);

    return {
      "statusCode": response.statusCode,
      "data": data,
    };
  }

  static Future<Map<String, dynamic>> deleteScan({
    required String scanId,
  }) async {
    final url = Uri.parse("$baseUrl/api/scans/$scanId");

    final response = await http.delete(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $authToken",
      },
    );

    final data = jsonDecode(response.body);

    return {
      "statusCode": response.statusCode,
      "data": data,
    };
  }

  static Future<Map<String, dynamic>> getProfile() async {
    final url = Uri.parse("$baseUrl/api/auth/me");

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $authToken",
      },
    );

    final data = jsonDecode(response.body);

    return {
      "statusCode": response.statusCode,
      "data": data,
    };
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String name,
  }) async {
    final url = Uri.parse("$baseUrl/api/auth/profile");

    final response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $authToken",
      },
      body: jsonEncode({
        "name": name,
      }),
    );

    final data = jsonDecode(response.body);

    return {
      "statusCode": response.statusCode,
      "data": data,
    };
  }

  static Future<Map<String, dynamic>> getProducts() async {
    final url = Uri.parse("$baseUrl/api/products");

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
      },
    );

    final data = jsonDecode(response.body);

    return {
      "statusCode": response.statusCode,
      "data": data,
    };
  }

  static Future<Map<String, dynamic>> createProduct({
    required String name,
    required String description,
    required String dimensions,
    required String category,
    required double price,
    required String imageUrl,
    String? imagePath,
  }) async {
    final url = Uri.parse("$baseUrl/api/products");

    final request = http.MultipartRequest("POST", url);

    request.fields["name"] = name;
    request.fields["description"] = description;
    request.fields["dimensions"] = dimensions;
    request.fields["category"] = category;
    request.fields["price"] = price.toString();
    request.fields["imageUrl"] = imageUrl;

    if (imagePath != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          "image",
          imagePath,
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    final data = jsonDecode(response.body);

    return {
      "statusCode": response.statusCode,
      "data": data,
    };
  }

  static Future<Map<String, dynamic>> deleteProduct({
    required String productId,
  }) async {
    final url = Uri.parse("$baseUrl/api/products/$productId");

    final response = await http.delete(
      url,
      headers: {
        "Content-Type": "application/json",
      },
    );

    final data = jsonDecode(response.body);

    return {
      "statusCode": response.statusCode,
      "data": data,
    };
  }

  static Future<Map<String, dynamic>> updateProduct({
    required String productId,
    required String name,
    required String description,
    required String dimensions,
    required String category,
    required double price,
    required String imageUrl,
    String? imagePath,
  }) async {
    final url = Uri.parse("$baseUrl/api/products/$productId");

    final request = http.MultipartRequest("PUT", url);

    request.fields["name"] = name;
    request.fields["description"] = description;
    request.fields["dimensions"] = dimensions;
    request.fields["category"] = category;
    request.fields["price"] = price.toString();
    request.fields["imageUrl"] = imageUrl;

    if (imagePath != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          "image",
          imagePath,
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    final data = jsonDecode(response.body);

    return {
      "statusCode": response.statusCode,
      "data": data,
    };
  }

  static Future<Map<String, dynamic>> getAnalytics() async {
    final url = Uri.parse("$baseUrl/api/analytics");

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
      },
    );

    final data = jsonDecode(response.body);

    return {
      "statusCode": response.statusCode,
      "data": data,
    };
  }

  static Future<Map<String, dynamic>> getScanLogs() async {
    final url = Uri.parse("$baseUrl/api/admin/scan-logs");

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
      },
    );

    final data = jsonDecode(response.body);

    return {
      "statusCode": response.statusCode,
      "data": data,
    };
  }

  static Future<Map<String, dynamic>> getScanLogDetails(
  String scanType,
  String scanId,
) async {
  final url = Uri.parse(
    "$baseUrl/api/admin/scan-logs/$scanType/$scanId",
  );

  final response = await http.get(
    url,
    headers: {
      "Content-Type": "application/json",
    },
  );

  final data = jsonDecode(response.body);

  return {
    "statusCode": response.statusCode,
    "data": data,
  };
}

  static Future<Map<String, dynamic>> getCategories() async {
    final url = Uri.parse("$baseUrl/api/admin/categories");

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
      },
    );

    final data = jsonDecode(response.body);

    return {
      "statusCode": response.statusCode,
      "data": data,
    };
  }

  static Future<Map<String, dynamic>> createCategory({
    required String category,
  }) async {
    final url = Uri.parse("$baseUrl/api/admin/categories");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "category": category,
      }),
    );

    final data = jsonDecode(response.body);

    return {
      "statusCode": response.statusCode,
      "data": data,
    };
  }

  static Future<Map<String, dynamic>> deleteCategory({
    required String categoryId,
  }) async {
    final url = Uri.parse("$baseUrl/api/admin/categories/$categoryId");

    final response = await http.delete(
      url,
      headers: {
        "Content-Type": "application/json",
      },
    );

    final data = jsonDecode(response.body);

    return {
      "statusCode": response.statusCode,
      "data": data,
    };
  }

  static Future<Map<String, dynamic>> getCategoryProducts({
    required String categoryId,
  }) async {
    final url = Uri.parse(
      "$baseUrl/api/admin/categories/$categoryId/products",
    );

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
      },
    );

    final data = jsonDecode(response.body);

    return {
      "statusCode": response.statusCode,
      "data": data,
    };
  }

  static Future<Map<String, dynamic>> updateCategory({
    required String categoryId,
    required String name,
  }) async {
    final url = Uri.parse("$baseUrl/api/admin/categories/$categoryId");

    final response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "name": name,
      }),
    );

    final data = jsonDecode(response.body);

    return {
      "statusCode": response.statusCode,
      "data": data,
    };
  }

  static Future<Map<String, dynamic>> getRecommendationRules() async {
    final url = Uri.parse("$baseUrl/api/admin/recommendation-rules");

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
      },
    );

    final data = jsonDecode(response.body);

    return {
      "statusCode": response.statusCode,
      "data": data,
    };
  }

  static Future<Map<String, dynamic>> createRecommendationRule({
    required String roomType,
    required String category,
    required int priority,
  }) async {
    final url = Uri.parse("$baseUrl/api/admin/recommendation-rules");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "roomType": roomType,
        "category": category,
        "priority": priority,
      }),
    );

    final data = jsonDecode(response.body);

    return {
      "statusCode": response.statusCode,
      "data": data,
    };
  }

  static Future<Map<String, dynamic>> deleteRecommendationRule({
    required String ruleId,
  }) async {
    final url = Uri.parse("$baseUrl/api/admin/recommendation-rules/$ruleId");

    final response = await http.delete(
      url,
      headers: {
        "Content-Type": "application/json",
      },
    );

    final data = jsonDecode(response.body);

    return {
      "statusCode": response.statusCode,
      "data": data,
    };
  }

  static Future<Map<String, dynamic>> updateRecommendationRule({
    required String ruleId,
    required String roomType,
    required String category,
    required int priority,
    required bool isActive,
  }) async {
    final url = Uri.parse("$baseUrl/api/admin/recommendation-rules/$ruleId");

    final response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "roomType": roomType,
        "category": category,
        "priority": priority,
        "isActive": isActive,
      }),
    );

    final data = jsonDecode(response.body);

    return {
      "statusCode": response.statusCode,
      "data": data,
    };
  }

  static Future<Map<String, dynamic>> getNotifications() async {
    final url = Uri.parse("$baseUrl/api/admin/notifications");

    final response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );

    final data = jsonDecode(response.body);

    return {
      "statusCode": response.statusCode,
      "data": data,
    };
  }

  static Future<Map<String, dynamic>> createNotification({
    required String title,
    required String message,
    required String targetRole,
  }) async {
    final url = Uri.parse("$baseUrl/api/admin/notifications");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "title": title,
        "message": message,
        "targetRole": targetRole,
      }),
    );

    final data = jsonDecode(response.body);

    return {
      "statusCode": response.statusCode,
      "data": data,
    };
  }

  static Future<Map<String, dynamic>> deleteNotification({
    required String notificationId,
  }) async {
    final url = Uri.parse("$baseUrl/api/admin/notifications/$notificationId");

    final response = await http.delete(
      url,
      headers: {"Content-Type": "application/json"},
    );

    final data = jsonDecode(response.body);

    return {
      "statusCode": response.statusCode,
      "data": data,
    };
  }

  static Future<Map<String, dynamic>>
    getUserNotifications() async {

  final url = Uri.parse("$baseUrl/api/notifications");

  final response = await http.get(
    url,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $authToken",
    },
  );

  final data = jsonDecode(response.body);

  return {
    "statusCode": response.statusCode,
    "data": data,
  };
}

static Future<Map<String, dynamic>> getVendors() async {
  final url = Uri.parse("$baseUrl/api/admin/vendors");

  final response = await http.get(
    url,
    headers: {
      "Content-Type": "application/json",
    },
  );

  final data = jsonDecode(response.body);

  return {
    "statusCode": response.statusCode,
    "data": data,
  };
}

static Future<Map<String, dynamic>> createVendor({
  required String name,
  required String status,
  required String website,
}) async {
  final url = Uri.parse("$baseUrl/api/admin/vendors");

  final response = await http.post(
    url,
    headers: {
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "name": name,
      "status": status,
      "website": website,
    }),
  );

  final data = jsonDecode(response.body);

  return {
    "statusCode": response.statusCode,
    "data": data,
  };
}

static Future<Map<String, dynamic>> deleteVendor({
  required String vendorId,
}) async {
  final url = Uri.parse("$baseUrl/api/admin/vendors/$vendorId");

  final response = await http.delete(
    url,
    headers: {
      "Content-Type": "application/json",
    },
  );

  final data = jsonDecode(response.body);

  return {
    "statusCode": response.statusCode,
    "data": data,
  };
}

static Future<Map<String, dynamic>> updateVendor({
  required String vendorId,
  required String name,
  required String status,
  required String website,
}) async {
  final url = Uri.parse("$baseUrl/api/admin/vendors/$vendorId");

  final response = await http.put(
    url,
    headers: {
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "name": name,
      "status": status,
      "website": website,
    }),
  );

  final data = jsonDecode(response.body);

  return {
    "statusCode": response.statusCode,
    "data": data,
  };
}

static Future<Map<String, dynamic>> getProductSyncs() async {
  final url = Uri.parse("$baseUrl/api/admin/product-syncs");

  final response = await http.get(
    url,
    headers: {
      "Content-Type": "application/json",
    },
  );

  final data = jsonDecode(response.body);

  return {
    "statusCode": response.statusCode,
    "data": data,
  };
}

static Future<Map<String, dynamic>> createProductSync({
  required String vendorId,
}) async {
  final url = Uri.parse("$baseUrl/api/admin/product-syncs");

  final response = await http.post(
    url,
    headers: {
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "vendorId": vendorId,
    }),
  );

  final data = jsonDecode(response.body);

  return {
    "statusCode": response.statusCode,
    "data": data,
  };
}

static Future<Map<String, dynamic>> deleteProductSync({
  required String syncId,
}) async {
  final url = Uri.parse("$baseUrl/api/admin/product-syncs/$syncId");

  final response = await http.delete(
    url,
    headers: {
      "Content-Type": "application/json",
    },
  );

  final data = jsonDecode(response.body);

  return {
    "statusCode": response.statusCode,
    "data": data,
  };
}

static Future<Map<String, dynamic>> detectSpaceWithAI({
  required String imagePath,
}) async {
  final url = Uri.parse("$baseUrl/api/ai/detect-space");

  final request = http.MultipartRequest("POST", url);

  request.files.add(
    await http.MultipartFile.fromPath(
      "image",
      imagePath,
    ),
  );

  final streamedResponse = await request.send();

  final response = await http.Response.fromStream(
    streamedResponse,
  );

  final data = jsonDecode(response.body);

  return {
    "statusCode": response.statusCode,
    "data": data,
  };
}

static Future<Map<String, dynamic>> saveVideoScan({
  required String videoPath,
  required String thumbnailUrl,
  required double pixelsPerCm,
  required List<Map<String, dynamic>> measurements,
}) async {
  final url =
      Uri.parse("$baseUrl/api/video-scans");

  final request =
      http.MultipartRequest("POST", url);

  request.headers["Authorization"] =
      "Bearer $authToken";

  request.fields["pixelsPerCm"] =
      pixelsPerCm.toString();

  request.fields["measurements"] =
      jsonEncode(measurements);

  request.files.add(
    await http.MultipartFile.fromPath(
      "video",
      videoPath,
    ),
  );

request.files.add(
  await http.MultipartFile.fromPath(
    "thumbnail",
    thumbnailUrl,
  ),
);

  final streamedResponse =
      await request.send();

  final response =
      await http.Response.fromStream(
    streamedResponse,
  );

  final data =
      jsonDecode(response.body);

  return {
    "statusCode": response.statusCode,
    "data": data,
  };
}

static Future<Map<String, dynamic>> deleteVideo(
  String id,
) async {
  final response = await http.delete(
    Uri.parse("$baseUrl/api/video-scans/$id"),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $authToken",
    },
  );

  final data = jsonDecode(response.body);

  return {
    "statusCode": response.statusCode,
    "data": data,
  };
}

static Future<Map<String, dynamic>>
getAdminProfile() async {

  final response = await http.get(
    Uri.parse("$baseUrl/api/admin/profile"),
    headers: {
      "Authorization": "Bearer $authToken",
    },
  );

  final data =
      jsonDecode(response.body);

  return {
    "statusCode": response.statusCode,
    "data": data,
  };
}

static Future<Map<String, dynamic>>
updateAdminProfile({
  required String name,
  required String email,
}) async {
  final response = await http.put(
    Uri.parse(
      "$baseUrl/api/admin/profile",
    ),
    headers: {
      "Content-Type":
          "application/json",
      "Authorization":
          "Bearer $authToken",
    },
    body: jsonEncode({
      "name": name,
      "email": email,
    }),
  );

  return {
    "statusCode":
        response.statusCode,
    "data":
        jsonDecode(response.body),
  };
}

static Future<Map<String, dynamic>>
changePassword({
  required String currentPassword,
  required String newPassword,
}) async {

  final response = await http.put(
    Uri.parse(
      "$baseUrl/api/admin/change-password",
    ),
    headers: {
      "Content-Type":
          "application/json",
      "Authorization":
          "Bearer $authToken",
    },
    body: jsonEncode({
      "currentPassword":
          currentPassword,
      "newPassword":
          newPassword,
    }),
  );

  return {
    "statusCode":
        response.statusCode,
    "data":
        jsonDecode(response.body),
  };
}

static Future<Map<String, dynamic>>
getAdminSettings() async {

  final response = await http.get(
    Uri.parse(
      "$baseUrl/api/admin/settings",
    ),
  );

  return {
    "statusCode": response.statusCode,
    "data": jsonDecode(response.body),
  };
}

static Future<Map<String, dynamic>>
updateAdminSettings({
  required bool scanAlerts,
  required bool productSyncAlerts,
  required bool systemNotifications,
}) async {

  final response = await http.put(
    Uri.parse(
      "$baseUrl/api/admin/settings",
    ),
    headers: {
      "Content-Type":
          "application/json",
    },
    body: jsonEncode({
      "scanAlerts": scanAlerts,
      "productSyncAlerts":
          productSyncAlerts,
      "systemNotifications":
          systemNotifications,
    }),
  );

  return {
    "statusCode": response.statusCode,
    "data": jsonDecode(response.body),
  };
}

static Future<Map<String, dynamic>> updateScan({
  required String scanId,
  required String roomType,
}) async {
  final url =
      Uri.parse("$baseUrl/api/scans/$scanId");

  final response = await http.put(
    url,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $authToken",
    },
    body: jsonEncode({
      "roomType": roomType,
    }),
  );

  final data =
      jsonDecode(response.body);

  return {
    "statusCode":
        response.statusCode,
    "data": data,
  };
}

static Future<Map<String, dynamic>> updateVideo({
  required String videoId,
  required String title,
}) async {
  final url =
      Uri.parse(
    "$baseUrl/api/video-scans/$videoId",
  );

  final response = await http.put(
    url,
    headers: {
      "Content-Type": "application/json",
      "Authorization":
          "Bearer $authToken",
    },
    body: jsonEncode({
      "title": title,
    }),
  );

  final data =
      jsonDecode(response.body);

  return {
    "statusCode":
        response.statusCode,
    "data": data,
  };
}

static Future<Map<String, dynamic>>
    getUnreadCount() async {
  final url = Uri.parse(
    "$baseUrl/api/notifications/unread-count",
  );

  final response = await http.get(
    url,
    headers: {
      "Authorization":
          "Bearer $authToken",
    },
  );

  return {
    "statusCode": response.statusCode,
    "data": jsonDecode(response.body),
  };
}

static Future<Map<String, dynamic>>
    markNotificationsRead() async {

  final url = Uri.parse(
    "$baseUrl/api/notifications/mark-read",
  );

  final response = await http.put(
    url,
    headers: {
      "Authorization":
          "Bearer $authToken",
    },
  );

  return {
    "statusCode": response.statusCode,
    "data": jsonDecode(response.body),
  };
}
}
