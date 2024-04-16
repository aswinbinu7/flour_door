import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/FoodModel.dart';
import '../Model/OrderModel.dart';
import '../Database/database_helper.dart';

class ConfirmOrderScreen extends StatefulWidget {
  final List<FoodModel> selectedFoodItems;
  final List<int> selectedQuantities;

  ConfirmOrderScreen({
    required this.selectedFoodItems,
    required this.selectedQuantities,
  });

  @override
  _ConfirmOrderScreenState createState() => _ConfirmOrderScreenState();
}

class _ConfirmOrderScreenState extends State<ConfirmOrderScreen> {
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _contactNumberController;
  late TextEditingController _addressCustomController;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _contactNumberController = TextEditingController();
    _addressCustomController = TextEditingController();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _contactNumberController.dispose();
    _addressCustomController.dispose();
    super.dispose();
  }

  Future<int> _fetchUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id') ?? 0; // Assuming 'user_id' is set in SharedPreferences
  }

  void _confirmOrder() async {
    // Extract data from text controllers
    String fullName = _fullNameController.text;
    String emailAddress = _emailController.text;
    int contactNumber = int.tryParse(_contactNumberController.text) ?? 0;
    String address = _addressCustomController.text;

    int userId = await _fetchUserId();
    if (userId == 0) {
      return;
    }


    // Save order to database
    try {
      DbHelper dbHelper = DbHelper();
      for (int i = 0; i < widget.selectedFoodItems.length; i++) {
        OrderModel order = OrderModel(
          orderUserId: userId, // You need to set the actual user ID here
          orderFoodId: widget.selectedFoodItems[i].food_id,
          quantity: widget.selectedQuantities[i],
          orderTime: DateTime.now().toString(),
          fullName: fullName,
          emailAddress: emailAddress,
          contactNumber: contactNumber,
          address: address,
        );

        await dbHelper.saveOrder(order);
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('Order placed successfully.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Pop both ConfirmOrderScreen and FoodDetailsScreen
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print("Error: $e");
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('An error occurred while placing the order. Please try again later.'),
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirm Order'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(labelText: 'Full Name'),
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email Address'),
              ),
              TextFormField(
                controller: _contactNumberController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: 'Contact Number'),
              ),
              TextFormField(
                controller: _addressCustomController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: 'Address'),
              ),

              SizedBox(height: 20.0),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  onPressed: _confirmOrder,
                  child: Text('Confirm Order'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
