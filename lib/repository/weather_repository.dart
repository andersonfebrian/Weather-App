import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:weather_app/models/weather.dart';
import 'package:http/http.dart' as http;

abstract class IWeatherRepository {
  Future<Weather> fetchWeather(String name);
}

class WeatherRepository implements IWeatherRepository {
  @override
  Future<Weather> fetchWeather(String name) async {
    try {
      final url = Uri.parse(
          "http://api.weatherapi.com/v1/current.json?key=${dotenv.env["WEATHER_API_KEY"]}&q=$name&aqi=no");
      final _data = await http.get(url);
      if (_data.statusCode == 200) {
        return Weather.fromJSON(jsonDecode(_data.body));
      } else {
        print(_data.statusCode);
      }
    } on Exception {}

    return Weather.empty();
  }
}
