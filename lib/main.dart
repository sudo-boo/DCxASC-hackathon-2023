import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

Future<Map<String, Map<String, String>>?> createLookupTable() async {
  String data = await rootBundle.loadString('assets/data.json');
  Map<String, Map<String, String>> lookupTable = {};

  Map<String, dynamic> jsonData = json.decode(data);
  jsonData.forEach((userId, userData) {
    lookupTable[userId] = Map<String, String>.from(userData);
  });

  return lookupTable;
}

void main() {
  runApp(MaterialApp(
    home: QRScannerScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class QRScannerScreen extends StatefulWidget {
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey();
  Barcode? result;
  final String gateID = "67v9ab8cpx";
  Map<String, Map<String, String>> lookupTable = {};

  @override
  void initState() {
    super.initState();
    initializeLookupTable();
  }

  Future<void> initializeLookupTable() async {
    Map<String, Map<String, String>>? table = await createLookupTable();
    if (table != null) {
      setState(() {
        lookupTable = table;
      });
    }
  }

  QRViewController? controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Scanner'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: (controller) {
                this.controller = controller;
                controller.scannedDataStream.listen((scanData) {
                  if (result == null) {
                    setState(() {
                      result = scanData;
                    });
                    // Stop scanning
                    controller.stopCamera();
                    // Show QR data in a dialog
                    _showQRDataDialog(context, result!.code ?? "No QR found");
                  }
                });
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: (result != null)
                  ? Text(
                'QR Code Data: ${result!.code}',
                style: TextStyle(fontSize: 18),
              )
                  : Text('Scan a QR code'),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Reload the data from the JSON file and update the UI
          _showLookupTableDialog(context);
        },
        child: Icon(Icons.refresh),
      ),
    );
  }


  Future<void> _showQRDataDialog(BuildContext context, String data) async {
    if (lookupTable.containsKey(data)) {
      Map<String, String> userData = lookupTable[data]!;
      String dateTime = userData['date_time'] ?? '';
      String eventId = userData['event_id'] ?? '';
      String guardId = userData['guard_id'] ?? '';
      int attendedBool = int.parse(userData['attended_bool'] ?? '0');

      if (attendedBool == 0) {
        // If attended is 0, change it to 1
        userData['attended_bool'] = '1';

        // Update the JSON data directly
        lookupTable[data] = userData;

        // Convert the lookup table back to a JSON string
        final updatedJsonContent = json.encode(lookupTable);

        // Get the document directory path
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/data.json';

        // Write the updated JSON content back to the file
        await File(filePath).writeAsString(updatedJsonContent);

        // Update the state with the new JSON data
        setState(() {
          // Do something with the updated JSON content, if needed
        });
      }

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('QR Code Data'),
            content: Column(
              children: <Widget>[
                Text('Date Time: $dateTime'),
                Text('Event ID: $eventId'),
                Text('Guard ID: $guardId'),
                Text('Attended Bool: $attendedBool'),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Resume scanning
                  controller?.resumeCamera();
                  setState(() {
                    result = null;
                  });
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('QR Code Data'),
            content: Text('User ID not found'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _showLookupTableDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Lookup Table Data'),
          content: SingleChildScrollView(
            child: Column(
              children: lookupTable.entries.map((entry) {
                final userId = entry.key;
                final userData = entry.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("User ID: $userId"),
                    Text("Date Time: ${userData['date_time']}"),
                    Text("Event ID: ${userData['event_id']}"),
                    Text("Guard ID: ${userData['guard_id']}"),
                    Text("Attended Bool: ${userData['attended_bool']}"),
                  ],
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
