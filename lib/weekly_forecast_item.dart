import 'dart:ui';

import 'package:flutter/material.dart';

class WeeklyForecastItems extends StatelessWidget {
  final IconData icon;
  final String weekName;
  final String date;
  final String temperature;
  final String description;

  const WeeklyForecastItems({
    super.key,
    required this.icon,
    required this.weekName,
    required this.date,
    required this.temperature,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.1), 
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(8)
      ), 
      elevation: 10,
      child: ClipRRect(
        borderRadius: BorderRadiusGeometry.circular(5),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.all(15),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 40
                ),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          weekName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          date,
                          style: TextStyle(
                            fontSize: 15
                          ),
                        )
                      ],
                    ),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 15
                      ),
                    )
                  ],
                ),
                Spacer(),
                Text(
                  "$temperature °C",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25
                  ),
                ),
              ],
            )
          ),
        ),
      ),
    );
  }
}