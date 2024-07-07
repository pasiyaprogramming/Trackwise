import 'package:flutter/material.dart';

class ImageCard extends StatelessWidget {
  final String imagePath;
  final VoidCallback onTap;
  final String text;
  final Alignment textAlignment;
  final String greeting;
  ImageCard(
      {required this.imagePath,
      required this.onTap,
      required this.text,
      required this.greeting,
      required this.textAlignment});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double maxWidth = screenWidth * 0.45;
    double fontSize = screenWidth * 0.05;
    double textWidth = text.length * fontSize * 1;
    double availableWidth = screenWidth - 16 - maxWidth;
    double actualWidth =
        textWidth < availableWidth ? textWidth : availableWidth;
    double leftPadding = screenWidth - 16 - actualWidth;
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              height: MediaQuery.of(context).size.height * 0.25,
              width: MediaQuery.of(context).size.width * 1,
            ),
          ),
          Positioned(
            top: 5,
            left: leftPadding,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: Text(
                greeting,
                textAlign: TextAlign.start,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            top: 23,
            left: leftPadding,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                textAlign: TextAlign.start,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
