import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:weather_app/bloc/weather_bloc.dart';
import 'package:weather_app/models/weather.dart';
import 'package:weather_app/repository/weather_repository.dart';
import 'package:charcode/charcode.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<WeatherBloc>(
          create: (context) => WeatherBloc(WeatherRepository()),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _weatherRepository = WeatherRepository();

  Weather? _weather = Weather.empty();

  final _key = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _weather != null
                ? _buildWeatherView(context, _weather!)
                : Container(
                    height: MediaQuery.of(context).size.height / 2,
                    width: MediaQuery.of(context).size.width,
                  ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 2,
              child: SizedBox(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.fromLTRB(50, 0, 0, 0),
                        child: Form(
                          key: _key,
                          child: TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Enter a City!";
                              }
                              return null;
                            },
                            onSaved: (value) async {
                              final _data = await _weatherRepository
                                  .fetchWeather(value as String);
                              setState(() {
                                this._weather = _data;
                              });
                            },
                            decoration: InputDecoration(
                              labelText: "Enter City",
                              labelStyle: TextStyle(
                                color: Colors.white,
                              ),
                              fillColor: Colors.white,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(25.0),
                                ),
                                borderSide: BorderSide(
                                  color: Colors.white,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(25.0),
                                ),
                                borderSide: BorderSide(
                                  color: Colors.red,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(
                                    25.0,
                                  ),
                                ),
                                borderSide: BorderSide(
                                  color: Colors.white,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(
                                    25.0,
                                  ),
                                ),
                              ),
                            ),
                            cursorColor: Colors.white,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      flex: 5,
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.fromLTRB(10, 10, 50, 0),
                        child: ElevatedButton(
                          onPressed: () {
                            if (_key.currentState!.validate()) {
                              _key.currentState!.save();
                            }
                          },
                          child: Icon(
                            Icons.search,
                            size: 32,
                          ),
                          style: ElevatedButton.styleFrom(
                            shadowColor: Colors.transparent,
                            primary: Colors.transparent,
                            elevation: 0.0,
                            onSurface: Colors.transparent,
                            splashFactory: NoSplash.splashFactory,
                            
                          ),
                        ),
                      ),
                      flex: 2,
                    ),
                  ],
                ),
                height: MediaQuery.of(context).size.height / 2,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.grey[850],
      ),
    );
  }
}

Widget _buildWeatherView(BuildContext context, Weather _weather) {
  return Container(
    height: MediaQuery.of(context).size.height / 2,
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _weather.isDay
              ? Image.asset(
                  "assets/images/sunrise.png",
                  height: 275,
                  width: 275,
                  color: Colors.white,
                )
              : Image.asset(
                  "assets/images/night_sky.png",
                  height: 275,
                  width: 275,
                  color: Colors.white,
                ),
          Divider(
            height: 10,
            color: Colors.transparent,
          ),
          Center(
            child: Text(
              "${_weather.city} - ${_weather.temp} ${String.fromCharCode($deg)}C",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ],
      ),
    ),
  );
}
