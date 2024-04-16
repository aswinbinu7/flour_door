import 'package:flutter/material.dart';
import '../Model/FoodModel.dart';
import '../Model/OrderModel.dart';

class TransactionPage extends StatefulWidget {
  final OrderModel order;
  final FoodModel food;

  TransactionPage({required this.order, required this.food});

  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final _formKey = GlobalKey<FormState>();
  String _cardNumber = '';
  String _expirationDate = '';
  String _cvv = '';
  String? _selectedPaymentMethod;
  List<String> _paymentMethods = ['Credit Card', 'Debit Card', 'Cash on Delivery'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complete Your Payment'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Payment Method:', style: Theme.of(context).textTheme.headline6),
              SizedBox(height: 10),
              _buildDropdown(),
              SizedBox(height: 20),
              _buildPaymentDetails(),
              SizedBox(height: 20),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Card(
      elevation: 4.0,
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Select Payment Method',
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          border: OutlineInputBorder(),
        ),
        value: _selectedPaymentMethod,
        items: _paymentMethods.map((String method) {
          return DropdownMenuItem<String>(
            value: method,
            child: Text(method),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            _selectedPaymentMethod = newValue;
          });
        },
        validator: (value) => value == null ? 'Please select a payment method' : null,
      ),
    );
  }

  Widget _buildPaymentDetails() {
    if (_selectedPaymentMethod == 'Credit Card' || _selectedPaymentMethod == 'Debit Card') {
      return Card(
        elevation: 4.0,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              _buildTextField(
                'Card Number',
                'Enter your card number',
                Icons.credit_card,
                    (value) => _cardNumber = value,
                _validateCardNumber,
                'Please enter a valid 16-digit card number',
              ),
              SizedBox(height: 10),
              _buildTextField(
                'Expiration Date (MM/YY)',
                'MM/YY',
                Icons.date_range,
                    (value) => _expirationDate = value,
                _validateDate,
                'Please enter a valid date (MM/YY)',
              ),
              SizedBox(height: 10),
              _buildTextField(
                'CVV',
                'Enter your CVV',
                Icons.lock_outline,
                    (value) => _cvv = value,
                _validateCVV,
                'Please enter a valid CVV (3 or 4 digits)',
              ),
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget _buildTextField(
      String label,
      String hint,
      IconData icon,
      Function(String) onSaved,
      Function(String) validator,
      String errorMessage) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(),
      ),
      onChanged: onSaved,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return errorMessage;
        } else if (!validator(value)) {
          return errorMessage;
        }
        return null;
      },
    );
  }

  ElevatedButton _buildSubmitButton() {
    return ElevatedButton(
      child: Text('Submit Payment', style: TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        minimumSize: Size(double.infinity, 50),
      ),
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          _submitPayment();
        }
      },
    );
  }

  bool _validateCardNumber(String input) {
    return input.length == 16 && RegExp(r'^\d+$').hasMatch(input);
  }

  bool _validateDate(String input) {
    return RegExp(r'^(0[1-9]|1[0-2])\/[0-9]{2}$').hasMatch(input);
  }

  bool _validateCVV(String input) {
    return RegExp(r'^\d{3,4}$').hasMatch(input);
  }

  void _submitPayment() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Success'),
        content: Text('Payment has been successfully processed.'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              Navigator.of(context).pop(); // Pop the TransactionPage
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
