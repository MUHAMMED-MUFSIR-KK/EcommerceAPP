import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_model.freezed.dart';
part 'product_model.g.dart';

@freezed
class Product with _$Product {
  const factory Product({
    required int id,
    required String name,
    required String description,
    required double price,
    required String image,
    required String category,
    required bool inStock,
    @Default(false) bool isFavorite,
    String? brand,
    double? rating,
    int? reviewCount,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
}

@freezed
class ProductsResponse with _$ProductsResponse {
  const factory ProductsResponse({
    required bool success,
    required String message,
    required List<Product> data,
    String? timestamp,
  }) = _ProductsResponse;

  factory ProductsResponse.fromJson(Map<String, dynamic> json) => _$ProductsResponseFromJson(json);
}