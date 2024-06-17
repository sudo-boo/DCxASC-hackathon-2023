import 'package:flutter/services.dart';
import 'dart:convert';

// Define a function to create the lookup table from the asset file
Future<Map<String, String>> createLookupTable() async {
  String data = await rootBundle.loadString('assets/data.txt');
  Map<String, String> lookupTable = {};

  Iterable<String> lines = LineSplitter.split(data);
  for (String line in lines) {
    List<String> parts = line.split('-|-');
    if (parts.length >= 1) {
      String userId = parts[0].trim();
      lookupTable[userId] = line;
    }
  }
  return lookupTable;
}
