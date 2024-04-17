import 'package:flutter/material.dart';

import 'package:flutter_sms/flutter_sms.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<String> phone = ["8009396321", "7980234043", "9696079958"];
String message = "I am in emergency pls help";

const String phoneKey = 'phone';
const String messageKey = 'message';

class SMSService {
  static void _sendSMS(String message, List<String> recipents) async {
    String result = await sendSMS(message: message, recipients: recipents)
        .catchError((onError) {
      print(onError);
    });
    print(result);
  }
}

class SOSButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
        onPressed: () async {
          // Get the current location of the user
          final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );

          // Create the message with the current location
          final messageWithLocation =
              '$message \n My current location is: \n https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}';

          // Launch the phone app with the contact number and message
          SMSService._sendSMS(messageWithLocation, phone);
        },
        child: Icon(Icons.emergency_outlined));
  }
}

class SMSPage extends StatefulWidget {
  const SMSPage({super.key});

  @override
  _SMSPageState createState() => _SMSPageState();
}

class _SMSPageState extends State<SMSPage> {
  TextEditingController _messageController = TextEditingController();
  TextEditingController _recipientController1 = TextEditingController();
  TextEditingController _recipientController2 = TextEditingController();
  TextEditingController _recipientController3 = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SOS Emergency'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    child: Text(
                      phone[0],
                      style: TextStyle(color: Colors.white),
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(15),
                    child: Text(
                      phone[1],
                      style: TextStyle(color: Colors.white),
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(15),
                    child: Text(
                      phone[2],
                      style: TextStyle(color: Colors.white),
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                  ),
                ],
              ),
            ),//display 3 phone numbers
            SizedBox(height: 20),
            TextField(
              controller: _recipientController1,
              decoration: InputDecoration(
                labelText: 'Recipient 1',
              ),
            ),//input for 1st recipient
            SizedBox(height: 16),
            TextField(
              controller: _recipientController2,
              decoration: InputDecoration(
                labelText: 'Recipient 2',
              ),
            ),//input for 2nd recipient
            SizedBox(height: 16),
            TextField(
              controller: _recipientController3,
              decoration: InputDecoration(
                labelText: 'Recipient 3',
              ),
            ),//input for 3rd recipient
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String phone1 = _recipientController1.text;
                String phone2 = _recipientController2.text;
                String phone3 = _recipientController3.text;

                List<String> recipents = [phone1, phone2, phone3];

                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setStringList(phoneKey, recipents);

                if (recipents.isNotEmpty) {
                  setState(() {
                    List<String> phone_cache = prefs.getStringList(phoneKey) ??
                        ["8009396321", "7980234043", "9696079958"];

                    for (int i = 0; i < 3; i++) {
                      phone[i] = phone_cache[i];
                    }
                  });

                  _recipientController1.clear();
                  _recipientController2.clear();
                  _recipientController3.clear();
                } else {
                  showDialog(
                    context: context,
                    builder: (_) => const AlertDialog(
                      title: Text('Error'),
                      content: Text('Please enter recipient and message.'),
                    ),
                  );
                }
              },
              child: Text('Set Phone'),
            ),//saving recipients button
            SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(15),
              child: Text(
                message,
                style: TextStyle(color: Colors.white),
              ),
              decoration: const BoxDecoration(
                color: Colors.blueGrey,
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
            ),//display the text message
            SizedBox(height: 16),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: 'Enter your message',
              ),
              maxLines: 1,
            ),//input for the text message
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String emergency_message = _messageController.text;

                if (emergency_message.isNotEmpty) {
                  setState(() async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.setString(messageKey, emergency_message);

                    String message_cache = prefs.getString(messageKey) ??
                        "I am in emergency pls help";

                    message = message_cache;
                    _messageController.clear();
                  });

                } else {
                  showDialog(
                    context: context,
                    builder: (_) => const AlertDialog(
                      title: Text('Error'),
                      content: Text('Please enter recipient and message.'),
                    ),
                  );
                }
              },
              child: Text('Set SMS'),
            ),//button for saving the text message
            SizedBox(height: 20),
            SOSButton()//the main sos button for sending the sos message
          ],
        ),
      ),
    );
  }
}
