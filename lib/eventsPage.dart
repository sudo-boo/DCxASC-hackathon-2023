import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final List<String> eventNames = [
    'Life Lessons With Top G',
    'Quantum Computing...What\'s that??',
    'Ludo Championship',
    'AI Girlfriends: An undiscovered phenomenon'
  ];

  final List<bool> bookings = [false, false, false, false];
  Map<int, String> existingKeys = {};

  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<void> _storeBookingKeys(Map<int, String> bookingKeys) async {
    String formattedKeys = bookingKeys.entries.map((entry) {
      return '${entry.key}:${entry.value}';
    }).join(',');

    await _storage.write(key: 'booking_keys', value: formattedKeys);
  }

  Future<void> _getStoredKeys() async {
    Map<int, String> storedKeys = await _getBookingKeys();
    setState(() {
      existingKeys = storedKeys;
      for (int i = 0; i < eventNames.length; i++) {
        bookings[i] = existingKeys.containsKey(i + 1);
      }
    });
  }

  Future<Map<int, String>> _getBookingKeys() async {
    String? encodedKeys = await _storage.read(key: 'booking_keys');
    if (encodedKeys != null) {
      List<String> keyPairs = encodedKeys.split(',');
      Map<int, String> decodedKeys = {};

      keyPairs.forEach((keyPair) {
        List<String> parts = keyPair.split(':');
        if (parts.length == 2) {
          int key = int.tryParse(parts[0].trim()) ?? 0;
          String value = parts[1].trim();
          decodedKeys[key] = value;
        }
      });

      return decodedKeys;
    } else {
      return {};
    }
  }

  String _generateBookingKey(int userId, List<int> eventIds) {
    DateTime now = DateTime.now();
    String bookingKey = '$userId-${eventIds.join('-')}';
    print('Booking Key: $bookingKey'); // Print booking key to terminal
    return bookingKey;
  }

  @override
  void initState() {
    super.initState();
    _getStoredKeys();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Book Your Seats"),
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: eventNames.length,
          itemBuilder: (context, index) {
            int eventId = index + 1;

            return EventCard(onScanQR: () async{
              String barcodeScanRes;

              barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
                  "#ff6666", "Cancel", true, ScanMode.QR);
              print(barcodeScanRes);
            },Entrypoint: "!",
              eventName: eventNames[index],
              isBooked: bookings[index],
              onBookPressed: () async {
                int userId = 1;
                List<int> eventIds = [eventId, eventId+1];

                String bookingKey = _generateBookingKey(userId, eventIds);

                existingKeys[eventId] = bookingKey;
                await _storeBookingKeys(existingKeys);

                setState(() {
                  bookings[index] = true;
                });
              },
              hasBooking: existingKeys.containsKey(eventId),
              bookingKey: existingKeys[eventId] ?? '',
            );
          },
        ),
      ),
    );
  }
}
class EventCard extends StatelessWidget {
  final String eventName;
  final bool isBooked;
  final bool hasBooking;
  final VoidCallback onBookPressed;
  final String bookingKey;
  final VoidCallback onScanQR;
  final String Entrypoint;

  const EventCard({
    required this.eventName,
    required this.isBooked,
    required this.hasBooking,
    required this.onBookPressed,
    required this.bookingKey,
    required this.onScanQR,
    required this.Entrypoint,
  });

  void _showTicketDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Ticket Details"),
          content: Text("Event: $eventName\nBooking Key: $bookingKey"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color.fromRGBO(246, 244, 235, 1),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 0, right: 12, top: 5),
                  child: Image.network(
                    "https://images.unsplash.com/photo-1508515053963-70c7cc39dfb5?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2960&q=80",
                    height: 150,
                    width: 150,
                  ),
                ),
                Flexible(
                  child: Text(
                    eventName,
                    softWrap: true,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: !isBooked && !hasBooking ? onBookPressed : onScanQR,
                child: Text(isBooked ? "Scan QR" : "Book Seat"),
              ),
              ElevatedButton(
                onPressed: hasBooking ? () => _showTicketDetails(context) : null,
                child: Text(hasBooking ? "View Ticket" : "Not Booked"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

