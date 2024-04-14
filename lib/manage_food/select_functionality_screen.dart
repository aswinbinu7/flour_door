import 'package:flutter/material.dart';
import '../login/login_screen.dart';
import 'list_users.dart';
import '../food/manage_food_screen.dart';
import 'orders_screen.dart';

class SelectFunctionalityScreen extends StatelessWidget {
  final List<FunctionalityItem> functionalityItems = [
    FunctionalityItem(
      title: 'ORDERS',
      icon: Icons.shopping_cart,
      color: Colors.black,
      onPressed: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => OrdersScreen()),
        );
      },
    ),
    FunctionalityItem(
      title: 'MANAGE PRODUCT',
      icon: Icons.food_bank,
      color: Colors.black,
      onPressed: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FoodDetailsPage()),
        );
      },
    ),
    FunctionalityItem(
      title: 'LIST USERS',
      icon: Icons.list_alt,
      color: Colors.black,
      onPressed: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ListUsers()),
        );
      },
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flour Door'),
        backgroundColor: Colors.orange,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.orange,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Row(
                children: [
                  Icon(Icons.logout, color: Colors.orange),
                  SizedBox(width: 10),
                  Text('LOGOUT', style: TextStyle(color: Colors.orange)),
                ],
              ),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                      (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome, Let's Begin",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.orange, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: functionalityItems.map((item) => ListTile(
                    leading: Icon(item.icon, color: item.color),
                    title: Text(item.title, style: TextStyle(color: Colors.black)),
                    onTap: () => item.onPressed(context),
                  )).toList(),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Time: ${DateTime.now().toString().substring(11, 16)}',
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
              SizedBox(height: 10),
              Text(
                'Temperature: 25°C',
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FunctionalityItem {
  final String title;
  final IconData icon;
  final Color color;
  final Function(BuildContext context) onPressed;

  FunctionalityItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.onPressed,
  });
}
