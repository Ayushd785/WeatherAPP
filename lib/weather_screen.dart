import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:weatherapp/additional_info_item.dart';
import 'package:weatherapp/hourly_forecast_item.dart';
import 'package:http/http.dart' as http;
import 'package:weatherapp/secrets.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      String cityname = 'London';
      final res = await http.get(
        Uri.parse(
            'https://api.openweathermap.org/data/2.5/forecast?q=$cityname,uk&APPID=$openWeatherAPIKey'),
      );
      final data = jsonDecode(res.body);

      if (data['cod'] != '200') {
        throw 'An unexpected error occoured';
      }
      return data;

      //
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              print('refresh');
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder(
        future: getCurrentWeather(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
              ),
            );
          }

          final data = snapshot.data!;

          final currenttemp = (data['list'][0]['main']['temp']);
          final currentsky = (data['list'][0]['weather'][0]['main']);
          final currentPressure = (data['list'][0]['main']['pressure']);
          final currentWind = (data['list'][0]['wind']['speed']);
          final currentHumidity = (data['list'][0]['main']['humidity']);
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // main card
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 10,
                          sigmaY: 10,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text(
                                '$currenttemp k',
                                style: const TextStyle(
                                    fontSize: 32, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Icon(
                                currentsky == 'Clouds' || currentsky == 'Rain'
                                    ? Icons.cloud
                                    : Icons.sunny,
                                size: 70,
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Text(
                                currentsky,
                                style: const TextStyle(fontSize: 30),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // weatherforecast
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Hourly Forecast',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                // weather forecast cards
                const SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      HourlyForecastItem(
                        time: '09:00',
                        icon: Icons.cloud,
                        temperature: '320.12',
                      ),
                      HourlyForecastItem(
                        time: '12:00',
                        icon: Icons.sunny,
                        temperature: '340.82',
                      ),
                      HourlyForecastItem(
                        time: '15:00',
                        icon: Icons.sunny,
                        temperature: '330.18',
                      ),
                      HourlyForecastItem(
                        time: '18:00',
                        icon: Icons.cloud,
                        temperature: '316.17',
                      ),
                      HourlyForecastItem(
                        time: '21:00',
                        icon: Icons.cloud_circle_sharp,
                        temperature: '314.12',
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),
                // additional information
                const Text(
                  'Additional Forecast',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    AdditionalInfoItems(
                      icon: Icons.water_drop,
                      label: 'Humidity',
                      value: currentHumidity.toString(),
                    ),
                    AdditionalInfoItems(
                      icon: Icons.air,
                      label: 'Wind speed',
                      value: currentWind.toString(),
                    ),
                    AdditionalInfoItems(
                      icon: Icons.beach_access,
                      label: 'Pressure',
                      value: currentPressure.toString(),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
