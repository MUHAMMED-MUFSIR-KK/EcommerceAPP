import 'package:flutter/material.dart';
import 'package:flutter_application_1/screen/pages/saved_page.dart';
import 'package:flutter_application_1/screen/pages/favorites_page.dart';
import 'package:flutter_application_1/screen/pages/orders_page.dart';
import 'package:flutter_application_1/screen/pages/user_details_page.dart';
import 'package:flutter_application_1/screen/pages/product_page.dart';
import 'package:flutter_application_1/controller/auth.dart';
import 'package:flutter_application_1/controller/products_controller.dart';
import 'package:flutter_application_1/model/product_model.dart';

class EcommerceHomePage extends StatefulWidget {
  const EcommerceHomePage({super.key});

  @override
  State<EcommerceHomePage> createState() => _EcommerceHomePageState();
}

class _EcommerceHomePageState extends State<EcommerceHomePage> {
  int _selectedIndex = 0;
  int _selectedCategoryIndex = -1;
  final AuthController _auth = AuthController();
  final ProductsController _productsController = ProductsController();
  Map<String, String> _userProfile = {
    'username': 'Loading...',
    'email': 'Loading...',
  };
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoadingProducts = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadProducts();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await _auth.getUserProfile();
      setState(() {
        _userProfile = profile;
      });
    } catch (e) {
      print("Error loading user profile: $e");
    }
  }

  Future<void> _loadProducts() async {
    print("HomePage: Starting to load products");
    setState(() {
      _isLoadingProducts = true;
    });

    try {
      print("HomePage: Calling products controller");
      final products = await _productsController.getProducts();
      print("HomePage: Received ${products.length} products from controller");
      if (products.isNotEmpty) {
        print("HomePage: First product name: ${products.first.name}");
      }
      setState(() {
        _products = products;
        _filteredProducts = products;
        _isLoadingProducts = false;
      });
      print(
        "HomePage: State updated - _products.length: ${_products.length}, _filteredProducts.length: ${_filteredProducts.length}, _isLoadingProducts: $_isLoadingProducts",
      );
    } catch (e) {
      print("HomePage: Error loading products: $e");
      setState(() {
        _isLoadingProducts = false;
      });
    }
  }

  void _filterProductsByCategory(int categoryIndex) {
    final categories = ["Technology", "Fashion", "Sports", "Supermarket"];

    setState(() {
      _selectedCategoryIndex = categoryIndex;
      if (categoryIndex == -1) {
        _filteredProducts = _products;
      } else {
        final categoryName = categories[categoryIndex];
        _filteredProducts = _products
            .where(
              (product) =>
                  product.category.toLowerCase() == categoryName.toLowerCase(),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with search
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Spacer(),
                              IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const UserDetailsPage(),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.person_rounded,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.search, color: Colors.grey),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: "Search products",
                                      border: InputBorder.none,
                                      hintStyle: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Cyber Linio Banner
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        // gradient: const LinearGradient(
                        //   colors: [Color(0xFFE91E63), Color(0xFF9C27B0)],
                        //   begin: Alignment.topLeft,
                        //   end: Alignment.bottomRight,
                        // ),
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      height: 160,
                    ),

                    const SizedBox(height: 24),

                    // Category tabs
                    SizedBox(
                      height: 50,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          _buildCategoryTab("All", -1),
                          _buildCategoryTab("Technology", 0),
                          _buildCategoryTab("Fashion", 1),
                          _buildCategoryTab("Sports", 2),
                          _buildCategoryTab("Supermarket", 3),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Hot sales section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Hot sales",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            width: 20,
                            height: 3,
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Product grid
                    SizedBox(
                      height: 220,
                      child: _isLoadingProducts
                          ? const Center(child: CircularProgressIndicator())
                          : _filteredProducts.isEmpty
                          ? const Center(
                              child: Text(
                                "No products found",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: _filteredProducts.length,
                              itemBuilder: (context, index) {
                                final product = _filteredProducts[index];
                                return _buildProductCardFromAPI(product);
                              },
                            ),
                    ),

                    const SizedBox(height: 24),

                    // Recently viewed section
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Recently viewed",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Recently viewed items
                    SizedBox(
                      height: 120,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          _buildRecentlyViewedCard(
                            Colors.purple.shade100,
                            Icons.laptop,
                          ),
                          _buildRecentlyViewedCard(
                            Colors.grey.shade800,
                            Icons.speaker,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SavedPage()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FavoritesPage()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OrdersPage()),
            );
          } else {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Orders',
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTab(String title, int categoryIndex) {
    bool isSelected = _selectedCategoryIndex == categoryIndex;
    return GestureDetector(
      onTap: () {
        _filterProductsByCategory(categoryIndex);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildProductCardFromAPI(Product product) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(color: Colors.purpleAccent),
          _buildProductCard(product.name, product.price.toString()),
        ],
      ),
    );
  }

  Widget _buildProductCard(String title, String price) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 120, color: Colors.blue),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentlyViewedCard(Color bgColor, IconData icon) {
    // Generate product name based on icon
    String productName = icon == Icons.laptop
        ? "Gaming Laptop"
        : icon == Icons.speaker
        ? "Bluetooth Speaker"
        : "Product";
    String price = icon == Icons.laptop ? "\$ 25,999" : "\$ 2,999";

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductPage(
              productName: productName,
              price: price,
              shipping: "Free shipping",
              bgColor: bgColor,
              icon: icon,
            ),
          ),
        );
      },
      child: Container(
        width: 100,
        height: 100,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(
                icon,
                size: 32,
                color: bgColor == Colors.grey.shade800
                    ? Colors.white
                    : Colors.grey.shade700,
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_border,
                  size: 12,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getProductIcon(String category) {
    switch (category.toLowerCase()) {
      case 'technology':
        return Icons.laptop_mac;
      case 'fashion':
        return Icons.shopping_bag;
      case 'sports':
        return Icons.sports_soccer;
      case 'supermarket':
        return Icons.local_grocery_store;
      default:
        return Icons.shopping_cart;
    }
  }

  Color _getProductColor(String category) {
    switch (category.toLowerCase()) {
      case 'technology':
        return Colors.blue.shade100;
      case 'fashion':
        return Colors.purple.shade100;
      case 'sports':
        return Colors.green.shade100;
      case 'supermarket':
        return Colors.orange.shade100;
      default:
        return Colors.grey.shade100;
    }
  }
}
