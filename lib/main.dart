import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'product_model.dart';

// URL Backend PHP Docker
const String baseUrl = 'http://192.168.1.35:8080';

void main() {
  runApp(const FlashopApp());
}

class FlashopApp extends StatelessWidget {
  const FlashopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flashop',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF9FBF8),
        primaryColor: const Color(0xFF36415A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF36415A),
          primary: const Color(0xFF36415A),
          secondary: const Color(0xFFB7D894),
        ),
        fontFamily: 'Roboto',
      ),
      home: const LoginScreen(),
    );
  }
}

// ==========================================
// 1. HALAMAN LOGIN (USERNAME & PASSWORD)
// ==========================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login-credentials'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _usernameController.text,
          'password': _passwordController.text,
        }),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const GoogleAuthVerificationScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Login Gagal!'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal terhubung ke server: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF8),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.flash_on, size: 64, color: Color(0xFF36415A)),
                const SizedBox(height: 16),
                const Text(
                  'Flashop Login',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF202734)),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF36415A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Masuk', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                  },
                  child: const Text('Belum punya akun? Register di sini', style: TextStyle(color: Color(0xFF36415A))),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 2. HALAMAN REGISTER
// ==========================================
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _register() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _usernameController.text,
          'password': _passwordController.text,
        }),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrasi Berhasil! Silakan Login.'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Registrasi Gagal!'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal terhubung ke server: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register Akun Baru')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username Baru',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF36415A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _isLoading ? null : _register,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Daftar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 3. VERIFIKASI GOOGLE AUTHENTICATOR (BARCODE SVG)
// ==========================================
class GoogleAuthVerificationScreen extends StatefulWidget {
  const GoogleAuthVerificationScreen({super.key});

  @override
  State<GoogleAuthVerificationScreen> createState() => _GoogleAuthVerificationScreenState();
}

class _GoogleAuthVerificationScreenState extends State<GoogleAuthVerificationScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  String? qrCodeSvg;
  bool isLoadingQr = true;

  @override
  void initState() {
    super.initState();
    _fetchQrCode();
  }

  Future<void> _fetchQrCode() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/auth/setup'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          qrCodeSvg = data['qr_code'];
          isLoadingQr = false;
        });
      }
    } catch (e) {
      setState(() => isLoadingQr = false);
    }
  }

  Future<void> _verifyOtp() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'code': _codeController.text}),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['authenticated'] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kode Google Authenticator Salah!'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF8),
      appBar: AppBar(
        title: const Text('Verifikasi Keamanan (2FA)', style: TextStyle(color: Color(0xFF202734), fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFE0F8C7),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Scan Barcode di Google Authenticator',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF202734)),
                  ),
                  const SizedBox(height: 16),
                  isLoadingQr
                      ? const CircularProgressIndicator(color: Color(0xFF36415A))
                      : (qrCodeSvg != null
                          ? Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: SizedBox(
                                width: 180,
                                height: 180,
                                child: SvgPicture.string(
                                  qrCodeSvg!,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            )
                          : const Text('Gagal memuat QR Code', style: TextStyle(color: Colors.red))),
                  const SizedBox(height: 24),
                  const Text(
                    'Masukkan kode 6-digit dari aplikasi Google Authenticator:',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: InputDecoration(
                      labelText: 'Kode OTP 6-Digit',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF36415A),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _isLoading ? null : _verifyOtp,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Verifikasi & Masuk Beranda', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 4. MODEL KERANJANG & PESANAN
// ==========================================
class CartItem {
  final Product product;
  int quantity;
  CartItem({required this.product, this.quantity = 1});
}

class OrderItem {
  final List<CartItem> items;
  final double totalPrice;
  final String date;

  OrderItem({required this.items, required this.totalPrice, required this.date});
}

// ==========================================
// 5. MAIN NAVIGATION SCREEN
// ==========================================
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final List<CartItem> cartItems = [];
  final List<OrderItem> orderHistory = [];

  void addToCart(Product product) {
    setState(() {
      final index = cartItems.indexWhere((item) => item.product.id == product.id);
      if (index >= 0) {
        cartItems[index].quantity++;
      } else {
        cartItems.add(CartItem(product: product));
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.title} ditambahkan ke keranjang!'),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF36415A),
      ),
    );
  }

  void checkoutCart() {
    if (cartItems.isEmpty) return;
    double total = cartItems.fold(0, (sum, item) => sum + (item.product.price * 15000 * item.quantity));
    
    setState(() {
      orderHistory.add(OrderItem(
        items: List.from(cartItems),
        totalPrice: total,
        date: 'Hari ini',
      ));
      cartItems.clear();
      _currentIndex = 2; 
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pembayaran berhasil! Pesanan Anda sedang diproses.'),
        backgroundColor: Color(0xFF36415A),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(
        onAddToCart: addToCart,
        cartList: cartItems,
        onCartTap: () => setState(() => _currentIndex = 1),
      ),
      CartScreen(
        cartList: cartItems,
        onCheckout: checkoutCart,
      ),
      OrdersScreen(orderList: orderHistory),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF36415A),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  const Icon(Icons.shopping_bag_outlined),
                  if (cartItems.isNotEmpty)
                    Positioned(
                      right: 0, top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(color: Color(0xFF36415A), shape: BoxShape.circle),
                        constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                        child: Text('${cartItems.length}', style: const TextStyle(color: Colors.white, fontSize: 8), textAlign: TextAlign.center),
                      ),
                    ),
                ],
              ),
              label: 'Keranjang',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  const Icon(Icons.description_outlined),
                  if (orderHistory.isNotEmpty)
                    Positioned(
                      right: 0, top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(color: Color(0xFF36415A), shape: BoxShape.circle),
                        constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                        child: Text('${orderHistory.length}', style: const TextStyle(color: Colors.white, fontSize: 8), textAlign: TextAlign.center),
                      ),
                    ),
                ],
              ),
              label: 'Pesanan',
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 6. HOME SCREEN & SERVER SEARCH API
// ==========================================
class HomeScreen extends StatefulWidget {
  final Function(Product) onAddToCart;
  final List<CartItem>? cartList;
  final VoidCallback onCartTap;

  const HomeScreen({super.key, required this.onAddToCart, this.cartList, required this.onCartTap});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> products = [];
  bool isLoading = true;
  String searchQuery = '';
  String selectedCategory = 'Semua';
  final TextEditingController _searchController = TextEditingController();

  final List<String> categories = ['Semua', 'beauty', 'fragrances', 'furniture', 'mens-shirts', 'womens-dresses', 'laptops'];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  List<Product> allProducts = [];

  Future<void> fetchProducts({String query = '', String category = 'Semua'}) async {
    setState(() => isLoading = true);

    try {
      final response = await http.get(Uri.parse('$baseUrl/products?limit=500'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List listProducts = data is List ? data : (data['products'] ?? []);
        
        allProducts = listProducts.map((json) => Product.fromJson(json)).toList();

        setState(() {
          products = allProducts.where((product) {
            bool matchesCategory = (category == 'Semua') || 
                                   (product.category.toLowerCase() == category.toLowerCase());
            
            bool matchesQuery = query.isEmpty || 
                                product.title.toLowerCase().contains(query.toLowerCase()) ||
                                product.description.toLowerCase().contains(query.toLowerCase()) ||
                                product.brand.toLowerCase().contains(query.toLowerCase());

            return matchesCategory && matchesQuery;
          }).toList();

          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _showProductFormDialog({Product? productToEdit}) {
    final titleController = TextEditingController(text: productToEdit?.title ?? '');
    final priceController = TextEditingController(text: productToEdit != null ? productToEdit.price.toString() : '');
    final categoryController = TextEditingController(text: productToEdit?.category ?? 'laptops');
    final descController = TextEditingController(text: productToEdit?.description ?? '');
    final thumbnailController = TextEditingController(text: productToEdit?.thumbnail ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(productToEdit == null ? 'Tambah Produk Baru (URL)' : 'Edit Produk'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Judul Produk')),
              TextField(controller: priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Harga (USD)')),
              TextField(controller: categoryController, decoration: const InputDecoration(labelText: 'Kategori')),
              TextField(controller: descController, decoration: const InputDecoration(labelText: 'Deskripsi')),
              TextField(controller: thumbnailController, decoration: const InputDecoration(labelText: 'Link URL Thumbnail Gambar')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF36415A)),
            onPressed: () async {
              final bodyData = {
                "title": titleController.text,
                "price": double.tryParse(priceController.text) ?? 0.0,
                "category": categoryController.text,
                "description": descController.text,
                "thumbnail": thumbnailController.text,
                "stock": 20,
                "brand": "Flashop",
                "sku": "BEA-FLS-${DateTime.now().millisecondsSinceEpoch}-${UniqueKey().toString()}"
              };

              try {
                http.Response response;

                if (productToEdit == null) {
                  response = await http.post(
                    Uri.parse('$baseUrl/products'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode(bodyData),
                  );
                } else {
                  response = await http.patch(
                    Uri.parse('$baseUrl/products/${productToEdit.id}'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode(bodyData),
                  );
                }

                if (response.statusCode == 201 || response.statusCode == 200) {
                  Navigator.pop(context);
                  fetchProducts(query: searchQuery, category: selectedCategory);
                } else {
                  final errorData = jsonDecode(response.body);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menyimpan: ${errorData['error'] ?? response.body}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Terjadi kesalahan: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProduct(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/products/$id'));
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produk berhasil dihapus dari database!'), backgroundColor: Colors.green),
        );
        fetchProducts(query: searchQuery, category: selectedCategory);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menghapus produk.'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final int cartCount = widget.cartList?.length ?? 0;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Text(
                        'Flashop',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF202734)),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.flash_on, size: 18, color: Color(0xFFB7D894)),
                    ],
                  ),
                  Row(
                    children: [
                      // Tombol Tambah Produk (+)
                      GestureDetector(
                        onTap: () => _showProductFormDialog(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF36415A),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.add, size: 20, color: Colors.white),
                        ),
                      ),
                      // Tombol Keranjang
                      GestureDetector(
                        onTap: widget.onCartTap,
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: const Icon(Icons.shopping_bag_outlined, size: 20, color: Color(0xFF36415A)),
                            ),
                            if (cartCount > 0)
                              Positioned(
                                right: 4,
                                top: 4,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF36415A),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '$cartCount',
                                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Tombol Logout
                      GestureDetector(
                        onTap: _logout,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: const Icon(Icons.logout, size: 20, color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() => searchQuery = value);
                  fetchProducts(query: searchQuery, category: selectedCategory);
                },
                decoration: InputDecoration(
                  hintText: 'Cari produk pria & wanita...',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF36415A)),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => searchQuery = '');
                            fetchProducts(category: selectedCategory);
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F8C7),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Style Untuk Semua ⚡',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF202734), height: 1.2),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Temukan koleksi tren terbaik hari ini.',
                          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    const Icon(Icons.local_mall, size: 40, color: Color(0xFF36415A)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Kategori',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF202734)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected = selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: const Color(0xFFB7D894),
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? const Color(0xFF202734) : Colors.grey,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.shade200),
                      ),
                      onSelected: (selected) {
                        setState(() => selectedCategory = cat);
                        fetchProducts(query: searchQuery, category: selectedCategory);
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Katalog Pilihan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF202734)),
                  ),
                  Text(
                    '${products.length} produk',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF36415A)))
                  : products.isEmpty
                      ? const Center(child: Text('Produk tidak ditemukan'))
                      : GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.62,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailPage(
                                      product: product,
                                      onAddToCart: widget.onAddToCart,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16.0),
                                  border: Border.all(color: Colors.grey.shade100),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Stack(
                                        children: [
                                          Container(
                                            width: double.infinity,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFF7F4F0),
                                              borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
                                            ),
                                            child: ClipRRect(
                                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
                                              child: Image.network(
                                                product.thumbnail,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) =>
                                                    const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 4,
                                            right: 4,
                                            child: Row(
                                              children: [
                                                InkWell(
                                                  onTap: () => _showProductFormDialog(productToEdit: product),
                                                  child: Container(
                                                    padding: const EdgeInsets.all(4),
                                                    decoration: const BoxDecoration(color: Colors.white70, shape: BoxShape.circle),
                                                    child: const Icon(Icons.edit, size: 14, color: Colors.blue),
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                InkWell(
                                                  onTap: () => _deleteProduct(product.id),
                                                  child: Container(
                                                    padding: const EdgeInsets.all(4),
                                                    decoration: const BoxDecoration(color: Colors.white70, shape: BoxShape.circle),
                                                    child: const Icon(Icons.delete, size: 14, color: Colors.red),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Positioned(
                                            top: 8,
                                            left: 8,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFE0F8C7),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: const Text(
                                                'Flash Deal',
                                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF202734)),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF202734)),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(Icons.star, size: 12, color: Colors.amber),
                                              const SizedBox(width: 4),
                                              Text(
                                                product.rating.toString(),
                                                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Rp ${(product.price * 15000).toStringAsFixed(0)}',
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF36415A)),
                                              ),
                                              GestureDetector(
                                                onTap: () => widget.onAddToCart(product),
                                                child: Container(
                                                  height: 26,
                                                  width: 26,
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFB7D894),
                                                    borderRadius: BorderRadius.circular(13),
                                                  ),
                                                  child: const Icon(Icons.add, size: 16, color: Color(0xFF202734)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 7. PRODUCT DETAIL PAGE
// ==========================================
class ProductDetailPage extends StatelessWidget {
  final Product product;
  final Function(Product)? onAddToCart;

  const ProductDetailPage({super.key, required this.product, this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.title, style: const TextStyle(fontSize: 16, color: Color(0xFF202734))),
        backgroundColor: const Color(0xFFE0F8C7),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF202734)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 300,
              width: double.infinity,
              color: const Color(0xFFF0ECE6),
              child: Image.network(
                product.thumbnail,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(Icons.broken_image, size: 60, color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F8C7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product.category.toUpperCase(),
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF202734)),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            product.rating.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF202734)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    product.title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF202734)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rp ${(product.price * 15000).toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF36415A)),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.grey),
                  const SizedBox(height: 10),
                  const Text(
                    'Deskripsi Produk',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF202734)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF36415A),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        if (onAddToCart != null) {
                          onAddToCart!(product);
                        }
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Tambah ke Keranjang',
                        style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 8. CART SCREEN & ORDERS SCREEN
// ==========================================
class CartScreen extends StatelessWidget {
  final List<CartItem>? cartList;
  final VoidCallback onCheckout;

  const CartScreen({super.key, this.cartList, required this.onCheckout});

  @override
  Widget build(BuildContext context) {
    final List<CartItem> items = cartList ?? [];
    double totalPrice = items.fold(0, (sum, item) => sum + (item.product.price * 15000 * item.quantity));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang Belanja', style: TextStyle(color: Color(0xFF202734), fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFE0F8C7),
        elevation: 0,
      ),
      body: items.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('Keranjangmu masih kosong', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                item.product.thumbnail,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.grey),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF202734)),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Rp ${(item.product.price * 15000).toStringAsFixed(0)}',
                                    style: const TextStyle(color: Color(0xFF36415A), fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FBF8),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Text('x${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, -5))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Pembayaran', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 2),
                          Text('Rp ${totalPrice.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF36415A))),
                        ],
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF36415A),
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: onCheckout,
                        child: const Text('Checkout Sekarang', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class OrdersScreen extends StatelessWidget {
  final List<OrderItem> orderList;

  const OrdersScreen({super.key, required this.orderList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pesanan', style: TextStyle(color: Color(0xFF202734), fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFE0F8C7),
        elevation: 0,
      ),
      body: orderList.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.description_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('Belum ada riwayat pesanan aktif.', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orderList.length,
              itemBuilder: (context, index) {
                final order = orderList[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F8C7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Status: Sedang Dikemas 📦',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF202734)),
                            ),
                          ),
                          Text(order.date, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                        ],
                      ),
                      const Divider(height: 24),
                      ...order.items.map((cartItem) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                Text('${cartItem.quantity}x ', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF36415A))),
                                Expanded(child: Text(cartItem.product.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13))),
                                Text('Rp ${(cartItem.product.price * 15000 * cartItem.quantity).toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          )),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Belanja:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(
                            'Rp ${order.totalPrice.toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF36415A), fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}