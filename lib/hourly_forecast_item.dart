import "dart:ui";

import "package:flutter/material.dart";

class HourlyForecastItem extends StatelessWidget {
  final String time;
  final IconData icon;
  final String temperature;
  final String description;

  const HourlyForecastItem({
    super.key,
    required this.time,
    required this.icon,
    required this.temperature,
    required this.description
  });

  @override
  Widget build(BuildContext context) {
    return Card(  
      color: Colors.white.withOpacity(0.1),    
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(8)
      ),      
      elevation: 10,
      //color: const Color.fromARGB(255, 44, 44, 44),
      child: ClipRRect(
        borderRadius: BorderRadiusGeometry.circular(5),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 150,
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Text(time,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    
                  ),
                ),
                SizedBox(height: 10),
                Icon(
                  icon,
                  size: 30,
                ),
                SizedBox(height: 10),
                Text(temperature,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17
                  ),
                ),
                SizedBox(height: 5),
                Text(description,
                  style: TextStyle(
                    fontSize: 12
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}