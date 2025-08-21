import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/secrets.dart';
import 'package:weather_app/weekly_forecast_item.dart';
import "hourly_forecast_item.dart";
import "additional_information.dart";
import 'package:http/http.dart' as http;
import 'package:weather_icons/weather_icons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {

  double temp = 0; 
  bool isLoading = false; //asigning value late

  @override
  void initState() {
    super.initState();
    getCurrentWeather();
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the 
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale 
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately. 
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
    } 

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();

  }

  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {

      Position position = await _determinePosition();
      double lat = position.latitude;
      double lon = position.longitude;
      //String cityName;
      final apiKey = dotenv.env['OPENWEATHER_API_KEY'];

      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      //String cityName = "Islamabad";

      final res = await http.get(
        Uri.parse("https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey"),
      );

      final data = jsonDecode(res.body);

      if (data['cod']!='200') {
        throw "An unexpected error";
      }

      return {
      'weather': data,
      'placemark': placemarks[0],
  };

    } catch (e) {
      throw e.toString();
    }
  }

  /* Future<Map<String, dynamic>> getWeatherData() async {
  final current = await getCurrentWeather();
  final weekly = await getWeeklyWeather();

  return {
    'current': current,
    'weekly': weekly,
  };
} */

  @override
  Widget build(BuildContext context) {
    final time1 = DateTime.now();
    final season = time1.month;
    final hour = time1.hour;

    final String backgroundImage;

    if (hour >= 4 && hour < 7) {
      if (season >=10 && season < 3) {
        backgroundImage = 'assets/sunrise.jpg';
      }
    }
    else if (hour >=7 && hour < 18) {
      backgroundImage = 'assets/day.jpg';
    }
    else if (hour >=18 && hour < 19) {
      backgroundImage = 'assets/sunset.jpg';
    }
    else {
      backgroundImage = 'assets/night.jpg';
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 50,
        surfaceTintColor: const Color.fromARGB(255, 0, 120, 176),
        forceMaterialTransparency: false,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.cloud),
            SizedBox(width: 8),
            Text("Sania's Weather App",
              style: TextStyle(
                fontWeight: FontWeight.bold
              ),
            ),
          ],
        ),
        
        foregroundColor: Colors.white,
        actions: [
          /*InkWell(
            onTap: () {
              print("refresh");
            },
            child: Icon(Icons.refresh),
          ),*/
          IconButton(
            tooltip: "Refresh",
            onPressed:() {
              setState(() {}
              );
            }, 
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(backgroundImage), 
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken)
                )
              ),
        child: FutureBuilder(
          future: getCurrentWeather(),
          //future: getWeatherData(),
          builder:(context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator.adaptive(
                  backgroundColor: Colors.white
                )
              );
            }
            
            if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString())
              );
            }
            
        
            final data = snapshot.data!['weather'];
            final Placemark place = snapshot.data!['placemark'];
        
            final currentCityName = data['city']['name'];
        
            final currentTemp = ((data['list'][0]['main']['temp']) - 273.15).toStringAsFixed(2);
            final currentSky = data['list'][0]['weather'][0]['main'];
            final currentDescription = data['list'][0]['weather'][0]['description'];
            final currentPressure = data['list'][0]['main']['pressure'];
            final currentHumidity = data['list'][0]['main']['humidity'];
            final currentWindSpeed = data['list'][0]['wind']['speed'];
            final hours = DateTime.now().hour;

            for (var item in data['list']) {
              if (item['dt_txt'].contains("12:00:00")) {
                DateTime weeklyDate = DateTime.parse(item['dt_txt']);
              }
            }
        
            IconData getWeatherIcon(String main, String description, int hrs) {
              switch(main) {
                case 'Clouds':
                  if (description == 'broken clouds' || description == 'few clouds') {
                    if (hrs >= 4 && hrs < 18) {
                      return WeatherIcons.day_cloudy;
                    } 
                    else {
                      return WeatherIcons.night_alt_cloudy;
                    }
                  }
                  else if (description == 'overcast clouds') {
                    return WeatherIcons.cloudy;
                  }
                  else {
                    return WeatherIcons.cloud;
                  }
        
                case 'Thunderstorm':
                if (description == 'thunderstorm with light rain' || description == 'thunderstorm with rain' || description == 'thunderstorm with heavy rain') {
                    return WeatherIcons.storm_showers;
                  }
                else {
                  return WeatherIcons.thunderstorm;
                }
        
                case 'Rain':
                if (description == 'light rain' || description == 'moderate rain') {
                  return WeatherIcons.showers;
                }
                else {
                  return WeatherIcons.rain;
                }
        
                default:
                  if (hrs >= 4 && hrs < 18) {
                    return WeatherIcons.day_sunny;
                  } 
                  else {
                    return WeatherIcons.night_clear;
                  }
              }
            }


            IconData getWeatherIcon2(String main, String description) {
              switch(main) {
                case 'Clouds':
                  if (description == 'broken clouds' || description == 'few clouds') {
                    
                      return WeatherIcons.day_cloudy;
                  }
                  else if (description == 'overcast clouds') {
                    return WeatherIcons.cloudy;
                  }
                  else {
                    return WeatherIcons.cloud;
                  }
        
                case 'Thunderstorm':
                if (description == 'thunderstorm with light rain' || description == 'thunderstorm with rain' || description == 'thunderstorm with heavy rain') {
                    return WeatherIcons.storm_showers;
                  }
                else {
                  return WeatherIcons.thunderstorm;
                }
        
                case 'Rain':
                if (description == 'light rain' || description == 'moderate rain') {
                  return WeatherIcons.showers;
                }
                else {
                  return WeatherIcons.rain;
                }
        
                default:
                  
                    return WeatherIcons.day_sunny;
              }
            }

            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SafeArea(
                child: Padding(
                  
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // main card
                      /* IconButton(
                        onPressed:() async{
                          bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
                          if (!serviceEnabled) {
                            setState(() {
                              Icon(Icons.location_off);
                              return;
                            });
                          }
                
                          LocationPermission permission = await Geolocator.checkPermission();
                          if (permission == LocationPermission.denied) {
                            print("Location permission denied");
                            return;
                          }
                
                          if (permission == LocationPermission.denied) {
                            print("Location permission denied forever");
                            return;
                          }
                
                          if (permission == LocationPermission.always) {
                            print("Location allowed always");
                            return;
                          }
                
                          Position position = await Geolocator.getCurrentPosition(
                            desiredAccuracy: LocationAccuracy.high
                          );
                          print("Latitude: ${position.latitude}, Longitude: ${position.longitude}");
                        }, 
                        icon: Icon(Icons.location_on)), */
                      SizedBox(height: 20),
                      //Text(currentCityName),
                      Row(
                        children: [
                          Icon(Icons.location_on),
                          Text("${place.locality}, ${place.country}")
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          SizedBox(width: 2),
                          Icon(Icons.calendar_today, size: 20),
                          SizedBox(width: 3),
                          Text("${DateFormat.EEEE().format(DateTime.now())} ${DateFormat('d/M/y').format(DateTime.now())}",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      
                      SizedBox(height: 10),
                      Card(
                        color: Colors.white.withOpacity(0.1),
                        elevation: 10,
                        child: ClipRRect(
                          borderRadius: BorderRadiusGeometry.circular(10),
                          child: Center(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Column(
                                  children: [
                                    Text("$currentTemp °C",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 40
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Icon(
                                      getWeatherIcon(currentSky, currentDescription, hours),
                                      size: 60,
                                    ),
                                    SizedBox(height: 10),
                                    Text(currentDescription,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w200,
                                        fontSize: 20
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text("Hourly Forecast",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30
                        ),
                      ),
                      SizedBox(height: 10),
                      /* SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (int i=0; i<5; i++) 
                                HourlyForecastItem(
                                  time: data['list'][i+1]['dt_txt'],
                                  icon: data['list'][i+1]['weather'][0]['main'] == 'Clouds' || data['list'][i+1]['weather'][0]['main'] == 'Rain' ? Icons.cloud : Icons.sunny,
                                  temperature: data['list'][i+1]['main']['temp'].toString()
                              )
                          ],
                        ),
                      ), */
                      
                      SizedBox(
                        height: 160,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 8,
                          itemBuilder:(context, index) {
                
                          final time = DateTime.parse(data['list'][index+1]['dt_txt']);
                          final time2 = DateTime.parse(data['list'][index+1]['dt_txt']).hour;
                          final temp = ((data['list'][index+1]['main']['temp']) - 273.15).toStringAsFixed(2);
                                  
                            return HourlyForecastItem(
                              time: DateFormat.j().format(time), 
                              icon: getWeatherIcon(data['list'][index+1]['weather'][0]['main'], data['list'][index+1]['weather'][0]['description'], time2),
                              temperature: temp.toString(),
                              description: data['list'][index+1]['weather'][0]['description']
                            );
                          },
                        ),
                      ),
                
                      SizedBox(height: 20),
                      Text("Additional Information",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: AdditionalInformation(
                              icon: Icons.water_drop,
                              infoName: "Humidity",
                              value: currentHumidity.toString()
                            ),
                          ),
                          Expanded(
                            child: AdditionalInformation(
                              icon: Icons.air,
                              infoName: "Wind Speed",
                              value: currentWindSpeed.toString()
                            ),
                          ),
                          Expanded(
                            child: AdditionalInformation(
                              icon: WeatherIcons.barometer,
                              infoName: "Pressure",
                              value: currentPressure.toString()
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20),

                      Text("Weekly Forecast",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30
                        ),
                      ),

                      SizedBox(height: 10),
                      
                      SizedBox(
                        height: 230,
                        child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: data['list'].where((item) => item['dt_txt'].toString().contains("00:00:00")).length,
                          itemBuilder:(context, index) {
                            
                            final dailyForecastList = data['list'].where((item) => item['dt_txt'].toString().contains("00:00:00")).toList();
                            final forecast = dailyForecastList[index];
                                        
                          final time = DateTime.parse(forecast['dt_txt']);
                          final temp = ((data['list'][index+1]['main']['temp']) - 273.15).toStringAsFixed(2);
                        
                            return WeeklyForecastItems(
                              weekName: DateFormat.E().format(time), 
                              date: DateFormat.MMMd().format(time),
                              icon: getWeatherIcon2(data['list'][index+1]['weather'][0]['main'], data['list'][index+1]['weather'][0]['description']),
                              temperature: temp.toString(),
                              description: data['list'][index+1]['weather'][0]['description']
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}