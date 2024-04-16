import 'package:flutter/material.dart';
import '../Database/database_helper.dart';
import '../Model/TimeSlotModel.dart';
import 'package:intl/intl.dart';

class ViewBookedSlotsScreen extends StatefulWidget {
  @override
  _ViewBookedSlotsScreenState createState() => _ViewBookedSlotsScreenState();
}

class _ViewBookedSlotsScreenState extends State<ViewBookedSlotsScreen> {
  late Future<List<TimeSlot>> bookedSlots;

  @override
  void initState() {
    super.initState();
    refreshSlots();
  }

  void refreshSlots() {
    bookedSlots = DbHelper().getBookedSlots();
  }

  void deleteSlot(int slotId) async {
    await DbHelper().deleteTimeSlot(slotId);
    refreshSlots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booked Time Slots'),
        backgroundColor: Colors.orange,
      ),
      body: FutureBuilder<List<TimeSlot>>(
        future: bookedSlots,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              if (snapshot.data!.isEmpty) {
                return Center(child: Text("No booked slots available."));
              }
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final slot = snapshot.data![index];
                  if (slot.slotId == null) return Container(); // Skip if slotId is null

                  return Dismissible(
                    key: Key(slot.slotId.toString()),
                    background: Container(color: Colors.red),
                    onDismissed: (direction) {
                      deleteSlot(slot.slotId!); // Assured not null
                    },
                    child: Card(
                      elevation: 4.0,
                      margin: EdgeInsets.all(8.0),
                      child: ListTile(
                        isThreeLine: true, // Enables three lines in ListTile for better space
                        title: Text('Date: ${DateFormat('yyyy-MM-dd').format(slot.startTime)}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Time: ${DateFormat('HH:mm').format(slot.startTime)} to ${DateFormat('HH:mm').format(slot.endTime)}'),
                            SizedBox(height: 5),
                            Text('Name: ${slot.bookedByName ?? "Not available"}'),
                            Text('Contact: ${slot.bookedByContact ?? "No contact"}'),
                          ],
                        ),
                        trailing: Icon(Icons.delete, color: Colors.red),
                      ),
                    ),
                  );
                },
              );
            }
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }
}
