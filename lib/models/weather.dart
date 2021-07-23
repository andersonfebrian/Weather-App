class Weather {
  String city, temp;
  bool isDay;

  Weather(this.city, this.temp, this.isDay);

  factory Weather.empty(){
    return Weather("", "", false);
  }

  factory Weather.fromJSON(dynamic json) {
    return Weather(
      json["location"]["name"].toString(),
      json["current"]["temp_c"].toString(),
      json["current"]["is_day"] == 1 ? true : false,
    );
  }
}
