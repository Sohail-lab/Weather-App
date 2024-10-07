import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:weather_app/services/weather_service.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/pages/info_page.dart';
import 'package:weather_app/pages/search_page.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final _weatherService = WeatherService('097268ebd752438a46e6f8d9eeb441e3');
  Weather? _weather;
  bool _isLoading = true;
  bool _noInternet = false;
  bool _noLocationService = false;

  _fetchWeather() async {
    setState(() {
      _isLoading = true;
      _noInternet = false;
      _noLocationService = false;
    });

    final checkService  = await Geolocator.isLocationServiceEnabled();
    if(!checkService) {
      setState(() {
        _isLoading = false;
        _noLocationService = true;
      });
    }

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      Fluttertoast.showToast(
        msg: "No Internet Connection. Please check your connection.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      setState(() {
        _isLoading = false;
        _noInternet = true;
      });
      return;
    }

    String cityName = await _weatherService.getCurrentCity();
    try {
      final weather = await _weatherService.getWeather(cityName);
      setState(() {
        _weather = weather;
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to load weather data. Please try again.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String getWeatherAnimation(String? mainCondition) {
    int currentHour = DateTime.now().hour;
    if (mainCondition == null) {
      return 'assets/blank.json';
    }
    if (currentHour >= 0 && currentHour < 7 || currentHour >= 19) {
      return 'assets/night.json';
    }
    switch (mainCondition.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return 'assets/cloudy.json';
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return 'assets/rainy.json';
      case 'thunderstorm':
        return 'assets/thunder.json';
      case 'clear':
        return 'assets/sunny.json';
      default:
        return 'assets/sunny.json';
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const InfoPage()),
            );
          },
        ),
        title: const Text("Weather"),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchPage()),
              );
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: GestureDetector(
        onDoubleTap: () {
          _fetchWeather();
        },
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.lightBlueAccent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(
                child: _noInternet
                    ? const Text(
                        "No Internet Connection",
                        style: TextStyle(fontSize: 24, color: Colors.white),
                      )
                    : _noLocationService
                    ? const Text(
                      "Location service Disabled",
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    )
                    : _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 100),
                              Text(
                                _weather?.cityName ?? "Loading city...",
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Lottie.asset(
                                getWeatherAnimation(_weather?.mainCondition),
                                width: 200,
                                height: 200,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "${_weather?.temperature ?? "N/A"}°C",
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
                              Text(
                                "Feels like ${_weather?.feelsLike ?? "N/A"}°C",
                                style: const TextStyle(
                                  fontSize: 15,
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
                                _weather?.mainCondition ?? "N/A",
                                style: const TextStyle(
                                  fontSize: 25,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Card(
                                margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
                                child: ListTile(
                                  leading: const Icon(Icons.water_drop, color: Colors.blueAccent),
                                  title: Text(
                                    "Humidity: ${_weather?.humidity ?? "N/A"}%",
                                    style: const TextStyle(fontSize: 18, color: Colors.black87),
                                  ),
                                ),
                              ),
                              Card(
                                margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
                                child: ListTile(
                                  leading: const Icon(Icons.wind_power, color: Colors.blueAccent),
                                  title: Text(
                                    "Windspeed: ${_weather?.windSpeed ?? "N/A"}",
                                    style: const TextStyle(fontSize: 18, color: Colors.black87),
                                  ),
                                ),
                              ),
                            ],
                          ),
              ),
            ),
            if (_isLoading) ...[
              const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
