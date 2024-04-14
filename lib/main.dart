import 'package:flutter/material.dart';
import 'Database/database_helper.dart';
import 'login/login_screen.dart';
import 'splash_screen.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();  // This is required when using asynchronous operations before runApp.
  DbHelper dbHelper = DbHelper();  // Create an instance of your DbHelper
  await dbHelper.initDb();  // Call the method that initializes your database

  // Print tables
  await dbHelper.printUserTable();
  await dbHelper.printFoodTable();
  await dbHelper.printOrdersTable();
  await dbHelper.printPaymentTable();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false,
      title: 'Login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreen(), // Show SplashScreen first
    );
  }
}
