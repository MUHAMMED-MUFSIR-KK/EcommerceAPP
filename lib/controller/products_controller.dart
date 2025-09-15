import 'package:flutter_application_1/services/api.dart';
import 'package:flutter_application_1/model/product_model.dart';

class ProductsController {
  final Api _api = Api();

  Future<List<Product>> getProducts() async {
    try {
      print("ProductsController: Fetching products");
      final response = await _api.getProducts();
      print("ProductsController: API response received: $response");

      List<Product> products = [];

      // Check if response has products array (main format from API)
      if (response is Map<String, dynamic> && response.containsKey('products')) {
        print("ProductsController: Found products array");
        final productsData = response['products'];
        if (productsData is List) {
          print("ProductsController: Processing ${productsData.length} items from products array");
          for (var item in productsData) {
            if (item is Map<String, dynamic>) {
              try {
                // Map API fields to model fields
                final mappedItem = {
                  'id': item['id'] is int ? item['id'] : int.tryParse(item['id'].toString()) ?? 0,
                  'name': item['name'] ?? '',
                  'description': item['description'] ?? '',
                  'price': item['price'] is String
                      ? double.tryParse(item['price']) ?? 0.0
                      : (item['price']?.toDouble() ?? 0.0),
                  'image': item['imageUrl'] ?? '',
                  'category': item['category'] ?? 'Technology',
                  'inStock': item['stock'] != null && item['stock'] > 0,
                  'isFavorite': false,
                  'brand': item['brand'] ?? 'Apple',
                  'rating': item['rating']?.toDouble() ?? 4.5,
                  'reviewCount': item['reviewCount'] ?? 100,
                };
                print("ProductsController: Mapped item: $mappedItem");
                products.add(Product.fromJson(mappedItem));
                print("ProductsController: Successfully parsed product: ${mappedItem['name']}");
              } catch (e) {
                print("ProductsController: Error parsing product: $e");
                print("ProductsController: Item that failed: $item");
              }
            }
          }
        }
      }
      // Check if response has success field and data array (alternative format)
      else if (response is Map<String, dynamic> && response.containsKey('success') && response['success'] == true) {
        print("ProductsController: Found success=true response");
        final data = response['data'];
        if (data is List) {
          print("ProductsController: Processing ${data.length} items from data array");
          for (var item in data) {
            if (item is Map<String, dynamic>) {
              try {
                // Map API fields to model fields
                final mappedItem = {
                  'id': item['id'] is int ? item['id'] : int.tryParse(item['id'].toString()) ?? 0,
                  'name': item['name'] ?? '',
                  'description': item['description'] ?? '',
                  'price': item['price'] is String
                      ? double.tryParse(item['price']) ?? 0.0
                      : (item['price']?.toDouble() ?? 0.0),
                  'image': item['imageUrl'] ?? '',
                  'category': item['category'] ?? 'Technology',
                  'inStock': item['stock'] != null && item['stock'] > 0,
                  'isFavorite': false,
                  'brand': item['brand'] ?? 'Apple',
                  'rating': item['rating']?.toDouble() ?? 4.5,
                  'reviewCount': item['reviewCount'] ?? 100,
                };
                products.add(Product.fromJson(mappedItem));
              } catch (e) {
                print("ProductsController: Error parsing product: $e");
              }
            }
          }
        }
      }
      else {
        print("ProductsController: Response format not recognized");
        print("ProductsController: Available keys: ${response is Map ? response.keys.toList() : 'Not a Map'}");
      }

      print("ProductsController: Final result - Parsed ${products.length} products");
      if (products.isNotEmpty) {
        print("ProductsController: First product: ${products.first.name}");
        return products;
      } else {
        print("ProductsController: No products found, returning empty list");
        return [];
      }
    } catch (e) {
      print("ProductsController: Error fetching products: $e");
      return [];
    }
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final allProducts = await getProducts();
      return allProducts.where((product) =>
        product.category.toLowerCase() == category.toLowerCase()).toList();
    } catch (e) {
      print("ProductsController: Error filtering products by category: $e");
      return [];
    }
  }

  Future<List<Product>> searchProducts(String query) async {
    try {
      final allProducts = await getProducts();
      return allProducts.where((product) =>
        product.name.toLowerCase().contains(query.toLowerCase()) ||
        product.description.toLowerCase().contains(query.toLowerCase()) ||
        product.category.toLowerCase().contains(query.toLowerCase())).toList();
    } catch (e) {
      print("ProductsController: Error searching products: $e");
      return [];
    }
  }
}