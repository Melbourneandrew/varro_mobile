import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class Ball {
  double x, y;
  Color color;
  double dx, dy;
  double speedMultiplier; // New field
  Ball(
      {required this.x,
      required this.y,
      required this.color,
      required this.dx,
      required this.dy,
      required this.speedMultiplier // Initialize this in the constructor
      });
}

class BallSwirl extends StatefulWidget {
  const BallSwirl({Key? key}) : super(key: key);

  @override
  BallSwirlState createState() => BallSwirlState();
}

enum BallState { excitedFloating, tightCircle, waveform, idleFloating }

class BallSwirlState extends State<BallSwirl> {
  late List<Ball> balls;
  late Timer timer;
  final int numBalls = 50;
  final List<Color> vibrantColors = [
    Colors.red,
    Colors.blue,
    Colors.pink,
    Colors.orange,
    Colors.purple,
    Colors.cyan,
    Colors.yellow,
    Colors.lime,
    Colors.deepPurple,
    Colors.lightGreen,
    Colors.deepOrange,
  ];

  double transitionProgress = 0.0;
  bool transitioning = false;
  double wavePhase = 0.0;
  double waveformTime = 0.0;
  BallState currentState = BallState.idleFloating;
  double lastPulseTime = 0.0; // Initialize this in your class
  double pulseFrequency = 1.0;

  @override
  void initState() {
    super.initState();
    waveformTime = 0.0;
    balls = initializeBalls();
    timer = Timer.periodic(const Duration(milliseconds: 16), (Timer t) => update());
    transitioning = false;
  }

  List<Ball> initializeBalls() {
    return List.generate(numBalls, (index) {
      return Ball(
          x: Random().nextDouble() * 150 - 50,
          y: Random().nextDouble() * 150 - 50,
          color: vibrantColors[Random().nextInt(vibrantColors.length)],
          dx: Random().nextDouble() * 2.5 - 1,
          dy: Random().nextDouble() * 2.5 - 1,
          speedMultiplier:
              Random().nextDouble() * 0.5 + 0.5 // Values between 0.5 and 1
          );
    });
  }

  double pulseSpeed = 0.016;
  double waveformSpeed = 0.09;
  void update() {
    setState(() {
      lastPulseTime += pulseSpeed; // Assuming the timer ticks every 16 ms
      waveformTime += waveformSpeed;
      for (var ball in balls) {
        double targetX = ball.x, targetY = ball.y;
        double angle;

        // Define the target state for each ball
        if (currentState == BallState.tightCircle) {
          angle = atan2(ball.y, ball.x);
          angle += 0.1 * ball.speedMultiplier;
          targetX = cos(angle) * 80;
          targetY = sin(angle) * 80;
        } else if (currentState == BallState.waveform) {
          double indexFraction = balls.indexOf(ball) / numBalls;
          angle = indexFraction * pi * 4 + waveformTime;
          targetX = indexFraction * 300 - 150;
          targetY = sin(angle) * 50;
        } else if (currentState == BallState.excitedFloating) {
          targetX = ball.x + ball.dx;
          targetY = ball.y + ball.dy;

          // Attraction towards the center for the freeFloating state
          double distance = sqrt(ball.x * ball.x + ball.y * ball.y);
          ball.dx += -ball.x / distance * 0.2;
          ball.dy += -ball.y / distance * 0.2;

          // Apply pulse
          if (lastPulseTime >= pulseFrequency) {
            ball.dx +=
                ball.x / distance * 3.0; // Adjust the intensity as needed
            ball.dy +=
                ball.y / distance * 3.0; // Adjust the intensity as needed
          }
          // Add a friction term
          ball.dx *= 0.99;
          ball.dy *= 0.99;
        } else if (currentState == BallState.idleFloating) {
          // Drift slowly by adding a small random motion.
          ball.dx += Random().nextDouble() * 0.2 - 0.1;
          ball.dy += Random().nextDouble() * 0.2 - 0.1;

          // Soft boundary condition to keep balls from drifting too far away
          double distance = sqrt(ball.x * ball.x + ball.y * ball.y);
          if (distance > 200) {
            // You can adjust this distance as needed
            ball.dx +=
                -ball.x / distance * 0.5; // Softly push back toward center
            ball.dy +=
                -ball.y / distance * 0.5; // Softly push back toward center
          }

          // Limit speed to avoid fast drifting
          if (ball.dx > 1.0) ball.dx = 1.0;
          if (ball.dx < -1.0) ball.dx = -1.0;
          if (ball.dy > 1.0) ball.dy = 1.0;
          if (ball.dy < -1.0) ball.dy = -1.0;

          targetX = ball.x + ball.dx;
          targetY = ball.y + ball.dy;
        }

        // Smoothly transition to the target state
        if (transitioning) {
          //Transition slower into the waveform
          if(currentState == BallState.waveform) {
            transitionProgress += 0.0005;
            //Transition slower into the circle
          }else if(currentState == BallState.tightCircle) {
              transitionProgress += 0.0005;

          }else{
            transitionProgress += 0.02;
          }
          if (transitionProgress >= 1.0) {
            transitionProgress = 1.0;
            transitioning = false;

          }
        } else {
          transitionProgress = 1.0;
        }

        // Interpolation
        ball.x += (targetX - ball.x) * transitionProgress;
        ball.y += (targetY - ball.y) * transitionProgress;
      }

      // Reset the pulse timer if it's time for another pulse
      if (lastPulseTime >= pulseFrequency) {
        lastPulseTime = 0.0;
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, double.infinity),
      painter: BallPainter(balls: balls),
    );
  }

  void toggleState([BallState? next]) {
    setState(() {
      if (next == null) {
        //Cycle to next enum state
        final nextIndex = BallState.values.indexOf(currentState) + 1;
        if (nextIndex >= BallState.values.length) {
          currentState = BallState.values[0];
        } else {
          currentState = BallState.values[nextIndex];
        }
      } else {
        currentState = next;
      }
      transitioning = true;
      transitionProgress = 0.0; // Reset transition progress
      // Reset momentum
      for (var ball in balls) {
        ball.dx = Random().nextDouble() * 2.5 - 1.25;
        ball.dy = Random().nextDouble() * 2.5 - 1.25;
      }
    });
  }

  void setBallsExcitedFloating() {
    toggleState(BallState.excitedFloating);
  }

  void setBallsTightCircle() {
    toggleState(BallState.tightCircle);
  }

  void setBallsWave() {
    toggleState(BallState.waveform);
  }
  void setBallsIdleFloating(){
    toggleState(BallState.idleFloating);
  }
}

class BallPainter extends CustomPainter {
  final List<Ball> balls;

  BallPainter({required this.balls});

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final Paint paint = Paint();

    for (var ball in balls) {
      paint.color = ball.color;
      canvas.drawCircle(
          Offset(centerX + ball.x, centerY + ball.y), 10.0, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
