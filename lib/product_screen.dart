import 'package:flutter/material.dart';
import 'api_service.dart';

class ProductScreen extends StatefulWidget {
  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late Future<List<dynamic>> _productList;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    setState(() {
      _productList = ApiService.getProducts();
    });
  }

  void _showProductDialog({Map<String, dynamic>? product}) {
    final titleController = TextEditingController(text: product?['title'] ?? '');
    final priceController = TextEditingController(text: product?['price']?.toString() ?? '');
    final categoryController = TextEditingController(text: product?['category'] ?? '');
    final thumbnailController = TextEditingController(text: product?['thumbnail'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product == null ? 'Tambah Produk Baru' : 'Edit Produk'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: InputDecoration(labelText: 'Judul Produk')),
              TextField(controller: priceController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Harga')),
              TextField(controller: categoryController, decoration: InputDecoration(labelText: 'Kategori')),
              TextField(controller: thumbnailController, decoration: InputDecoration(labelText: 'Link URL Thumbnail Gambar')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final data = {
                "title": titleController.text,
                "price": double.tryParse(priceController.text) ?? 0.0,
                "category": categoryController.text,
                "thumbnail": thumbnailController.text,
              };

              if (product == null) {
                await ApiService.addProduct(data);
              } else {
                await ApiService.updateProduct(product['id'], data);
              }

              Navigator.pop(context);
              _loadProducts();
            },
            child: Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flashop - Manajemen Produk'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showProductDialog(),
            tooltip: 'Tambah Produk',
          )
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _productList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Belum ada data produk.'));
          }

          final products = snapshot.data!;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final item = products[index];
              return ListTile(
                leading: item['thumbnail'] != null && item['thumbnail'].toString().isNotEmpty
                    ? Image.network(item['thumbnail'], width: 50, height: 50, fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image))
                    : Icon(Icons.image),
                title: Text(item['title'] ?? ''),
                subtitle: Text('Rp ${item['price']} | ${item['category']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showProductDialog(product: item),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await ApiService.deleteProduct(item['id']);
                        _loadProducts();
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}