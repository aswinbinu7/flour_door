import 'package:flutter/material.dart';
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

  void _confirmOrder() async {
    // Extract data from text controllers
    String fullName = _fullNameController.text;
    String emailAddress = _emailController.text;
    int contactNumber = int.tryParse(_contactNumberController.text) ?? 0;
    String address = _addressCustomController.text;


    // Save order to database
    try {
      DbHelper dbHelper = DbHelper();
      for (int i = 0; i < widget.selectedFoodItems.length; i++) {
        OrderModel order = OrderModel(
          orderUserId: 1, // You need to set the actual user ID here
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
              // TextFormField(
              //   controller: _trainNameCustomController,
              //   decoration: InputDecoration(labelText: 'Train Name'),
              // ),
              // DropdownButtonFormField<String>(
              //   value: _selectedCompartment,
              //   onChanged: (String? value) {
              //     setState(() {
              //       _selectedCompartment = value!;
              //     });
              //   },
              //   decoration: InputDecoration(labelText: 'Compartment'),
              //   items: ['General', 'Sleeper', 'AC', 'Sitting Chair']
              //       .map<DropdownMenuItem<String>>((String value) {
              //     return DropdownMenuItem<String>(
              //       value: value,
              //       child: Text(value),
              //     );
              //   }).toList(),
              // ),
              // DropdownButtonFormField<String>(
              //   value: _selectedBogie,
              //   onChanged: (String? value) {
              //     setState(() {
              //       _selectedBogie = value!;
              //     });
              //   },
              //   decoration: InputDecoration(labelText: 'Bogie'),
              //   items: ['S1', 'S2', 'S3', 'S4', 'S5', 'S6', 'S7', 'S8']
              //       .map<DropdownMenuItem<String>>((String value) {
              //     return DropdownMenuItem<String>(
              //       value: value,
              //       child: Text(value),
              //     );
              //   }).toList(),
              // ),
              // TextFormField(
              //   controller: _seatNumberController,
              //   keyboardType: TextInputType.number,
              //   decoration: InputDecoration(labelText: 'Seat Number'),
              // ),

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
