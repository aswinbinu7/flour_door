class FoodModel {
  int? food_id;
  String food_name;
  double price;
  String description;

  FoodModel({
    this.food_id,
    required this.food_name,
    required this.price,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      // 'food_id': food_id,
      'food_name': food_name,
      'price': price,
      'description': description,
    };
  }

  factory FoodModel.fromMap(Map<String, dynamic> map) {
    return FoodModel(
      food_id: map['food_id'],
      food_name: map['food_name'],
      price: map['price'],
      description: map['description'],
    );
  }
}
