import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_routes/api.dart';
import 'package:http/http.dart' as http;

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  List<LatLng> points = [];

  getCoordinates() async {
    final response = await http.get(
      getRouteURL("49.41461,8.681495", "49.420318,8.687872"),
    );

    setState(() {
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final coordinates =
            data['features'][0]['geometry']['coordinates'] as List;

        points = coordinates
            .map((e) => LatLng(e[0].toDouble(), e[1].toDouble()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(49.41461, 8.681495),
          initialZoom: 15,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          const MarkerLayer(
            markers: [
              Marker(
                point: LatLng(49.41461, 8.681495),
                width: 80,
                height: 80,
                child: Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 50,
                ),
              ),
              Marker(
                point: LatLng(49.420318, 8.687872),
                width: 80,
                height: 80,
                child: Icon(
                  Icons.location_on,
                  color: Colors.blue,
                  size: 50,
                ),
              ),
            ],
          ),
          PolylineLayer(
            polylineCulling: false,
            polylines: [
              Polyline(
                points: points,
                color: Colors.blue,
                strokeWidth: 5,
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          getCoordinates();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
