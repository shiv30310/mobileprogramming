import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welding Equipment Store',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blueGrey,
          accentColor: Colors.orange,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueGrey,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 2,
        ),
        cardTheme: const CardTheme(
          elevation: 3,
          margin: EdgeInsets.all(8),
        ),
      ),
      home: ShoppingHomePage(),
    );
  }
}

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });
}

class ShoppingHomePage extends StatefulWidget {
  @override
  _ShoppingHomePageState createState() => _ShoppingHomePageState();
}

class _ShoppingHomePageState extends State<ShoppingHomePage> {
  // In your _ShoppingHomePageState class, replace the products list with:

  // In your _ShoppingHomePageState class, replace the products list with:

  List<Product> products = [
    Product(
      id: 'WM-1001',
      name: 'Casio F-91W',
      description: 'Classic digital watch with alarm and stopwatch',
      price: 19.99,
      imageUrl: 'https://images.unsplash.com/photo-1524805444758-089113d48a6d',
    ),
    Product(
      id: 'WM-1002',
      name: 'Timex Weekender',
      description: '38mm leather/nylon strap, Indiglo backlight',
      price: 39.99,
      imageUrl: 'https://images.unsplash.com/photo-1539874754764-5a96559165b0',
    ),
    Product(
      id: 'WM-1003',
      name: 'Seiko 5 SNK809',
      description: 'Automatic mechanical, 37mm canvas strap',
      price: 129.99,
      imageUrl: 'https://images.unsplash.com/photo-1542496658-e33a6d0d50f6',
    ),
    Product(
      id: 'WM-1004',
      name: 'Citizen Eco-Drive',
      description: 'Solar-powered, Date display, 40mm stainless',
      price: 179.99,
      imageUrl: 'https://images.unsplash.com/photo-1524805444758-089113d48a6d',
    ),
    Product(
      id: 'WM-1005',
      name: 'Casio Edifice',
      description: 'Chronograph, 45mm metal bracelet',
      price: 149.99,
      imageUrl: 'https://images.unsplash.com/photo-1524805444758-089113d48a6d',
    ),
    Product(
      id: 'WM-1006',
      name: 'Timex Expedition',
      description: 'Rugged 40mm field watch with nylon strap',
      price: 49.99,
      imageUrl: 'https://images.unsplash.com/photo-1539874754764-5a96559165b0',
    ),
    Product(
      id: 'WM-1007',
      name: 'Orient Bambino',
      description: 'Automatic dress watch, 40mm leather strap',
      price: 159.99,
      imageUrl: 'https://images.unsplash.com/photo-1542496658-e33a6d0d50f6',
    ),
    Product(
      id: 'WM-1008',
      name: 'Casio G-Shock DW5600',
      description: 'Shock-resistant digital, 200m water resistance',
      price: 69.99,
      imageUrl: 'https://images.unsplash.com/photo-1539874754764-5a96559165b0',
    ),
    Product(
      id: 'WM-1009',
      name: 'Timex Marlin',
      description: 'Vintage-inspired 40mm automatic',
      price: 199.99,
      imageUrl: 'https://images.unsplash.com/photo-1524805444758-089113d48a6d',
    ),
    Product(
      id: 'WM-1010',
      name: 'Seiko Solar Chronograph',
      description: '42mm stainless steel, Solar-powered',
      price: 229.99,
      imageUrl: 'https://images.unsplash.com/photo-1539874754764-5a96559165b0',
    ),
  ];

  Map<Product, int> cartItems = {};

  @override
  void initState() {
    super.initState();
    loadCart();
  }

  Future<void> saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartData = cartItems.map((key, value) => MapEntry(key.id, value));
    await prefs.setString('cart', jsonEncode(cartData));
  }

  Future<void> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartData = prefs.getString('cart');
    if (cartData != null) {
      final decoded = jsonDecode(cartData) as Map<String, dynamic>;
      setState(() {
        cartItems = decoded.map((productId, quantity) {
          final product = products.firstWhere((p) => p.id == productId);
          return MapEntry(product, quantity as int);
        });
      });
    }
  }

  void addToCart(Product product) {
    setState(() {
      if (cartItems.containsKey(product)) {
        cartItems[product] = cartItems[product]! + 1;
      } else {
        cartItems[product] = 1;
      }
      saveCart();
    });
  }

  void removeFromCart(Product product) {
    setState(() {
      if (cartItems.containsKey(product)) {
        if (cartItems[product]! > 1) {
          cartItems[product] = cartItems[product]! - 1;
        } else {
          cartItems.remove(product);
        }
        saveCart();
      }
    });
  }

  double getTotalPrice() {
    double total = 0.0;
    cartItems.forEach((product, quantity) {
      total += product.price * quantity;
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Premium Watches Shop'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CartPage(
                        cartItems: cartItems,
                        totalPrice: getTotalPrice(),
                        removeFromCart: removeFromCart,
                        addToCart: addToCart,
                      ),
                    ),
                  );
                },
              ),
              if (cartItems.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      cartItems.values.reduce((a, b) => a + b).toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailPage(product: product),
                ),
              );
            },
            child: Card(
              margin: EdgeInsets.all(8),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Icon(Icons.error, color: Colors.red),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      product.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => addToCart(product),
                          child: Text('Add to Cart'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ProductDetailPage extends StatelessWidget {
  final Product product;

  ProductDetailPage({required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(
              product.imageUrl,
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    product.description,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ShoppingHomePage(),
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        child: Text('Add to Cart'),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
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

class CartPage extends StatelessWidget {
  final Map<Product, int> cartItems;
  final double totalPrice;
  final Function(Product) removeFromCart;
  final Function(Product) addToCart;

  CartPage({
    required this.cartItems,
    required this.totalPrice,
    required this.removeFromCart,
    required this.addToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      body: Column(
        children: [
          Expanded(
            child: cartItems.isEmpty
                ? Center(
              child: Text(
                'Your cart is empty',
                style: TextStyle(fontSize: 18),
              ),
            )
                : ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final product = cartItems.keys.elementAt(index);
                final quantity = cartItems.values.elementAt(index);
                return Dismissible(
                  key: Key(product.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) => removeFromCart(product),
                  child: Card(
                    margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            child: Image.network(
                              product.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Center(
                                child: Icon(Icons.error, color: Colors.red),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '\$${product.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove),
                                onPressed: () => removeFromCart(product),
                              ),
                              Text(quantity.toString()),
                              IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () => addToCart(product),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Checkout functionality would be implemented here')),
                );
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'PROCEED TO CHECKOUT',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: Size(double.infinity, 0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}