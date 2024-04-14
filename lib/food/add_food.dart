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
    if (_foodNameController.text.isEmpty || _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill out all fields')),
      );
      return;
    }

    try {
      double price = double.parse(_priceController.text.trim());
      FoodModel food = FoodModel(
        food_name: _foodNameController.text.trim(),
        price: price,
        description: _descriptionController.text.trim(),
      );
      await _dbHelper.saveFood(food);
      Navigator.pop(context, true); // return true if food is added
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding product: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Product Details'),
        backgroundColor: Colors.orange[600],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            color: Colors.white,
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _foodNameController,
                    decoration: InputDecoration(
                      labelText: 'Product Name',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange[800]!),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Price',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange[800]!),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange[800]!),
                      ),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 32.0),
                  ElevatedButton(
                    onPressed: _addFood,
                    child: Text('Add Product'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[800]),
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
