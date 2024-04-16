import 'package:flutter/material.dart';
import '../Database/database_helper.dart';
import '../Model/TimeSlotModel.dart';
import 'package:intl/intl.dart';
import '../services/preferences.dart';
import 'confirm_booking.dart';

class ViewTimeSlotsScreen extends StatefulWidget {
  @override
  _ViewTimeSlotsScreenState createState() => _ViewTimeSlotsScreenState();
}

class _ViewTimeSlotsScreenState extends State<ViewTimeSlotsScreen> {
  late Future<List<TimeSlot>> slots;
  late int userId;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() async {
    final int? id = await PreferencesService().getUserId();
    if (id != null) {
      setState(() {
        userId = id;
      });
      slots = DbHelper().getAvailableSlots(); // Load slots after fetching user ID
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text('Available Time Slots', style: Theme.of(context).textTheme.headline6),
      ),
      body: FutureBuilder<List<TimeSlot>>(
        future: slots,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: Theme.of(context).textTheme.subtitle1));
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return Center(child: Text('No available time slots', style: Theme.of(context).textTheme.subtitle1));
          } else if (snapshot.hasData) {
            return ListView.separated(
              itemCount: snapshot.data!.length,
              separatorBuilder: (_, __) => Divider(height: 1),
              itemBuilder: (context, index) {
                final slot = snapshot.data![index];
                final dateFormat = DateFormat('yyyy-MM-dd');
                final timeFormat = DateFormat('HH:mm');
                return ListTile(
                  leading: Icon(slot.isBooked ? Icons.lock : Icons.lock_open, color: slot.isBooked ? Colors.red : Colors.green),
                  title: Text(
                    'Date: ${dateFormat.format(slot.startTime)}',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'From: ${timeFormat.format(slot.startTime)} To: ${timeFormat.format(slot.endTime)}',
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
                      Text(
                        slot.isBooked ? 'Booked by ${slot.bookedByName ?? "N/A"}' : 'Available',
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
                    ],
                  ),
                  trailing: slot.isBooked ? null : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.blue, // Background color
                    ),
                    child: Text('Book'),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => BookingDetailsScreen(slot: slot))
                      ).then((_) {
                        setState(() {  // Refresh the slots list after booking
                          slots = DbHelper().getAvailableSlots();
                        });
                      });
                    },
                  ),
                );
              },
            );
          }
          return SizedBox();  // Return an empty widget for other unexpected states
        },
      ),
    );
  }
}
