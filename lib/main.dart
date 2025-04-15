import 'package:flutter/material.dart';
import 'dart:math';
import 'tennis_courts.dart';

void main() {
  runApp(FindTennisCourtApp());
}

class FindTennisCourtApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Find Tennis Court',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

const Map<String, List<double>> cityCoordinates = {
  'San Ramon': [37.7675, -121.958],
  'Pleasanton': [37.6624, -121.8747],
  'Walnut Creek': [37.9101, -122.0652],
  'Fremont': [37.5483, -121.9886],
  'Berkeley': [37.8716, -122.2727],
  'San Francisco': [37.7749, -122.4194],
  'San Jose': [37.3382, -121.8863],
  'Dublin': [37.7022, -121.9358],
  'Danville': [37.8216, -121.9996],
  'Mountain View': [37.3861, -122.0839],
  'Palo Alto': [37.4419, -122.1430],
  'Redwood City': [37.4852, -122.2364],
};

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedCity1;
  String? selectedCity2;
  List<TennisCourt> topCourts = [];

  void findTopCourts() {
    if (selectedCity1 == null || selectedCity2 == null) {
      setState(() {
        topCourts = [];
      });
      return;
    }

    final coords1 = cityCoordinates[selectedCity1]!;
    final coords2 = cityCoordinates[selectedCity2]!;

    final midLat = (coords1[0] + coords2[0]) / 2;
    final midLon = (coords1[1] + coords2[1]) / 2;

    final sorted = tennisCourts
        .map((court) => MapEntry(court, haversine(midLat, midLon, court.latitude, court.longitude)))
        .toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    setState(() {
      topCourts = sorted.take(3).map((e) => e.key).toList();
    });
  }

  double haversine(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // Earth radius in km
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(double deg) => deg * (pi / 180);

  bool isPrivateCourt(String name) {
    final lowercase = name.toLowerCase();
    return lowercase.contains('club') || lowercase.contains('country') || lowercase.contains('bay club');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🎾 Find Tennis Court'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text("Select your cities:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCity1,
                decoration: InputDecoration(
                  labelText: 'Your City',
                  border: OutlineInputBorder(),
                ),
                items: cityCoordinates.keys.map((city) {
                  return DropdownMenuItem(value: city, child: Text(city));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCity1 = value;
                  });
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCity2,
                decoration: InputDecoration(
                  labelText: 'Friend\'s City',
                  border: OutlineInputBorder(),
                ),
                items: cityCoordinates.keys.map((city) {
                  return DropdownMenuItem(value: city, child: Text(city));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCity2 = value;
                  });
                },
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: findTopCourts,
                icon: Icon(Icons.sports_tennis),
                label: Text('Find Courts'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                  backgroundColor: Colors.teal,
                ),
              ),
              SizedBox(height: 30),
              if (topCourts.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("🎯 Top 3 Closest Courts", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    SizedBox(height: 16),
                    ...topCourts.asMap().entries.map((entry) {
                      final index = entry.key;
                      final court = entry.value;
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        margin: EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${index + 1}. ${court.name}",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              if (isPrivateCourt(court.name))
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text("🔒 Private Court", style: TextStyle(color: Colors.red)),
                                ),
                              SizedBox(height: 8),
                              Text("📍 Lat: ${court.latitude}, Lon: ${court.longitude}"),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
