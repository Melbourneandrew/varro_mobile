import 'package:flutter/material.dart';

class FadingText extends StatefulWidget {
  final String displayText;

  const FadingText(this.displayText, {Key? key}) : super(key: key);

  @override
  FadingTextButtonWidgetState createState() => FadingTextButtonWidgetState();
}

class FadingTextButtonWidgetState extends State<FadingText> {
  double _opacity = 1.0;
  int _animationDurationMils = 1500;
  GlobalKey textKey = GlobalKey();

  void fadeOutText() {
    setState(() {
      _animationDurationMils = 1500;
      _opacity = 0.0; // Set opacity to 0 to make the text fade away
    });
  }

  void resetOpacity() {
    setState(() {
      _animationDurationMils = 0;
      _opacity = 1.0; // Set opacity to 1 to make the text reappear
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AnimatedOpacity(
            opacity: _opacity,
            duration: Duration(milliseconds: _animationDurationMils),
            // Duration for the fade effect
            child: Text(
              key: textKey,
              widget.displayText, // Use the displayText parameter
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontFamily: 'Avenir Heavy',
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
