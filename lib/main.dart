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

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: BlocConsumer<WeatherBloc, WeatherState>(
          listener: (context, state) {
            print("listener - $state");
          },
          builder: (context, state) {
            print("builder - $state");
            if (state is WeatherInitial) {
              return Column(
                children: [
                  _weatherView(context, Weather.empty(), empty: true),
                  _searchBar(context),
                ],
              );
            }

            if (state is FetchedWeather) {
              return Column(
                children: [
                  _weatherView(context, state.weather),
                  _searchBar(context),
                ],
              );
            }

            if (state is WeatherLoading) {
              return Column(
                children: [
                  _loading(context),
                  _searchBar(context),
                ],
              );
            }

            return Container();
          },
        ),
        backgroundColor: Colors.grey[850],
      ),
    );
  }
}

Widget _loading(BuildContext context) {
  return Container(
    height: MediaQuery.of(context).size.height / 2,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          color: Colors.white,
        ),
        Divider(
          height: 15.0,
          color: Colors.transparent,
        ),
        Text(
          "Loading ...",
          style: TextStyle(color: Colors.white),
        ),
      ],
    ),
  );
}

Widget _searchBar(BuildContext context) {
  final _tffBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(
        25.0,
      ),
    ),
    borderSide: BorderSide(color: Colors.white),
  );
  final _tffErrorBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(
        25.0,
      ),
    ),
    borderSide: BorderSide(
      color: Colors.red,
    ),
  );

  final _key = GlobalKey<FormState>();

  return Container(
    height: MediaQuery.of(context).size.height / 2,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.fromLTRB(50, 0, 25, 0),
            child: Form(
              key: _key,
              child: TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter a City!";
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: "Enter City",
                  labelStyle: TextStyle(
                    color: Colors.white,
                  ),
                  enabledBorder: _tffBorder,
                  focusedBorder: _tffBorder,
                  errorBorder: _tffErrorBorder,
                  focusedErrorBorder: _tffErrorBorder,
                  isDense: true,
                ),
                style: TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                onSaved: (value) => BlocProvider.of<WeatherBloc>(context)
                    .add(FetchWeather(value as String)),
              ),
            ),
          ),
          flex: 6,
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.fromLTRB(0, 0, 25, 0),
            child: ElevatedButton(
              child: Icon(Icons.search),
              onPressed: () {
                if (_key.currentState!.validate()) _key.currentState!.save();
              },
              style: ElevatedButton.styleFrom(
                shadowColor: Colors.transparent,
                primary: Colors.transparent,
                elevation: 0.0,
                onSurface: Colors.transparent,
                splashFactory: NoSplash.splashFactory,
              ),
            ),
          ),
          flex: 1,
        ),
      ],
    ),
  );
}

Widget _weatherView(BuildContext context, Weather weather,
    {bool empty = false}) {
  return Container(
    height: MediaQuery.of(context).size.height / 2,
    child: empty
        ? Column()
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              weather.isDay
                  ? Image.asset(
                      "assets/images/sunrise.png",
                      height: 280,
                      width: 280,
                      color: Colors.white,
                    )
                  : Image.asset(
                      "assets/images/night_sky.png",
                      height: 280,
                      width: 280,
                      color: Colors.white,
                    ),
              Divider(
                height: 10.0,
                color: Colors.transparent,
              ),
              Text(
                "${weather.city} - ${weather.temp} ${String.fromCharCode($deg)}C",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                ),
              ),
              Divider(
                height: 15.0,
                color: Colors.transparent,
              ),
              GestureDetector(
                child: Text(
                  "more info",
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.lightBlue[400],
                  ),
                ),
                onTap: () => showDialog(
                  context: context,
                  builder: (context) => _moreDialog(context, weather),
                ),
              ),
            ],
          ),
  );
}

Widget _moreDialog(BuildContext context, Weather weather) {
  return AlertDialog(
    title: Text("${weather.city}", style: TextStyle(color: Theme.of(context).primaryColor),),
    elevation: 0.0 ,
    backgroundColor: Colors.black,
  );
}
