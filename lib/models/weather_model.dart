class Weather {
  final String cityName;
  final double temperature;
  final String mainCondition;
  final dynamic humidity;
  final dynamic windSpeed;
  final dynamic feelsLike;

  Weather({
    required this.cityName,
    required this.mainCondition,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.feelsLike,
    });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(cityName: json['name'] + ', ' + json['sys']['country'], 
    temperature: json['main']['temp'],
    mainCondition: json['weather'][0]['main'],
    humidity: json['main']['humidity'],
    windSpeed: json['wind']['speed'],
    feelsLike: json['main']['feels_like'],
    );
  }
}