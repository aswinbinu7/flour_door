import 'package:flutter/material.dart';
import '../Model/FoodModel.dart';
import '../Model/OrderModel.dart';
import '../Model/PaymentModel.dart';

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

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(),
      isDense: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Payment Details',
                style: Theme.of(context).textTheme.headline6?.copyWith(color: Theme.of(context).primaryColor),
              ),
              SizedBox(height: 20.0),
              DropdownButtonFormField<String>(
                decoration: _inputDecoration('Payment Method'),
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
              SizedBox(height: 20.0),
              if (_selectedPaymentMethod == 'Credit Card' || _selectedPaymentMethod == 'Debit Card') ...[
                TextFormField(
                  decoration: _inputDecoration('Card Number'),
                  onChanged: (value) => _cardNumber = value,
                  validator: (value) => value!.isEmpty ? 'Please enter your card number' : null,
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  decoration: _inputDecoration('Expiration Date'),
                  onChanged: (value) => _expirationDate = value,
                  validator: (value) => value!.isEmpty ? 'Please enter the expiration date' : null,
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  decoration: _inputDecoration('CVV'),
                  onChanged: (value) => _cvv = value,
                  validator: (value) => value!.isEmpty ? 'Please enter your CVV' : null,
                ),
                SizedBox(height: 30.0),
              ],
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _submitPayment();
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size.fromHeight(50),
                ),
                child: Text('Submit Payment'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitPayment() async {
    String paymentMethod = _selectedPaymentMethod ?? 'Cash on Delivery'; // Default to Cash on Delivery if not selected
    String paymentDate = DateTime.now().toString();

    // Assuming PaymentModel setup is correct and DbHelper is configured properly
    PaymentModel paymentDetails = PaymentModel(
      paymentMethod: paymentMethod,
      paymentDate: paymentDate,
      relatedOrderId: widget.order.orderId!,
    );

    // DbHelper dbHelper = DbHelper();
    // int result = await dbHelper.savePayment(paymentDetails);

    // Assuming result processing as per your app's logic
    int result = 1; // Placeholder success code
    if (result > 0) {
      print('Payment Details:');
      print('Method: $paymentMethod');
      print('Date: $paymentDate');
      print('Order ID: ${widget.order.orderId}');

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Success'),
          content: Text('Payment has been successfully processed.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                // Optionally navigate away from the transaction page or reset the form
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      print('Error saving payment details');
    }
  }
}