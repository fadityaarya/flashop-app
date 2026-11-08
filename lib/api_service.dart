import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Gunakan http://10.0.2.2:8080 untuk emulator Android, atau IP komputer Anda untuk HP fisik
  static const String baseUrl = 'http://localhost:8080';

  // 1. Verifikasi Google Authenticator
  static Future> verifyGoogleAuth(String code) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'code': code}),
    );
    return jsonDecode(response.body);
  }

  // 2. Get All Products (CRUD)
  static Future<List<dynamic>> getProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data is List ? data : data['products'] ?? [];
    }
    throw Exception('Gagal memuat produk');
  }

  // 3. Add Product (Menggunakan URL Thumbnail)
  static Future<bool> addProduct(Map<String, dynamic> productData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/products/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(productData),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  // 4. Update Product
  static Future<bool> updateProduct(int id, Map<String, dynamic> productData) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/products/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(productData),
    );
    return response.statusCode == 200;
  }

  // 5. Delete Product
  static Future<bool> deleteProduct(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/products/$id'),
    );
    return response.statusCode == 200;
  }
}