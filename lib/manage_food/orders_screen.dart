import 'package:flutter/material.dart';
import '../Database/database_helper.dart';
import '../Model/OrderModel.dart';
import '../Model/FoodModel.dart';

class OrdersScreen extends StatefulWidget {
  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrdersScreen> {
  late List<OrderModel> _orders;
  late DbHelper _dbHelper;
  Map<int, bool> _expanded = {};

  @override
  void initState() {
    super.initState();
    _dbHelper = DbHelper();
    _orders = [];
    _fetchOrders();
  }

  void _fetchOrders() async {
    List<OrderModel> orders = await _dbHelper.getAllOrders();
    setState(() {
      _orders = orders;
      _expanded = Map.fromIterable(orders, key: (order) => order.orderId, value: (order) => false);
    });
  }

  void _deleteOrder(int orderId) async {
    await _dbHelper.deleteOrder(orderId);
    _fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order History'),
        backgroundColor: Colors.orange,  // Changed to orange
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order History',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.0),
            if (_orders.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    'No orders yet.',
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    OrderModel order = _orders[index];
                    return Card(
                      elevation: 4.0,
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      child: ExpansionTile(
                        key: PageStorageKey<int>(order.orderId!),
                        title: Text('Order #${order.orderId}'),
                        subtitle: Text('Tap to view details'),
                        children: [
                          FutureBuilder<FoodModel?>(
                            future: _dbHelper.getFoodById(order.orderFoodId!),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator(color: Colors.orange)); // Color added
                              } else if (snapshot.hasError || snapshot.data == null) {
                                return ListTile(title: Text('Failed to load food details'));
                              } else {
                                FoodModel food = snapshot.data!;
                                double totalItemPrice = food.price * order.quantity; // Calculate total item price
                                return Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Product Details:', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                                      Text('Product Name: ${food.food_name}'),
                                      Text('Price per Item: \$${food.price}'),
                                      Text('Quantity: ${order.quantity}'),
                                      Text('Total Price: \$${totalItemPrice.toStringAsFixed(2)}'),
                                      SizedBox(height: 10),
                                      Text('Customer Details:', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                                      Text('Full Name: ${order.fullName}'),
                                      Text('Email Address: ${order.emailAddress}'),
                                      Text('Contact Number: ${order.contactNumber}'),
                                      Text('Address: ${order.address}'),
                                      IconButton(
                                        icon: Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _deleteOrder(order.orderId!),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
