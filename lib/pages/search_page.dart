import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:weather_app/services/weather_service.dart';
import 'package:weather_app/models/weather_model.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final String apikey = '097268ebd752438a46e6f8d9eeb441e3';
  var city = 'London';
  Weather? weath;
  bool _isLoading = false;
  final TextEditingController cityController = TextEditingController();
  String _errorMessage = "";

  Future<void> fetchWeather() async {
  setState(() {
    _isLoading = true;
    _errorMessage = "";
    weath = null;
  });

  // Check for internet connectivity
  if (await _hasInternetConnection()) {
    try {
      final weather = await WeatherService(apikey).getWeather(city);
      setState(() {
        _isLoading = false;
        weath = weather;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Place not found. Please try again.";
      });
    }
  } else {
    setState(() {
      _isLoading = false;
      _errorMessage = "No Internet Connection";
    });
    Fluttertoast.showToast(
      msg: "No Internet Connection",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}

  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Search Weather"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.lightBlueAccent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.lightBlueAccent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 100),
                            TextField(
                              controller: cityController,
                              decoration: InputDecoration(
                                labelText: "Enter city name",
                                labelStyle: const TextStyle(color: Colors.white),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.2),
                              ),
                              style: const TextStyle(color: Colors.white),
                              onChanged: (value) {
                                city = value;
                              },
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                fetchWeather();
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                                backgroundColor: Colors.white.withOpacity(0.7),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              child: const Text(
                                "Search",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            const SizedBox(height: 20),
                            if (_isLoading)
                              const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            else if (_errorMessage.isNotEmpty)
                              Text(
                                _errorMessage,
                                style: const TextStyle(fontSize: 20, color: Colors.red),
                              )
                            else if (weath != null)
                              Column(
                                children: [
                                  Text(
                                    "${weath?.cityName}",
                                    style: const TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w300,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "${weath?.temperature}°C",
                                    style: const TextStyle(
                                      fontSize: 60,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 10.0,
                                          color: Colors.black54,
                                          offset: Offset(3.0, 3.0),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    weath?.mainCondition ?? "N/A",
                                    style: const TextStyle(
                                      fontSize: 25,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Card(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 25.0),
                                    child: ListTile(
                                      leading: const Icon(Icons.water_drop, color: Colors.blueAccent),
                                      title: Text(
                                        "Humidity: ${weath?.humidity ?? "N/A"}%",
                                        style: const TextStyle(fontSize: 18, color: Colors.black87),
                                      ),
                                    ),
                                  ),
                                  Card(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 25.0),
                                    child: ListTile(
                                      leading: const Icon(Icons.wind_power, color: Colors.blueAccent),
                                      title: Text(
                                        "Windspeed: ${weath?.windSpeed ?? "N/A"}",
                                        style: const TextStyle(fontSize: 18, color: Colors.black87),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            else
                              const Text(
                                "Search for a city to get the weather",
                                style: TextStyle(fontSize: 16, color: Colors.white),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
