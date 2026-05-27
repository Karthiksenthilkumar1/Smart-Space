import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String emulatorUrl = "http://10.0.2.2:8000";

  static const String localNetworkUrl =
      "http://172.30.4.77:8000";

  static String baseUrl = emulatorUrl;
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
}