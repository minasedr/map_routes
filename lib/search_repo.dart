import 'dart:convert';

import 'package:http/http.dart' as http;

Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
  const String nominatimUrl = 'https://nominatim.openstreetmap.org/search';
  final Map<String, String> params = {
    'q': query,
    'format': 'json',
    'limit': '5', // Limit suggestions to 5 results
  };

  final uri = Uri.parse(nominatimUrl).replace(queryParameters: params);
  final response = await http.get(uri);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body) as List;
    return data.map((place) => place as Map<String, dynamic>).toList();
  } else {
    throw Exception(
        'Failed to fetch suggestions. Status code: ${response.statusCode}');
  }
}
