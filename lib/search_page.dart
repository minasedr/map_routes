import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_routes/search_repo.dart';
import 'package:http/http.dart' as http;

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  LatLng? source;
  List suggestions = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Padding(padding: EdgeInsets.all(10)),
          SizedBox(
            height: 60,
            width: 300,
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: 'Search for a pickup place',
                contentPadding: EdgeInsets.all(16.0),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) async {
                if (value.isEmpty) {
                  suggestions = [];
                } else {
                  suggestions = await searchPlaces(value);
                }
                setState(() {});
              },
            ),
          ),
          SizedBox(
            height: 100,
            width: 400,
            child: Expanded(
              child: ListView.builder(
                itemCount: suggestions.length,
                itemBuilder: (context, index) {
                  final place = suggestions[index];
                  return GestureDetector(
                    onTap: () {
                      searchController.text = place['display_name'];
                      suggestions = [];
                      setState(() async {
                        source = await getLocation(place['display_name']);
                      });
                    },
                    child: ListTile(
                      title: LocationCard(
                        placeName:
                            parseLocation(place['display_name'])['placeName']!,
                        address:
                            parseLocation(place['display_name'])['address']!,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Column(
            children: [
              Text(
                'Source: $source',
                style: const TextStyle(fontSize: 18.0),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<LatLng> getLocation(String location) async {
  String baseURL =
      "https://nominatim.openstreetmap.org/search?format=json&q=$location";

  final response = await http.get(Uri.parse(baseURL));

  final loc = jsonDecode(response.body)[0];

  final latitude = loc['lat'];
  final longitude = loc['long'];

  return LatLng(latitude, longitude);
}

Map<String, String> parseLocation(String locationString) {
  final parts = locationString.split(',');
  if (parts.length < 3) {
    return {'placeName': locationString, 'address': ''};
  }

  final placeName = parts.sublist(0, 3).join(', ');
  final address = parts.skip(3).join(', ');

  return {'placeName': placeName, 'address': address};
}

class LocationCard extends StatelessWidget {
  final String placeName;
  final String address;

  const LocationCard({
    super.key,
    required this.placeName,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Avoid excessive card height
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              placeName,
              style:
                  const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4.0), // Add some vertical spacing
            Text(
              address,
              style: const TextStyle(fontSize: 14.0, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
