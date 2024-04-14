import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io' as io;

import '../Model/OrderModel.dart';
import '../Model/PaymentModel.dart';
import '../Model/UserModel.dart';
import '../Model/FoodModel.dart';

class DbHelper {
  static Database? _db;

  static const String DB_Name = 'flour_door_order.db';
  static const String Table_User = 'user';
  static const String Table_Food = 'food';
  static const String Table_Order = 'orders'; // Renamed table to "orders"
  static const String Table_Payment = 'payment';

  // Columns for user table
  static const String C_UserID = 'user_id';
  static const String C_UserName = 'user_name';
  static const String C_Email = 'email';
  static const String C_Password = 'password';


  // Columns for food table
  static const String C_FoodID = 'food_id';
  static const String C_FoodName = 'food_name';
  static const String C_Price = 'price';
  static const String C_Description = 'description';

  // Columns for orders table
  static const String C_OrderID = 'order_id';
  static const String C_OrderUserID = 'order_user_id';
  static const String C_OrderFoodID = 'order_food_id';
  static const String C_Quantity = 'quantity';
  static const String C_OrderTime = 'order_time';
  static const String C_FullName = 'full_name'; // New field
  static const String C_EmailAddress = 'email_address'; // New field
  static const String C_ContactNumber = 'contact_number'; // New field
  static const String C_Address = 'address'; // New field

  // Payment table
  static const String C_PaymentID = 'payment_id';
  static const String C_PaymentMethod = 'payment_method';
  static const String C_PaymentDate = 'payment_date';
  static const String C_RelatedOrderID = 'related_order_id';

  static const int Version = 1;

  Future<Database?> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DB_Name);
    var db = await openDatabase(path, version: Version, onCreate: _onCreate);

    // Enable foreign key support using a SQL command
    await db.execute("PRAGMA foreign_keys = ON;");

    return db;
  }

  _onCreate(Database db, int intVersion) async {
    // Create user table
    await db.execute("CREATE TABLE $Table_User ("
        " $C_UserID INTEGER PRIMARY KEY AUTOINCREMENT, "
        " $C_UserName TEXT, "
        " $C_Email TEXT,"
        " $C_Password TEXT "
        ")");


    // Create food table
    await db.execute("CREATE TABLE $Table_Food ("
        " $C_FoodID INTEGER PRIMARY KEY AUTOINCREMENT, "
        " $C_FoodName TEXT, "
        " $C_Price REAL,"
        " $C_Description TEXT "
        ")");

    // Create order table
    await db.execute("CREATE TABLE $Table_Order ("
        " $C_OrderID INTEGER PRIMARY KEY AUTOINCREMENT, "
        " $C_OrderUserID INTEGER, "
        " $C_OrderFoodID INTEGER, "
        " $C_Quantity INTEGER, "
        " $C_OrderTime TEXT, "
        " $C_FullName TEXT, " // Added fullName column
        " $C_EmailAddress TEXT, " // Added emailAddress column
        " $C_ContactNumber INTEGER, " // Added contactNumber column
        " $C_Address TEXT, " // Added trainNameCustom column
        " FOREIGN KEY ($C_OrderUserID) REFERENCES $Table_User($C_UserID), "
        " FOREIGN KEY ($C_OrderFoodID) REFERENCES $Table_Food($C_FoodID) "
        ")");

    // Create payment table
    await db.execute("CREATE TABLE $Table_Payment ("
        " $C_PaymentID INTEGER PRIMARY KEY AUTOINCREMENT, "
        " $C_PaymentMethod TEXT, "
        " $C_PaymentDate TEXT, "
        " $C_RelatedOrderID INTEGER, "
        " FOREIGN KEY ($C_RelatedOrderID) REFERENCES $Table_Order($C_OrderID) "
        ")");
  }

  Future<int> saveUser(UserModel user) async {
    var dbClient = await db;
    if (dbClient == null) {
      // Handle if database is not initialized
      return -1;
    }
    var res = await dbClient.insert(Table_User, user.toMap());
    return res;
  }

  Future<List<UserModel>> getAllUsers() async {
    var dbClient = await db;
    if (dbClient == null) {
      // Handle if database is not initialized
      return [];
    }
    var res = await dbClient.query(Table_User);
    List<UserModel> users = res.isNotEmpty
        ? res.map((user) => UserModel.fromMap(user)).toList()
        : [];
    return users;
  }

  Future<UserModel?> getLoginUser(String username, String password) async {
    var dbClient = await db;
    if (dbClient == null) {
      // Handle if database is not initialized
      return null;
    }
    var res = await dbClient.rawQuery(
      "SELECT * FROM $Table_User WHERE "
          "$C_UserName = ? AND "
          "$C_Password = ?",
      [username, password],
    );

    if (res.isNotEmpty) {
      return UserModel.fromMap(res.first);
    }

    return null;
  }

  Future<int> updateUser(UserModel user) async {
    var dbClient = await db;
    if (dbClient == null) {
      // Handle if database is not initialized
      return -1;
    }
    var res = await dbClient.update(Table_User, user.toMap(),
        where: '$C_UserID = ?', whereArgs: [user.user_id]);
    return res;
  }

  Future<int> deleteUser(String user_id) async {
    var dbClient = await db;
    if (dbClient == null) {
      // Handle if database is not initialized
      return -1;
    }
    var res = await dbClient
        .delete(Table_User, where: '$C_UserID = ?', whereArgs: [user_id]);
    return res;
  }



  Future<UserModel?> getUserById(int userId) async {
    var dbClient = await db;
    var res = await dbClient?.query(Table_User,
        where: '$C_UserID = ?', whereArgs: [userId]);
    return res!.isNotEmpty ? UserModel.fromMap(res.first) : null;
  }

  // Methods for Food operations
  Future<int> saveFood(FoodModel food) async {
    var dbClient = await db;
    if (dbClient == null) {
      // Handle if database is not initialized
      return -1;
    }
    var res = await dbClient.insert(Table_Food, food.toMap());
    return res;
  }

  Future<List<FoodModel>> getAllFoods() async {
    var dbClient = await db;
    if (dbClient == null) {
      // Handle if database is not initialized
      return [];
    }
    var res = await dbClient.query(Table_Food);
    List<FoodModel> foods = res.isNotEmpty
        ? res.map((food) => FoodModel.fromMap(food)).toList()
        : [];
    return foods;
  }

  Future<int> updateFood(FoodModel food) async {
    var dbClient = await db;
    if (dbClient == null) {
      // Handle if database is not initialized
      return -1;
    }
    var res = await dbClient.update(Table_Food, food.toMap(),
        where: '$C_FoodID = ?', whereArgs: [food.food_id]);
    return res;
  }

  Future<int> deleteFood(String foodId) async {
    var dbClient = await db;
    if (dbClient == null) {
      // Handle if database is not initialized
      return -1;
    }
    var res = await dbClient
        .delete(Table_Food, where: '$C_FoodID = ?', whereArgs: [foodId]);
    return res;
  }

  Future<Object?> getLoggedInUserId() async {
    var dbClient = await db;
    if (dbClient == null) {
      print("Error: Database is not initialized.");
      return null;
    }
    try {
      // Execute SQL query to retrieve the logged-in user ID
      var res = await dbClient.rawQuery("SELECT $C_UserID FROM $Table_User");
      if (res.isNotEmpty) {
        return res.first[C_UserID];
      } else {
        print("Error: No logged-in user found.");
        return null;
      }
    } catch (e) {
      print("Error retrieving logged-in user ID: $e");
      return null;
    }
  }


  // Method to save order
  Future<int> saveOrder(OrderModel order) async {
    var dbClient = await db;
    if (dbClient == null) {
      // Handle if database is not initialized
      return -1;
    }
    var res = await dbClient.insert(Table_Order, order.toMap());
    return res;
  }

  // Method to get all orders
  Future<List<OrderModel>> getAllOrders() async {
    var dbClient = await db;
    if (dbClient == null) {
      // Handle if database is not initialized
      return [];
    }
    var res = await dbClient.query(Table_Order);
    List<OrderModel> orders = res.isNotEmpty
        ? res.map((order) => OrderModel.fromMap(order)).toList()
        : [];
    return orders;
  }

  Future<int> deleteOrder(int orderId) async {
    var dbClient = await db;
    if (dbClient == null) {
      // Handle if database is not initialized
      return -1;
    }
    var res = await dbClient.delete(
      Table_Order,
      where: '$C_OrderID = ?',
      whereArgs: [orderId],
    );
    return res;
  }

  // Method to get food by ID
  Future<FoodModel?> getFoodById(int foodId) async {
    var dbClient = await db;
    var res = await dbClient!.query(
      Table_Food,
      where: '$C_FoodID = ?',
      whereArgs: [foodId],
    );
    return res.isNotEmpty ? FoodModel.fromMap(res.first) : null;
  }

  Future<int> updateUserProfile(String username, String email, int userId) async {
    var dbClient = await db;
    if (dbClient == null) {
      return -1;
    }
    var res = await dbClient.update(Table_User, {'user_name': username, 'email': email},
        where: '$C_UserID = ?', whereArgs: [userId]);
    return res;
  }

  Future<Map<String, dynamic>> getUserProfile(int userId) async {
    var dbClient = await db;
    if (dbClient == null) {
      return {};
    }
    var res = await dbClient.query(Table_User,
        where: '$C_UserID = ?', whereArgs: [userId]);
    return res.isNotEmpty ? res.first : {};
  }

  // Method to save payment
  Future<int> savePayment(PaymentModel payment) async {
    var dbClient = await db;
    if (dbClient == null) {
      return -1;
    }
    var res = await dbClient.insert(Table_Payment, payment.toMap());
    return res;
  }

}
