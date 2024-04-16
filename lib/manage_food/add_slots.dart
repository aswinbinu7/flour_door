import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Database/database_helper.dart';
import '../Model/TimeSlotModel.dart';

class AddTimeSlotScreen extends StatefulWidget {
  @override
  _AddTimeSlotScreenState createState() => _AddTimeSlotScreenState();
}

class _AddTimeSlotScreenState extends State<AddTimeSlotScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime selectedStartDate = DateTime.now();
  DateTime selectedEndDate = DateTime.now().add(Duration(hours: 1));

  Future<void> _selectDateTime(BuildContext context, bool isStart) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStart ? selectedStartDate : selectedEndDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(isStart ? selectedStartDate : selectedEndDate),
      );
      if (pickedTime != null) {
        final DateTime combinedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute);
        setState(() {
          if (isStart) {
            selectedStartDate = combinedDateTime;
            if (selectedEndDate.isBefore(combinedDateTime.add(Duration(hours: 1)))) {
              selectedEndDate = combinedDateTime.add(Duration(hours: 1));
            }
          } else {
            selectedEndDate = combinedDateTime;
          }
        });
      }
    }
  }

  void _saveTimeSlot() {
    if (_formKey.currentState!.validate()) {
      TimeSlot newSlot = TimeSlot(
        startTime: selectedStartDate,
        endTime: selectedEndDate,
        isBooked: false,
      );
      DbHelper().addTimeSlot(newSlot).then((_) {
        Navigator.pop(context);
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding time slot: $error')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    TextStyle largerTextStyle = TextStyle(fontSize: 18); // Larger text style for better visibility
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text('Add Time Slot', style: largerTextStyle),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                InkWell(
                  onTap: () => _selectDateTime(context, true),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Row(
                      children: [
                        Expanded(child: Text('Start Date:', style: largerTextStyle)),
                        Text(DateFormat('yyyy-MM-dd – HH:mm').format(selectedStartDate), style: largerTextStyle),
                        Icon(Icons.calendar_today_outlined, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => _selectDateTime(context, false),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Row(
                      children: [
                        Expanded(child: Text('End Date:', style: largerTextStyle)),
                        Text(DateFormat('yyyy-MM-dd – HH:mm').format(selectedEndDate), style: largerTextStyle),
                        Icon(Icons.calendar_today_outlined, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _saveTimeSlot,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 60), // Larger button
                    textStyle: largerTextStyle,
                  ),
                  child: Text('Save Time Slot'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
