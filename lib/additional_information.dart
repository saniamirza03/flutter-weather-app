import "dart:ui";

import "package:flutter/material.dart";

class AdditionalInformation extends StatelessWidget {
  final IconData icon;
  final String infoName;
  final String value;
  const AdditionalInformation({
    super.key,
    required this.icon,
    required this.infoName,
    required this.value
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
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 30,
                ),
                SizedBox(height: 5),
            
                Text(infoName),
                SizedBox(height: 5),
                Text(value,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17
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