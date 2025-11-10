import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> getCollections(String deviceId) async {
  final response = await http.get(
    Uri.parse('http://localhost:3000/collections/$deviceId'),
  );
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    print('Subcollections: ${data['subcollections']}');
  } else {
    print('Error: ${response.statusCode}');
  }
}
