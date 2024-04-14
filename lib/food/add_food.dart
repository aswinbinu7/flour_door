import 'package:flutter/material.dart';
import '../Model/FoodModel.dart';
import '../Database/database_helper.dart';

class AddFoodPage extends StatefulWidget {
  @override
  _AddFoodPageState createState() => _AddFoodPageState();
}

class _AddFoodPageState extends State<AddFoodPage> {
  late TextEditingController _foodNameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late DbHelper _dbHelper;

  @override
  void initState() {
    super.initState();
    _foodNameController = TextEditingController();
    _priceController = TextEditingController();
    _descriptionController = TextEditingController();
    _dbHelper = DbHelper();
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addFood() async {
    String foodName = _foodNameController.text.trim();
    double price = double.parse(_priceController.text.trim());
    String description = _descriptionController.text.trim();

    FoodModel food = FoodModel(
      // Since your food_id is now autoincrementing, you don't need to generate it manually
      // food_id: DateTime.now().millisecondsSinceEpoch.toString(),
      food_name: foodName,
      price: price,
      description: description,
    );

    // Save the food to the database
    await _dbHelper.saveFood(food);

    // Fetch all items from the database
    List<FoodModel> allFoods = await _dbHelper.getAllFoods();

    // Print the details of all items in the database
    print('Current Food Items:');
    for (FoodModel item in allFoods) {
      print('Food ID: ${item.food_id}');
      print('Food Name: ${item.food_name}');
      print('Price: \$${item.price.toStringAsFixed(2)}');
      print('Description: ${item.description}');
      print('--------------------');
    }

    // Pop the food details page after adding food
    Navigator.pop(context);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Food Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _foodNameController,
              decoration: InputDecoration(labelText: 'Food Name'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Price'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: _addFood,
              child: Text('Add Food'),
            ),
          ],
        ),
      ),
    );
  }
}
