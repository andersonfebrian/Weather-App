part of 'weather_bloc.dart';

@immutable
abstract class WeatherState {
  const WeatherState();
}

class WeatherInitial extends WeatherState {}

class WeatherLoading extends WeatherState {}

class FetchedWeather extends WeatherState {
  final Weather weather;
  const FetchedWeather(this.weather);
}
