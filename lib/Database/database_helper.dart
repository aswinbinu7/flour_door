import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io' as io;

import '../Model/FeedbackModel.dart';
import '../Model/OrderModel.dart';
import '../Model/PaymentModel.dart';
import '../Model/TimeSlotModel.dart';
import '../Model/UserModel.dart';
import '../Model/FoodModel.dart';

class DbHelper {
  static Database? _db;

  static const String DB_Name = 'flour_door_order.db';
  static const String Table_User = 'user';
  static const String Table_Food = 'food';
  static const String Table_Order = 'orders'; // Renamed table to "orders"
  static const String Table_Payment = 'payment';
  static const String Table_Feedback = 'feedback';
  static const String Table_TimeSlots = 'time_slots';

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

  // Columns for payment table
  static const String C_PaymentID = 'payment_id';
  static const String C_PaymentMethod = 'payment_method';
  static const String C_PaymentDate = 'payment_date';
  static const String C_RelatedOrderID = 'related_order_id';

  // Columns for feedback table
  static const String C_FeedbackID = 'feedback_id';
  static const String C_FeedbackUserName = 'user_name';
  static const String C_UserFeedback = 'user_feedback';

  // Columns for time slots table
  static const String C_SlotID = 'slot_id';
  static const String C_StartTime = 'start_time';
  static const String C_EndTime = 'end_time';
  static const String C_IsBooked = 'is_booked';  // 0 = available, 1 = booked
  static const String C_BookedBy = 'booked_by';  // User ID of the user who booked the slot
  static const String C_BookedByName = 'booked_by_name';  // Name of the person who booked the slot
  static const String C_BookedByContact = 'booked_by_contact';  // Contact of the person who booked the slot

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
    await db.execute("PRAGMA foreign_keys = ON;");
    return db;
  }

  _onCreate(Database db, int intVersion) async {
    // Create user table
    await db.execute("CREATE TABLE $Table_User ("
        " $C_UserID INTEGER PRIMARY KEY AUTOINCREMENT, "
        " $C_UserName TEXT, "
        " $C_Email TEXT, "
        " $C_Password TEXT)");

    // Create food table
    await db.execute("CREATE TABLE $Table_Food ("
        " $C_FoodID INTEGER PRIMARY KEY AUTOINCREMENT, "
        " $C_FoodName TEXT, "
        " $C_Price REAL, "
        " $C_Description TEXT)");

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
        " $C_Address TEXT, "
        " FOREIGN KEY ($C_OrderUserID) REFERENCES $Table_User($C_UserID), "
        " FOREIGN KEY ($C_OrderFoodID) REFERENCES $Table_Food($C_FoodID) "
        ")");

    // Create payment table
    await db.execute("CREATE TABLE $Table_Payment ("
        " $C_PaymentID INTEGER PRIMARY KEY AUTOINCREMENT, "
        " $C_PaymentMethod TEXT, "
        " $C_PaymentDate TEXT, "
        " $C_RelatedOrderID INTEGER, "
        " FOREIGN KEY ($C_RelatedOrderID) REFERENCES $Table_Order($C_OrderID))");

    // Create feedback table
    await db.execute("CREATE TABLE $Table_Feedback ("
        " $C_FeedbackID INTEGER PRIMARY KEY AUTOINCREMENT, "
        " $C_FeedbackUserName TEXT NOT NULL, "
        " $C_UserFeedback TEXT NOT NULL)");

    // Create time slots table
    await db.execute("CREATE TABLE $Table_TimeSlots ("
        " $C_SlotID INTEGER PRIMARY KEY AUTOINCREMENT, "
        " $C_StartTime TEXT NOT NULL, "
        " $C_EndTime TEXT NOT NULL, "
        " $C_IsBooked INTEGER DEFAULT 0, "
        " $C_BookedBy INTEGER, "
        " $C_BookedByName TEXT, "
        " $C_BookedByContact TEXT, "
        " FOREIGN KEY ($C_BookedBy) REFERENCES $Table_User($C_UserID))");
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

  // Method to print user table
  Future<void> printUserTable() async {
    final dbClient = await db;
    List<Map> list = await dbClient!.query(Table_User);
    print("User Table Data: ");
    list.forEach((row) {
      print(row);
    });
  }

  // Method to print food table
  Future<void> printFoodTable() async {
    final dbClient = await db;
    List<Map> list = await dbClient!.query(Table_Food);
    print("Food Table Data: ");
    list.forEach((row) {
      print(row);
    });
  }

  // Method to print orders table
  Future<void> printOrdersTable() async {
    final dbClient = await db;
    List<Map> list = await dbClient!.query(Table_Order);
    print("Orders Table Data: ");
    list.forEach((row) {
      print(row);
    });
  }

  // Method to print orders table
  Future<void> printSlotTable() async {
    final dbClient = await db;
    List<Map> list = await dbClient!.query(Table_TimeSlots);
    print("Slots Table Data: ");
    list.forEach((row) {
      print(row);
    });
  }

  // Method to print payment table
  Future<void> printPaymentTable() async {
    final dbClient = await db;
    List<Map> list = await dbClient!.query(Table_Payment);
    print("Payment Table Data: ");
    list.forEach((row) {
      print(row);
    });
  }

  Future<List<OrderModel>> getOrdersByUserId(int userId) async {
    var dbClient = await db; // Get the database instance
    if (dbClient != null) {
      List<Map<String, dynamic>> result = await dbClient.query(
          Table_Order,
          where: '$C_OrderUserID = ?', // Use the column name for user ID in orders table
          whereArgs: [userId]
      );

      return result.map((data) => OrderModel.fromMap(data)).toList();
    } else {
      return [];
    }
  }

  // Method to insert feedback using a Feedback object
  Future<void> insertFeedback(UserFeedback feedback) async {
    final dbClient = await db;
    await dbClient?.insert(Table_Feedback, feedback.toMap());
  }

  Future<List<UserFeedback>> getFeedbacks() async {
    final db = await this.db;
    final List<Map<String, dynamic>> maps = await db!.query(DbHelper.Table_Feedback);

    return List.generate(maps.length, (i) {
      return UserFeedback.fromMap(maps[i] as Map<String, dynamic>);
    });
  }

  // Add a new time slot
  Future<void> addTimeSlot(TimeSlot slot) async {
    final dbClient = await db; // make sure you have a getter for `db`
    await dbClient!.insert(
      Table_TimeSlots, // Table name as defined in DbHelper
      slot.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }


// Fetch all available time slots
  Future<List<Map<String, dynamic>>> fetchAvailableSlots() async {
    var dbClient = await db;
    var result = await dbClient!.query(
      Table_TimeSlots,
      where: "$C_IsBooked = ?",
      whereArgs: [0],
    );
    return result;
  }

// Book a time slot
  Future<void> bookTimeSlot(int slotId, int userId) async {
    var dbClient = await db;
    await dbClient!.update(
      Table_TimeSlots,
      {
        C_IsBooked: 1,
        C_BookedBy: userId,
      },
      where: "$C_SlotID = ?",
      whereArgs: [slotId],
    );
  }

  // Method to fetch all time slots
  Future<List<TimeSlot>> getAllSlots() async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient!.query(DbHelper.Table_TimeSlots);
    return List.generate(maps.length, (i) {
      return TimeSlot.fromMap(maps[i]);
    });
  }

// Method to fetch only available slots
  Future<List<TimeSlot>> getAvailableSlots() async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient!.query(
      DbHelper.Table_TimeSlots,
      where: '${DbHelper.C_IsBooked} = ?',
      whereArgs: [0],  // 0 means not booked
    );
    return List.generate(maps.length, (i) {
      return TimeSlot.fromMap(maps[i]);
    });
  }

  // Method to update a time slot
  Future<void> updateTimeSlot(TimeSlot slot) async {
    final dbClient = await db;
    await dbClient!.update(
      Table_TimeSlots,
      slot.toMap(),
      where: '$C_SlotID = ?',
      whereArgs: [slot.slotId],
    );
  }

  Future<List<TimeSlot>> getBookedSlots() async {
    var dbClient = await db;
    var result = await dbClient!.query(
        Table_TimeSlots,
        where: '$C_IsBooked = ?',
        whereArgs: [1]
    );

    List<TimeSlot> slots = result.isNotEmpty
        ? result.map((item) => TimeSlot.fromMap(item)).toList()
        : [];
    return slots;
  }

  Future<void> deleteTimeSlot(int slotId) async {
    var dbClient = await db;
    await dbClient!.delete(
      Table_TimeSlots,
      where: '$C_SlotID = ?',
      whereArgs: [slotId],
    );
  }

}
