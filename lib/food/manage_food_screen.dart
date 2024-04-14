import 'package:flutter/material.dart';
import '../Model/FoodModel.dart';
import '../Database/database_helper.dart';
import 'add_food.dart'; // Import AddFoodPage

class FoodDetailsPage extends StatefulWidget {
  @override
  _FoodDetailsPageState createState() => _FoodDetailsPageState();
}

class _FoodDetailsPageState extends State<FoodDetailsPage> {
  late DbHelper _dbHelper;
  late List<FoodModel> _foodItems;

  @override
  void initState() {
    super.initState();
    _dbHelper = DbHelper();
    _foodItems = [];
    _fetchFoodItems();
  }

  void _fetchFoodItems() async {
    List<FoodModel> foodItems = await _dbHelper.getAllFoods();
    setState(() {
      _foodItems = foodItems;
    });
  }

  void _deleteFood(int index) async {
    await _dbHelper.deleteFood(_foodItems[index].food_id.toString());
    _fetchFoodItems(); // Refresh food items after deletion
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to delete this item?"),
          actions: <Widget>[
            TextButton(
              child: Text("Delete", style: TextStyle(color: Colors.orange)),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
                _deleteFood(index); // Perform the deletion
              },
            ),
            TextButton(
              child: Text("Cancel", style: TextStyle(color: Colors.black54)),
              onPressed: () {
                Navigator.of(context).pop(); // Just dismiss the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food Details'),
        backgroundColor: Colors.orange,  // Set the color theme to orange
      ),
      body: _buildFoodList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddFoodPage(),
            ),
          ).then((value) {
            _fetchFoodItems();  // Refresh food items when returning from AddFoodPage
          });
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.orange,  // Set FAB color to orange
      ),
    );
  }

  Widget _buildFoodList() {
    if (_foodItems.isEmpty) {
      return Center(
        child: Text('No food items available'),
      );
    }

    return ListView.builder(
      itemCount: _foodItems.length,
      itemBuilder: (context, index) {
        FoodModel food = _foodItems[index];
        return ListTile(
          title: Text(food.food_name),
          subtitle: Text('\$${food.price.toStringAsFixed(2)}'),
          trailing: IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () => _confirmDelete(index), // Call confirm delete method on press
          ),
        );
      },
    );
  }
}
