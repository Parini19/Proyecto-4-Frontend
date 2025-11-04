/// Food item model for cinema concessions
class FoodItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final FoodCategory category;
  final bool isAvailable;

  const FoodItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.isAvailable = true,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      category: FoodCategory.values.byName(json['category'] as String),
      isAvailable: json['isAvailable'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category.name,
      'isAvailable': isAvailable,
    };
  }
}

enum FoodCategory {
  combo,
  popcorn,
  drink,
  candy,
  snack,
}

extension FoodCategoryExtension on FoodCategory {
  String get displayName {
    switch (this) {
      case FoodCategory.combo:
        return 'Combos';
      case FoodCategory.popcorn:
        return 'Palomitas';
      case FoodCategory.drink:
        return 'Bebidas';
      case FoodCategory.candy:
        return 'Dulces';
      case FoodCategory.snack:
        return 'Snacks';
    }
  }
}

/// Cart item with quantity
class CartItem {
  final FoodItem foodItem;
  final int quantity;

  const CartItem({
    required this.foodItem,
    required this.quantity,
  });

  double get totalPrice => foodItem.price * quantity;

  CartItem copyWith({
    FoodItem? foodItem,
    int? quantity,
  }) {
    return CartItem(
      foodItem: foodItem ?? this.foodItem,
      quantity: quantity ?? this.quantity,
    );
  }
}

/// Mock food items
final List<FoodItem> mockFoodItems = [
  // Combos
  FoodItem(
    id: 'F1',
    name: 'Combo Clásico',
    description: 'Palomitas medianas + Refresco mediano',
    price: 150.0,
    imageUrl: 'https://image.tmdb.org/t/p/w500/combo1.jpg',
    category: FoodCategory.combo,
  ),
  FoodItem(
    id: 'F2',
    name: 'Combo Pareja',
    description: 'Palomitas grandes + 2 Refrescos medianos',
    price: 250.0,
    imageUrl: 'https://image.tmdb.org/t/p/w500/combo2.jpg',
    category: FoodCategory.combo,
  ),
  FoodItem(
    id: 'F3',
    name: 'Combo Familia',
    description: 'Palomitas jumbo + 4 Refrescos medianos + 2 Nachos',
    price: 450.0,
    imageUrl: 'https://image.tmdb.org/t/p/w500/combo3.jpg',
    category: FoodCategory.combo,
  ),

  // Palomitas
  FoodItem(
    id: 'F4',
    name: 'Palomitas Chicas',
    description: 'Palomitas con mantequilla',
    price: 60.0,
    imageUrl: 'https://image.tmdb.org/t/p/w500/popcorn1.jpg',
    category: FoodCategory.popcorn,
  ),
  FoodItem(
    id: 'F5',
    name: 'Palomitas Medianas',
    description: 'Palomitas con mantequilla',
    price: 80.0,
    imageUrl: 'https://image.tmdb.org/t/p/w500/popcorn2.jpg',
    category: FoodCategory.popcorn,
  ),
  FoodItem(
    id: 'F6',
    name: 'Palomitas Grandes',
    description: 'Palomitas con mantequilla',
    price: 110.0,
    imageUrl: 'https://image.tmdb.org/t/p/w500/popcorn3.jpg',
    category: FoodCategory.popcorn,
  ),

  // Bebidas
  FoodItem(
    id: 'F7',
    name: 'Refresco Chico',
    description: 'Coca-Cola, Sprite, o Fanta',
    price: 40.0,
    imageUrl: 'https://image.tmdb.org/t/p/w500/drink1.jpg',
    category: FoodCategory.drink,
  ),
  FoodItem(
    id: 'F8',
    name: 'Refresco Mediano',
    description: 'Coca-Cola, Sprite, o Fanta',
    price: 55.0,
    imageUrl: 'https://image.tmdb.org/t/p/w500/drink2.jpg',
    category: FoodCategory.drink,
  ),
  FoodItem(
    id: 'F9',
    name: 'Agua Embotellada',
    description: 'Agua natural 600ml',
    price: 35.0,
    imageUrl: 'https://image.tmdb.org/t/p/w500/water.jpg',
    category: FoodCategory.drink,
  ),

  // Dulces
  FoodItem(
    id: 'F10',
    name: 'M&Ms',
    description: 'Chocolate con cacahuate',
    price: 45.0,
    imageUrl: 'https://image.tmdb.org/t/p/w500/mms.jpg',
    category: FoodCategory.candy,
  ),
  FoodItem(
    id: 'F11',
    name: 'Skittles',
    description: 'Caramelos de frutas',
    price: 45.0,
    imageUrl: 'https://image.tmdb.org/t/p/w500/skittles.jpg',
    category: FoodCategory.candy,
  ),
  FoodItem(
    id: 'F12',
    name: 'Nachos',
    description: 'Nachos con queso cheddar',
    price: 70.0,
    imageUrl: 'https://image.tmdb.org/t/p/w500/nachos.jpg',
    category: FoodCategory.snack,
  ),
];
