import 'package:flutter/material.dart';

void main() => runApp(MyShopApp());

class MyShopApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Luxury Vehicles',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ShopHomePage(),
    );
  }
}

class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String description;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.description,
  });
}

class ShopHomePage extends StatefulWidget {
  @override
  _ShopHomePageState createState() => _ShopHomePageState();
}

class _ShopHomePageState extends State<ShopHomePage> {
  final List<Product> _products = [
    // Living Room
    Product(
      id: 'LR-101',
      name: 'Modern Sofa',
      description: '3-seater fabric sofa with wooden legs, beige',
      price: 599.99,
      imageUrl: 'https://images.unsplash.com/photo-1555529669-e69e7aa0ba9a',
    ),
    Product(
      id: 'LR-102',
      name: 'Coffee Table',
      description: 'Round glass top with metal base, 36" diameter',
      price: 149.99,
      imageUrl: 'https://images.unsplash.com/photo-1567538096630-e0c55bd6374c',
    ),

    // Bedroom
    Product(
      id: 'BR-201',
      name: 'Queen Bed Frame',
      description: 'Upholstered headboard, dark grey fabric',
      price: 399.99,
      imageUrl: 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85',
    ),
    Product(
      id: 'BR-202',
      name: 'Nightstand',
      description: 'Wooden with 2 drawers, 24" height',
      price: 89.99,
      imageUrl: 'https://images.unsplash.com/photo-1592078615290-033ee584e267',
    ),

    // Dining Room
    Product(
      id: 'DR-301',
      name: 'Dining Table Set',
      description: '6-seater extendable table with chairs, walnut finish',
      price: 899.99,
      imageUrl: 'https://images.unsplash.com/photo-1567538096631-e9806f9f4b19',
    ),
    Product(
      id: 'DR-302',
      name: 'Bar Cabinet',
      description: 'Modern liquor storage with glass doors',
      price: 349.99,
      imageUrl: 'https://images.unsplash.com/photo-1598300042247-d088f8ab3a91',
    ),

    // Home Office
    Product(
      id: 'OF-401',
      name: 'Executive Chair',
      description: 'Ergonomic leather office chair, adjustable height',
      price: 249.99,
      imageUrl: 'https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd',
    ),
    Product(
      id: 'OF-402',
      name: 'L-Shaped Desk',
      description: 'Home office workstation, 63" x 63"',
      price: 299.99,
      imageUrl: 'https://images.unsplash.com/photo-1497366811353-6870744d04b2',
    ),

    // Outdoor
    Product(
      id: 'OD-501',
      name: 'Patio Set',
      description: '4-piece rattan furniture set with cushions',
      price: 499.99,
      imageUrl: 'https://images.unsplash.com/photo-1555529669-e69e7aa0ba9a',
    ),
    Product(
      id: 'OD-502',
      name: 'Hammock',
      description: 'Outdoor cotton hammock with steel stand',
      price: 129.99,
      imageUrl: 'https://images.unsplash.com/photo-1523438885200-e635ba2c371e',
    ),
  ];

  final List<Product> _cart = [];

  Widget _buildProductImage(String imageUrl) {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[200],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.grey[400]),
                SizedBox(height: 4),
                Text('Image not available', style: TextStyle(color: Colors.grey[500])),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addToCart(Product product) {
    setState(() {
      _cart.add(product);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to your collection'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  double get _totalPrice => _cart.fold(0, (sum, item) => sum + item.price);

  void _goToCart() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        builder: (_, scrollController) => Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text('Your Luxury Collection',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Expanded(
                child: _cart.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined,
                          size: 48, color: Colors.grey[400]),
                      SizedBox(height: 16),
                      Text('Your collection is empty',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                    ],
                  ),
                )
                    : ListView.builder(
                  controller: scrollController,
                  itemCount: _cart.length,
                  itemBuilder: (_, index) {
                    final item = _cart[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: 80,
                                height: 60,
                                child: _buildProductImage(item.imageUrl),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.name,
                                      style: TextStyle(fontWeight: FontWeight.bold)),
                                  SizedBox(height: 4),
                                  Text(item.description,
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                            Text('\$${item.price.toStringAsFixed(2)}',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (_cart.isNotEmpty) ...[
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total:', style: TextStyle(fontSize: 18)),
                    Text('\$${_totalPrice.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Checkout functionality would go here
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Proceeding to checkout'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Complete Purchase', style: TextStyle(fontSize: 16)),
                ),
              ],
              SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Continue Browsing'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Furniture Shopify'),
        centerTitle: true,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.collections),
                onPressed: _goToCart,
              ),
              if (_cart.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 5,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      _cart.length.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _products.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemBuilder: (context, index) {
          final product = _products[index];
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                // Would navigate to product detail page in a real app
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      child: _buildProductImage(product.imageUrl),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          product.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.add_shopping_cart),
                              color: Colors.black,
                              onPressed: () => _addToCart(product),
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
    );
  }
}