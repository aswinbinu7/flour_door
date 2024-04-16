import 'package:flutter/material.dart';
import '../Model/FoodModel.dart';
import '../Database/database_helper.dart';
import '../Model/OrderModel.dart';
import 'confirm_order_screen.dart'; // Import the ConfirmOrderScreen file

class FoodDetailsScreen extends StatefulWidget {
  @override
  _FoodDetailsScreenState createState() => _FoodDetailsScreenState();
}

class _FoodDetailsScreenState extends State<FoodDetailsScreen> {
  late List<FoodModel> _foodList;
  late DbHelper _dbHelper;
  late List<bool> _selectedItems;
  late List<int> _selectedQuantities;

  @override
  void initState() {
    super.initState();
    _dbHelper = DbHelper();
    _foodList = [];
    _selectedItems = List<bool>.generate(0, (index) => false);
    _selectedQuantities = List<int>.generate(0, (index) => 1);
    _fetchFoodItems();
  }

  void _fetchFoodItems() async {
    List<FoodModel> foodItems = await _dbHelper.getAllFoods();
    setState(() {
      _foodList = foodItems;
      _selectedItems = List<bool>.generate(foodItems.length, (index) => false);
      _selectedQuantities = List<int>.generate(foodItems.length, (index) => 1);
    });
  }

  void _placeOrder() async {
    List<FoodModel> selectedFoodItems = [];
    List<int> selectedQuantities = [];
    for (int i = 0; i < _foodList.length; i++) {
      if (_selectedItems[i]) {
        selectedFoodItems.add(_foodList[i]);
        selectedQuantities.add(_selectedQuantities[i]);
      }
    }

    if (selectedFoodItems.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('No items selected.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    // Navigate to the ConfirmOrderScreen and pass necessary data
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ConfirmOrderScreen(
        selectedFoodItems: selectedFoodItems,
        selectedQuantities: selectedQuantities,
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food Details'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _foodList.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.orange[50],
                    elevation: 4.0,
                    margin: EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(
                        _foodList[index].food_name,
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10.0),
                          Text(
                            'Description: ${_foodList[index].description}',
                            style: TextStyle(fontSize: 16.0),
                          ),
                          SizedBox(height: 10.0),
                          Text(
                              'Price: ₹${_foodList[index].price}',
                              style: TextStyle(fontSize: 16.0, color: Colors.black87),
                            ),
                          SizedBox(height: 10.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Quantity: ${_selectedQuantities[index]}'),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.remove, color: Colors.orange),
                                    onPressed: () {
                                      if (_selectedQuantities[index] > 1) {
                                        setState(() => _selectedQuantities[index]--);
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.add, color: Colors.orange),
                                    onPressed: () {
                                      setState(() => _selectedQuantities[index]++);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: Checkbox(
                        value: _selectedItems[index],
                        onChanged: (bool? value) {
                          setState(() {
                            _selectedItems[index] = value!;
                          });
                        },
                        activeColor: Colors.orange,
                        checkColor: Colors.white,
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20.0),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
                onPressed: _placeOrder,
                child: Text('Place Order'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: FoodDetailsScreen(),
  ));
}
